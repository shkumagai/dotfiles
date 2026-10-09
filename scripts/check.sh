#!/usr/bin/env bash
# shellcheck shell=bash
#
# Verify the dotfiles repository after a change.
#
# Layers:
#   static       syntax / lint / editorconfig for target files (no side effects)
#   consistency  mise [dotfiles] deployment, unmanaged files, package coverage, docs
#   runtime      actually load configs in isolation (zsh, tmux, vim, git, ...)
#   security     secret scan, public-repo exposure, Claude permission rules
#
# Usage: scripts/check.sh [--all] [--layer LIST] [--fix] [-h]
#   --all         target every tracked file (default: changed + untracked files)
#   --layer LIST  comma separated layers to run (default: all layers)
#   --fix         auto-fix mechanical editorconfig violations
#
# Exit status: 0 when there is no FAIL, 1 otherwise.

set -u -o pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}" || exit 2

MODE=changed
LAYERS=static,consistency,runtime,security
FIX=0
ZSH_STARTUP_LIMIT_MS="${DOTFILES_CHECK_ZSH_MS:-500}"

usage() {
  sed -n '3,17p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --all) MODE=all ;;
    --layer) shift; LAYERS="${1:-}" ;;
    --layer=*) LAYERS="${1#*=}" ;;
    --fix) FIX=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

TMPDIR_CHECK="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-check.XXXXXX")"
TMUX_SOCKET="dotfiles-check-$$"
cleanup() {
  tmux -L "${TMUX_SOCKET}" kill-server >/dev/null 2>&1 || true
  rm -r -f -- "${TMPDIR_CHECK}"
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

if [ -t 1 ]; then
  C_PASS=$'\033[32m' C_WARN=$'\033[33m' C_FAIL=$'\033[31m' C_SKIP=$'\033[90m' C_HEAD=$'\033[1;36m' C_RESET=$'\033[0m'
else
  C_PASS='' C_WARN='' C_FAIL='' C_SKIP='' C_HEAD='' C_RESET=''
fi

N_PASS=0 N_WARN=0 N_FAIL=0 N_SKIP=0

section() { printf '\n%s== %s ==%s\n' "${C_HEAD}" "$1" "${C_RESET}"; }

# report STATUS NAME [DETAIL...]  -- DETAIL lines are indented below the result
report() {
  local status="$1" name="$2" color
  shift 2
  case "${status}" in
    PASS) color="${C_PASS}"; N_PASS=$((N_PASS + 1)) ;;
    WARN) color="${C_WARN}"; N_WARN=$((N_WARN + 1)) ;;
    FAIL) color="${C_FAIL}"; N_FAIL=$((N_FAIL + 1)) ;;
    SKIP) color="${C_SKIP}"; N_SKIP=$((N_SKIP + 1)) ;;
  esac
  printf '%s[%s]%s %s\n' "${color}" "${status}" "${C_RESET}" "${name}"
  local detail
  for detail in "$@"; do
    [ -n "${detail}" ] && printf '%s\n' "${detail}" | sed 's/^/       /'
  done
}

has() { command -v "$1" >/dev/null 2>&1; }

# with_timeout SECONDS CMD...  (macOS has no coreutils timeout by default)
with_timeout() {
  local secs="$1"
  shift
  perl -e 'alarm shift; exec @ARGV or die "exec: $!\n"' "${secs}" "$@"
}

layer_enabled() { case ",${LAYERS}," in *",$1,"*) return 0 ;; esac; return 1; }

# ---------------------------------------------------------------------------
# Target files
# ---------------------------------------------------------------------------

TARGETS="${TMPDIR_CHECK}/targets"
if [ "${MODE}" = all ]; then
  git ls-files > "${TARGETS}"
else
  {
    git diff --name-only HEAD 2>/dev/null
    git ls-files --others --exclude-standard
  } | sort -u > "${TARGETS}"
fi
# drop deleted files and archived configs
grep -v '^deprecated/' "${TARGETS}" | while IFS= read -r f; do [ -f "$f" ] && printf '%s\n' "$f"; done > "${TARGETS}.tmp"
mv "${TARGETS}.tmp" "${TARGETS}"

# file_kind PATH -> zsh | bash | sh | toml-mise | toml | json | jsonc | yaml | gitconfig | tmux | ssh | brewfile | vim | makefile | python | other
file_kind() {
  local f="$1" shebang
  case "$f" in
    home/.config/mise/config.toml) echo toml-mise; return ;;
    home/.config/mise/mise.lock) echo toml; return ;;
    *.toml) echo toml; return ;;
    home/.config/zed/*.json) echo jsonc; return ;;
    *.json) echo json; return ;;
    *.yml|*.yaml) echo yaml; return ;;
    home/.config/git/config) echo gitconfig; return ;;
    home/.config/tmux/*.conf) echo tmux; return ;;
    home/.ssh/config) echo ssh; return ;;
    */Brewfile) echo brewfile; return ;;
    *.vim|*/.vimrc) echo vim; return ;;
    Makefile|*/Makefile) echo makefile; return ;;
    *.py) echo python; return ;;
    *.zsh|home/.zshrc|home/.zshenv|home/.zprofile) echo zsh; return ;;
    *.sh) echo bash; return ;;
  esac
  shebang="$(head -n 1 "$f" 2>/dev/null)"
  case "${shebang}" in
    '#!'*zsh*) echo zsh ;;
    '#!'*bash*) echo bash ;;
    '#!'*/sh|'#!'*' sh') echo sh ;;
    '#!'*python*) echo python ;;
    *) echo other ;;
  esac
}

# Validate JSON with comments / trailing commas (Zed settings).
jsonc_check() {
  python3 - "$1" <<'PY'
import json, re, sys
src = open(sys.argv[1], encoding="utf-8").read()
out, i, n = [], 0, len(src)
while i < n:
    c = src[i]
    if c == '"':
        j = i + 1
        while j < n and src[j] != '"':
            j += 2 if src[j] == "\\" else 1
        out.append(src[i:j + 1]); i = j + 1
    elif src.startswith("//", i):
        while i < n and src[i] != "\n":
            i += 1
    elif src.startswith("/*", i):
        i = src.find("*/", i + 2)
        i = n if i < 0 else i + 2
    else:
        out.append(c); i += 1
json.loads(re.sub(r",(\s*[}\]])", r"\1", "".join(out)))
PY
}

# ---------------------------------------------------------------------------
# Layer 1: static
# ---------------------------------------------------------------------------

check_syntax() {
  local f="$1" kind="$2" out
  case "${kind}" in
    zsh) out="$(zsh -n "$f" 2>&1)" ;;
    bash) out="$(bash -n "$f" 2>&1)" ;;
    sh) out="$(sh -n "$f" 2>&1)" ;;
    toml-mise) out="$(MISE_GLOBAL_CONFIG_FILE="${ROOT}/$f" mise config ls 2>&1 >/dev/null | grep -iE 'error|parse' || true)" ;;
    toml) out="$(yq -p toml -o json . "$f" 2>&1 >/dev/null)" ;;
    json) out="$(jq empty "$f" 2>&1)" ;;
    jsonc) out="$(jsonc_check "$f" 2>&1)" ;;
    yaml) out="$(yq -p yaml -o json . "$f" 2>&1 >/dev/null)" ;;
    gitconfig) out="$(git config -f "$f" --list 2>&1 >/dev/null)" ;;
    tmux) out="$(tmux -L "${TMUX_SOCKET}" -f /dev/null new-session -d \; source-file -n "$f" 2>&1)" ;;
    ssh) out="$(ssh -G -F "$f" dotfiles-check.invalid 2>&1 >/dev/null | grep -v 'Pseudo-terminal' || true)" ;;
    brewfile) out="$(ruby -c "$f" 2>&1 >/dev/null)" ;;
    python) out="$(python3 -c 'import ast,sys
try: ast.parse(open(sys.argv[1]).read(), sys.argv[1])
except SyntaxError as e: sys.exit(f"line {e.lineno}: {e.msg}")' "$f" 2>&1)" ;;
    *) return 0 ;;
  esac
  local rc=$?
  if [ "${rc}" -ne 0 ] || [ -n "${out}" ]; then
    report FAIL "syntax(${kind}): $f" "${out}"
  else
    report PASS "syntax(${kind}): $f"
  fi
}

check_shellcheck() {
  local f="$1" kind="$2" out
  [ "${kind}" = bash ] || [ "${kind}" = sh ] || return 0
  if ! has shellcheck; then report SKIP "shellcheck: $f" "shellcheck not installed"; return; fi
  if out="$(shellcheck -S error -f gcc "$f" 2>&1)" && [ -z "${out}" ]; then
    if out="$(shellcheck -S warning -f gcc "$f" 2>&1)" && [ -z "${out}" ]; then
      report PASS "shellcheck: $f"
    else
      report WARN "shellcheck: $f" "${out}"
    fi
  else
    report FAIL "shellcheck: $f" "${out}"
  fi
}

check_makefile() {
  local f="$1" out
  if ! has checkmake; then report SKIP "checkmake: $f" "checkmake not installed"; return; fi
  if out="$(checkmake "$f" 2>&1)"; then
    report PASS "checkmake: $f"
  else
    report WARN "checkmake: $f" "${out}"
  fi
}

# editorconfig: LF, final newline, trailing whitespace (not *.md), indent style
check_editorconfig() {
  local f="$1" kind="$2" problems=()
  grep -Iq . "$f" 2>/dev/null || return 0 # binary or empty
  if grep -q $'\r' "$f"; then
    problems+=("CRLF line endings")
    [ "${FIX}" = 1 ] && perl -pi -e 's/\r$//' "$f"
  fi
  if [ -n "$(tail -c 1 "$f")" ]; then
    problems+=("missing final newline")
    [ "${FIX}" = 1 ] && printf '\n' >> "$f"
  fi
  case "$f" in
    *.md) ;;
    *)
      local lines
      lines="$(grep -nE '[[:blank:]]+$' "$f" | cut -d: -f1 | paste -sd, -)"
      if [ -n "${lines}" ]; then
        problems+=("trailing whitespace at line ${lines}")
        [ "${FIX}" = 1 ] && perl -pi -e 's/[ \t]+$//' "$f"
      fi
      ;;
  esac
  case "${kind}" in
    makefile|gitconfig) ;;
    *)
      local tabs
      tabs="$(grep -n $'^\t' "$f" | cut -d: -f1 | head -n 10 | paste -sd, -)"
      [ -n "${tabs}" ] && problems+=("tab indentation at line ${tabs} (expected spaces)")
      ;;
  esac
  if [ ${#problems[@]} -eq 0 ]; then
    report PASS "editorconfig: $f"
  elif [ "${FIX}" = 1 ]; then
    report WARN "editorconfig: $f (fixed where possible)" "${problems[@]}"
  else
    report WARN "editorconfig: $f" "${problems[@]}"
  fi
}

layer_static() {
  section "static (${MODE}: $(wc -l < "${TARGETS}" | tr -d ' ') files)"
  if [ ! -s "${TARGETS}" ]; then
    report SKIP "no target files" "working tree has no changes; use --all to check everything"
    return
  fi
  local f kind
  while IFS= read -r f; do
    kind="$(file_kind "$f")"
    check_syntax "$f" "${kind}"
    check_shellcheck "$f" "${kind}"
    [ "${kind}" = makefile ] && check_makefile "$f"
    check_editorconfig "$f" "${kind}"
  done < "${TARGETS}"
}

# ---------------------------------------------------------------------------
# Layer 2: consistency
# ---------------------------------------------------------------------------

# Paths under home/ that are intentionally not deployed by mise [dotfiles].
UNMANAGED_ALLOWLIST="home/README.md"

layer_consistency() {
  section "consistency"
  local out managed status_file="${TMPDIR_CHECK}/dot-status"

  if ! has mise; then report SKIP "mise checks" "mise not installed"; return; fi

  # 1. every [dotfiles] entry is applied
  mise dotfiles status > "${status_file}" 2>&1
  out="$(awk '$1 ~ /^~\// && $NF != "applied"' "${status_file}")"
  if [ -n "${out}" ]; then
    report FAIL "mise dotfiles: entries not applied (run: make dotfiles)" "${out}"
  else
    report PASS "mise dotfiles: all entries applied"
  fi
  out="$(mise dotfiles diff 2>&1)"
  case "${out}" in
    *"all files are applied"*|"") report PASS "mise dotfiles diff: no drift" ;;
    *) report WARN "mise dotfiles diff: deployed files differ from source" "${out}" ;;
  esac

  # 2. files under home/ not covered by any [dotfiles] entry
  managed="$(awk '$1 ~ /^~\// {sub(/^~\//, "home/", $1); print $1}' "${status_file}")"
  local f m covered missing=()
  while IFS= read -r f; do
    covered=0
    for m in ${managed} ${UNMANAGED_ALLOWLIST}; do
      case "$f" in "$m"|"$m"/*) covered=1; break ;; esac
    done
    [ "${covered}" = 0 ] && missing+=("$f")
  done < <(git ls-files home/)
  if [ ${#missing[@]} -gt 0 ]; then
    report WARN "unmanaged files under home/ (not in mise [dotfiles])" "${missing[@]}"
  else
    report PASS "every file under home/ is deployed by mise [dotfiles]"
  fi

  # 3. dangling symlinks that point into this repository
  local dangling=() target
  while IFS= read -r f; do
    target="$(readlink "$f")"
    case "${target}" in
      "${ROOT}"/*|*/.dotfiles/*) [ -e "$f" ] || dangling+=("$f -> ${target}") ;;
    esac
  done < <(find "${HOME}" "${HOME}/.config" "${HOME}/.local/bin" -maxdepth 1 -type l 2>/dev/null)
  if [ ${#dangling[@]} -gt 0 ]; then
    report FAIL "dangling symlinks into the repository" "${dangling[@]}"
  else
    report PASS "no dangling symlinks into the repository"
  fi

  # 4. tools whose config is managed are declared in [bootstrap.packages]
  local cfg="home/.config/mise/config.toml" dir pkg undeclared=()
  for dir in home/.config/*/ home/.config/*.toml; do
    pkg="$(basename "${dir%/}" .toml)"
    case "${pkg}" in mise|homebrew) continue ;; esac
    grep -qE "^\"brew(-cask)?:${pkg}\"" "${cfg}" || undeclared+=("${pkg} (config: ${dir%/})")
  done
  if [ ${#undeclared[@]} -gt 0 ]; then
    report WARN "configured tools missing from [bootstrap.packages]" "${undeclared[@]}"
  else
    report PASS "every configured tool is declared in [bootstrap.packages]"
  fi

  # 5. mise health
  out="$(mise doctor 2>&1)"
  if printf '%s' "${out}" | grep -qE '^[0-9]+ problems? found'; then
    report FAIL "mise doctor" "$(printf '%s\n' "${out}" | sed -n '/problem/,$p')"
  elif printf '%s' "${out}" | grep -qE '^[0-9]+ warnings? found'; then
    report WARN "mise doctor" "$(printf '%s\n' "${out}" | sed -n '/warning.* found/,$p' | head -n 20)"
  else
    report PASS "mise doctor"
  fi
  out="$(mise ls --missing 2>&1)"
  if [ -n "${out}" ]; then
    report WARN "mise tools declared but not installed (run: mise install)" "${out}"
  else
    report PASS "all mise tools installed"
  fi

  # 6. tracked files that .gitignore says should be ignored
  out="$(git ls-files -ci --exclude-standard | grep -vE '(^|/)\.git(keep|empty)$')"
  if [ -n "${out}" ]; then
    report WARN "tracked files matching .gitignore" "${out}"
  else
    report PASS "no tracked file matches .gitignore"
  fi

  # 7. home/README.md structure tree mentions every entry under home/.config
  local name undocumented=()
  for dir in home/.config/*; do
    name="$(basename "${dir}")"
    grep -qF "${name}" home/README.md || undocumented+=("${dir}")
  done
  for dir in home/.* ; do
    name="$(basename "${dir}")"
    case "${name}" in .|..|.config) continue ;; esac
    grep -qF "${name}" home/README.md || undocumented+=("${dir}")
  done
  if [ ${#undocumented[@]} -gt 0 ]; then
    report WARN "entries missing from home/README.md Structure" "${undocumented[@]}"
  else
    report PASS "home/README.md Structure covers home/"
  fi

  # 8. files referenced by Claude Code hooks exist
  if has jq; then
    local missing_hooks=() p
    while IFS= read -r p; do
      p="${p/#\~/${HOME}}"
      [ -e "$p" ] || missing_hooks+=("$p")
    done < <(jq -r '.. | objects | select(.type? == "command") | .command' home/.claude/settings.json \
      | grep -oE "(~|/)[^ '\"]+\.(sh|py|js|ts)" | sort -u)
    if [ ${#missing_hooks[@]} -gt 0 ]; then
      report FAIL "Claude hook scripts not found" "${missing_hooks[@]}"
    else
      report PASS "Claude hook scripts exist"
    fi
  fi
}

# ---------------------------------------------------------------------------
# Layer 3: runtime
# ---------------------------------------------------------------------------

layer_runtime() {
  section "runtime"
  local out err="${TMPDIR_CHECK}/stderr"

  # zsh interactive startup under a pseudo terminal (stderr must stay empty)
  local start end ms
  : > "${err}"
  start="$(perl -MTime::HiRes=time -e 'printf "%d", time*1000')"
  with_timeout 20 script -q /dev/null zsh -fc "exec zsh -i -c exit 2>'${err}'" </dev/null >/dev/null 2>&1
  local rc=$?
  end="$(perl -MTime::HiRes=time -e 'printf "%d", time*1000')"
  ms=$((end - start))
  if [ ${rc} -ne 0 ] || [ -s "${err}" ]; then
    report FAIL "zsh interactive startup (rc=${rc})" "$(head -n 20 "${err}")"
  elif [ ${ms} -gt "${ZSH_STARTUP_LIMIT_MS}" ]; then
    report WARN "zsh interactive startup: ${ms}ms (> ${ZSH_STARTUP_LIMIT_MS}ms)"
  else
    report PASS "zsh interactive startup: ${ms}ms"
  fi
  : > "${err}"
  with_timeout 20 script -q /dev/null zsh -fc "exec zsh -l -i -c exit 2>'${err}'" </dev/null >/dev/null 2>&1
  rc=$?
  if [ ${rc} -ne 0 ] || [ -s "${err}" ]; then
    report FAIL "zsh login shell startup (rc=${rc})" "$(head -n 20 "${err}")"
  else
    report PASS "zsh login shell startup"
  fi

  # tmux: load the real config into an isolated server
  if has tmux; then
    if out="$(tmux -L "${TMUX_SOCKET}" -f /dev/null new-session -d \; source-file "${ROOT}/home/.config/tmux/tmux.conf" 2>&1)" && [ -z "${out}" ]; then
      report PASS "tmux config loads"
    else
      report FAIL "tmux config loads" "${out}"
    fi
    tmux -L "${TMUX_SOCKET}" kill-server >/dev/null 2>&1
  fi

  # vim: load .vimrc headless and collect error messages
  if has vim; then
    out="$(with_timeout 20 vim -Nu "${ROOT}/home/.vimrc" -i NONE -es \
      -c 'redir => g:m | silent messages | redir END | call writefile(split(g:m, "\n"), "/dev/stderr")' \
      -c 'qa!' </dev/null 2>&1 | grep -E '^E[0-9]+:|Error' )"
    if [ -n "${out}" ]; then
      report FAIL "vim loads .vimrc" "${out}"
    else
      report PASS "vim loads .vimrc"
    fi
  fi

  # git: resolved configuration, including includes
  if out="$(git config --global --list --show-origin 2>&1 >/dev/null)" && [ -z "${out}" ]; then
    report PASS "git global config resolves"
  else
    report FAIL "git global config resolves" "${out}"
  fi

  # tools that validate their own config
  if has starship; then
    if out="$(STARSHIP_CONFIG="${ROOT}/home/.config/starship.toml" starship prompt 2>&1 >/dev/null)" && [ -z "${out}" ]; then
      report PASS "starship config"
    else
      report FAIL "starship config" "${out}"
    fi
  fi
  if has jj; then
    if out="$(jj config list --user 2>&1 >/dev/null)"; then report PASS "jj config"; else report FAIL "jj config" "${out}"; fi
  fi
  if has gh; then
    if out="$(gh config list 2>&1 >/dev/null)"; then report PASS "gh config"; else report FAIL "gh config" "${out}"; fi
  fi
  if has sheldon; then
    if out="$(sheldon source 2>&1 >/dev/null)"; then report PASS "sheldon source"; else report FAIL "sheldon source" "${out}"; fi
  fi
}

# ---------------------------------------------------------------------------
# Layer 4: security
# ---------------------------------------------------------------------------

layer_security() {
  section "security"
  local added="${TMPDIR_CHECK}/added" out

  # content to scan: added lines in the diff + untracked files (or every file with --all)
  if [ "${MODE}" = all ]; then
    git grep -n -I -e '' -- . ':!deprecated' > "${added}" 2>/dev/null
  else
    {
      git diff -U0 HEAD 2>/dev/null | awk '/^\+\+\+ b\//{f=substr($0,7)} /^@@/{split($3,a,/[,+]/); n=a[2]; next} /^\+/ && !/^\+\+\+/{print f":"n": "substr($0,2); n++}'
      git ls-files --others --exclude-standard -z | xargs -0 -I{} grep -n -I -H -e '' {} 2>/dev/null
    } > "${added}"
  fi

  out="$(grep -E -e '-----BEGIN [A-Z ]*PRIVATE KEY-----' \
    -e 'AKIA[0-9A-Z]{16}' \
    -e '(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{30,}' -e 'github_pat_[A-Za-z0-9_]{30,}' \
    -e 'sk-ant-[A-Za-z0-9_-]{20,}' -e 'sk-[A-Za-z0-9]{32,}' \
    -e 'xox[abpr]-[A-Za-z0-9-]{10,}' -e 'AIza[0-9A-Za-z_-]{35}' \
    "${added}" | cut -c1-160)"
  if [ -n "${out}" ]; then
    report FAIL "secret-like tokens in content" "${out}"
  else
    report PASS "no secret-like tokens"
  fi

  out="$(grep -iE '(password|passwd|secret|token|api[_-]?key)[[:space:]]*[=:][[:space:]]*["'\'']?[A-Za-z0-9/+_.-]{8,}' "${added}" \
    | grep -vE '^[^:]+:[0-9]+:[[:space:]]*(#|//|")' \
    | grep -viE '[=:][[:space:]]*["'"'"']?([/~$]|password["'"'"']?$)' \
    | grep -viE '(op://|<|example|dummy|placeholder|getenv|keychain)' | cut -c1-160)"
  if [ -n "${out}" ]; then
    report WARN "credential-like assignments (review manually)" "${out}"
  else
    report PASS "no credential-like assignments"
  fi

  out="$(grep -nE '(^|[^0-9.])(10\.[0-9]+\.[0-9]+\.[0-9]+|192\.168\.[0-9]+\.[0-9]+|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+\.[0-9]+)' "${added}" | cut -c1-160)"
  if [ -n "${out}" ]; then
    report WARN "private IP addresses (exposed in a public repository)" "${out}"
  else
    report PASS "no private IP addresses"
  fi

  # sensitive file names tracked or about to be added
  out="$( { git ls-files; git ls-files --others --exclude-standard; } \
    | grep -E '(^|/)(id_(rsa|ed25519|ecdsa|dsa)(\.pub)?|.*\.pem|.*\.p12|.*\.key|\.env(\..*)?|hosts\.yml|known_hosts|\.netrc|credentials(\.json)?)$')"
  if [ -n "${out}" ]; then
    report FAIL "sensitive files tracked or untracked-but-not-ignored" "${out}"
  else
    report PASS "no sensitive file names"
  fi

  # .ssh/config is published with the repository
  if grep -qx 'home/.ssh/config' "${TARGETS}"; then
    report WARN "home/.ssh/config changed: host names/users become public" \
      "$(git diff -U0 HEAD -- home/.ssh/config | grep -E '^\+[[:space:]]*(Host|HostName|User|IdentityFile|ProxyJump)[[:space:]]' | cut -c1-160)"
  fi

  # Claude Code permission rules
  if has jq; then
    out="$(jq -r '
      [ (.permissions.allow // [])[] | select(test("^(Bash|Bash\\(\\*\\)|Bash\\(sudo.*|Edit|Write|Read\\(//\\*\\*\\))$")) | "overly broad allow rule: " + . ],
      [ select(.permissions.defaultMode == "bypassPermissions") | "defaultMode is bypassPermissions" ]
      | .[]' home/.claude/settings.json 2>&1)"
    if [ -n "${out}" ]; then
      report WARN "Claude Code permissions" "${out}"
    else
      report PASS "Claude Code permissions"
    fi
  fi
}

# ---------------------------------------------------------------------------

printf 'dotfiles check: %s (mode=%s, layers=%s%s)\n' "${ROOT}" "${MODE}" "${LAYERS}" "$([ "${FIX}" = 1 ] && echo ', fix')"

layer_enabled static && layer_static
layer_enabled consistency && layer_consistency
layer_enabled runtime && layer_runtime
layer_enabled security && layer_security

section "summary"
printf '%sPASS %d%s  %sWARN %d%s  %sFAIL %d%s  %sSKIP %d%s\n' \
  "${C_PASS}" "${N_PASS}" "${C_RESET}" "${C_WARN}" "${N_WARN}" "${C_RESET}" \
  "${C_FAIL}" "${N_FAIL}" "${C_RESET}" "${C_SKIP}" "${N_SKIP}" "${C_RESET}"
if [ "${N_FAIL}" -gt 0 ]; then
  echo "Result: NG (fix FAIL items before committing)"
  exit 1
fi
echo "Result: OK"

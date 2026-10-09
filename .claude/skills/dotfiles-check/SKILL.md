---
name: dotfiles-check
description: Verify this dotfiles repository after edits or structural changes — syntax/lint, mise [dotfiles] deployment consistency, isolated runtime loading (zsh, tmux, vim, git, starship, ...) and secret/public-exposure checks — then report a commit-ready verdict. Use after modifying files under home/, mise config, Makefile or scripts/, before committing, or when the user asks to check/validate/verify the dotfiles.
---

# dotfiles-check

Run `scripts/check.sh`, interpret the results, and tell the user whether the change is safe to commit.

## Arguments

- (none): check changed + untracked files only (default)
- `all`: pass `--all` to check every tracked file
- `fix`: pass `--fix` to auto-fix mechanical editorconfig violations (CRLF, final newline, trailing whitespace)
- `<layer>[,<layer>]`: pass `--layer` with any of `static`, `consistency`, `runtime`, `security`

## Steps

1. Run the script from the repository root:

   ```sh
   scripts/check.sh [--all] [--fix] [--layer LIST]
   ```

   Exit status 1 means at least one FAIL.

2. Review the diff yourself for what the script cannot judge (`git diff HEAD`, plus untracked files):
   - The change does what it was meant to do, and nothing else unrelated slipped in.
   - A new config file/directory under `home/` has a matching `[dotfiles]` entry in
     `home/.config/mise/config.toml`, and its tool is in `[bootstrap.packages]`.
   - A new tool/dir is reflected in the Structure tree of `home/README.md`.
   - Removed entries leave no references behind (zsh `source`, tmux `source-file`, hooks, Makefile).
   - Do not read `home/.ssh/config` contents beyond what the script prints (`~/.ssh` is denied by permissions).

3. For each FAIL, find the root cause and propose a concrete fix. For each WARN, decide whether it was
   introduced by this change or already existed; pre-existing WARNs go in a short "known issues" list only.
   Apply fixes only for FAILs caused by the current change, and only after confirming with the user,
   except mechanical editorconfig fixes when `fix` was requested. Re-run the script after fixing.

4. Report in Japanese with this shape:

   | Layer | Result | Notes |
   |---|---|---|
   | static | ✅ / ⚠️ / ❌ | ... |
   | consistency | ... | ... |
   | runtime | ... | ... |
   | security | ... | ... |

   Then one verdict line: **コミット可** (no FAIL) or **要修正** (with the FAIL list), followed by
   introduced WARNs and, briefly, pre-existing known issues.

## Notes on results

- `syntax(toml-mise)` is validated by mise itself because the config uses TOML 1.1 multi-line inline tables
  that `yq`/`tomllib` cannot parse.
- `unmanaged files under home/`: a file in the repo that mise does not deploy. Either add a `[dotfiles]`
  entry or add it to `UNMANAGED_ALLOWLIST` in `scripts/check.sh` if intentional.
- `home/.ssh/config changed`: the repository is public (installed from raw.githubusercontent.com),
  so any host name, user or IdentityFile path gets published. Always surface this to the user.
- Runtime checks run in isolation: tmux uses a dedicated socket (`-L dotfiles-check-<pid>`) that is killed
  on exit, zsh runs under `script` to get a pty; nothing is written to the user's environment.
- zsh startup threshold defaults to 500ms; override with `DOTFILES_CHECK_ZSH_MS`.

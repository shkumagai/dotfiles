# -*- encoding: utf-8 -*-
# shellcheck shell=zsh

# in ~/.zshenv, executed `unsetopt GLOBAL_RCS` and ignored /etc/zshrc
if [[ -r /etc/zshrc ]]; then
  source /etc/zshrc
fi

umask 022

if [[ "$TERM" != 'dumb' ]]; then
  stty -ixon -ixoff
fi

# Environment variables
# Fall back to xterm-256color only when the terminfo for $TERM is missing
# (e.g. xterm-ghostty on a remote host); keep "dumb" terminals as they are.
if [[ "$TERM" != 'dumb' ]] && ! infocmp "$TERM" >/dev/null 2>&1; then
  export TERM=xterm-256color
fi

# Aliases
alias ls='ls -G'

# Shell functions and hooks are not inherited by child shells, so they are
# set up here (every interactive shell) instead of ~/.zshenv, which returns
# early in child shells.

# Mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Activate sheldon if available
# Cache the output of `sheldon source` so that sheldon is not exec'd on every shell startup.
# The cache is regenerated (checked without exec) when it is missing, when plugins.toml,
# plugins.lock or ~/.zsh.d (local plugins) is newer than it, or when the sheldon binary changed
# (its resolved path is recorded on the first line, since Homebrew keeps the bottle's mtime).
# To regenerate it, delete the cache file.
if command -v sheldon >/dev/null 2>&1; then
  __sheldon="${commands[sheldon]}"
  __sheldon_real="${__sheldon:A}"
  __sheldon_cache="${XDG_CACHE_HOME}/zsh/sheldon-source.zsh"
  __sheldon_head=
  [[ -r "${__sheldon_cache}" ]] && IFS= read -r __sheldon_head < "${__sheldon_cache}"
  if [[ "${__sheldon_head}" != "# ${__sheldon_real}" \
    || "${__sheldon_real}" -nt "${__sheldon_cache}" \
    || "${XDG_CONFIG_HOME}/sheldon/plugins.toml" -nt "${__sheldon_cache}" \
    || "${XDG_DATA_HOME}/sheldon/plugins.lock" -nt "${__sheldon_cache}" \
    || "${HOME}/.zsh.d" -nt "${__sheldon_cache}" ]]; then
    # Write to a temporary file and rename it, so that an interrupted write never leaves a broken cache.
    # zsh/files provides builtin mkdir/mv/rm (as zf_*), which avoids extra exec.
    if zmodload -F zsh/files b:zf_mkdir b:zf_mv b:zf_rm 2>/dev/null \
      && { [[ -d "${__sheldon_cache:h}" ]] || zf_mkdir -p "${__sheldon_cache:h}"; } 2>/dev/null \
      && { print -r -- "# ${__sheldon_real}" && "${__sheldon}" source; } >| "${__sheldon_cache}.$$" 2>/dev/null \
      && zf_mv -f "${__sheldon_cache}.$$" "${__sheldon_cache}" 2>/dev/null; then
      :
    else
      zf_rm -f "${__sheldon_cache}.$$" 2>/dev/null
      __sheldon_cache=
    fi
  fi
  if [[ -n "${__sheldon_cache}" ]]; then
    source "${__sheldon_cache}"
  else
    # Fall back to the uncached way if the cache could not be written.
    eval "$(sheldon source)"
  fi
  unset __sheldon __sheldon_real __sheldon_cache __sheldon_head
fi

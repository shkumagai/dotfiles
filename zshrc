# ~/.zshrc

# load global settings
source ~/.zsh.d/zshrc

export TERM=xterm-256color

# Additional local settings
[[ -f "${HOME}/.zshrc.inc" ]] && source "${HOME}/.zshrc.inc"

# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh

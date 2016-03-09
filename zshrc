# ~/.zshrc

# load global settings
source ~/.zsh.d/zshrc

export TERM=xterm-256color
#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "$HOME/.gvm/bin/gvm-init.sh" ]] && source "$HOME/.gvm/bin/gvm-init.sh"

TMPPATH=$(echo $PATH | perl -npe 's!/opt/local/s?bin!!g;')
export PATH=/opt/local/bin:/opt/local/sbin:$PATH

# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh

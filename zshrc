# ~/.zshrc

# load global settings
source ~/.zsh.d/zshrc

export TERM=xterm-256color

if [ -x "/opt/local/bin/port" ]; then
    export PATH=/opt/local/bin:/opt/local/sbin:$PATH
elif [ -x "/usr/local/bin/brew" ]; then
    export PATH=/usr/local/bin:/usr/local/sbin:$PATH
    if [ -f $(brew --prefix)/etc/brew-wrap ]; then
        source $(brew --prefix)/etc/brew-wrap
    fi
    PATH=/usr/local/share/git-core/contrib/diff-highlight:$PATH
fi

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "$HOME/.gvm/bin/gvm-init.sh" ]] && source "$HOME/.gvm/bin/gvm-init.sh"

# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh

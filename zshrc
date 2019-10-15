# ~/.zshrc

# load global settings
source ~/.zsh.d/zshrc

export TERM=xterm-256color

if [ -x "/opt/local/bin/port" ]; then
    export PATH=/opt/local/bin:/opt/local/sbin:$PATH
    PATH=/opt/local/share/git/contrib/diff-highlight:$PATH
fi
if [ -x "/usr/local/bin/brew" ]; then
    export PATH=/usr/local/bin:/usr/local/sbin:$PATH
    if [ -f $(brew --prefix)/etc/brew-wrap ]; then
        source $(brew --prefix)/etc/brew-wrap
    fi
    PATH=/usr/local/share/git-core/contrib/diff-highlight:$PATH
    export HOMEBREW_NO_INSTALL_CLEANUP=1
fi

# for PostgreSQL@9.6
export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"

# added by travis gem
[ -f /Users/shkumagai/.travis/travis.sh ] && source /Users/shkumagai/.travis/travis.sh

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "$HOME/.gvm/bin/gvm-init.sh" ]] && source "$HOME/.gvm/bin/gvm-init.sh"

# Local variables:
# mode: shell-script
# sh-basic-offset: 2
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: sw=2 ts=2 et filetype=sh

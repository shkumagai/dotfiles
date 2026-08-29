# Structure

```
./home
    +-- .config/                  # Root of XDG_CONFIG_HOME
        +-- git/                  # git configuration directory
            +-- config
            +-- ignore
        +-- mise/                 # mise configuration directory
            +-- config.toml
        +-- sheldon/              # sheldon configuration directory
            +-- plugins.toml
        +-- tmux/                 # tmux configuration directory
            +-- keybinding.conf
            +-- status.conf
            +-- tmux.conf
        +-- zed/                  # Zed configuration directory
            +-- themes/
            +-- settings.json
        +-- starship.toml         # Starship configuration
    +-- .ssh/
        +-- config
    +-- .tmux.d/
        +-- bin/
    +-- .vim/
        +-- bundle/
        +-- ftdetect/
    +-- . zsh.d/                  # Zsh configuration directory
        +-- automation.zsh
        +-- completion.zsh
        +-- function.zsh
        +-- history.zsh
        +-- misc.zsh
        +-- prompt.zsh
        +-- visual.zsh
    +-- .vimrc
    +-- .zprofile
    +-- .zshenv
    +-- .zshrc
```

# RC files loading order for Zsh

## Login shell

When: start terminal, ssh, tmux, screeen

| global or local | path |
|-----------------|------|
| global          | `/etc/zshenv` |
| local           | `${HOME}/.zshenv` |
| global          | `/etc/zprofile` |
| local           | `${HOME}/.zprofile` |
| global          | `/etc/zshrc` |
| local           | `${HOME}/.zshrc` |
| global          | `/etc/zlogin` |
| local           | `${HOME}/.zlogin` |


## Interactive shell

When: start zsh on terminal

| global or local | path |
|-----------------|------|
| global          | `/etc/zshenv` |
| local           | `${HOME}/.zshenv` |
| global          | `/etc/zshrc` |
| local           | `${HOME}/.zshrc` |


## Execute shell script

| global or local | path |
|-----------------|------|
| global          | `/etc/zshenv` |
| local           | `${HOME}/.zshenv` |


## Logout

| global or local | path |
|-----------------|------|
| local           | `${HOME}/.zlogout` |
| global          | `/etc/zlogout` |

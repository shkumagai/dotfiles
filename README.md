# My dotfiles

# Usage

### Step 1: Install [Xcode Command Line Tools](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools)

```sh
xcode-select --install
```

### Step 2: Run the install script

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/shkumagai/dotfiles/refs/heads/master/install.sh)"
```

# What this repository does

- Apply minimum configurations: `.zshrc` / `.zprofile` / `.zshenv` / `.ssh/config` / `.config/*` 
- Install [mise](https://mise.jdx.dev/) at first, then install some tools via [mise](https://mise.jdx.dev/)
- Run the initial setups

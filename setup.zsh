#!/bin/sh

# Install XCode Command Line Utilities
xcode-select --install

# Setup GitHub SSH Authentication
mkdir -p "${HOME}/.ssh"
ssh-keygen -f "${HOME}/.ssh/github" -C ""
cat >> ~/.ssh/config <<EOF
Host github.com
  IdentityFile ~/.ssh/github
EOF
cat <<EOF
Upload the following public key to github, then press ENTER to continue:

$(cat "${HOME}/.ssh/github.pub")

Note: You should upload it as both an Authentication Key and Signing Key.
EOF
# Wait for user confirmation
read

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Setup Configuration
git clone git@github.com:/tomerhanochi/dotfiles "${HOME}/.config"

# Setup ZSH environment variables
ln -s "${HOME}/.config/zsh/.zshenv" ~/.zshenv

source ~/.zshenv

# Install all formulas and casks
brew bundle install -g

# Create main terminal session
zellij attach --create-background terminal
zellij --session terminal action rename-tab zsh

# Create dotfiles session
cd "${XDG_CONFIG_HOME}"
zellij attach --create-background dotfiles
zellij --session dotfiles action rename-tab hx
zellij --session dotfiles action new-tab --name zsh
cd "${OLDPWD}"

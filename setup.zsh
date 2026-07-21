#!/usr/bin/env zsh

setopt err_exit no_unset pipe_fail

echo "Installing XCode Command Line Utilities..."
if ! xcode-select --install &> /dev/null; then
  echo "XCode Command Line Utilities are already installed, skipping...";
fi
echo "Done!"

echo "Configuring Touch ID for sudo..."
sed "s/^#auth/auth/" /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local
echo "Done!"

echo "Installing homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "Done!"

echo "Cloning dotfiles into '${HOME}/.config'..."
# Clone over HTTPS since the SSH key does not exist yet, then point origin at
# SSH so future pushes authenticate with the Secure Enclave key created below.
(
  mkdir -p "${HOME}/.config"
  cd "${HOME}/.config"
  git clone https://github.com/tomerhanochi/dotfiles .
  git remote set-url origin git@github.com:/tomerhanochi/dotfiles
)
echo "Done!"

echo "Configuring zsh environment variables..."
ln -s "${HOME}/.config/zsh/.zshenv" ~/.zshenv

source ~/.zshenv
echo "Done!"

echo "Installing all homebrew formulas and casks..."
brew bundle install -g
echo "Done!"

echo "Creating Secure Enclave SSH keys..."
for cn in git github.com; do
  just -g ssh-create "${cn}"
done

just -g ssh-export
echo "Done!"

echo "Including dotfiles ssh config in ~/.ssh/config..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/config
grep -qxF 'Include ~/.config/ssh/*' ~/.ssh/config || printf 'Include ~/.config/ssh/*\n' >> ~/.ssh/config
echo "Done!"

cat <<EOF
Upload the following AUTHENTICATION public key to github:

$(cat "${HOME}/.ssh/keys/github.com/current.pub")

Upload the following SIGNING public key to github:

$(cat "${HOME}/.ssh/keys/git/current.pub")
EOF
# Wait for user confirmation
read "?Press ENTER once you have uploaded the public keys to continue..."
echo "Done!"

echo "Creating zellij terminal session..."
zellij attach --create-background terminal
zellij --session terminal action rename-tab zsh
echo "Done!"

echo "Creating zellij dotfiles session..."
(
  cd "${XDG_CONFIG_HOME}"
  zellij attach --create-background dotfiles
  zellij --session dotfiles action rename-tab hx
  zellij --session dotfiles action new-tab --name zsh
)
echo "Done!"

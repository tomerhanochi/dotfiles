#!/bin/sh

set -euo pipefail

## Functions
function extract_pubkey_label() {
  local pubkey="$1";
  local pubkey_hash="$(echo "${pubkey}" | ssh-keygen -lf - | grep -o 'SHA256:\S*')";
  local ctk_identity="$(sc_auth list-ctk-identities -t ssh -e b64 | grep "${pubkey_hash}")";
  if [[ ctk_identity == "" ]]; then
    return;
  fi
  echo "${ctk_identity}" | awk '{print $4}';
}

function find_pubkey_by_label() {
  local label="$1";
  ssh-add -L 2>&1 | while read -r pubkey; do
    local pubkey_label="$(extract_pubkey_label "${pubkey}")";

    if [[ "${label}" == "${pubkey_label}" ]]; then
      echo "${pubkey}";
      return;
    fi
  done
}

function pubkey_path() {
  local label="$1";
  echo "${HOME}/.ssh/${label}.pub";
}

echo "Installing XCode Command Line Utilities..."
if ! xcode-select --install &> /dev/null; then
  echo "XCode Command Line Utilities are already installed, skipping...";
fi
echo "Done!"

echo "Creating Secure Enclave SSH keys..."
github_label="github-authentication"
git_label="git-signing"

export SSH_SK_PROVIDER=/usr/lib/ssh-keychain.dylib

labels=("${github_label}" "${git_label}")
for label in "${labels[@]}"; do
  sc_auth create-ctk-identity -l "${label}" -k p-256-ne -t bio
done
SSH_ASKPASS_REQUIRE=force SSH_ASKPASS=echo ssh-add -K &> /dev/null
echo "Done!"

echo "Configuring GitHub authentication and Git signing SSH keys..."
for label in "${labels[@]}"; do
  public_key="$(find_pubkey_by_label "${github_label}")"
  public_key_path="$(pubkey_path "${label}")"
  echo "${public_key}" > "${public_key_path}"
done

cat >> ~/.ssh/config <<EOF
Host github.com
  IdentityFile $(pubkey_path "${github_label}")
  IdentitiesOnly yes
EOF
cat <<EOF
Upload the following AUTHENTICATION public key to github:

$(find_pubkey_by_label "${github_label}")

Upload the following SIGNING public key to github:

$(find_pubkey_by_label "${git_label}")

Note: Press ENTER to continue
EOF
# Wait for user confirmation
read
echo "Done!"

echo "Installing homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "Done!"

echo "Cloning dotfiles into '${HOME}/.config'..."
git clone git@github.com:/tomerhanochi/dotfiles "${HOME}/.config"
echo "Done!"

echo "Configuring zsh environment variables..."
ln -s "${HOME}/.config/zsh/.zshenv" ~/.zshenv

source ~/.zshenv
echo "Done!"

echo "Installing all homebrew formulas and casks..."
brew bundle install -g
echo "Done!"

echo "Creating zellij terminal session..."
zellij attach --create-background terminal
zellij --session terminal action rename-tab zsh
echo "Done!"

echo "Creating zellij dotfiles session..."
cd "${XDG_CONFIG_HOME}"
zellij attach --create-background dotfiles
zellij --session dotfiles action rename-tab hx
zellij --session dotfiles action new-tab --name zsh
cd "${OLDPWD}"
echo "Done!"

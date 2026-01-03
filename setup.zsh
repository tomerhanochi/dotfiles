#!/bin/sh

set -euo pipefail

## Functions
function hash_pubkey() {
  local pubkey="$1";
  local pubkey_hash="$(echo "${pubkey}" | ssh-keygen -lf - | grep -o 'SHA256:\S*')";
  echo "${pubkey_hash}";
}

function extract_ctk_identity() {
  local pubkey_hash="$1";
  local ctk_identity="$(sc_auth list-ctk-identities -t ssh -e b64 | grep "${pubkey_hash}")";
  echo "${ctk_identity}";
}

function find_pubkey() {
  local cn="$1";
  local label="$2";
  ssh-add -L 2>&1 | while read -r pubkey; do
    local pubkey_hash="$(hash_pubkey "${pubkey}")"
    local ctk_identity="$(extract_ctk_identity "${pubkey_hash}")";
    if [[ "${ctk_identity}" == "" ]]; then
      continue;
    fi

    # CTK Identity columns:
    # Key Type | Public Key Hash | Prot | Label | Common Name | Email Address | Valid To | Valid
    local ctk_identity_cn="$(echo "${ctk_identity}" | awk '{print $5}')"
    local ctk_identity_label="$(echo "${ctk_identity}" | awk '{print $4}')"

    if [[ "${cn}" == "${ctk_identity_cn}" ]] && [[ "${label}" == "${ctk_identity_label}" ]]; then
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
timestamp="$(date +'%Y-%m-%d')"
github_cn="github-authentication"
git_cn="git-signing"

export SSH_SK_PROVIDER=/usr/lib/ssh-keychain.dylib

common_names=("${github_cn}" "${git_cn}")
for cn in "${common_names[@]}"; do
  sc_auth create-ctk-identity -N "${cn}" -l "${timestamp}" -k p-256-ne -t bio
done
SSH_ASKPASS_REQUIRE=force SSH_ASKPASS=echo ssh-add -K &> /dev/null
echo "Done!"

echo "Configuring GitHub authentication and Git signing SSH keys..."
for cn in "${common_names[@]}"; do
  public_key="$(find_pubkey "${cn}" "${timestamp}")"
  public_key_path="$(pubkey_path "${cn}")"
  echo "${public_key}" > "${public_key_path}"
done

if ! grep 'Host github.com' ~/.ssh/config; then
  cat >> ~/.ssh/config <<EOF
Host github.com
  IdentityFile $(pubkey_path "${github_cn}")
  IdentitiesOnly yes
EOF
fi
cat <<EOF
Upload the following AUTHENTICATION public key to github:

$(find_pubkey "${github_cn}" "${timestamp}")

Upload the following SIGNING public key to github:

$(find_pubkey "${git_cn}" "${timestamp}")

Note: Press ENTER to continue, CTRL+C to quit.
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

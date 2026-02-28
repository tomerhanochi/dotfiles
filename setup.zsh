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

function export_keys() {
  local keycount="$(sc_auth list-ctk-identities -t ssh -e b64 | tail -n +2 | wc -l | tr -d '[:space:]')";
  local tmpdir="$(mktemp -d)";
  (
    cd "${tmpdir}" &&
    for i in $(seq 0 "${keycount}"); do
      {
        if [ "${i}" -ne 0 ]; then yes y | head -n "${i}"; fi;
        if [ "${i}" -ne "${keycount}" ]; then yes n | head -n "$((keycount - i))"; fi;
      } | SSH_ASKPASS_REQUIRE=force SSH_ASKPASS=echo ssh-keygen -w /usr/lib/ssh-keychain.dylib -K -N "" || :;

      local public_key_path="$(find . -type 'f' -name '*.pub')";
      local public_key_hash="$(hash_pubkey "$(cat "${public_key_path}")")";
      local private_key_path="$(find . -type 'f' -not -name '*.pub')";

      local ctk_identity="$(extract_ctk_identity "${public_key_hash}")";
      # Key Type | Public Key Hash | Prot | Label | Common Name | Email Address | Valid To | Valid
      local ctk_identity_cn="$(echo "${ctk_identity}" | awk '{print $5}')";
      local ctk_identity_label="$(echo "${ctk_identity}" | awk '{print $4}')";

      local directory="${HOME}/.ssh/${ctk_identity_cn}";
      mkdir -p "${directory}";
      chmod 700 "${directory}"
      mv "${public_key_path}" "${directory}/${ctk_identity_label}.pub";
      mv "${private_key_path}" "${directory}/${ctk_identity_label}";
    done;
  )
  rm -rf "${tmpdir}";
}

echo "Installing XCode Command Line Utilities..."
if ! xcode-select --install &> /dev/null; then
  echo "XCode Command Line Utilities are already installed, skipping...";
fi
echo "Done!"

echo "Creating Secure Enclave SSH keys..."
timestamp="$(date +'%Y-%m-%dT%H-%M-%S')"
github_cn="github-authentication"
git_cn="git-signing"

common_names=("${github_cn}" "${git_cn}")
for cn in "${common_names[@]}"; do
  sc_auth create-ctk-identity -N "${cn}" -l "${timestamp}" -k p-256-ne -t bio
done

export_keys

for cn in "${common_names[@]}"; do
  ln -sf "${timestamp}" "${HOME}/.ssh/${cn}/current"
  ln -sf "${timestamp}.pub" "${HOME}/.ssh/${cn}/current.pub"
done
echo "Done!"

if ! grep 'Host github.com' ~/.ssh/config; then
  cat >> ~/.ssh/config <<EOF
Host github.com
  User git
  SecurityKeyProvider /usr/lib/ssh-keychain.dylib
  IdentityFile ~/.ssh/${github_cn}/current
  IdentitiesOnly yes
EOF
fi

cat <<EOF
Upload the following AUTHENTICATION public key to github:

$(cat "${HOME}/.ssh/${github_cn}.pub")

Upload the following SIGNING public key to github:

$(cat "${HOME}/.ssh/${git_cn}.pub")

Note: Press ENTER to continue.
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

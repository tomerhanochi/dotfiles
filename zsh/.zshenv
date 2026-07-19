###########################
######### EXPORTS #########
###########################
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_EXECUTABLE_HOME="${HOME}/.local/bin"

for p in "/usr/local/bin" "${XDG_EXECUTABLE_HOME}"; do
  if [[ ! -d "${p}" ]] || [[ ":${PATH}:" == *":${p}:"* ]]; then
    continue
  fi
  export PATH="${p}:${PATH}"
done

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

export EDITOR=hx
export VIEWER="${EDITOR}"
export VISUAL="${EDITOR}"

export GPG_TTY="$(tty)"

export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/starship.toml"

export CARGO_TARGET_DIR="${XDG_CACHE_HOME}/cargo/target"

# See:
# 1. https://github.com/zellij-org/zellij/blob/68362d4cf0b20682d16647570cc324a770b687bc/zellij-client/src/lib.rs#L402-L408
# 2. https://github.com/zellij-org/zellij/blob/68362d4cf0b20682d16647570cc324a770b687bc/zellij-client/src/lib.rs#L337-L340
export ZELLIJ_SOCKET_DIR="/tmp/zellij-${USER}"

###########################
########## EVALS ##########
###########################
eval $(/opt/homebrew/bin/brew shellenv zsh)

###########################
######### SCRIPTS #########
###########################
if [[ -e "${HOME}/.cargo/env" ]]; then
  source "${HOME}/.cargo/env"
fi

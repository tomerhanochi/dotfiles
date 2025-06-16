###########################
######### EXPORTS #########
###########################
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_EXECUTABLE_HOME="$HOME/.local/bin"

if [ -d "$XDG_EXCEUTABLE_HOME" ] && [[ "$PATH" != *"$XDG_EXCEUTABLE_HOME"* ]]; then
  export PATH="$XDG_EXCEUTABLE_HOME:$PATH"
fi

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export EDITOR=hx
export VIEWER="$EDITOR"

export GPG_TTY="$(tty)"

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

export CARGO_TARGET_DIR="$XDG_CACHE_HOME/cargo/target"

###########################
########## EVALS ##########
###########################
eval $(/opt/homebrew/bin/brew shellenv)

###########################
######### SCRIPTS #########
###########################
if [ -e "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

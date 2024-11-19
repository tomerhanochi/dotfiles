###########################
######### EXPORTS #########
###########################
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_HOME="$HOME/.local/share"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export EDITOR=hx
export VIEWER="$EDITOR"

export GPG_TTY="$(tty)"

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

###########################
######### SCRIPTS #########
###########################
if [ -e "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

###########################
########## EVALS ##########
###########################
eval $(/opt/homebrew/bin/brew shellenv)

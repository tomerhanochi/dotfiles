###########################
######### EXPORTS #########
###########################
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-"$HOME/.cache"}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-"$HOME/.local/state"}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-"$HOME/.local/share"}"

export EDITOR=nvim
export VIEWER="$EDITOR"

export GPG_TTY="$(tty)"

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

###########################
######## FUNCTIONS ########
###########################


###########################
######### ALIASES #########
###########################
alias nano="$EDITOR"
alias nvim="$EDITOR"
alias vim="$EDITOR"
alias vi="$EDITOR"

###########################
######## AUTOLOADS ########
###########################
autoload -Uz compinit && compinit

###########################
########## EVALS ##########
###########################
eval "$(starship init zsh)"

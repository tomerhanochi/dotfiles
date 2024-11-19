###########################
######### EXPORTS #########
###########################
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

###########################
######## FUNCTIONS ########
###########################

###########################
######### ALIASES #########
###########################

###########################
######## AUTOLOADS ########
###########################
autoload -Uz compinit && compinit

###########################
########## EVALS ##########
###########################
eval $(/opt/homebrew/bin/brew shellenv)
eval "$(starship init zsh)"
source <(fzf --zsh)

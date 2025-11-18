###########################
######## FUNCTIONS ########
###########################

###########################
######### ALIASES #########
###########################
alias ls=eza

###########################
######## AUTOLOADS ########
###########################
autoload -Uz compinit && compinit
autoload -Uz select-word-style && select-word-style bash

###########################
########## EVALS ##########
###########################
eval "$(starship init zsh)"
eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd cd)"

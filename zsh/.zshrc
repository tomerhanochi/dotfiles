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

###########################
########### SSH ###########
###########################
SSH_ASKPASS_REQUIRE=force SSH_ASKPASS=echo ssh-add -K &> /dev/null

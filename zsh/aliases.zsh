#!/usr/bin/env zsh

# LS
alias la="ls -al"
alias l1="ls -1"
alias rn="ls" # typo
alias /-="ls" # typo

# CD
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."


alias dud="du -h -c -d "  # disk usage depth
alias df="df -h"

alias svim="sudo vim"

alias tma="tmux attach -d || tmux new-session -s "

alias tree-src="tree -I \"node_modules|lib|target\""
alias source-zsh="source ~/.zshrc"

# APT
alias apt-full-upgrade="sudo apt update && sudo apt upgrade && sudo apt dist-upgrade && sudo apt autoremove"

# DOCKER
alias dorker='docker'
alias dokcer='docker' # typo
alias dokcr='docker'  # typo
alias dockr='docker'  # typo
alias dockre='docker' # typo

alias dpsa='docker ps -a'
alias dlf='docker logs -f'
alias docker-rm-all='docker rm -f $(docker ps -aq); docker ps -a'
alias docker-rm-all-images='docker-rm-all; docker rmi -f  $(docker images -q); docker images'
function docker-exec {
  docker exec -it $1 bash
}


function vertc-lines {
 awk -F\, '{for(i=1;i<=NF;i++) printf("%3d  %s\n",i,$i)}'
}

function vertc {
 awk -F\, '{for(i=1;i<=NF;i++) printf("%s\n",$i)}'
}


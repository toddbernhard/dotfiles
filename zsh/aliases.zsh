#!/usr/bin/env zsh

# If not running interactively, do nothing
if ! [[ -o login ]]; then
    return
fi

# LS
alias lss='ls -CF'  # -C columns, -F add annotations like / or *
alias ll='ls -AlFh' # -l list format, -h human sizes
alias la="ls -A"    # -A show hidden but not . or ..
alias l1="ls -1"    # -1 just the names
alias rn="ls" # typo
alias /-="ls" # typo

# CD
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cd..="cd .."
alias cd...="cd ../.."
alias cd-="cd -"

alias mkdir='mkdir -p -v' # -p make intermediate directories, -v list each created director

alias dud="du -h -c -d "  # disk usage depth
alias du='du -h'
alias df="df -h"

alias less='less -Fi' # -F quit if one screen, -i ignore case during search

alias svim="sudo vim"

alias tma="tmux attach -d || tmux new-session"
alias tmaa="tmux attach -d || tmux new-session -s "

alias tree="tree -nF"
alias tree-src="tree -I \"node_modules|lib|target\""

alias source-zsh="source ~/.zshrc"

# Safety features
# Generally, check before overwriting
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'  # check when deleting more than 3 or a recursive directory
alias ln='ln -i'

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

# alias reboot='sudo systemctl reboot'
# alias poweroff='sudo systemctl poweroff'

## Toggle Dvorak ##
# alias asdf="setxkbmap dvorak"
# alias aoeu="setxkbmap qwerty"


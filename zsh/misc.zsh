#!/usr/bin/env zsh

# history
HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory  # append rather than replace
setopt HIST_FIND_NO_DUPS  # show commands only once when searching


# setopt autocd  # allows you to skip the cd command
setopt extendedglob  # enables things like "cp ^*.(tar|bz2|gz)"
setopt dotglob  # show hidden files in tab completion
unsetopt beep  # no beep?

[[ "$TERM" == "xterm" ]] && export TERM=xterm-256color

export SHELL=/bin/zsh
export EDITOR=/usr/bin/vim

export PATH="$HOME"/bin:/sbin:/usr/sbin:"$PATH"

export ACK_COLOR_MATCH="bold cyan"
export ACK_COLOR_LINENO="yellow"
export ACK_COLOR_FILENAME="blue"

# Vim bindings
bindkey -v

# Autocompletion plugins
autoload -Uz compinit && compinit

#!/usr/bin/env zsh

# history
HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory  # append rather than replace
setopt HIST_FIND_NO_DUPS  # show commands only once when searching

setopt autocd  # allows you to skip the cd command
setopt extendedglob  # enables things like "cp ^*.(tar|bz2|gz)"
setopt dotglob  # show hidden files in tab completion
unsetopt beep  # no beep?
bindkey -v  # vi mode, vs emacs

#autoload

export SHELL=/bin/zsh
export EDITOR=/usr/bin/vim

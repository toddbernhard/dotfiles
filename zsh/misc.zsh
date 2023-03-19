#!/usr/bin/env zsh

export SHELL=/bin/zsh
export EDITOR=/usr/bin/vim

export PATH="$HOME"/bin:/sbin:/usr/sbin:"$PATH"

# Login shells only past this point
if ! [[ -o login ]]; then
    return
fi

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

# Vim bindings
bindkey -v

# Autocompletion plugins
autoload -Uz compinit && compinit

# Initialize pyenv
if type "pyenv" > /dev/null; then
  eval "$(pyenv init -)"
fi

# Colors
[[ "$TERM" == "xterm" ]] && export TERM=xterm-256color

export CLICOLOR="Yes"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

export ACK_COLOR_MATCH="bold cyan"
export ACK_COLOR_LINENO="yellow"
export ACK_COLOR_FILENAME="blue"

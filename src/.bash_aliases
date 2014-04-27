####  bash_aliases  ####

# If not running interactively, do nothing
[ -z "$PS1" ] && return

## Modified commands ##
alias df='df -h'
alias du='du -h'
alias mkdir='mkdir -p -v'
alias dmesg='dmesg -HL'
alias date='date "+%A, %B %d, %Y [%T]"'
#

## New commands ##
alias du1='du --max-depth=1'
alias hist='history | grep'   # takes an argument
#

## Privileged access ##
if [ $UID -ne 0 ]; then
    alias sudo='sudo '
    alias svim='sudoedit'
#    alias update='sudo pacman -Syu'
    alias reboot='sudo systemctl reboot'
    alias poweroff='sudo systemctl poweroff'
fi

## Safety features ##
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
#

## Clean typos ##
alias cd..='cd ..'
#

## Toggle Dvorak ##
alias asdf="setxkbmap dvorak"
alias aoeu="setxkbmap qwerty"
#
           
## Package management ##
#alias pac="/usr/bin/pacman -S"      # default action
#alias pacu="/usr/bin/pacman -Syu"   # [u]pdate
#alias pacr="/usr/bin/pacman -Rs"    # [r]emove
#alias pacs="/usr/bin/pacman -Ss"    # [s]earch
#alias paci="/usr/bin/pacman -Si"    # [i]nfo
#alias pacl="/usr/bin/pacman -Qt"    # [l]ist unrequired
#alias paclo="/usr/bin/pacman -Qdt"  # [l]ist [o]rphans
#

alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'

## enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias less='less -Fi'

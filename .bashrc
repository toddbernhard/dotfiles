# .bashrc

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias sudo="sudo "

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


### shorten the prompt to the first letter of each directory in the working directory path ###
_abbrev_pwd() {
  #ALLOWED_LENGTH=20
  ABBREV_LENGTH=3

  stub=""
  leftover=`pwd|sed -e "s!$HOME!~!"`
  if [ `expr index "$leftover" "~"` -eq 1 ];then
    stub="~"
    leftover=`echo ${leftover:1}`
  fi

  #echo "$stub | $leftover"

  # while [ `expr ${#stub} + ${#leftover}` -gt $ALLOWED_LENGTH -a `expr index "${leftover:1}" "/"` -gt 1 ]
  while [ `expr index "${leftover:1}" "/"` -gt 1 ]
  do
    stub=$stub`echo $leftover|sed -re "s!([^/]{1,$ABBREV_LENGTH})[^/]*/.*!\1!"`
    leftover=`echo $leftover|sed -re "s![^/]+/(.*)!\1!"`
    #echo "$stub | $leftover"
  done
  echo "$stub$leftover"
}
PROMPT_COMMAND=_abbrev_pwd

# change prompt to only the working dir path
#PROMPT_COMMAND='DIR=`pwd|sed -e "s!$HOME!~!"`; if [ ${#DIR} -gt 30 ]; then CurDir=${DIR:0:12}...${DIR:${#DIR}-15}; else CurDir=$DIR; fi'

. .bash_prompt_blue_shift


function _git_branch() {
  local git_status="`git status -unormal 2>&1`"
  if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
    if [[ "$git_status" =~ nothing\ to\ commit ]]; then
      is_dirty=false
    elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
      is_dirty=true
    else
      is_dirty=true
    fi

    if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
      branch=${BASH_REMATCH[1]}
    else
      # Detached HEAD.  (branch=HEAD is a faster alternative.)
      branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null ||
        echo HEAD`)"
    fi
        
    if [[ "$branch" == "master" ]]; then
      if $is_dirty ; then
        color=$PROMPT_BRANCH_DIRTY_MASTER_COLOR
         #color="7;38;05;9m"
      else
        color=$PROMPT_BRANCH_MASTER_COLOR
      fi
    else
		if $is_dirty ; then
        color="1;"$PROMPT_BRANCH_COLOR
      else
        color="0;"$PROMPT_BRANCH_COLOR
      fi
    fi

    if $is_dirty ; then
      branch=$branch"*"
    fi

    #if [[ "$branch" != ' ' || "$color" != "29" ]]; then
    #    echo -n '${PROMPT_START}0;35m\]'" $branch "'\[\e[0m\]'
    #fi

    #printf "%b %s %b" "${PROMPT_START}${color}" "${branch}" "${PROMPT_STOP}"
    echo -n "${PROMPT_START}${color}$branch${PROMPT_STOP}"
  fi
}

function _prompt_token() {
    # if root, use yellow #. else use green $
    if [[ $UID -eq "0" ]]; then
      token="#"
      user_color=$PROMPT_TOKEN_ROOT_COLOR
    else
      user_color=$PROMPT_TOKEN_COLOR
      token="$"
    fi
    
    # if exit status is non-zero, color the $ red
    if [ "$1" -eq 0 ]; then
        echo -n "${PROMPT_START}$user_color$token"
    else
        echo -n "${PROMPT_START}${PROMPT_TOKEN_ERROR_COLOR}$1 $token"
    fi
    echo "${PROMPT_STOP} "
}


_my_prompt() {
  
  if [[ $UID -eq "0" ]]; then
    USER_COLOR=$PROMPT_USER_ROOT_COLOR
  else
    USER_COLOR=$PROMPT_USER_COLOR
  fi


  path=$(_abbrev_pwd)

  echo ""
  echo -n "${PROMPT_START}${USER_COLOR}\u${PROMPT_STOP}"  # user
  echo -n " ${PROMPT_START}${PROMPT_GRAY}at${PROMPT_STOP}"  # at

  env | grep -q "SSH_CLIENT"
  if [ $? -ne "0" ]; then
    echo -n " \h"
  else
    echo -n " ${PROMPT_START}${PROMPT_HOST_COLOR}\h${PROMPT_STOP}" # host
  fi

  echo -n " ${PROMPT_START}${PROMPT_GRAY}in${PROMPT_STOP}"  # in
  echo -n " ${PROMPT_START}${PROMPT_DIR_COLOR}${path}${PROMPT_STOP}" # working dir

  # if pwd is git repo, show it
  branch=$(_git_branch)
  if [ ! -z $branch ]; then # if branch is not empty
    echo -n " ${PROMPT_START}${PROMPT_GRAY}on${PROMPT_STOP}"   # on
    echo -n " $branch"
  fi

  echo -n " ${PROMPT_START}${PROMPT_GRAY}at \A${PROMPT_STOP}"

  echo ""
}

# User specific aliases and functions

export EDITOR=vim
export PAGER="less -Fi" # One-page -> close less; ignore case

alias less='less -Fi'

set bell-style visual

function _prompt_command() {
    PS1="`
        exit_status=$?
        _my_prompt
        _prompt_token $exit_status
    `"
}
PROMPT_COMMAND=_prompt_command


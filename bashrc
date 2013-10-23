# .bashrc

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi


## Setup HISTORY ##
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
      else
        color=$PROMPT_BRANCH_MASTER_COLOR
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
export SUDO_EDITOR=vim
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


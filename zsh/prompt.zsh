# ZSH prompt, customized by Todd Bernhard

# Adapted from:
# Pure
# by Sindre Sorhus
# https://github.com/sindresorhus/pure
# MIT License

# For my own and others sanity
# git:
# %b => current branch
# %a => current action (rebase/merge)
# prompt:
# %F => color dict
# %f => reset color
# %~ => current path
# %* => time
# %n => username
# %m => shortname host
# %(?..) => prompt conditional - %(condition.true.false)


host() {
  echo -n "%F{${ZSH_PROMPT_HOST_COLOR:-"green"}}${ZSH_PROMPT_HOST:-"%m"}%f"
}

# Shortens current directory path by truncating all ancestor directories
# to ABBREV_LENGTH chars. Echos the result
abbrev_pwd() {
  ABBREV_LENGTH=3
  stub=""
  leftover=`print -P "%~"`

  #leftover=`$PWD|sed -e "s!$HOME!~!"` # for bash
  #echo "$stub | $leftover"

  if [ `expr index "$leftover" "~"` -eq 1 ];then
    stub="~"
    leftover=`echo ${leftover:1}`
  fi

  #echo "$stub | $leftover"
  while [ `expr index "${leftover:1}" "/"` -gt 1 ]
  do
    stub=$stub`echo $leftover|sed -re "s!([^/]{1,$ABBREV_LENGTH})[^/]*/.*!\1!"`
    leftover=`echo $leftover|sed -re "s![^/]+/(.*)!\1!"`
    #echo "$stub | $leftover"
  done
  echo -n "%F{${ZSH_PROMPT_PWD_COLOR:-"blue"}}$stub$leftover%f"
}

exit_code() {
  echo -n "%(?..%F{red}%?%f )"
}

# fastest possible way to check if repo is dirty
git_dirty() {
	# check if we're in a git repo
	command git rev-parse --is-inside-work-tree &>/dev/null || return
	# check if it's dirty
	[[ "$PURE_GIT_UNTRACKED_DIRTY" == 0 ]] && local umode="-uno" || local umode="-unormal"
	command test -n "$(git status --porcelain --ignore-submodules ${umode})"

	(($? == 0)) && echo '%F{magenta}.%f '
}

git_check_upstream() {
  # check if we're in a git repo
  git_path=$(git rev-parse --is-inside-work-tree 2> /dev/null)
  if [ $? = 0 ]; then
    echo "in git"
  fi
  
  # prevents parallel runs
  # touch "~/.zsh/checking-upstream"

  # check if there is anything to pull
	command git fetch &>/dev/null &&
  # check if there is an upstream configured for this branch
	command git rev-parse --abbrev-ref @'{u}' &>/dev/null && {
    local =$(command git rev-list --right-only --count HEAD...@'{u}' 2>/dev/null) > 0
		local downstream=$(command git rev-list --left-only --count HEAD...@'{u}' 2>/dev/null) > 0
    echo -n "%F{cyan}"
    if (( $upstream && $downstream )); then
      echo -n "⇅ "
    fi
    #  elif [ $upstream ]; then
    #    echo -n "↓ "
    #  elif [ $downstream ]; then
    #    echo -n "↑ "
    #  fi
    #  echo -n "%f"
		#}

}
}

async-rprompt() {
  sleep 2 && RPROMPT=$(date)
  
  # Save the prompt in a temp file so the parent shell can read it.
  printf "%s" $RPROMPT > ~/.zsh_rprompt
  # Signal the parent shell to update the prompt.
  kill -12
}
# Build the prompt in a background job.
#async-rprompt &!

# communicate with upstream-checking daemon
git_push_pull() {
	(( ${GIT_UPSTREAM:-1} )) && {

  	# check if we're in a git repo
	  command git rev-parse --is-inside-work-tree &>/dev/null
    if [ $? -eq 0 ]; then
      # set for daemon
      export ZSH_PROMPT_GIT_DIR=$(pwd)
    
      # check if upstream fetch is still useful
      if [ "$ZSH_PROMPT_GIT_FETCHED_DIR" = "$(pwd)" ]; then
        echo -n "%F{cyan}"
        case ${ZSH_PROMPT_GIT_FETCHED:?"not set"} in
          updown) echo -n "⇅" ;;
          down) echo -n "↓";;
          up) echo -n "↑" ;;
          *) echo -n " " ;;
        esac
        echo -n " %f"
      fi

    else # not in git repo
      unset ZSH_PROMPT_GIT_DIR
    fi

		# check check if there is anything to pull
		#command git fetch &>/dev/null &&
		# check if there is an upstream configured for this branch
		#command git rev-parse --abbrev-ref @'{u}' &>/dev/null && {
    #  local upstream=$(command git rev-list --right-only --count HEAD...@'{u}' 2>/dev/null) > 0
		#	local downstream=$(command git rev-list --left-only --count HEAD...@'{u}' 2>/dev/null) > 0
    #  echo -n "%F{cyan}"
    #  if (( $upstream && $downstream )); then
    #    echo -n "⇅ "
    #  elif [ $upstream ]; then
    #    echo -n "↓ "
    #  elif [ $downstream ]; then
    #    echo -n "↑ "
    #  fi
    #  echo -n "%f"
		#}
	} &!
}

right_prompt() {
  echo "$(git_dirty)$vcs_info_msg_0_"
}

#$(git_push_pull)

prompt_pure_setup() {
	# prevent percentage showing up
	# if output doesn't end with a newline
	export PROMPT_EOL_MARK=''

	#prompt_opts=(cr subst percent)

	zmodload zsh/datetime
	autoload -Uz add-zsh-hook
	autoload -Uz vcs_info

	add-zsh-hook precmd prompt_pure_precmd
	add-zsh-hook preexec prompt_pure_preexec

	zstyle ':vcs_info:*' enable git
	zstyle ':vcs_info:git*' formats ' %b'
	zstyle ':vcs_info:git*' actionformats ' %b|%a'

  PROMPT='$(left_prompt)'
  RPROMPT='$(right_prompt)'
}

left_prompt() {
  echo -n "\n▏$(host) $(abbrev_pwd) $(exit_code)⤜ "  # ᚛'$(left_prompt)'
}

prompt_pure_precmd() {
	# shows the full path in the title
	print -Pn '\e]0;%~\a'

	# git info
	vcs_info

	# reset value since `preexec` isn't always triggered
	unset cmd_timestamp
}

prompt_pure_preexec() {
	# shows the current dir and executed command in the title when a process is active
	print -Pn "\e]0;"
	echo -nE "$PWD:t: $2"
	print -Pn "\a"
}

prompt_pure_setup "$@"

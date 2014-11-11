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

setopt PROMPT_SUBST

host() {
  echo -n "%F{${ZSH_PROMPT_HOST_COLOR:-"green"}}${ZSH_PROMPT_HOST:-"%m"}%f"
}

# Shortens current directory path by truncating all ancestor directories
# to ABBREV_LENGTH chars. Echos the result
abbrev_pwd() {
  ABBREV_LENGTH=3
  stub=""
  leftover=`print -P "%~"`   #leftover=`$PWD|sed -e "s!$HOME!~!"` # for bash

  #echo "$stub | $leftover"

  if [ `expr index "$leftover" "~"` -eq 1 ];then
    # echo "true"
    stub="~"
    leftover=`echo $leftover | sed -re 's!^~(.*)$!\1!'`
  fi

  #echo "$stub | $leftover"
  if [ `echo "$leftover" | sed -re 's![^/]!!g' | wc -c` -gt 2 ]; then
    stub=$stub`echo $leftover|sed -re "s!([^/]{1,$ABBREV_LENGTH})[^/]*/.*!\1!"`
    leftover=`echo $leftover|sed -re "s![^/]+/(.*)!\1!"`
    #echo "$stub | $leftover"
  fi
  echo -n "%F{${ZSH_PROMPT_PWD_COLOR:-"blue"}}$stub$leftover%f"
}

exit_code() {
  echo -n "%(?..%F{red}%?%f )"
}

git_dirty() {
  dirty_count=$(git status --porcelain 2>/dev/null | wc -l)

  echo -n "%F{magenta}"
	if [ "$dirty_count" -gt 5 ]; then
    echo -n "$dirty_count "
  elif [ "$dirty_count" -gt 0 ]; then
    echo -n ". "
  fi
  echo -n "%f"
}


# checking if we need to push/pull, or "upstream", is done in the background.
# these two files help the concurrency stuff
touch_lock_path=".zsh-checking-upstream"
diff_path=".zsh-upstream-diff"

# fetches and updates 'upstream-diff' with "downup", "down", "up"
git_check_upstream() {
  # check if we're in a git repo
  git_path=$(git rev-parse --git-dir 2> /dev/null)
  if [ $? = 0 ]; then
    git_path=${git_path%.git}
    
    # prevents parallel runs      
    touch_lock="$git_path$touch_lock_path"
    if [ ! -e $touch_lock ]; then
       touch "$touch_lock"
       # check if there is anything to pull
       command git fetch &>/dev/null &&
       # check if there is an upstream configured for this branch
	     command git rev-parse --abbrev-ref @'{u}' &>/dev/null && {
         local diff=''
         (( $(command git rev-list --right-only --count HEAD...@'{u}' 2>/dev/null) > 0 )) && diff+='down'
         (( $(command git rev-list --left-only --count HEAD...@'{u}' 2>/dev/null) > 0 )) && diff+='up'
         echo "$diff" > "$git_path$diff_path"
      }

      rm "$touch_lock"
    fi
  fi
}

# reads 'upstream-diff' and prints arrows
git_print_upstream() {
  # check if we're in a git repo
  git_path=$(git rev-parse --git-dir 2> /dev/null)
  if [  $? = 0 ]; then
    git_path=${git_path%.git}

    diff="$git_path$diff_path"
    if [ -r "$diff" ]; then

      echo -n "%F{yellow}"
      case $(cat $diff) in
        updown | downup) echo -n "⇅ " ;;
        down) echo -n "↓ ";;
        up) echo -n "↑ " ;;
        *) ;;
      esac
      echo -n "%f"

    fi
  fi
}

prompt_pure_setup() {
	# prevent percentage showing up
	# if output doesn't end with a newline
	export PROMPT_EOL_MARK=''

	#prompt_opts=(cr subst percent)

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
  echo -n "\n▏$(host) $(abbrev_pwd) $(exit_code)⤜ "  # ᚛"
}

right_prompt() {
  echo -n "$(git_dirty)$(git_print_upstream)$vcs_info_msg_0_"
}

prompt_pure_precmd() {
	# shows the full path in the title
	print -Pn '\e]0;%~\a'

	# git info
	vcs_info

  # in a background subshell, updates a "diff" file for 
  (git_check_upstream &)

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

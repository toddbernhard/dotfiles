#[ ZSH prompt

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

setopt PROMPT_SUBST   # in prompt, do param and arithm expansion, and command subst
export ZLE_RPROMPT_INDENT=1  # unfortunately, 0 seems to screw up my left prompt (?!)

host() {
  echo -n "%F{${ZSH_PROMPT_HOST_COLOR:-"green"}}${PROMPT_HOST:-"%m"}%f"
}

# Shortens current directory path by truncating all ancestor directories
# to ABBREV_LENGTH chars. Echos the result
abbrev_pwd() {
  ABBREV_LENGTH=3
  stub=""
  leftover=$(print -P "%~")   #leftover=$($PWD|sed -e "s!$HOME!~!") # for bash

  #echo "$stub | $leftover"

  if [ $(expr index "$leftover" "~") -eq 1 ]; then
    stub="~"
    leftover=$(echo $leftover | sed -re 's!^~(.*)$!\1!')
  fi

  #echo "$stub | $leftover"
  if [ $(echo "$leftover" | sed -re 's![^/]!!g' | wc -c) -gt 2 ]; then
    stub=$stub$(echo $leftover|sed -re "s!([^/]{1,$ABBREV_LENGTH})[^/]*/.*!\1!")
    leftover=$(echo $leftover|sed -re "s![^/]+/(.*)!\1!")
    #echo "$stub | $leftover"
  fi
  echo -n "%F{${ZSH_PROMPT_PWD_COLOR:-"blue"}}$stub$leftover%f"
}

exit_code() {
  # http://stackoverflow.com/questions/4466245/customize-zshs-prompt-when-displaying-previous-command-exit-code
  echo -n "%(?..%F{red}%?%f )"
}

command_pointer=$(echo -n "%F{cyan}ⅵ%f")
insert_pointer="⤜"  # ᚛
current_pointer="$insert_pointer"

vi_mode_toggle() {
  if [ "$KEYMAP" = "vicmd" ]; then
    current_pointer="$command_pointer"
  else
    current_pointer="$insert_pointer"
  fi

  zle reset-prompt
}

pointer() {
  echo -n "$current_pointer"
}

git_dirty_count() {
  dirty_count=$(git status --porcelain 2>/dev/null | wc -l)

  echo -n "%F{magenta}"
  if   [ "$dirty_count" -gt 5 ]; then; echo -n "$dirty_count "
  elif [ "$dirty_count" -gt 0 ]; then; echo -n ". "; fi
  echo -n "%f"
}


# checking if we need to push/pull, or "upstream", is done in the background.
# these two files help the concurrency stuff
touch_lock_path=".zsh-checking-upstream"
diff_path=".zsh-upstream-diff"

create_upstream_diff() {
  command git fetch &>/dev/null &&   # check if there is anything to pull
  command git rev-parse --abbrev-ref @'{u}' &>/dev/null &&   # check if there is an upstream configured for this branch
  {
    local down_commits=$(command git rev-list --right-only --count HEAD...@'{u}' 2>/dev/null)
    local up_commits=$(command git rev-list --left-only --count HEAD...@'{u}' 2>/dev/null)
    if [[ $down_commits -gt 0 ]]; then; echo -n 'down'; fi
    if [[ $up_commits -gt 0   ]]; then; echo -n 'up'  ; fi
  }
}

# fetches and updates upstream-diff' with "downup", "down", "up"
git_check_upstream() {
  if [ "$ZSH_PROMPT_ENABLE_UPSTREAM" ]; then

  # check if we're in a git repo
  git_path=$(git rev-parse --git-dir 2> /dev/null)
  if [ $? = 0 ]; then
    git_path=${git_path%.git}

    # prevents parallel runs
    touch_lock="$git_path$touch_lock_path"
    if [ ! -e $touch_lock ]; then
      touch "$touch_lock"

      local diff=$(create_upstream_diff)
      echo $diff > "$git_path$diff_path"

      rm "$touch_lock"
    fi
  fi

  fi
}

# reads 'upstream-diff' and prints arrows
git_print_upstream() {
  if [ "$ZSH_PROMPT_ENABLE_UPSTREAM" ]; then

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

  fi
}

left_prompt() {
  echo -n "\n▏$(host) $(abbrev_pwd) $(exit_code)$(pointer) "
}

right_prompt() {
  echo -n "$(git_dirty_count)$(git_print_upstream)$vcs_info_msg_0_"
}

precmd_hook() {
  # shows the full path in the title
  print -Pn "\e]0;%~\a"

  # git info, refresh vcs_info cmds
  vcs_info

  # in a background subshell, updates a "diff" file for
  if [ "$ZSH_PROMPT_ENABLE_UPSTREAM" ]; then
    (git_check_upstream &)
  fi

  #reset value since `preexec` isn't always triggered
  unset cmd_timestamp
}

# show CWD in title
# runs after entered command is read, before it is run
preexec_hook() {
  print -Pn "\e]0;%~ | $2\a"
}


# Initialization

# prevent percentage showing up if output doesn't end with a newline
export PROMPT_EOL_MARK=''

#prompt_opts=(cr subst percent)

autoload -Uz add-zsh-hook
autoload -Uz vcs_info

add-zsh-hook precmd precmd_hook
add-zsh-hook preexec preexec_hook

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats '%b'
zstyle ':vcs_info:git*' actionformats '%b|%a'

zle -N zle-keymap-select vi_mode_toggle
zle -N zle-line-init vi_mode_toggle
KEYTIMEOUT=1  # reduces delay to enter insert mode

PROMPT='$(left_prompt)'
RPROMPT='$(right_prompt)'

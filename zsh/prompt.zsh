# ZSH prompt

# Adapted from:
# Pure
# by Sindre Sorhus
# https://github.com/sindresorhus/pure
# MIT License

# git format strings:
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

setopt PROMPT_SUBST   # in prompt, do parameter and arithmetic expansion, and command substition
#export ZLE_RPROMPT_INDENT=1  # unfortunately, 0 seems to screw up my left prompt (?!)


# Asynchronously check upstream for different commits
# Populates a file $git_root/.zsh_upstream_diff with "downup", "down", "up"
git_check_upstream() {
  local git_root
  local touch_lock
  local remote_commits
  local local_commits
  local diff

  # check if we're in a git repo
  git_root=$(git rev-parse --git-dir 2> /dev/null)
  # shellcheck disable=SC2181
  if [ $? = 0 ]; then
    git_root=${git_root%.git}

    # prevents parallel runs
    touch_lock="${git_root}.zsh-checking-upstream"
    if [ ! -e "$touch_lock" ]; then
      touch "$touch_lock"

      # Determine if local or origin have more commits
      command git fetch &>/dev/null &&   # check if there is anything to pull
      command git rev-parse --abbrev-ref @'{u}' &>/dev/null &&   # check if there is an upstream configured for this branch
      {
        remote_commits=$(command git rev-list --right-only --count HEAD...@'{u}' 2>/dev/null)
        local_commits=$(command git rev-list --left-only --count HEAD...@'{u}' 2>/dev/null)
        if [[ $remote_commits -gt 0 ]]; then diff="${diff}down"; fi
        if [[ $local_commits  -gt 0 ]]; then diff="${diff}up"  ; fi
      }

      echo "$diff" > "${git_root}.zsh-upstream-diff"

      rm "$touch_lock"
    fi
  fi
}



left_prompt() {
  local HOSTNAME
  local ABBREV_PWD
  local EXIT_CODE
  local POINTER


  # HOSTNAME
  HOSTNAME="%F{${ZSH_PROMPT_HOST_COLOR:-"green"}}${PROMPT_HOST:-"%m"}%f"


  # ABBREV_PWD
  # Shortens current directory path by truncating all ancestor directories to ABBREV_LENGTH chars
  local curdir_incl_tilde
  local out
  local ABBREV_LENGTH=4

  curdir_incl_tilde=$(print -P "%~")  # print current directory, using ~ for HOME
  out=""

  IFS='/' read -rA dir_parts <<< "$curdir_incl_tilde"
  for part in "${dir_parts[@]}"
  do
    if [[ "$part" == "${dir_parts[-1]}" ]]; then
      out="${out}${part}"
    else
      out="${out}${part[1,$ABBREV_LENGTH]}/"
    fi
  done

  ABBREV_PWD="%F{${ZSH_PROMPT_PWD_COLOR:-"blue"}}${out}%f"


  # EXIT_CODE
  # show red code w/ space when non-zero, else nothing
  # http://stackoverflow.com/questions/4466245/customize-zshs-prompt-when-displaying-previous-command-exit-code
  EXIT_CODE="%(?..%F{red}%?%f )"


  # POINTER
  if [ "$KEYMAP" = "vicmd" ]; then
    POINTER="%F{cyan}ⅵ%f"  # command pointer
  else
    POINTER="᚛"  # "⤜ "  # insert pointer
  fi


  # shellcheck disable=SC2028
  echo -n "\n▏${HOSTNAME} ${ABBREV_PWD} ${EXIT_CODE}${POINTER} "
}

right_prompt() {

  if [ -z "$ZSH_PROMPT_DISABLE_GIT" ]; then
    local DIRTY_ICON
    local UPSTREAM_ICON

    # DIRTY FILE COUNT
    local dirty_count
    dirty_count=$(git status --porcelain 2>/dev/null | wc -l)

    if   [ "$dirty_count" -gt 5 ]; then DIRTY_ICON="$dirty_count"
    elif [ "$dirty_count" -gt 0 ]; then DIRTY_ICON="."
    fi

    DIRTY_ICON="%F{magenta}${DIRTY_ICON}%f "

    # UPSTREAM_ICON
    # Reads $git_root/.zsh-upstream-diff and prints arrows
    if [ "$ZSH_PROMPT_ENABLE_UPSTREAM" ]; then
      local git_root
      local diff_path
      # check if we're in a git repo
      git_root=$(git rev-parse --git-dir 2> /dev/null)
      # shellcheck disable=SC2181
      if [  $? = 0 ]; then
        git_root=${git_root%.git}

        diff_path="${git_root}.zsh-upstream-diff"
        if [ -r "$diff_path" ]; then

          case $(cat "$diff_path") in
            downup) UPSTREAM_ICON="⇅" ;;
            down)   UPSTREAM_ICON="↓" ;;
            up)     UPSTREAM_ICON="↑" ;;
            *) ;;
          esac

          UPSTREAM_ICON="%F{yellow}${UPSTREAM_ICON}%f "
        fi
      fi
    fi


    # shellcheck disable=SC2154
    echo -n "${DIRTY_ICON}${UPSTREAM_ICON}$vcs_info_msg_0_"
  else
    echo -n "(no git)"
  fi
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

zle -N zle-keymap-select vim_mode_toggled
#zle -N zle-line-init vim_mode_toggled
# shellcheck disable=SC2034
KEYTIMEOUT=1  # 10ms delay to enter insert mode

# shellcheck disable=SC2016
# shellcheck disable=SC2034
PROMPT='$(left_prompt)'
# shellcheck disable=SC2016
# shellcheck disable=SC2034
RPROMPT='$(right_prompt)'

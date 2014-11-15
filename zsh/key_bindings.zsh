#!/usr/bin/env zsh


if [[ "${terminfo[kcuu1]}" != "" ]]; then
  bindkey "${terminfo[kcuu1]}" up-line-or-search          # start typing + [Up-Arrow] - fuzzy find history forward
fi

if [[ "${terminfo[kcuu1]}" != "" ]]; then
        bindkey "${terminfo[kcuu1]}" up-line-or-search    # start typing + [Up-Arrow] - fuzzy find history forward
fi
if [[ "${terminfo[kcud1]}" != "" ]]; then
        bindkey "${terminfo[kcud1]}" down-line-or-search  # start typing + [Down-Arrow] - fuzzy find history backward
fi
if [[ "${terminfo[khome]}" != "" ]]; then
        bindkey "${terminfo[khome]}" beginning-of-line    # [Home] - Go to beginning of line
fi
if [[ "${terminfo[kend]}" != "" ]]; then
        bindkey "${terminfo[kend]}" end-of-line           # [End] - Go to end of line
fi

bindkey ' ' magic-space                                   # [Space] - do history expansion

bindkey '^[[1;5C' forward-word                            # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word                           # [Ctrl-LeftArrow] - move backward one word

if [[ "${terminfo[kcbt]}" != "" ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete       # [Shift-Tab] - move through the completion menu backwards
fi

bindkey '^?' backward-delete-char                         # [Backspace] - delete backward
if [[ "${terminfo[kdch1]}" != "" ]]; then
  bindkey "${terminfo[kdch1]}" delete-char                # [Delete] - delete forward
else
  bindkey "^[[3~" delete-char
  bindkey "^[3;5~" delete-char
  bindkey "\e[3~" delete-char
fi



# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

export EDITOR=vim
export PAGER="less -Fi"

alias less='less -Fi'

set bell-style visual
shopt -s histappend

function _git_prompt() {
    local git_status="`git status -unormal 2>&1`"
    if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
            local color=29
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
            local color=136
        else
            local color=61
        fi
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
            branch=${BASH_REMATCH[1]}
            test "$branch" != master || branch=' '
        else
            # Detached HEAD.  (branch=HEAD is a faster alternative.)
            branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null ||
                echo HEAD`)"
        fi
        if [[ "$branch" != ' ' || "$color" != "29" ]]; then
            echo -n '\[\e[48;5;'"$color"'m\]'"$branch"'\[\e[0m\] '
        fi
    fi
}
function _standard_prompt() {
    echo -n '\[\e[0;34m\][\u@\h \W]'
    # if exit status is non-zero, color the $ red
    if [ "$1" -eq 0 ]; then
        echo -n '\[\033[0;34m\]'
    else
        echo -n '\[\033[0;31m\]'
    fi
    echo -n '\$\[\e[0m\] '
}

function _prompt_command() {
    PS1="`
        exit_status=$?
        _git_prompt
        _standard_prompt $exit_status
    `"
}
PROMPT_COMMAND=_prompt_command


if which tmux 2>&1 >/dev/null; then
    alias tmux="tmux -2"
    #if not inside a tmux session, and if no session is started, start a new session
    test -z "$TMUX" && (tmux -2 attach || tmux -2 new-session)
fi

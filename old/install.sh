#!/bin/bash

##  Args  ##
############

GLOBAL_FLAG=
THEME=

while getopts gt: OPT; do
    case "$OPT" in
    g)  GLOBAL_FLAG=1;;
    t)  THEME="$OPTARG";;
    ?)  echo "Usage: $0 [-g] [-t theme]"
            exit 2;;
    esac
done

# Defaults
if [[ -z "$GLOBAL_FLAG" ]]; then
    GLOBAL_FLAG=0
fi
if [[ -z "$THEME" ]]; then
    THEME=bash_themes/blue_orange.theme
fi


##  PATHS  ##
#############

#  length != 0
if [[ "$GLOBAL_FLAG" -eq "1" ]]; then
    if [[ "$EUID" -ne "0" ]]; then
        echo "You must run as root to install global defaults"
        exit 1
    fi
    _BASHRC=/etc/bash.bashrc
    _BASH_PORTABLE=/etc/bash.bash_portable
    _BASH_PROFILE=/etc/profile
    _INPUTRC=/etc/inputrc
    _VIMRC=/etc/vimrc
else
    _BASHRC=~/.bashrc
    _BASH_PORTABLE=~/.bash_portable
    _BASH_PROFILE=~/.bash_profile
    _INPUTRC=~/.inputrc
    _GITCONFIG=~/.gitconfig
    _GITIGNORE=~/.gitignore_global
    _VIMRC=~/.vimrc
fi


##  INSTALL  ##
###############

# BASH
cp "$THEME" buffer

options=("pacman" "yum")
PS3="Which package manager aliases? "
select opt in "${options[@]}" "none of the above"; do 

    case "$REPLY" in

    1 ) cat << EOF >> buffer
alias pac="/usr/bin/pacman -S"      # default action
alias pacu="/usr/bin/pacman -Syu"   # [u]pdate
alias pacr="/usr/bin/pacman -Rs"    # [r]emove
alias pacs="/usr/bin/pacman -Ss"    # [s]earch
alias paci="/usr/bin/pacman -Si"    # [i]nfo
alias pacl="/usr/bin/pacman -Qt"    # [l]ist unrequired
alias paclo="/usr/bin/pacman -Qdt"  # [l]ist [o]rphans
EOF
    ;;
    
    2 ) cat << EOF >> buffer
alias yum="/usr/bin/yum install"      # default action
alias yumu="/usr/bin/yum update"   # [u]pdate
alias yumr="/usr/bin/yum remove"    # [r]emove
alias yums="/usr/bin/yum search"    # [s]earch
alias yumi="/usr/bin/yum info"    # [i]nfo
alias pacl="/usr/bin/yum list installed"    # [l]ist
EOF
    ;;

    * ) echo "None";;

    esac
    break
done

cat src/.bash_aliases >> buffer
cat src/.bash_portable >> buffer
mv buffer $_BASH_PORTABLE
echo "Copied theme, .bash_aliases, .bashrc to $_BASH_PORTABLE"

SOURCE_STRING="source $_BASH_PORTABLE"
if [ -f "$_BASHRC" ]; then
    cat "$_BASHRC" | grep -q "$SOURCE_STRING"
    if [[ $? -ne "0" ]]; then
        echo "$SOURCE_STRING" >> "$_BASHRC"
        echo "Added '$SOURCE_STRING' to $_BASHRC"
    fi
else
    echo "$SOURCE_STRING" > "$_BASHRC"
    echo "Created $_BASHRC"
fi

src/gen_bash_profile.sh "$GLOBAL_FLAG" > buffer
./overwrite_check.sh buffer "$_BASH_PROFILE"

# INPUTRC
src/gen_inputrc.sh "$GLOBAL_FLAG" > buffer
./overwrite_check.sh buffer "$_INPUTRC"

# GIT
if [[ "$GLOBAL_FLAG" -eq "0" ]]; then
    ./overwrite_check.sh src/.gitconfig "$_GITCONFIG"
    ./overwrite_check.sh src/.gitignore_global "$_GITIGNORE"
fi

# VIM
./overwrite_check.sh src/.vimrc "$_VIMRC"

rm buffer

#!/usr/bin/env bash

if [[ "$#" -ne "1" ]]; then
    echo "Usage: $0 <global_flag>"
    exit 1
fi

GLOBAL_FLAG=$1

if [[ "$GLOBAL_FLAG" -eq "1" ]]; then
    _BASHRC=/etc/bash.bashrc
else
    _BASHRC=~/.bashrc
fi

cat << EOF
# Get the aliases and functions
if [ -f "$_BASHRC" ]; then
	  . "$_BASHRC"
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH
EOF

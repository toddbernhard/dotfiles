#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <global_flag>"
    exit 1
fi

GLOBAL_FLAG=$1

if [[ "$GLOBAL_FLAG" -eq "1" ]]; then
    INCLUDE_GLOBAL="\$include /etc/inputrc"
else
    INCLUDE_GLOBAL=""
fi

cat << EOF 
"\e[A": history-search-backward
"\e[B": history-search-forward
set show-all-if-ambiguous on
set completion-ignore-case on

$INCLUDE_GLOBAL
EOF

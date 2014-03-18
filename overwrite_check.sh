#!/usr/bin/env bash


if [[ "$#" -ne "2" ]]; then
    echo "Usage: $0 <src> <dest>"
    exit 1
fi

SRC="$1"
DEST="$2"


if [[ ! -f "$SRC" ]]; then
    echo "$SRC is not a file"
    exit 2
fi


if [[ ! -a "$DEST" ]]; then
    cp "$SRC" "$DEST"
    echo "copied $SRC to $DEST."
    exit 0


else
    if [[ ! -f "$DEST" ]]; then
        echo "$DEST is not a file"
        exit 3

    else
        echo ""
        echo "File $DEST already exists. Last 30 lines:"
        echo ""
        tail -30 "$DEST" | while read LINE; do
            echo "    $LINE"
        done
        if [[ ! -z "$LINE" ]]; then
            echo ""
        fi
    
        echo "[o]verwrite, [a]ppend, or [n]othing?"
        read LINE
        case $LINE in
            a|append)      cat "$SRC" >> "$DEST";;
            o|overwrite)   cp "$SRC" "$DEST";;
            ?)             echo "nothing."; exit 0;;
        esac
    fi
fi

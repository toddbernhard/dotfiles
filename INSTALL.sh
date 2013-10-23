#!/bin/bash

# Config
THEME=arch_blue_orange.theme


# Setup this script
set -e  # fail fast


# Setup BASH

cp $THEME ~/.bash_portable
cat bash_aliases >> ~/.bash_portable
cat bashrc >> ~/.bash_portable
echo "Copied bashrc to ~/.bash_portable"

SOURCE_STRING="source ~/.bash_portable"
if [ -x ~/.bashrc ]; then
    cat ~/.bashrc | grep -q "$SOURCE_STRING"
    if [ $? -ne "0" ]; then
        echo "$SOURCE_STRING" >> ~/.bashrc
        echo "Added '$SOURCE_STRING' to .bashrc"
    fi
else
    echo "$SOURCE_STRING" > ~/.bashrc
    echo "Created ~/.bashrc"
fi
source ~/.bashrc


# Setup VIM
cp vimrc ~/.vimrc
echo "Created ~/.vimrc"


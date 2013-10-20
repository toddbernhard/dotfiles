#!/bin/bash

# Setup this script

set -e  # fail fast


# Setup BASH

cp blue_orange.theme ~/.bash_portable
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


# Setup VIM

if [ -x ~/.vimrc ]; then
   cp vimrc tmp
   cat ~/.vimrc >> tmp
   cp tmp ~/.vimrc
   rm tmp
else
   cp vimrc ~/.vimrc
fi

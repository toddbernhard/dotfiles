#!/bin/bash

cp .bash_prompt_blue_shift ~/.bash_portable
cat .bashrc >> ~/.bash_portable
echo "Copied .bashrc to ~/.bash_portable"

SOURCE_STRING="source ~/.bash_portable"
cat ~/.bashrc | grep -q "$SOURCE_STRING"
if [ $? -ne "0" ]; then
  echo "$SOURCE_STRING" >> ~/.bashrc
  echo "Added '$SOURCE_STRING' to .bashrc"
fi


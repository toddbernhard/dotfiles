#!/bin/bash

cp .bash_prompt_blue_shift ~/.bash_default
cat .bashrc >> ~/.bash_default
echo "Copied .bashrc to ~/.bash_default"

echo ". .bash_default" >> ~/.bashrc



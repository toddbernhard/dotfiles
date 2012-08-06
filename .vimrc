

call pathogen#infect()
syntax on
filetype plugin indent on


set nocompatible          " Who cares about VI compatability
set laststatus=2          " Always show the statusline
set encoding=utf-8        " Necessary to show Unicode glyphs
set rnu                   " Relative line numbers rock
set tabstop=2
set softtabstop=2
set expandtab
set incsearch             " Incremental search
set ignorecase            " Ignore case in search ...
set smartcase             "  unless upper case chars occur in search string
set bs=indent,eol,start

set t_Co=256
set background=dark
colorscheme desert


    let g:Powerline_colorscheme = 'skwp'


" Map w!! to write file with sudo, when forgot to open with sudo.
cmap w!! w !sudo tee % >/dev/null

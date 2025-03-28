#!/usr/bin/bash

if ls "/tmp/gdnv.pipe" 1> /dev/null 2>&1; then
    nvim --server /tmp/gdnv.pipe --remote "<C-\><C-N>:e $1<CR>:call cursor({line}+1,{col})<CR>"
else
    ./kitty_launch.sh -e nvim --listen /tmp/gdnv.pipe --remote "$1"
fi

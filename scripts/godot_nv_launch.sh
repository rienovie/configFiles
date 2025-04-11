#!/usr/bin/bash

if ls "/tmp/gdnv.pipe" 1> /dev/null 2>&1; then
    nvim --server /tmp/gdnv.pipe --remote-tab "$1"
else
    /$HOME/Scripts/kitty_launch.sh -e nvim --listen /tmp/gdnv.pipe --remote "$1"
fi

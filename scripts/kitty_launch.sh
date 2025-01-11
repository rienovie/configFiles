#!/usr/bin/bash

randomBackground=$(find "/home/vince/.config/kitty/backgrounds" -type f | shuf -n 1)

randomColor=$(shuf -n 1 "/home/vince/.config/kitty/colors.txt")

kitty -o background="$randomColor" -o background_image="$randomBackground" "$@"

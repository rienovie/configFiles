#!/usr/bin/bash

randomBackground=$(find "/home/vince/.config/kitty/backgrounds" -type f | shuf -n 1)

# bgColor=$(shuf -n 1 "/home/vince/.config/kitty/colors.txt")
# bgColor="#052a06" # green
bgColor="#00394b" # blue-ish

kitty -o background="$bgColor" -o background_image="$randomBackground" "$@"

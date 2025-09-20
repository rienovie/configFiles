#!/usr/bin/bash

if [ "$(cat /home/vince/Scripts/waybar_updates/updateValue)" == "󰻌  Updates available! " ]; then
    alacritty -e paru && flatpak update && read -p 'Updates have finished...'
fi

~/Scripts/waybar_updates/systemStartup.sh --once

#!/usr/bin/bash

if [ "$(cat /home/vince/Scripts/waybar_updates/updateValue)" == "Updates are available! 󰻌 " ]; then
    kitty --class updater sh -c "sudo pacman -Syu && read -p 'Updates have finished...'"
fi

~/Scripts/waybar_updates/systemStartup.sh --once

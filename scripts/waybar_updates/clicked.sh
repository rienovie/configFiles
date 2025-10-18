#!/usr/bin/bash

if [ "$(cat /home/vince/Scripts/waybar_updates/updateValue)" == "󰻌  Updates available! " ]; then
    alacritty -e bash "$HOME/Scripts/waybar_updates/updateCommand.sh"
fi

~/Scripts/waybar_updates/systemStartup.sh --once

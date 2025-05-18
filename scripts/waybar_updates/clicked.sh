#!/usr/bin/bash

if [ "$(cat updateValue)" == "󰻌" ]; then
    kitty --class updater sh -c "eos-update && read -p 'Updates have finished...'"
else
    ~/Scripts/waybar_updates/systemStartup.sh --once
fi

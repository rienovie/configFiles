#!/usr/bin/bash

if [ "$1" == "--once" ]; then
    runOnce=true
else
    runOnce=false
fi

iconUpToDate=$"󰕥"
iconChecking=$"󱆢"
iconUpdate=$"󰻌"

while :; do
    echo "$iconChecking Checking for updates..." > ~/Scripts/waybar_updates/updateValue
    # sleep 2 so it shows in the panel that it's checking
    sleep 2
    if checkupdates; then
        play /home/vince/Music/sounds/boot.ogg &
        echo "$iconUpdate Updates are available!" > ~/Scripts/waybar_updates/updateValue
    fi
    echo "$iconUpToDate Up to date." > ~/Scripts/waybar_updates/updateValue
    if $runOnce; then
        exit 0
    fi
    sleep 1800
done

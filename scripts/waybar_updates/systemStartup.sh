#!/usr/bin/bash

if [ "$1" == "--once" ]; then
    runOnce=true
else
    runOnce=false
fi
echo $runOnce

iconUpToDate=$"󰕥"
iconChecking=$"󱆢"
iconUpdate=$"󰻌"

while :; do
    echo "$iconChecking Checking for updates..." > ~/Scripts/waybar_updates/updateValue
    # sleep 2 so it shows in the panel that it's checking
    sleep 2
    if checkupdates; then
        echo "$iconUpdate Updates are available!" > ~/Scripts/waybar_updates/updateValue
        play /home/vince/Music/sounds/boot.ogg
    else
        echo "$iconUpToDate Up to date." > ~/Scripts/waybar_updates/updateValue
    fi

    if $runOnce; then
        exit 0
    fi
    sleep 1800
done

#!/usr/bin/bash

if [ "$1" == "--once" ]; then
    runOnce=true
else
    runOnce=false
fi
echo $runOnce

iconUpToDate=$"󰕥"
iconChecking=$"󱆢 Checking for updates..."
iconUpdate=$"󰻌 Updates are available!"

while :; do
    echo "$iconChecking" > ~/Scripts/waybar_updates/updateValue
    # sleep 2 so it shows in the panel that it's checking
    sleep 2
    if checkupdates; then
        echo "$iconUpdate" > ~/Scripts/waybar_updates/updateValue
        play /home/vince/Music/sounds/boot.ogg
    else
        echo "$iconUpToDate" > ~/Scripts/waybar_updates/updateValue
    fi

    if $runOnce; then
        exit 0
    fi
    sleep 1800
done

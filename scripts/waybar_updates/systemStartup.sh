#!/usr/bin/bash

if [ "$1" == "--once" ]; then
    runOnce=true
else
    runOnce=false
fi
echo $runOnce

iconUpToDate=$"󰕥"
iconChecking=$"󱆢  Checking for updates... "
iconUpdate=$"󰻌  Updates available! "

while :; do
    echo "$iconChecking" > ~/Scripts/waybar_updates/updateValue
    dunstify -a waybar_updates "Checking for updates..."
    if checkupdates; then
        echo "$iconUpdate" > ~/Scripts/waybar_updates/updateValue
        dunstify -a waybar_updates -i /usr/share/icons/breeze-dark/status/64/dialog-warning.svg -u critical -t 1500 "Updates available!"
    else
        echo "$iconUpToDate" > ~/Scripts/waybar_updates/updateValue
        dunstify -a waybar_updates -i /usr/share/icons/breeze-dark/status/64/dialog-positive.svg "System is up to date."
    fi

    if $runOnce; then
        exit 0
    fi
    sleep 1800
done

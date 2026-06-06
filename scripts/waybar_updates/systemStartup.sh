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

# so multiple clicks don't run this script again
if [ "$(cat $HOME/Scripts/waybar_updates/updateValue)" == "$iconChecking" ]; then
    exit 0
fi

while :; do
    # don't want to run if the system startup script is checking again
    if [ "$(cat $HOME/Scripts/waybar_updates/updateValue)" != "$iconUpdate" ] || $runOnce; then
        echo "$iconChecking" > ~/Scripts/waybar_updates/updateValue
        # dunstify -a waybar_updates "Checking for updates..."
        # sleep so it has a chance to show up in the bar
        sleep 3
        if checkupdates; then
            if [ "$(cat $HOME/Scripts/waybar_updates/updateValue)" != "$iconUpdate" ]; then
                echo "$iconUpdate" > ~/Scripts/waybar_updates/updateValue
                # dunstify -a waybar_updates -i /usr/share/icons/breeze-dark/status/64/dialog-warning.svg -u critical -t 1500 "Updates available!"
            fi
        else
            echo "$iconUpToDate" > ~/Scripts/waybar_updates/updateValue
            # dunstify -a waybar_updates -i /usr/share/icons/breeze-dark/status/64/dialog-positive.svg "System is up to date."
        fi
    fi

    if $runOnce; then
        exit 0
    fi
    sleep 1800
done

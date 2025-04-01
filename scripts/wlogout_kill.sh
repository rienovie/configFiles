#!/usr/bin/bash

sess=$XDG_SESSION_DESKTOP

if [ "$sess" == "sway" ]; then
    dunstify "Unable to mouse kill in sway (as far as I know...)"
elif [ "$sess" == "hyprland" ]; then
    hyprctl kill
else
    dunstify "Error when trying to mouse kill. $sess is not handled."
fi

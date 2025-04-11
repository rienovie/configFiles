#!/usr/bin/bash

sess=$XDG_SESSION_DESKTOP

if [ "$sess" == "sway" ]; then
    sway exit
elif [ "$sess" == "hyprland" ]; then
    hyprctl dispatch exit
elif [ "$sess" == "niri" ]; then
    niri msg action quit
else
    dunstify "Error when trying to exit. $sess is not handled."
fi

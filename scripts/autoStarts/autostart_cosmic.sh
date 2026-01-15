#!/usr/bin/bash


# for some reason, this doesn't work
# if [ "$XDG_SESSION_DESKTOP" != "cosmic" ]; then
#     exit
# fi
# HACK:
if [ "$XDG_CURRENT_DESKTOP" == "niri" ]; then
    exit
fi

sleep 2

$QT_QPA_PLATFORMTHEME=qt6ct

steam -silent >/dev/null 3>&1 &
discord --start-minimized >/dev/null 3>&1 &
python /home/vince/Scripts/python/newUpdate.py >/dev/null 3>&1


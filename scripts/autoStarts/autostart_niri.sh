#!/usr/bin/bash

if [ "$XDG_SESSION_DESKTOP" != "niri" ]; then
    exit
fi

# /home/vince/Apps/crystal-dock/build/crystal-dock &

# Should be obsolete with new niri update has xwayland-satellite built in
# xwayland-satellite >/dev/null 3>&1 &

# sleep is required because xwayland-satellite needs to startup prior
# sleep 4

# This is currently broken for Ghostty so just using update waybar applet for now
# python ~/Scripts/python/updateTray.py &
bash ~/Scripts/waybar_updates/systemStartup.sh &

steam -silent >/dev/null 3>&1 &
discord --start-minimized >/dev/null 3>&1 &


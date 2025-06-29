#!/usr/bin/sh

if [ "$XDG_SESSION_DESKTOP" = "gnome" ]; then
    dunstify "Session returned gnome, running autostart_gnome.sh"
    steam -silent >/dev/null 2>&1 &
    discord --start-minimized >/dev/null 2>&1
fi

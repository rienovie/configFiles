#!/usr/bin/sh

if [ "$XDG_SESSION_DESKTOP" = "gnome" ]; then
    steam -silent >/dev/null 2>&1 &
    discord --start-minimized >/dev/null 2>&1
fi

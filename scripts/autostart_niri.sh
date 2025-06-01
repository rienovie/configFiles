#!/usr/bin/bash

if [ "$XDG_SESSION_DESKTOP" != "niri" ]; then
    exit
fi

xwayland-satellite >/dev/null 3>&1 &

# sleep is required because xwayland-satellite needs to startup prior
sleep 4

steam -silent >/dev/null 3>&1 &
discord --start-minimized >/dev/null 3>&1 &


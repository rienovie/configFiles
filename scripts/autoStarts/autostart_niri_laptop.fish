#!/usr/bin/env fish

if not test "$XDG_SESSION_DESKTOP" = "niri"
    exit 1
end

xwayland-satellite >/dev/null 3>&1 &

# HACK: without sleep tray icon doens't show
sleep 1

python ~/Scripts/python/updateTray.py >/dev/null 3>&1 &


#!/usr/bin/bash

# would check if cosmic but currently var does not return anything when script gets run
# so just making sure it's not gnome
if [ "$XDG_SESSION_DESKTOP" != "cosmic" ]; then
    exit
fi

steam -silent >/dev/null 3>&1 &
discord --start-minimized >/dev/null 3>&1 &
sh /home/vince/Scripts/checkForUpdates.sh >/dev/null 3>&1


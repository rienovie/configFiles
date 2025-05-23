#!/usr/bin/bash

# HACK:
# not sure why it runs the update script multiple times, but this is a stopgap for now
if [ "$XDG_SESSION_DESKTOP" == "niri" ]; then
    exit 0
fi

# initial sleep mosstly because of cosmic alpha
sleep 5

while :; do
    # dunstify "" -a "Checking for updates..." -i /usr/share/icons/breeze-dark/status/24/update-none.svg -u low

    checkupdates
    # not sure why but returns 2 when nothing is there
    if [ $? -ne 2 ]; then
        play /home/vince/Music/sounds/boot.ogg &
        ACTION=$(dunstify -u critical "Updates are available" -a "Updates are available" -i /usr/share/pixmaps/nwg-update-available.svg --action="open,open")
        if [ "$ACTION" == "open" ]; then
            kitty --class updater sh -c "eos-update && read -p 'Updates have finished...'"
        fi
        sleep 1800
        continue
    fi
    # dunstify "" -a "System is up-to-date" -i /usr/share/icons/breeze-dark/emblems/16/package-installed-updated.svg
    sleep 1800
done

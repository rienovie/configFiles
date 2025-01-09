#!/usr/bin/bash

while [ 0 == 0 ]; do
    notify-send "" -a "Checking for updates..." -i /usr/share/icons/breeze-dark/status/24/update-none.svg -u low
    dunstify "" -a "Checking for updates..." -i /usr/share/icons/breeze-dark/status/24/update-none.svg -u low

    checkupdates
    # not sure why but returns 2 when nothing is there
    if [ $? -ne 2 ]; then
        ACTION=$(dunstify -u critical "" -a "Updates are available" -i /usr/share/icons/breeze-dark/status/24/update-low.svg --action="open,open")
        if [ $ACTION == "open" ]; then
            kitty sh -c "eos-update && echo 'Updates have finished.' && read"
        fi
        sleep 1800
        continue
    fi
    dunstify "" -a "System is up-to-date" -i /usr/share/icons/breeze-dark/emblems/16/package-installed-updated.svg
    sleep 1800
done

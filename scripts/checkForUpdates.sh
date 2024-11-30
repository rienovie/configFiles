#!/usr/bin/bash

while [ 0 == 0 ]; do
    dunstify "" -a "Checking for updates" -i /usr/share/icons/Papirus-Dark/22x22@2x/panel/mintupdate-checking.svg -u low
    checkupdates

    # not sure why but returns 2 when nothing is there
    # will test again when there is actually updates
    if [ $? -ne 2 ]; then
        ACTION=$(dunstify -u critical "" -a "Updates are available" -i /usr/share/icons/Papirus-Dark/22x22@2x/panel/mintupdate-updates-available.svg --action="open,open")
        if [ $ACTION == "open" ]; then
            kitty --hold -e eos-update
        fi
        sleep 1800
        continue
    fi
    dunstify "" -a "System is up-to-date" -i /usr/share/icons/Papirus-Dark/22x22@2x/panel/mintupdate-up-to-date.svg
    sleep 1800
done


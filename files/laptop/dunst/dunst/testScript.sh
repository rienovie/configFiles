#!/usr/bin/bash

ACTION=$(dunstify -u critical "" -a "Updates are available" -i /usr/share/icons/Papirus-Dark/22x22@2x/panel/mintupdate-updates-available.svg -A "open,Open")
if [ $ACTION == "open" ]; then
	pamac-manager --updates
fi

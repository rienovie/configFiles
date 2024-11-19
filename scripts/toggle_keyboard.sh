#!/usr/bin/bash

variant=$(hyprctl getoption input:kb_variant | grep -o 'dvorak')

if [ -z "$variant" ]; then
    hyprctl keyword input:kb_variant dvorak
    dunstify "Dvorak" -r 9999 -a "Keyboard Mode" -i "/usr/share/icons/Papirus-Dark/96x96/devices/keyboard.svg"
else
    hyprctl keyword input:kb_variant \ 
    dunstify "Standard" -r 9999 -a "Keyboard Mode" -i "/usr/share/icons/Papirus-Dark/96x96/devices/keyboard.svg"
fi

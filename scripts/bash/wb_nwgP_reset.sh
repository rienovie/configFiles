#!/usr/bin/bash

# This is kinda buggy, but works so meh

killall waybar nwg-dock-hyprland

nwg-dock-hyprland -p bottom -x -f && waybar

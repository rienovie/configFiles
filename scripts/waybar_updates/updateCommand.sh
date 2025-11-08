#!/usr/bin/bash

# paru calls AUR but don't want to use it for now
sudo pacman -Syu && flatpak update && read -p 'Updates have finished...'

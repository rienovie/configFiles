#!/usr/bin/bash

cd ~/Apps/crystal-dock || exit 1

git pull

cmake --build build --parallel || exit 1

killall crystal-dock
/home/vince/Apps/crystal-dock/build/crystal-dock &

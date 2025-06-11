#!/usr/bin/bash

cd ~/Apps/crystal-dock || exit 1

git pull

cmake -S src -B build -DCMAKE_INSTALL_PREFIX=/usr || exit 1
cmake --build build --parallel || exit 1
sudo cmake --install build || exit 1

killall crystal-dock
crystal-dock &

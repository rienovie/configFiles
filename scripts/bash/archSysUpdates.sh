#!/usr/bin/env bash

# This is used as a generic update script that other update scripts I use can call

paru && flatpak update && echo -ne '\n\n\n\e[36mUpdates have finished...' && read


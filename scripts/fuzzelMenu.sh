#!/usr/bin/bash

# Made with Basher
# Goblins question Linux?


if pgrep -x "fuzzel" > /dev/null; then
	pkill -x "fuzzel"
else
	fuzzel
fi

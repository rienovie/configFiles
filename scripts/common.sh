#!/usr/bin/bash

# input is prompt
# auto appends [y/N]
# will exit if No
# TODO: make it return a bool or something
confirm() {

    confirmInput="$1"

    if [ $# -gt 0 ]; then
        confirmPrompt="$confirmInput [y/N]:"
    else
        confirmPrompt="Continue? [y/N]:"
    fi

    read -p "$confirmPrompt" -r confirmSelection

    case "$confirmSelection" in
    [yY] | [yY][eE][sS])
        echo "Continuing..."
        ;;
    "" | [nN] | [nN][oO])
        echo "Canceling..."
        exit 1
        ;;
    *)
        echo "$confirmSelection is not a valid option."
        confirm "$confirmInput"
        ;;
    esac
}

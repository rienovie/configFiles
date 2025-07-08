#!/usr/bin/bash

# input is prompt
# auto appends [y/N]
# Defaults No, use affirm for default Yes
# returns 0 for yes 1 for no
# so you can just type: if confirm; then
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
        return 0
        ;;
    "" | [nN] | [nN][oO])
        return 1
        ;;
    *)
        echo "$confirmSelection is not a valid option."
        confirm "$confirmInput"
        ;;
    esac
}

# input is prompt
# auto appends [Y/n]
# Defaults Yes, use confirm for default No
# returns 0 for yes 1 for no
# so you can just type: if affirm; then
affirm() {

    affirmInput="$1"

    if [ $# -gt 0 ]; then
        affirmPrompt="$affirmInput [Y/n]:"
    else
        affirmPrompt="Continue? [Y/n]:"
    fi

    read -p "$affirmPrompt" -r affirmSelection

    case "$affirmSelection" in
    "" | [yY] | [yY][eE][sS])
        return 0
        ;;
    [nN] | [nN][oO])
        return 1
        ;;
    *)
        echo "$affirmSelection is not a valid option."
        affirm "$affirmInput"
        ;;
    esac
}

# # do while example
# while :; do
#     read -p 'Enter email: ' -r email
#
#     confirm "'$email' is correct?" && break
# done

runExtern() {

    "$@" </dev/null &>/dev/null &

}


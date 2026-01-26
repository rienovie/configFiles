#!/usr/bin/bash

# common include guard
if [[  -n "${COMMON_INCLUDED}" ]]; then
    return
fi

COMMON_INCLUDED=1

declare -A __INCLUDED_SOURCES

# Source a file safely without duplicates
include() {
    if [ ! -f "$1" ]; then
        echo "File $1 not found"
        return 1
    fi

    newFile=$(realpath "$1")

    if [[ -z "${__INCLUDED_SOURCES[$newFile]}" ]]; then
        __INCLUDED_SOURCES["$newFile"]=1
        builtin source "$newFile"
    fi
}

# Dialog menu, $1 is title, $2 is prompt, $3 is menu items
auto_menu() {
    HEIGHT=$((LINES / 2))
    WIDTH=$((COLUMNS / 2))
    MENU_HEIGHT=$((HEIGHT - 10))
    [ $MENU_HEIGHT -lt 4 ] && MENU_HEIGHT=4

    dialog --colors --stdout \
        --title "$1" \
        --menu "$2" \
        $HEIGHT $WIDTH $MENU_HEIGHT \
        "${@:3}"
}

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

    echo -ne "$confirmPrompt"
    read -r confirmSelection

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

    echo -ne "$affirmPrompt"
    read -r affirmSelection

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

# TODO: haven't checked if this works properly yet
runExtern() {

    "$@" </dev/null &>/dev/null &

}

# echos with 1 second delay
slowPrint() {
    echo -e "$@"
    sleep 1
}


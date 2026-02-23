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

# HACK: this is here because otherwise the dialog sizing is off
# this should only ever run once even if the script is included multiple times because of the include guard
sleep 0.1

# -----------------------------------------------------------------------------
# Dialog helpers
# -----------------------------------------------------------------------------

# Sizing helpers for dialog widgets
_d_height() { echo $(( LINES   / 2 )); }
_d_width()  { echo $(( COLUMNS / 2 )); }

# Dialog menu, $1 is title, $2 is prompt, $3+ is menu items
auto_menu() {
    MENU_HEIGHT=$(($(_d_height) - 10))
    [ $MENU_HEIGHT -lt 4 ] && MENU_HEIGHT=4

    dialog --colors --stdout \
        --title "$1" \
        --menu "$2" \
        $(_d_height) $(_d_width) $MENU_HEIGHT \
        "${@:3}"
}

# Simple message box — blocks until the user presses OK
# Reads $TITLE and $BACKTITLE from the calling script
# Usage: show_msg "Some message"
show_msg() {
    dialog --colors --backtitle "$BACKTITLE" \
        --title "$TITLE" \
        --msgbox "$1" \
        "$(_d_height)" "$(_d_width)"
}

# Yes / No box
# Returns 0 for Yes, 1 for No
# Usage: if yesno "Are you sure?"; then ...
yesno() {
    dialog --colors --backtitle "$BACKTITLE" \
        --title "$TITLE" \
        --yesno "$1" \
        "$(_d_height)" "$(_d_width)"
}

# Single-line input box
# Prints user input to stdout; capture with $()
# Usage: value=$(get_input "Enter a value:" "default text")
get_input() {
    local prompt="${1:-Enter value:}"
    local default="${2:-}"
    dialog --colors --backtitle "$BACKTITLE" \
        --title "$TITLE" \
        --stdout \
        --inputbox "$prompt" \
        "$(_d_height)" "$(_d_width)" \
        "$default"
}

# Password input box (input is hidden)
# Usage: pass=$(get_password "Enter password:")
get_password() {
    local prompt="${1:-Enter password:}"
    dialog --colors --backtitle "$BACKTITLE" \
        --title "$TITLE" \
        --stdout \
        --passwordbox "$prompt" \
        "$(_d_height)" "$(_d_width)"
}

# Checklist — multiple items can be toggled on/off
# Returns space-separated list of selected tags to stdout
# Args after prompt: tag, description, state  (repeating triplets)
# Usage: selections=$(show_checklist "Pick options:" "opt1" "Desc 1" "on" "opt2" "Desc 2" "off")
show_checklist() {
    local prompt="$1"; shift
    local list_height=$(( $(_d_height) - 8 ))
    [ "$list_height" -lt 4 ] && list_height=4

    dialog --colors --backtitle "$BACKTITLE" \
        --title "$TITLE" \
        --stdout \
        --checklist "$prompt" \
        "$(_d_height)" "$(_d_width)" "$list_height" \
        "$@"
}

# Radio list — single selection from a list
# Args after prompt: tag, description, state  (repeating triplets)
# Usage: choice=$(show_radiolist "Pick one:" "opt1" "Desc 1" "on" "opt2" "Desc 2" "off")
show_radiolist() {
    local prompt="$1"; shift
    local list_height=$(( $(_d_height) - 8 ))
    [ "$list_height" -lt 4 ] && list_height=4

    dialog --colors --backtitle "$BACKTITLE" \
        --title "$TITLE" \
        --stdout \
        --radiolist "$prompt" \
        "$(_d_height)" "$(_d_width)" "$list_height" \
        "$@"
}

# Progress / gauge — reads percentage values (0-100) from stdin
# Usage: some_func | show_gauge "Working..."
show_gauge() {
    local prompt="${1:-Please wait...}"
    dialog --colors --backtitle "$BACKTITLE" \
        --title "$TITLE" \
        --gauge "$prompt" \
        "$(_d_height)" "$(_d_width)" 0
}

# -----------------------------------------------------------------------------
# Confirmation helpers
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------
# Misc helpers
# -----------------------------------------------------------------------------

# TODO: haven't checked if this works properly yet
runExtern() {

    "$@" </dev/null &>/dev/null &

}

# echos with 1 second delay
slowPrint() {
    echo -e "$@"
    sleep 1
}

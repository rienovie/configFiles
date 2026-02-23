#!/usr/bin/bash

# =============================================================================
# dialog_template.sh — Template for dialog-based bash scripts
# =============================================================================
# Usage:
#   ./dialog_template.sh
#   ./dialog_template.sh [arg1] [arg2]
#
# Dependencies:
#   dialog, common.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# -----------------------------------------------------------------------------
# Constants — $TITLE and $BACKTITLE are read by the dialog helpers in common.sh
# -----------------------------------------------------------------------------
TITLE="My Dialog Script"
BACKTITLE="$TITLE"

# -----------------------------------------------------------------------------
# Menu actions  (add your own functions here)
# -----------------------------------------------------------------------------

action_example_menu() {
    # auto_menu: auto_menu "Title" "Prompt" tag "Description" ...
    local choice
    choice=$(auto_menu "Sub-menu" "Choose an action:" \
        "1" "Do thing A" \
        "2" "Do thing B" \
        "3" "Back")

    case "$choice" in
        1) show_msg "You chose thing A." ;;
        2) show_msg "You chose thing B." ;;
        3) return ;;
    esac
}

action_input_demo() {
    local name
    name=$(get_input "Enter your name:" "World")
    [ -z "$name" ] && return          # user pressed Cancel

    show_msg "Hello, \Z4$name\Zn!"   # \Z4 = blue, \Zn = reset (dialog colour codes)
}

action_checklist_demo() {
    local selections
    selections=$(show_checklist "Select packages to install:" \
        "git"    "Version control"  "on"  \
        "curl"   "HTTP client"      "on"  \
        "htop"   "Process viewer"   "off" \
        "jq"     "JSON processor"   "off")

    [ -z "$selections" ] && return    # user pressed Cancel

    if yesno "Install: $selections ?"; then
        # Replace with your actual install command
        show_msg "Would install: $selections"
    fi
}

action_gauge_demo() {
    # Pipe progress percentages (0-100) into show_gauge
    {
        for i in 10 25 50 75 90 100; do
            echo "$i"
            sleep 0.3
        done
    } | show_gauge "Simulating work..."

    show_msg "Done!"
}

# -----------------------------------------------------------------------------
# Main menu loop
# -----------------------------------------------------------------------------

main() {
    while true; do
        local choice
        choice=$(auto_menu "$TITLE" "Select an option:" \
            "1" "Example sub-menu" \
            "2" "Input demo" \
            "3" "Checklist demo" \
            "4" "Gauge / progress demo" \
            "q" "Quit")

        # auto_menu returns non-zero on Cancel/Esc
        # shellcheck disable=SC2181
        [ $? -ne 0 ] && break

        case "$choice" in
            1) action_example_menu   ;;
            2) action_input_demo     ;;
            3) action_checklist_demo ;;
            4) action_gauge_demo     ;;
            q) break                 ;;
            *) show_msg "Unknown option: $choice" ;;
        esac
    done

    clear
}

main "$@"

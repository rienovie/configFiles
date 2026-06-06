#!/usr/bin/env bash

source /home/vince/Scripts/bash/common.sh

# p_ as prefix to avoid conflicts with other functions
p_createVenv() {
    python -m venv .venv
    slowPrint "Virtualenv created."
}

p_activate() {
    if [ -d .venv ]; then
        source .venv/bin/activate
        return
    else
        slowPrint "Virtualenv does not exist."
        return
    fi
}

p_removeVenv() {
    if [ -d .venv ]; then
        if confirm "Are you sure you want to remove the virtualenv?"; then
            deactivate # just in case active
            slowPrint "Removing virtualenv..."
            rm -rf .venv
            return
        else
            slowPrint "Virtualenv not removed."
            return
        fi
    fi
}

p_printHelp() {
    slowPrint "
Usage: pvenv [arg]

If no argument is given:
    venv already active -> deactivate -> exit
    exists but not active -> activate -> exit
    doesn't exist -> create -> activate -> exit

Arguments:
    -h, --help         Print this help message and exit
    -c, --create       Create a virtualenv in the current directory
    -d, --deactivate   Deactivate a virtualenv that is currently active
    -a, --activate     Activate the virtualenv in the current directory
    -rm, --remove      Remove the virtualenv in the current directory"
}

main() {
    case "$1" in
        -h|--help)
            p_printHelp
            return
            ;;
        -c|--create)
            p_createVenv
            return
            ;;
        -d|--deactivate)
            deactivate
            slowPrint "Deactivated virtualenv."
            return
            ;;
        -a|--activate)
            p_activate
            return
            ;;
        -rm|--remove)
            p_removeVenv
            return
            ;;
        "")
            deactivate
            if [ -d .venv ]; then
                p_activate
                return
            else
                p_createVenv
                p_activate
                return
            fi
            ;;
        *)
            slowPrint "Unknown argument: $1"
            p_printHelp
            return
            ;;
    esac

}

main "$@"

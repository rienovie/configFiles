#!/usr/bin/env bash

source ../scripts/bash/common.sh

BACKTITLE="Manage Config Files"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

_require_vars() {
    if [ ! -f "vars/system" ]; then
        show_msg "No system name found in 'vars/system'.\nPlease run Init first."
        return 1
    fi
}

_section_checklist() {
    show_checklist "Select sections to process (all enabled by default):" \
        "vars"       "Vars directory"   "on" \
        "configs"    "Config files"     "on" \
        "scripts"    "Scripts"          "on" \
        "sounds"     "Sounds"           "on" \
        "wallpapers" "Wallpapers"       "on"
}

_selected() {
    echo "$1" | grep -qw "$2"
}

# -----------------------------------------------------------------------------
# Repo → System
# -----------------------------------------------------------------------------

do_repo_to_system() {
    TITLE="Repo → System"

    _require_vars || return

    local systemName
    systemName=$(cat "vars/system")

    local repoPath="../files/$systemName"
    local systemPath="$HOME/.config"

    show_msg "This script will \ZbREPLACE\ZB the current system config files\nwith the repo '\Zb$systemName\ZB' config files.\n\n\Zb\Z1Repo Config ($systemName)  →  System Config\Zn"

    if ! yesno "Please verify that you want to continue."; then
        return
    fi

    local selected
    selected=$(_section_checklist)
    [ $? -ne 0 ] && return

    # -- Vars ------------------------------------------------------------------
    if _selected "$selected" "vars"; then
        show_msg "Handling vars..."
        rm -rf "vars"
        if [ ! -d "../vars/$systemName" ]; then
            mkdir -p "../vars/$systemName"
            touch "../vars/$systemName/paths"
            echo "$systemName" > "../vars/$systemName/system"
            touch "../vars/$systemName/initialized"
        fi
        cp -alr "../vars/$systemName" "vars"
    fi

    # -- Config files ----------------------------------------------------------
    if _selected "$selected" "configs"; then
        show_msg "Handling config files..."
        local paths=()
        mapfile -t paths < <(cat "vars/paths" "defaultConfigPaths" 2>/dev/null | grep -v '^\s*$' | sort -u)

        for path in "${paths[@]}"; do
            if [ -d "$systemPath/$path" ]; then
                rm -rf "$systemPath/$path"
            else
                mkdir -p "$(dirname "$systemPath/$path")"
            fi
            cp -alr "$repoPath/$path" "$systemPath/$path"
        done
    fi

    # -- Scripts ---------------------------------------------------------------
    if _selected "$selected" "scripts"; then
        show_msg "Handling scripts..."
        local systemScriptsPath="$HOME/Scripts"
        rm -rf "$systemScriptsPath"
        cp -alr "../scripts" "$systemScriptsPath"
    fi

    # -- Sounds ----------------------------------------------------------------
    if _selected "$selected" "sounds"; then
        show_msg "Handling sounds..."
        local systemSoundsPath="$HOME/Music/sounds"
        rm -rf "$systemSoundsPath"
        cp -alr "../sounds" "$systemSoundsPath"
    fi

    # -- Wallpapers ------------------------------------------------------------
    if _selected "$selected" "wallpapers"; then
        show_msg "Handling wallpapers..."
        local systemWallpapersPath="$HOME/Pictures/wallpapers"
        rm -rf "$systemWallpapersPath"
        cp -alr "../wallpapers" "$systemWallpapersPath"
    fi

    show_msg "Repo → System complete."
}

# -----------------------------------------------------------------------------
# System → Repo
# -----------------------------------------------------------------------------

do_system_to_repo() {
    TITLE="System → Repo"

    _require_vars || return

    local systemName
    systemName=$(cat "vars/system")

    local repoPath="../files/$systemName"
    local systemPath="$HOME/.config"

    if ! yesno "This script will \ZbREPLACE\ZB the repo '\Zb$systemName\ZB' config files\nwith the current system config files.\n\n\Zb\Z1System Config  →  Repo Config ($systemName)\Zn\n\nPlease verify that you want to continue."; then
        return
    fi

    local selected
    selected=$(_section_checklist)
    [ $? -ne 0 ] && return

    # -- Vars ------------------------------------------------------------------
    if _selected "$selected" "vars"; then
        show_msg "Handling vars..."
        rm -rf "../vars/$systemName"
        cp -alr "vars" "../vars/$systemName"
    fi

    # -- Config files ----------------------------------------------------------
    if _selected "$selected" "configs"; then
        show_msg "Handling config files..."
        local paths=()
        mapfile -t paths < <(cat "vars/paths" "defaultConfigPaths" 2>/dev/null | grep -v '^\s*$' | sort -u)

        for path in "${paths[@]}"; do
            if [ -d "$repoPath/$path" ]; then
                rm -rf "$repoPath/$path"
            fi
            mkdir -p "$(dirname "$repoPath/$path")"
            cp -alr "$systemPath/$path" "$repoPath/$path"
        done
    fi

    # -- Scripts ---------------------------------------------------------------
    if _selected "$selected" "scripts"; then
        show_msg "Handling scripts..."
        local scriptsPath="../scripts"
        rm -rf "$scriptsPath"
        cp -alr "$HOME/Scripts" "$scriptsPath"
    fi

    # -- Sounds ----------------------------------------------------------------
    if _selected "$selected" "sounds"; then
        show_msg "Handling sounds..."
        local soundsPath="../sounds"
        rm -rf "$soundsPath"
        cp -alr "$HOME/Music/sounds" "$soundsPath"
    fi

    # -- Wallpapers ------------------------------------------------------------
    if _selected "$selected" "wallpapers"; then
        show_msg "Handling wallpapers..."
        local wallpapersPath="../wallpapers"
        rm -rf "$wallpapersPath"
        cp -alr "$HOME/Pictures/wallpapers" "$wallpapersPath"
    fi

    show_msg "System → Repo complete."
}

# -----------------------------------------------------------------------------
# Init
# -----------------------------------------------------------------------------

do_init() {
    TITLE="Init"

    show_msg "This is the initialization for this repo.\nIt should only be run once per system."

    if ! yesno "Do you want to continue?"; then
        return
    fi

    if [ -d "vars" ]; then
        show_msg "The 'vars' directory already exists.\nThis script was probably run before."

        if ! yesno "Please verify that you want to continue."; then
            return
        fi

        show_msg "Clearing vars directory..."
        rm -rf "vars"
    fi

    mkdir -p "vars"

    local systemName
    systemName=$(get_input "What should this system be called?")
    [ $? -ne 0 ] && return

    while ! yesno "The system will be called '$systemName'. Is that correct?"; do
        systemName=$(get_input "What should this system be called?" "$systemName")
        [ $? -ne 0 ] && return
    done

    echo "$systemName" > "vars/system"
    touch "vars/paths" "vars/initialized"

    show_msg "Checking to see if system config already exists..."

    if [ -d "../files/$systemName" ]; then
        show_msg "Found system config in '../files/$systemName'."

        if ! yesno "Would you like to apply the config found to this system?"; then
            return
        fi

        do_repo_to_system
        show_msg "Initialization complete."
        return
    fi

    mkdir -p "../files/$systemName"

    while true; do
        local configApply
        configApply=$(auto_menu "Init — Apply Config" "No existing config was found for '$systemName'.\nWhat would you like to do?" \
            "add"    "Add the current system config to the repo" \
            "copy"   "Copy an existing config to this system" \
            "cancel" "Go back to the main menu"
        )

        case "$configApply" in
            add)
                do_system_to_repo
                show_msg "Initialization complete."
                return
                ;;
            copy)
                mapfile -t available < <(find ../files -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null)

                if [ ${#available[@]} -eq 0 ]; then
                    show_msg "No existing configs found in '../files'.\nPlease use 'add' instead."
                    continue
                fi

                local radio_args=()
                for i in "${!available[@]}"; do
                    local state="off"
                    [ $i -eq 0 ] && state="on"
                    radio_args+=("${available[$i]}" "${available[$i]}" "$state")
                done

                local configName
                configName=$(show_radiolist "Select a config to copy:" "${radio_args[@]}")
                [ $? -ne 0 ] && continue

                if [ -z "$configName" ] || [ ! -d "../files/$configName" ]; then
                    show_msg "Config '$configName' not found."
                    continue
                fi

                show_msg "Copying config '$configName' to '$systemName'..."
                cp -r "../files/$configName/." "../files/$systemName/"

                do_repo_to_system
                show_msg "Initialization complete."
                return
                ;;
            cancel | "")
                return
                ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Main menu
# -----------------------------------------------------------------------------

while true; do
    choice=$(auto_menu "Manage Config Files" "" \
        "Init"   "Initialize System" \
        "Repo"   "Repo to System" \
        "System" "System to Repo" \
        "Quit"   "Quit"
    )

    case "$choice" in
        Init)
            do_init
            ;;
        Repo)
            do_repo_to_system
            ;;
        System)
            do_system_to_repo
            ;;
        Quit | "")
            exit 0
            ;;
    esac

done

#!/usr/bin/env bash

# Function to check if a required command exists
check_dependency() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Error: '$1' is required but not installed. Please install it before running this script."
        exit 1
    }
}

# --- Dependency Checks ---
# Check for dialog and package managers
check_dependency "dialog"
if ! command -v paru &> /dev/null && ! command -v pacman &> /dev/null; then
    echo "Error: Neither 'paru' nor 'pacman' found. Please ensure an Arch-based system is set up."
    exit 1
fi

# --- Utility Functions ---

# Function to slow print text with dialog formatting (using a simple notice)
slow_print() {
    dialog --message "$@" --title "System Notice" --no-escape
}

# Checklist — multiple items can be toggled on/off
# Returns space-separated list of selected tags to stdout
# Args after prompt: tag, description, state  (repeating triplets)
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


# --- Step 1: System Update ---

system_update() {
    slow_print "Starting system update..."

    if command -v paru &> /dev/null; then
        echo "Using 'paru' for updates."
        sudo paru -Syu
    elif command -v pacman &> /dev/null; then
        echo "Using 'pacman' for updates (sudo required)."
        sudo pacman -Syu
    else
        slow_print "Warning: Could not determine update method. Skipping system update."
    fi

    if [ $? -eq 0 ]; then
        slow_print "System update completed successfully."
    else
        slow_print "WARNING: System update failed or required manual intervention. Please check the output above."
    fi
}

# --- Step 2: Package Collection Setup ---

package_collection_setup() {
    local group_options=(
        "Default" "Default packages (core system components)" "on"
        "Gnome" "Full GNOME desktop environment" "off"
        "Hyprland" "Hyprland Wayland compositor setup" "off"
        "LXQt_Wayland" "LXQt on Wayland with modern tools" "off"
        "Laptop" "Optimized configuration for laptop use cases" "off"
        "Niri" "Niri Tiling Window Manager setup" "off"
    )

    local selections
    # Capture selected groups from the checklist
    selections=$(show_checklist "Select desired package groups:" "${group_options[@]}")

    if [ -z "$selections" ]; then
        PACKAGES_LIST="None Selected"
        return 1
    fi

    PACKAGES_LIST="$selections"
}

# Function to execute package installation (requires external config files)
install_packages() {
    PACKAGE_DIR="./packages" # Assuming the 'packages' directory is available next to the script
    if [ ! -d "$PACKAGE_DIR" ]; then
        slow_print "Error: Packages directory '$PACKAGE_DIR' not found. Cannot proceed with package installation."
        return 1
    fi

    INSTALL_CMD="sudo pacman -S"
    ALL_PACKAGES=""

    IFS=' ' read -r -a groups <<< "$PACKAGES_LIST" # Split selected list into array

    for group in "${groups[@]}"; do
        PACKAGE_FILE="$PACKAGE_DIR/${group}.txt"
        if [ -f "$PACKAGE_FILE" ]; then
            # Read packages from file, ignoring comments and empty lines
            while IFS= read -r package; do
                [[ ! -z "$package" && ! "$package" =~ ^[[:space:]]*# ]] && ALL_PACKAGES+=" $package"
            done < "$PACKAGE_FILE"
        else
            echo "Warning: Package file '$PACKAGE_FILE' not found."
        fi
    done

    if [ -n "$ALL_PACKAGES" ]; then
        echo "Attempting to install packages..."
        $INSTALL_CMD $ALL_PACKAGES
        if [ $? -eq 0 ]; then
            slow_print "All selected packages installed successfully."
        else
            slow_print "WARNING: Package installation failed. Check sudo privileges or package names."
        fi
    else
        slow_print "No valid packages were loaded from the group files."
    fi
}

# --- Step 3: Git & SSH Setup ---

git_ssh_setup() {
    echo -e "\n--- Git & SSH Setup ---\n"
    local email=""
    local username=""

    # Collect Email
    email=$(dialog --inputbox "Enter your primary GitHub email address:" 8 50)
    if [ $? -ne 0 ]; then return 1; fi # Check if dialog cancelled

    # Confirm Email
    if ! dialog --yesno "Is '$email' correct?"; then echo "Email setup cancelled."; return 1; fi

    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$email" > /dev/null 2>&1 # Suppress standard output for cleaner dialog flow

    # Add to agent (Requires interactive input, which is hard in a script)
    dialog --msgbox "SSH Key generated. You MUST manually run 'ssh-add ~/.ssh/id_ed25519' and follow the prompts." 10 60
    sleep 3

    # Collect Username
    username=$(dialog --inputbox "Enter your desired Git username:" 8 50)
    if [ $? -ne 0 ]; then return 1; fi

    if ! dialog --yesno "Is '$username' correct?"; then echo "Username setup cancelled."; return 1; fi

    # Configure git
    git config --global user.email "$email"
    git config --global user.name "$username"
    slow_print "Git credentials set successfully."
}


# --- Main Execution Flow ---

main() {
    echo "=============================="
    dialog --title "Arch Setup Wizard" \
        --messagebox "Welcome to the Arch Setup Wizard.\n\nThis script automates system configuration, package installation, and Git setup using dialogs. Continue?" 10 60

    # Step 1: System Update (Requires sudo)
    system_update

    # Step 2: Package Selection
    echo -e "\n\n=============================="
    dialog --title "Package Configuration" \
        --messagebox "Now selecting desired packages..." 10 60
    package_collection_setup

    # Step 3: Install Packages (Requires sudo)
    echo -e "\n\n=============================="
    slow_print "Initiating package installation. This step requires root privileges."
    install_packages

    # Step 4: Git & SSH Setup
    echo -e "\n\n=============================="
    dialog --title "User Identity Setup" \
        --messagebox "Setting up Git and SSH keys..." 10 60
    git_ssh_setup

    # Optional final step (Config Files)
    if [ ! -d "configFiles" ]; then
        slow_print "\n\n--- Configuration Files ---\nCloning required configuration files repository."
        mkdir -p "$HOME/Repos" && cd "$HOME/Repos" || { slow_print "Could not change directory to $HOME/Repos. Skipping config clone."; }
        git clone --recursive git@github.com:rienovie/configFiles.git
    else
        slow_print "\n\n--- Configuration Files ---\nConfig files already detected."
    fi

    # Final step trigger (Interactive)
    if dialog --yesno "Setup complete! Do you want to run the configFiles initialization script now?"; then
        echo -e "\nRunning final configuration setup..."
        (cd "configFiles/manage" && /bin/bash manage.sh) # Using bash since parent script is bash
    fi

    slow_print "\n=============================="
    dialog --title "Complete" \
        --messagebox "Setup process finished! Please reboot your system to complete all changes." 10 60
}

# Execute main function
main

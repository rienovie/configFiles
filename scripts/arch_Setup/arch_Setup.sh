#!/usr/bin/bash

source ../common.sh

# This will be used as a script that I can run on a fresh install of any arch based distro (arch, endevourOS, cachyOS)
# and it'll auto install/configure my install for me

cmdToRun="sudo pacman -S"

if affirm "Include default packages?"; then
    echo "Default packages will be installed."
    cmdToRun="$cmdToRun $(cat packages/default.txt)"
else
    echo "Default packages will NOT be installed."
fi

declare -a selectedPackages=()

while :; do
    echo "Available:"
    echo $"[1]GNOME [2]Hyprland [3]LXQt Wayland [4]Niri [5]Finished"
    read -p "Choose 1-5: " -r choice
    case $choice in
        1)
            if [[ ! " ${selectedPackages[@]} " =~ " gnome " ]]; then
                selectedPackages+=("gnome")
                echo "✓ GNOME added"
            else
                selectedPackages=("${selectedPackages[@]/gnome}")
                echo "✗ GNOME removed"
            fi
            ;;
        2)
            if [[ ! " ${selectedPackages[@]} " =~ " hyprland " ]]; then
                selectedPackages+=("hyprland")
                echo "✓ Hyprland added"
            else
                selectedPackages=("${selectedPackages[@]/hyprland}")
                echo "✗ Hyprland removed"
            fi
            ;;
        3)
            if [[ ! " ${selectedPackages[@]} " =~ " lxqt_wl " ]]; then
                selectedPackages+=("lxqt_wl")
                echo "✓ LXQt Wayland added"
            else
                selectedPackages=("${selectedPackages[@]/lxqt_wl}")
                echo "✗ LXQt Wayland removed"
            fi
            ;;
        4)
            if [[ ! " ${selectedPackages[@]} " =~ " niri " ]]; then
                selectedPackages+=("niri")
                echo "✓ Niri packages added"
            else
                # Remove niri from array
                selectedPackages=("${selectedPackages[@]/niri}")
                echo "✗ Niri packages removed"
            fi
            ;;
        5)
            echo "Package selection complete."
            break
            ;;
        *)
            echo "Invalid choice. Please enter 1-5."
            ;;
    esac
    
    echo ""
    if [ ${#selectedPackages[@]} -gt 0 ]; then
        echo "Currently selected: ${selectedPackages[*]}"
    else
        echo "No additional packages selected"
    fi
    echo ""
done

for package in "${selectedPackages[@]}"; do
    case $package in
        "gnome")
            additionalFile="packages/gnome.txt"
            ;;
        "hyprland")
            additionalFile="packages/hyprland.txt"
            ;;
        "lxqt_wl")
            additionalFile="packages/lxqt_wl.txt"
            ;;
        "niri")
            additionalFile="packages/niri.txt"
            ;;
    esac
    
    if [ -f "$additionalFile" ]; then
        cmdToRun="$cmdToRun $(cat $additionalFile)"
    fi
done

echo "Installing packages..."

$cmdToRun

if [ ! -d "$HOME/Apps" ]; then
    mkdir "$HOME/Apps"
fi

echo "GitHub SSH key..."

while :; do
    read -p 'Enter email: ' -r email

    confirm "'$email' is correct?" && break
done

ssh-keygen -t ed25519 -C "$email"

eval "$(ssh-agent -s)"

ssh-add "$HOME/.ssh/id_ed25519"

echo ""
echo "This is where you click the link and setup the ssh."
echo "Script cannot continue until git is fully setup."

echo "https://github.com/settings/keys"
echo "Copy following for ssh key:"

cat "$HOME/.ssh/id_ed25519.pub"

read -p "Hit enter after you have connected ssh git to continue..." -r

git config --global user.email "$email"

while :; do
    read -p "Enter git username: " -r guName

    confirm "'$guName' is correct?" && break
done

git config --global user.name "$guName"

if [ ! -d "$HOME/Repos" ]; then
    mkdir "$HOME/Repos"
fi

cd "$HOME/Repos" || exit 1

git clone git@github.com:rienovie/configFiles.git

cd "configFiles/bash" || exit 1

bash toSystem.sh

read -p "Script has finished. Hit enter to exit." -r

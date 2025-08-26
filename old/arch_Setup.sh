#!/usr/bin/bash

source ../bash/common.sh

# This will be used as a script that I can run on a fresh install of any arch based distro (arch, endevourOS, cachyOS)
# and it'll auto install/configure my install for me

slowPrint "\n~~~~~~ Updating system ~~~~~~\n"

# Make sure system is fully up to date before running script
if paru --version; then
    paru
else
    sudo pacman -Syu
fi

if ! confirm "\nContinue to package collections?"; then
    slowPrint "\nExiting script..."
    exit 0
fi

slowPrint "\n~~~~~~ Package Collections ~~~~~~\n"

cmdToRun="sudo pacman -S"

if affirm "Include default packages?"; then
    slowPrint "\nDefault packages will be installed."
    cmdToRun="$cmdToRun $(cat packages/default.txt)"
else
    slowPrint "\nDefault packages will NOT be installed."
fi

declare -a selectedPackages=()

while :; do
    slowPrint "\nAvailable:\n[G]NOME [H]yprland [L]XQt Wayland [N]iri [F]inished"
    read -p "Choose which to add or remove: " -r choice
    case $choice in
        [Gg])
            if [[ ! " ${selectedPackages[@]} " =~ " gnome " ]]; then
                selectedPackages+=("gnome")
                echo -e "\n✓ GNOME added"
            else
                selectedPackages=("${selectedPackages[@]/gnome}")
                echo -e "\n✗ GNOME removed"
            fi
            ;;
        [Hh])
            if [[ ! " ${selectedPackages[@]} " =~ " hyprland " ]]; then
                selectedPackages+=("hyprland")
                echo -e "\n✓ Hyprland added"
            else
                selectedPackages=("${selectedPackages[@]/hyprland}")
                echo -e "\n✗ Hyprland removed"
            fi
            ;;
        [Ll])
            if [[ ! " ${selectedPackages[@]} " =~ " lxqt_wl " ]]; then
                selectedPackages+=("lxqt_wl")
                echo -e "\n✓ LXQt Wayland added"
            else
                selectedPackages=("${selectedPackages[@]/lxqt_wl}")
                echo -e "\n✗ LXQt Wayland removed"
            fi
            ;;
        [Nn])
            if [[ ! " ${selectedPackages[@]} " =~ " niri " ]]; then
                selectedPackages+=("niri")
                echo -e "\n✓ Niri packages added"
            else
                # Remove niri from array
                selectedPackages=("${selectedPackages[@]/niri}")
                echo -e "\n✗ Niri packages removed"
            fi
            ;;
        [Ff])
            echo -e "\nPackage selection complete."
            break
            ;;
        *)
            echo -e "\nInvalid choice."
            ;;
    esac

    if [ ${#selectedPackages[@]} -gt 0 ]; then
        echo -e "\nCurrently selected: ${selectedPackages[*]}"
    else
        echo -e "\nNo additional packages selected"
    fi
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

if ! confirm "\nContinue to git ssh setup?"; then
    slowPrint "\nExiting script..."
    exit 0
fi

if [ ! -d "$HOME/Apps" ]; then
    echo "Directory $HOME/Apps does not exist, creating..."
    mkdir "$HOME/Apps"
fi

slowPrint "\n~~~~~~ Github & SSH ~~~~~~\n"

while :; do
    read -p 'Enter email: ' -r email

    confirm "\n$email is correct?" && break
done

ssh-keygen -t ed25519 -C "$email"

eval "$(ssh-agent -s)"

ssh-add "$HOME/.ssh/id_ed25519"

slowPrint "\nThis is where you click the link and setup the ssh."
slowPrint "\nScript cannot continue until git is fully setup."

echo "https://github.com/settings/keys"
echo "Copy following for ssh key:"

cat "$HOME/.ssh/id_ed25519.pub"

read -p "Hit enter after you have connected ssh git to continue..." -r

while :; do
    slowPrint "\nConfirm you ACTUALLY OPENED the link and did what you needed to."
    if ! confirm "\n"; then
        continue
    fi
    break
done

git config --global user.email "$email"

while :; do
    read -p "Enter git username: " -r guName
    confirm "\n$guName is correct?" && break
done

git config --global user.name "$guName"

if [ ! -d "$HOME/Repos" ]; then
    mkdir "$HOME/Repos"
fi

cd "$HOME/Repos" || exit 1

git clone git@github.com:rienovie/configFiles.git

cd "configFiles/bash" || exit 1

bash toSystem.sh

slowPrint "\nScript has finished."

read -p "Hit enter to exit." -r

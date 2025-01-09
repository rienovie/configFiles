#!/usr/bin/bash

source ./common.sh

# This will be used as a script that I can run on a fresh install of arch (endevour)
# and it'll auto install/configure my install for me

curSession="$XDG_SESSION_DESKTOP"

if [ "$curSession" == "GNOME" ]; then
    file="packages_gnome.txt"
elif [ "$curSession" == "hyprland" ]; then
    file="packages_hyprland.txt"
else
    echo "Error, session type $curSession did not match any defined sessions."
    exit 1
fi

# install apps
cmdToRun="sudo pacman -S"

while read -r line; do
    cmdToRun="$cmdToRun $line"
done <"$file"

$cmdToRun

if [ ! -d "$HOME/Apps" ]; then
    mkdir "$HOME/Apps"
fi

echo "GitHub SSH key..."
read -p 'Enter email: ' -r email

confirm "'$email' is correct?"

ssh-keygen -t ed25519 -C "$email"

eval "$(ssh-agent -s)"

ssh-add "$HOME/.ssh/id_ed25519"

echo "https://github.com/settings/keys"
echo "Copy following for ssh key:"

cat "$HOME/.ssh/id_ed25519.pub"

read -p "Hit enter to continue..." -r

if [ ! -d "$HOME/Repos" ]; then
    mkdir "$HOME/Repos"
fi

cd "$HOME/Repos" || exit 1

git clone git@github.com:rienovie/configFiles.git

cd "configFiles/bash" || exit 1

bash toSystem.sh

read -p "Script has finished. Hit enter to exit." -r

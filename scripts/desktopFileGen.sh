#!/usr/bin/bash

# I will update this to be more useful, this is just for now
# I want this to be able to accept args to be able to automate this script without user input
# I also want to have a list of items you can edit like icon categories type etc

echo $'\n\nDesktop file generator.\n\nWill place .desktop file in .local/share/applications\n\n'

echo "Please enter Name:"
read inputName

echo $'\n\n Please enter Exec:'
read inputExec

if [ ! -d /home/$USER/.local/share/applications ]; then
    echo "$HOME/.local/share/applications dir not found. Creating..."
    mkdir /home/$USER/.local/share/applications
fi

file="/home/$USER/.local/share/applications/$inputName.desktop"
contents="[Desktop Entry]
Type=Application
Name=$inputName
Exec=$inputExec
#Icon=
#Categories=
#Terminal=false
#Version=1.0"

touch $file

echo "$contents" > "$file"

chmod +x $file

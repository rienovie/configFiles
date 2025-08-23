#!/usr/bin/env fish

source common.fish

printf "\n\nDesktop file generator.\n\nWill place .desktop file in .local/share/applications\n\n"

if test (count $argv) -gt 0; and affirm "Executable is '$argv[1]' correct?"
    set inputExec argv[1]
else
    read --prompt-str "Exec:" inputExec
    while not affirm "You entered '$inputExec' as the executable location. Is that correct?"
	read --prompt-str "Exec:" inputExec
    end
end

read --prompt-str "Name:" inputName

while not affirm "The application will be listed as '$inputName' is that correct?"
    read --prompt-str "Name:" inputName
end

if not test -d $HOME/.local/share/applications
    echo "$HOME/.local/share/applications directory not found. Creating..."
    mkdir $HOME/.local/share/applications
end

set file "$HOME/.local/share/applications/$inputName.desktop"
set contents "[Desktop Entry]
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

if confirm "Desktop file has been created. Would you like to open it?"
    cd $HOME/.local/share/applications
    nvim "$inputName.desktop"
end

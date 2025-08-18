#!/usr/bin/env fish

if not test -f init.fish
    echo "Please run script from manage directory."
end

source "../scripts/fish/common.fish"

# Will set this for the entire script
set slowPrintDelay 1

set systemName (cat vars/system)

slowPrint "This script will REPLACE the current repo '$systemName' config files with the system config files."
slowPrint "Please verify that you want to continue."

if not confirm
    slowPrint "Exiting..."
    exit 1
end
set repoPath "../files/$systemName"
set systemPath "$HOME/.config"

slowPrint "Handling vars..."
if not test -d "../vars/$systemName"
    mkdir "../vars/$systemName"
end
rm -rf "../vars/$systemName"
cp -alr "vars" "../vars/$systemName"

slowPrint "Handled vars, now handling config files..."

set paths (cat "vars/paths")
set defaultPaths (cat "defaultConfigPaths")
set paths $paths $defaultPaths

for path in $paths
    if test -d "$repoPath/$path"
        # Could make this better by skipping rm from .gitignore
        rm -rf "$repoPath/$path/"
    end
    cp -alr "$systemPath/$path" "$repoPath/$path"
end

slowPrint "Config files handled... now handling scripts..."

set scriptsPath "../scripts"
set systemScriptsPath "$HOME/Scripts"

if test -d "$scriptsPath"
    rm -rf "$scriptsPath"
else
    mkdir -p "$scriptsPath"
end
cp -alr "$systemScriptsPath" "$scriptsPath"

slowPrint "Scripts handled... now handling sounds..."

set soundsPath "../sounds"
set systemSoundsPath "$HOME/Music/sounds"

if test -d "$soundsPath"
    rm -rf "$soundsPath"
else
    mkdir -p "$soundsPath"
end
cp -alr "$systemSoundsPath" "$soundsPath"

slowPrint "Sounds handled... now handling wallpapers..."

set wallpapersPath "../wallpapers"
set systemWallpapersPath "$HOME/Pictures/wallpapers"

if test -d "$wallpapersPath"
    rm -rf "$wallpapersPath"
else
    mkdir -p "$wallpapersPath"
end
cp -alr "$systemWallpapersPath" "$wallpapersPath"

slowPrint "Wallpapers handled."

slowPrint "systemToRepo.fish script complete."
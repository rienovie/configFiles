#!/usr/bin/env fish

if not test -f "init.fish"
    echo "Please run script from manage directory."
end

source "../scripts/fish/common.fish"

# Will set this for the entire script
# Long delay because this is the more dangerous script
set slowPrintDelay 1

set systemName (cat "vars/system")

slowPrint "This script will REPLACE the current system config files with the repo '$systemName' config files."
repeat 3 echo
slowPrint "$systemName Repo Config  --> replacing -->  System Config"
repeat 3 echo
slowPrint "Please verify that you want to continue."

if not confirm
    slowPrint "Exiting..."
    exit 1
end
set repoPath "../files/$systemName"
set systemPath "$HOME/.config"

slowPrint "Handling vars..."
rm -rf vars
if not test -d "../vars/$systemName"
    mkdir "../vars/$systemName"
    touch "../vars/$systemName/paths"
    echo "$systemName" >"../vars/$systemName/system"
    touch "../vars/$systemName/initialized"
end
cp -alr "../vars/$systemName" vars

slowPrint "Handled vars, now handling config files..."

set paths (cat "vars/paths")
set defaultPaths (cat "defaultConfigPaths")
set paths $paths $defaultPaths

for path in $paths
    if test -d "$systemPath/$path"
        # Could make this better by skipping rm from .gitignore
        rm -rf "$systemPath/$path"
    else
        mkdir -p "$systemPath/$path"
    end
    cp -alr "$repoPath/$path" "$systemPath/$path"
end

slowPrint "Config files handled... now handling scripts..."

set scriptsPath "../scripts"
set systemScriptsPath "$HOME/Scripts"

if test -d "$systemScriptsPath"
    rm -rf "$systemScriptsPath"
else
    mkdir -p "$systemScriptsPath"
end
cp -alr "$scriptsPath" "$systemScriptsPath"

slowPrint "Scripts handled... now handling sounds..."

set soundsPath "../sounds"
set systemSoundsPath "$HOME/Music/sounds"

if test -d "$systemSoundsPath"
    rm -rf "$systemSoundsPath"
else
    mkdir -p "$systemSoundsPath"
end
cp -alr "$soundsPath" "$systemSoundsPath"

slowPrint "Sounds handled... now handling wallpapers..."

set wallpapersPath "../wallpapers"
set systemWallpapersPath "$HOME/Pictures/wallpapers"

if test -d "$systemWallpapersPath"
    rm -rf "$systemWallpapersPath"
else
    mkdir -p "$systemWallpapersPath"
end
cp -alr "$wallpapersPath" "$systemWallpapersPath"

slowPrint "Wallpapers handled."

slowPrint "repoToSystem.fish script complete."

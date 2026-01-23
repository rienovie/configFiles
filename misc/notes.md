Handle flatpak, aur, and git application builds in arch_setup

for the arch_setup script, make a single command to run on a fresh install without
cloning the repo using wget

for the systemToRepo and repoToSystem scripts give options for each section like scripts/sounds/etc

have certain paths be the same for each system (maybe have the default config files and just modify for the specific system)
with this can have push up to default files or spilt from main

have "s" alias use fuzy for next arg dir

for update script, make sure the window stays open if there's an error

when mkdir, default to cd into the dir

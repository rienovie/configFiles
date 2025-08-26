#!/usr/bin/env fish

# I'm pretty sure this'll work, next install I'll check
if test -f ../fish/common.fish
	source ../fish/common.fish
else if test -f fish/common.fish
	source fish/common.fish
else if test -f common.fish
	source common.fish
else
	echo "Failed to autofind common.fish script."
	echo "Script cannot continue without it."
	read -p "Please enter location of common.fish:" comFileLoc
	while ! test -f $comFileLoc
		echo "Script was not found at location: $comFileLoc"
		read -p "Please enter the location of common script: " comFileLoc
	end
	source $comfileLoc
end

# This comes from the common script
slowPrint "\n\n~~~~~ Updating System ~~~~~\n\n"

# Want to make sure the system is fully utd before trying to install anything
if test (paru --version)
	paru
else
	sudo pacman -Syu
end

slowPrint "\n\n~~~~~ Package Collections ~~~~~\n\n"

set cmdToRun "sudo pacman -S"

# TODO: this feels like it could be a common function
if test -d "packages"
	set packDir "packages"
else if test -d "arch_setup/packages"
	set packDir "arch_setup/packages"
else
	echo "Unable to find packages directory."
	read -p "Please enter directory location: " packDir
	while ! test -d $packDir
		echo "Directory not found: $packDir"
		read -p "Please enter directory location: " packDir
	end
end

set packagesList "Default"

while true
	slowPrint "Current package groups to install: $packagesList\n"
	slowPrint "[D]efault [G]nome [H]yprland [L]xqt_Wayland La[p]top [N]iri [F]inished"
	read -p "Enter group to add or remove: " groupToAdd

	switch $groupToAdd
	case D d
		if not contains "Default" $packagesList
			set packagesList $packagesList "Default"
		else
			set packagesList (string match -v "Default" $packagesList)
		end
	case G g
		if not contains "Gnome" $packagesList
			set packagesList $packagesList "Gnome"
		else
			set packagesList (string match -v "Gnome" $packagesList)
		end
	case H h
		if not contains "Hyprland" $packagesList
			set packagesList $packagesList "Hyprland"
		else
			set packagesList (string match -v "Hyprland" $packagesList)
		end
	case L l
		if not contains "LXQt_Wayland" $packagesList
			set packagesList $packagesList "LXQt_Wayland"
		else
			set packagesList (string match -v "LXQt_Wayland" $packagesList)
		end
	case P p
		if not contains "Laptop" $packagesList
			set packagesList $packagesList "Laptop"
		else
			set packagesList (string match -v "Laptop" $packagesList)
		end
	case N n
		if not contains "Niri" $packagesList
			set packagesList $packagesList "Niri"
		else
			set packagesList (string match -v "Niri" $packagesList)
		end
	case F f
		break
	case "" '*'
		slowPrint "Invalid selection made, please enter a valid selection."
	end
end

slowPrint "\n\n~~~~~ Installing Packages ~~~~~\n\n"

for group in $packagesList
	set cmdToRun $cmdToRun (cat $packDir/$group.txt)
end

$cmdToRun

# This script can be used to install just the packages at anytime
if not affirm "Continue to git & ssh setup?"
	slowPrint "\nExiting script..."
	exit 0
end

# Always need these directories and if going past the packages probably need to create them
if not test -d "$HOME/Apps"
	mkdir "$HOME/Apps"
end
if not test -d "$HOME/Repos"
	mkdir "$HOME/Repos"
end

slowPrint "\n\n~~~~~ Git & SSH ~~~~~\n\n"

while true
	read -p "Enter email: " email

	if affirm "Is $email correct?"
		break
	end
end

ssh-keygen -t ed25519 -C "$email"

eval "$(ssh-agent -s)"

ssh-add "$HOME/.ssh/id_ed25519"

slowPrint "This is where you click the link and setup the ssh."
slowPrint "Script cannot continue until git is fully setup."
repeat 2 echo
slowPrint "https://github.com/settings/keys"
repeat 2 echo
slowPrint "Copy following for ssh key:"

repeat 3 echo
slowPrint (cat "$HOME/.ssh/id_ed25519.pub")
repeat 3 echo

read -p "Hit enter after you have connected ssh git to continue..." -r

while true
	slowPrint "Confirm you ACTUALLY OPENED the link and did what you needed to."
	if confirm "I have actually opened the link and added the ssh key."
		break
	end
end

git config --global user.email "$email"

while true
	read -p "Enter git username: " -r guName

	if affirm "Is $guName correct?"
		break
	end
end

git config --global user.name "$guName"

slowPrint "\n\n~~~~~ Config Files ~~~~~\n\n"

cd "$HOME/Repos"

git clone --recursive git@github.com:rienovie/configFiles.git

if not test $status
	slowPrint "Failed to clone configFiles repo for some reason."
	slowPrint "Exiting script..."
	exit 1
end

slowPrint "ConfigFiles repo cloned."

if affirm "Would you like to run the configFiles init script?"
	slowPrint "\n\n~~~~~ Running configFiles init script ~~~~~\n\n"
	cd "configFiles/manage"
	fish init.fish
end

slowPrint "\n\n~~~~~ Arch setup script has finished ~~~~~\n\n"

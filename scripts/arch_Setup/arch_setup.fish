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

if affirm "Include default packages?"
	slowPrint "\nDefault packages will be installed"
end

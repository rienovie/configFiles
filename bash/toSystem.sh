#!/usr/bin/bash

# Made with Basher
# Linux fights against AI!


if [ ! -f "paths.txt" ]; then
	echo "paths.txt not found. Please run script from '{repoRoot}/bash/'"
	exit 1
fi

confirmPrompt() {
	echo "Attempting to link all files to the corresponding directories in .config"
	echo $'\nDirectories to link:'
	cat paths.txt
	echo $'\nThis will DELETE EVERYTHING from the above directories in '"/home/$USER/.config/{LISTED DIRECTORIES} then link all files in $(realpath "../files")/{LISTED DIRECTORIES} to /home/$USER/.config"
	echo $'\nThis will also DELETE EVERYTHING from '"/home/$USER/Scripts then link all files in $(realpath "../scripts") to /home/$USER/Scripts\n"
	echo $'\nsystem config files <<< git repo files.\n'
	read -p "Are you sure you want to continue? [y/N] : " confirmation
	
	case "$confirmation" in
		[yY][eE][sS]|[yY])
			echo $'\nStarting script...\n'
			;;
		[nN][oO]|[nN]|"")
			echo "Script canceled."
			exit 0
			;;
		*)
			echo "$confirmation is an invalid input."
			confirmPrompt
			;;
	esac

}

confirmPrompt

file=$(realpath "paths.txt")
homePath="/home/$USER"
declare -i erCount=0
declare -a erMessages[0]="Error message list:"
erMessage="No error."

cd ..

while read -r line; do
	lineFullPath="$homePath/.config/$line"
	if [ -d "files/$line" ]; then
		echo $'\n'"Directory files/$line was found."
		if [ ! -d "$lineFullPath" ]; then
			((erCount++))
			erMessage="$lineFullPath does not exist, creating..."
			erMessages[$erCount]=$erMessage
			echo $erMessage
			mkdir "$lineFullPath"
		fi
		echo "Clearing $lineFullPath"
		rm -rf $lineFullPath/*
		echo "Linking all from files/$line to $lineFullPath"
		cp -alv files/$line/* $lineFullPath
		echo "$lineFullPath linking finished."
	else
		((erCount++))
		erMessage="Directory files/$line was not found. Skipping."
		erMessages[$erCount]=$erMessage
		echo $erMessage
	fi
done < "$file"

echo $'Config files linked.\nStarting linking of Scripts'


if [ -d "scripts" ]; then
	echo "Directory scripts was found."
	if [ ! -d "$homePath/Scripts" ]; then
		((erCount++))
		erMessage="$homePath/Scripts does not exist, creating..."
		erMessages[$erCount]=$erMessage
		echo $erMessage
		mkdir "$homePath/Scripts"
	fi
	echo "Clearing $homePath/Scripts"
	rm -rf "$homePath/Scripts/*"
	echo "Linking all from Scripts"
	cp -alv scripts/* $homePath/Scripts
	echo "$homePath/Scripts linking finished."
else
	((erCount++))
	erMessage="Directory scripts not found. Skipping."
	erMessages[$erCount]=$erMessage
	echo $erMessage
fi

echo "
Full Script has finished with $erCount errors."

if [ "${#erMessages[*]}" != "1" ]; then
	echo $erMessages
fi

#!usr/bin/bash

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

cd ..

while read -r line; do
	lineFullPath="$homePath/.config/$line"
	if [ -d "files/$line" ]; then
		echo $'\n'"Directory files/$line was found."
		if [ ! -d "$lineFullPath" ]; then
			echo "$lineFullPath does not exist, creating..."
			mkdir "$lineFullPath"
		fi
		echo "Clearing $lineFullPath"
		rm -rf $lineFullPath/*
		echo "Linking all from files/$line to $lineFullPath"
		cp -alv files/$line/* $lineFullPath
		echo "$lineFullPath linking finished."
	else
		echo "Directory files/$line was not found."
		echo "Skipping files/$line."
	fi
done < "$file"

echo "Script finished."

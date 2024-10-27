#!usr/bin/bash

# Made with Basher
# Cats blame everything on Neovim?

if [ ! -f "paths.txt" ]; then
	echo "paths.txt not found. Please run script from '{repoRoot}/bash/'"
	exit 1
fi

confirmPrompt() {
	echo "Attempting to link all files to the corresponding directories in .config"
	echo $'\nDirectories to link:'
	cat paths.txt
	echo $'\nThis will DELETE EVERYTHING from the above directories in '"$(realpath "../files")/{LISTED DIRECTORIES} then link all files in /home/$USER/.config/{LISTED DIRECTORIES} to $(realpath "../files")"
	echo $'\nsystem config files >>> git repo files.\n'
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
	if [ -d "$lineFullPath" ]; then
		echo $'\n'"Directory $lineFullPath was found."
		if [ ! -d "files/$line" ]; then
			echo "files/$line does not exist, creating..."
			mkdir "files/$line"
		fi
		echo "Clearing files/$line"
		rm -rf files/$line/*
		echo "Linking all from $lineFullPath to files/$line"
		cp -alv $lineFullPath/* files/$line
		echo "$line linking finished."
	else
		echo "Directory $lineFullPath was not found."
		echo "Skipping $lineFullPath."
	fi
done < "$file"

echo "Script finished."

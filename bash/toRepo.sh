#!/usr/bin/bash

# Made with Basher
# Cats blame everything on Neovim?

if [ ! -f "paths.txt" ]; then
	echo "paths.txt not found. Please run script from '{repoRoot}/bash/'"
	exit 1
fi

if [ $# -gt 0 ] && [ $1 == "-v" ]; then
	echo "Verbose On"
	cpArgs="-alvr"
else
	echo "Verbose Off"
	cpArgs="-alr"
fi

confirmPrompt() {
	echo $'\n\n        system >>> repo\n\n'
	read -p "Continue? [y/N] : " confirmation
	
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
	if [ -d "$lineFullPath" ]; then
		echo $'\n'"Directory $lineFullPath was found."
		if [ ! -d "files/$line" ]; then
			((erCount++))
			erMessage="files/$line does not exist, creating..."
			erMessages[$erCount]=$erMessage
			echo $erMessage
			mkdir "files/$line"
		fi
		echo "Clearing files/$line"
		rm -rf files/$line/*
		echo "Linking all from $lineFullPath to files/$line"
		cp $cpArgs $lineFullPath/* files/$line
		echo "$line linking finished."
	else
		((erCount++))
		erMessage="Directory $lineFullPath was not found. Skipping."
		erMessages[$erCount]=$erMessage
		echo $erMessage
	fi
done < "$file"

if [ -d "$homePath/Scripts" ]; then
	echo $'\n'"Directory $homePath/Scripts was found."
	if [ ! -d "scripts" ]; then
		((erCount++))
		erMessage="Directory scripts does not exist, creating..."
		erMessages[$erCount]=$erMessage
		echo $erMessage
		mkdir "scripts"
	fi
	echo "Clearing scripts"
	rm -rf scripts/*
	echo "Linking all from $homePath/Scripts to scripts"
	cp $cpArgs $homePath/Scripts/* scripts
	echo "scripts linking finished."
else
	((erCount++))
	erMessage="Directory $homePath/Scripts was not found. Skipping."
	erMessages[$erCount]=$erMessage
	echo $erMessage
fi

if [ -d "$homePath/Music/sounds" ]; then
	echo $'\n'"Directory $homePath/Music/sounds was found."
	if [ ! -d "sounds" ]; then
		((erCount++))
		erMessage="Directory sounds does not exist, creating..."
		erMessages[$erCount]=$erMessage
		echo $erMessage
		mkdir "sounds"
	fi
	echo "Clearing sounds"
	rm -rf sounds/*
	echo "Linking all from $homePath/Music/sounds to sounds"
	cp $cpArgs $homePath/Music/sounds/* sounds
	echo "sounds linking finished."
else
	((erCount++))
	erMessage="Directory $homePath/sounds was not found. Skipping."
	erMessages[$erCount]=$erMessage
	echo $erMessage
fi

echo "
Full Script has finished with $erCount errors."

if [ "${#erMessages[*]}" != "1" ]; then
	echo "${erMessages[*]}"
fi

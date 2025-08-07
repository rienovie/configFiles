#!/usr/bin/bash

if pgrep -x "rofi" > /dev/null; then
	pkill -x "rofi"
else
	THEMES[0]="54"
	THEMES[1]="61"
	THEMES[2]="62"
	THEMES[3]="64"
	THEMES[4]="65"
	THEMES[5]="67"
	THEMES[6]="69"
	THEMES[7]="610"
	THEMES[8]="71"
	THEMES[9]="72"
	THEMES[10]="75"
	THEMES[11]="77"
	THEMES[12]="79"

	CHOSEN=$(echo ${THEMES[RANDOM % 13]})
	TYPE=${CHOSEN:0:1}
	STYLE=${CHOSEN:1}

	dir="$HOME/.config/rofi/launchers/type-$TYPE"
	theme="style-$STYLE"

	## Run
	rofi \
		-show drun \
		-theme ${dir}/${theme}.rasi
fi

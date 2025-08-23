#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Power Menu
#
## Available Styles
#
## style-1   style-2   style-3   style-4   style-5

if pgrep -x "rofi"; then
	killall rofi
	exit 0
fi

# Current Theme
dir="$HOME/.config/rofi/powermenu/type-1"
theme='style-5'

# CMDs
uptime="`uptime -p | sed -e 's/up //g'`"
host=`hostname`

# Options
shutdown=' Shutdown'
reboot=' Reboot'
lock=' Waybar'
suspend=' Kill App'
logout=' Logout'
yes=' Yes'
no=' No'

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "$host" \
		-mesg "Uptime: $uptime" \
		-theme ${dir}/${theme}.rasi \
		-hover-select \
		-me-select-entry "" \
		-me-accept-entry "MousePrimary"
}

#Confirmation Variable
CONFIRM_TYPE="UNSPECIFIED"

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: northeast; anchor: northeast; fullscreen: false; width: 700px; y-offset: 120px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg "Are you sure you wish to $CONFIRM_TYPE?" \
		-theme ${dir}/${theme}.rasi \
		-hover-select \
		-me-select-entry "" \
		-me-accept-entry "MousePrimary"
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
		elif [[ $1 == '--suspend' ]]; then
			mpc -q pause
			amixer set Master mute
			systemctl suspend
		elif [[ $1 == '--logout' ]]; then
			if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
				openbox --exit
			elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
				bspc quit
			elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
				i3-msg exit
			elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
				qdbus org.kde.ksmserver /KSMServer logout 0 0 0
			elif [[ "$DESKTOP_SESSION" == 'hyprland' ]]; then
				hyprctl dispatch exit
			fi
		fi
	else
		exit 0
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		CONFIRM_TYPE="Shutdown"
		run_cmd --shutdown
        ;;
    $reboot)
		CONFIRM_TYPE="Reboot"
		run_cmd --reboot
        ;;
    $lock)
		killall waybar

		waybar

		# if [[ -x '/usr/bin/betterlockscreen' ]]; then
		# 	betterlockscreen -l
		# elif [[ -x '/usr/bin/i3lock' ]]; then
		# 	i3lock
		# fi

        ;;
    $suspend)
		# run_cmd --suspend
		
		hyprctl kill
        ;;
    $logout)
		CONFIRM_TYPE="Logout"
		run_cmd --logout
        ;;
esac

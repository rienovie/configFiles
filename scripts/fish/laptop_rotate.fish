#!/usr/bin/env fish

killall waybar

set config_file "/home/vince/.config/niri/config.kdl"
set current_transform (grep "transform" $config_file | sed 's/.*transform "\(.*\)".*/\1/')

if test "$current_transform" = "normal"
    set new_transform "90"
    waybar -c ~/.config/waybar/laptop_vertical_config.jsonc &
    gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true
else
    set new_transform "normal"
    gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled false
    waybar &
end

sed -i "s/transform \".*\"/transform \"$new_transform\"/" $config_file

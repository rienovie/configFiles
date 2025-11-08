#!/usr/bin/env fish

set currentValue (sed -n 's/center-focused-column "\(.*\)"/\1/p' ~/.config/niri/config.kdl)

echo "Current value is $currentValue"
set currentValue (string trim "$currentValue")
echo "Current value is $currentValue"

if test "$currentValue" = always
    echo "1st if"
    set newText never
else if test "$currentValue" = never
    echo "2nd if"
    set newText always
else
    echo "3rd if"
end

echo "Current value is $currentValue"

sed -i 's/center-focused-column "\(.*\)"/center-focused-column "'$newText'"/' ~/.config/niri/config.kdl

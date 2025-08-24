#!/usr/bin/env fish

set current_brightness (brightnessctl g)
set max_brightness (brightnessctl m)
set current_percent (math "round($current_brightness / $max_brightness * 100)")

if test "$current_percent" -ge 100
    brightnessctl set 75%
else if test "$current_percent" -ge 75
    brightnessctl set 50%
else if test "$current_percent" -ge 50
    brightnessctl set 25%
else if test "$current_percent" -ge 25
    brightnessctl set 0%
else
    brightnessctl set 100%
end
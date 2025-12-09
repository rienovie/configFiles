#!/usr/bin/env bash

percent=$(glxinfo -B | awk '
    /Dedicated video memory:/   { total=$4 }
    /Currently available dedicated video memory:/ { free=$6 }
    END{ printf "%i", ((total-free)/total)*100 }'
)
printf '%s\n' "$percent"


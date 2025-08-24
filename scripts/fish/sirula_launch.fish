#!/usr/bin/env fish

if pgrep -x sirula > /dev/null
    pkill -x sirula
else
    sirula
end
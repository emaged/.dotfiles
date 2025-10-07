#!/usr/bin/env bash

# Launch Polybar on each connected monitor
if type "xrandr"; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        if [ "$m" == "HDMI-0" ]; then
            MONITOR=$m polybar --reload right &
        else
            MONITOR=$m polybar --reload example &
        fi
    done
else
    polybar --reload example &
fi


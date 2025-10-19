#!/bin/sh

# Author: Catppuccin-themed lock screen
# Dependencies: swaylock-effects v1.7+
# Description: Wallpaper on all monitors, ring + clock on middle monitor

# Paths
wallpapers_path="${HOME}/.config/sway/wallpapers/"

# Catppuccin colors
color_bg="00000000"
color_bs_hl="F5E0DC"
color_caps_bs_hl="FAB387"
color_caps_key_hl="A6E3A1"
color_key_hl="A6E3A1"
color_ring="B4Befe"
color_ring_clear="F5E0DC"
color_ring_caps="FAB387"
color_ring_ver="89B4FA"
color_ring_wrong="EBA0AC"
color_text="CDD6F4"
color_text_clear="F5E0DC"
color_text_caps="FAB387"
color_text_ver="89B4FA"
color_text_wrong="EBA0AC"
color_line="00000000"
color_separator="00000000"

# Pick a random wallpaper
wallpaper="$(find "${wallpapers_path}" -type f | shuf -n 1)"

# Only lock if not already running
if ! pgrep -x swaylock > /dev/null; then
    swaylock \
        --image "${wallpaper}" \
        --scaling fill \
        --effect-blur 7x5 \
        --effect-vignette 0.2:0.2 \
        --indicator \
        --clock \
        --timestr "%I:%M %p" \
        --datestr "%b %d, %G" \
        --indicator-caps-lock \
        --indicator-radius 170 \
        --indicator-thickness 15 \
        --bs-hl-color "#${color_bs_hl}" \
        --key-hl-color "#${color_key_hl}" \
        --caps-lock-bs-hl-color "#${color_caps_bs_hl}" \
        --caps-lock-key-hl-color "#${color_caps_key_hl}" \
        --inside-color "#${color_bg}" \
        --inside-clear-color "#${color_bg}" \
        --inside-caps-lock-color "#${color_bg}" \
        --inside-ver-color "#${color_bg}" \
        --inside-wrong-color "#${color_bg}" \
        --line-color "#${color_line}" \
        --line-clear-color "#${color_line}" \
        --line-caps-lock-color "#${color_line}" \
        --line-ver-color "#${color_line}" \
        --line-wrong-color "#${color_line}" \
        --ring-color "#${color_ring}" \
        --ring-clear-color "#${color_ring_clear}" \
        --ring-caps-lock-color "#${color_ring_caps}" \
        --ring-ver-color "#${color_ring_ver}" \
        --ring-wrong-color "#${color_ring_wrong}" \
        --separator-color "#${color_separator}" \
        --text-color "#${color_text}" \
        --text-clear-color "#${color_text_clear}" \
        --text-ver-color "#${color_text_ver}" \
        --text-wrong-color "#${color_text_wrong}" \
        --text-caps-lock-color "#${color_text_caps}"
fi

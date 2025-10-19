#!/usr/bin/env bash
# File: ~/.config/sway/powermenu.sh

THEME_STR='
window {
    width: 20%;
    location: center;
    border: 1px;
    border-radius: 10px;
    padding: 10px;
}
listview {
    lines: 6;
    fixed-height: true;
}
'

# Define menu options with icons
CHOICE=$(echo -e "  Lock\n  Logout\n  Suspend\n  Hibernate\n  Reboot\n  Shutdown" | rofi -dmenu -p "Power Menu" -theme-str "$THEME_STR")

case "$CHOICE" in
    "  Lock")
        ~/.config/swaylock/swaylock_bash.sh 
        ;;
    "  Logout")
        swaymsg exit
        ;;
    "  Suspend")
        ~/.config/swaylock/swaylock_bash.sh &
        systemctl suspend
        ;;
    "  Hibernate")
        ~/.config/swaylock/swaylock_bash.sh & 
        systemctl hibernate
        ;;
    "  Reboot")
        systemctl reboot
        ;;
    "  Shutdown")
        systemctl poweroff
        ;;
esac

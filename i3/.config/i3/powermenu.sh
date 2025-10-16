#!/usr/bin/env bash
# File: ~/.config/i3/powermenu.sh


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
        betterlockscreen -l
        ;;
    "  Logout")
        i3-msg exit
        ;;
    "  Suspend")
        betterlockscreen -l && systemctl suspend
        ;;
    "  Hibernate")
        betterlockscreen -l && systemctl hibernate
        ;;
    "  Reboot")
        systemctl reboot
        ;;
    "  Shutdown")
        systemctl poweroff
        ;;
esac

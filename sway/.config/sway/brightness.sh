#!/bin/sh

# displays you have
DISPLAYS=$(ddcutil detect 2>/dev/null | awk '/^Display / {print $2}')

# read brightness from first display
CURRENT=$(ddcutil getvcp 10 --display 1 | awk -F'=' '{print $2}' | awk -F',' '{print $1}')

if [ "$CURRENT" -gt 50 ]; then
  TARGET=0
else
  TARGET=100
fi

for d in $DISPLAYS; do
  ddcutil setvcp 10 $TARGET --display $d
done

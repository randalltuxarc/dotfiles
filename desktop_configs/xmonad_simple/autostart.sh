#!/bin/bash
# simple autostart scripts for xmonad

## Run compton effect composite
# compton -cCfb -D 4 -r 5 -l -5 -t -2 -o 0.2 -e 0.6 &

## Run thunar daemon
thunar --daemon &

## Detect and Configure touchpad
if egrep iq 'touchpad' /proc/bus/input/devices;
then
    synclient VertEdgeScroll=1 &
    synclient TapButton1=1 &
fi

## Set keyboard settings - 250 ms delay and 25 cps (characters per second) repeat rate.
## Adjust the values according to your preferences
xset r rate 250 25 &

##

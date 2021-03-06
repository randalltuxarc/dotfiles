#!/bin/bash

# this is a simple config for herbstluftwm

hc() {
    herbstclient "$@"
}

hc emit_hook reload
#nitrogen --restore &

# remove all existing keybindings
hc keyunbind --all

# keybindings
Mod=Mod4    # Use alt as the main modifier

#herbstclient load ${TAG_NAMES[0]} '(clients max:0)'

# tags
# TAG_NAMES=( {1..9} )
TAG_NAMES=( h e r b s t )
TAG_KEYS=( {1..9} 0 )

hc rename default "${TAG_NAMES[0]}" || true
for i in ${!TAG_NAMES[@]} ; do
    hc add "${TAG_NAMES[$i]}"
    key="${TAG_KEYS[$i]}"
    if ! [ -z "$key" ] ; then
        hc keybind "$Mod-$key" use "${TAG_NAMES[$i]}"
        hc keybind "$Mod-Shift-$key" move "${TAG_NAMES[$i]}"
    fi
done

# applications keybinds
hc keybind $Mod-Shift-p spawn dmenu_run -b
hc keybind $Mod-Shift-t spawn thunar
hc keybind $Mod-Shift-g spawn google-chrome-stable
hc keybind $Mod-Shift-Return spawn urxvt

# system keybinds
hc keybind $Mod-Shift-q quit
hc keybind $Mod-Shift-r reload
hc keybind $Mod-Shift-c close

# gaps
hc keybind $Mod-section pad 0 16 0 0
hc keybind $Mod-apostrophe pad 0 0 0 0

# xcmenu aka. loliclip
hc keybind Control-adiaeresis spawn xcmenuctrl
hc keybind Control-odiaeresis spawn lolimpdnu

# herbstluftwm layout manager
hc keybind Control-section spawn ~/bin/hlwm_lm.sh load
hc keybind Control-apostrophe spawn ~/bin/hlwm_lm.sh save

# focusing clients
hc keybind $Mod-j     focus left
hc keybind $Mod-k     focus down
hc keybind $Mod-i     focus up
hc keybind $Mod-l     focus right

# moving clients
hc keybind $Mod-Shift-Left  shift left
hc keybind $Mod-Shift-Down  shift down
hc keybind $Mod-Shift-Up    shift up
hc keybind $Mod-Shift-Right shift right
hc keybind $Mod-Shift-h     shift left
hc keybind $Mod-Shift-j     shift down
hc keybind $Mod-Shift-k     shift up
hc keybind $Mod-Shift-l     shift right

# splitting frames
# create an empty frame at the specified direction
hc keybind $Mod-w       split   bottom  0.5
hc keybind $Mod-q       split   right   0.5
# let the current frame explode into subframes
hc keybind $Mod-e split explode

# resizing frames
resizestep=0.01
hc keybind Control-j		resize left +$resizestep
hc keybind Control-k		resize down +$resizestep
hc keybind Control-i		resize up +$resizestep
hc keybind Control-l		resize right +$resizestep
hc keybind $Mod-Control-Left    resize left +$resizestep
hc keybind $Mod-Control-Down    resize down +$resizestep
hc keybind $Mod-Control-Up      resize up +$resizestep
hc keybind $Mod-Control-Right   resize right +$resizestep

# cycle through tags
hc keybind $Mod-adiaeresis use_index +1 --skip-visible
hc keybind $Mod-odiaeresis use_index -1 --skip-visible

# layouting
hc keybind $Mod-r remove
hc keybind $Mod-Shift-Tab cycle_layout 1
hc keybind $Mod-Shift-f floating toggle
hc keybind $Mod-Shift-m fullscreen toggle
hc keybind $Mod-Shift-p pseudotile toggle

# mouse
#hc mouseunbind --all
hc mousebind $Mod-Button1 move
hc mousebind $Mod-Button2 zoom
hc mousebind $Mod-Button3 resize

# focus
hc keybind Control-period   cycle_monitor
hc keybind $Mod-Tab         cycle_all +1
hc keybind $Mod-Shift-Tab   cycle_all -1
hc keybind $Mod-c cycle
hc keybind $Mod-u jumpto urgent

# colors
hc set frame_border_active_color '#303030'
hc set frame_border_normal_color '#1f1f22'
hc set frame_bg_active_color '#303033'
hc set frame_bg_normal_color '#1f1f22'
hc set window_border_active_color '#303033'
hc set window_border_normal_color '#1f1f22'
hc set window_border_urgent_color '#4cdcd4'
hc set frame_border_width 2
hc set window_border_width 1
hc set window_border_inner_width 0
hc set always_show_frame 0
hc set frame_gap 0
hc set frame_bg_transparent 1

# add overlapping window borders
hc set window_gap 0
hc set frame_padding 0
hc set smart_window_surroundings 0
hc set smart_frame_surroundings 1
hc set mouse_recenter_gap 0

# rules
hc unrule -F
#hc rule class=XTerm tag=3 # move all xterms to tag 3
hc rule focus=on # normally do not focus new clients
# give focus to most common terminals
hc rule class~'(.*[Rr]xvt.*|.*[Tt]erm|Konsole)' focus=on
hc rule windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' pseudotile=on
hc rule windowtype='_NET_WM_WINDOW_TYPE_DIALOG' focus=on
hc rule windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK)' manage=off

hc rule class=Dwb tag=term focus=on
hc rule class=mpv tag=term focus=on
hc rule class=wine tag=term focus=on

# unlock, just to be sure
hc unlock

herbstclient set tree_style '╾│ ├└╼─┐'

# do multi monitor setup here, e.g.:
#hc set_monitors 1280x1024+0+0 1920x1080+1280+0
# or simply:
hc detect_monitors

## panel for main monitor -- ignore second monitor
# hc pad 0 14 0 0 0

# find the panel
panel=~/.config/herbstluftwm/panel.sh
[ -x "$panel" ] || panel=/etc/xdg/herbstluftwm/panel.sh
for monitor in $(herbstclient list_monitors | cut -d: -f1) ; do
    # start it on each monitor
    "$panel" &
done
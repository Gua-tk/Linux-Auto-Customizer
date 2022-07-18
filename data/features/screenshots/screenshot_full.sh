#!/usr/bin/env bash
mkdir -p "€{XDG_PICTURES_DIR}/screenshots"
screenshotname="Screenshot-$(date +%Y-%m-%d-%H:%M:%S).png"
gnome-screenshot -f "€{XDG_PICTURES_DIR}/screenshots/${screenshotname}" && xclip -in -selection clipboard -target image/png "€{XDG_PICTURES_DIR}/screenshots/$screenshotname" && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga
unset screenshotname

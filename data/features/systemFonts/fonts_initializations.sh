#!/usr/bin/env bash
# Check if gsettings command is available
if ! command -v gsettings &> /dev/null
then
  return
fi

# Interface text
gsettings set org.gnome.desktop.interface font-name 'Roboto Medium 11'
# Document text //RF
gsettings set org.gnome.desktop.interface document-font-name 'Fira Code weight=453 10'
# Monospaced text
gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Regular 12'
# Inherited window titles
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Hermit Bold 9'

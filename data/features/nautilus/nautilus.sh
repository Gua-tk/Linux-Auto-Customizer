#!/usr/bin/env bash
# Check if xdg-mime command is available
if ! command -v xdg-mime &> /dev/null
then
  return
fi

xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search
xdg-mime default org.gnome.Nautilus.desktop inode/directory

# Check if gsettings command is available
if ! command -v gsettings &> /dev/null
then
  return
fi

gsettings set org.gnome.desktop.background show-desktop-icons true

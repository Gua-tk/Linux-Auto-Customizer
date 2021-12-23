
# Check if gsettings command is available
if ! command -v gsettings &> /dev/null
then
  return
fi

xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search
gsettings set org.gnome.desktop.background show-desktop-icons true
xdg-mime default org.gnome.Nautilus.desktop inode/directory


# Check if gsettings command is available
if ! command -v gsettings &> /dev/null
then
  return
fi

profile_uuid="$(gsettings get org.gnome.Terminal.ProfilesList default | cut -d "'" -f2)"
if [ -n "${profile_uuid}" ]; then
  # make sure the profile is set to not use theme colors
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/ use-theme-colors false # --> Don't use system color theme

  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/ use-transparent-background true
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/ background-transparency-percent "10"

  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/ bold-color "#6E46A4"
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/ background-color "#282A36"
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/ foreground-color "#F8F8F2"

  ##############################################################################################################################grey#######pink#######green######yellow#####purple#####red#######cyan#######orange####lighgrey##lightpink##lightgreen#lightyellow#lightpurple#lightred#lightcyan##lightorange
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_uuid}/ palette "['#262626', '#E356A7', '#42E66C', '#E4F34A', '#9B6BDF', '#E64747', '#75D7EC', '#EFA554', '#7A7A7A', '#FF79C6', '#50FA7B', '#F1FA8C', '#BD93F9', '#FF5555', '#8BE9FD', '#FFB86C']"

  # Cursor like in a text editor
  gsettings set org.gnome.Terminal.Legacy.Profile:/:"${profile_uuid}"/ cursor-shape 'ibeam'
  
  unset profile_uuid
else
  echo "ERROR, non terminal default profile list found"
fi

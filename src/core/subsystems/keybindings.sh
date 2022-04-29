# https://askubuntu.com/questions/597395/how-to-set-custom-keyboard-shortcuts-from-terminal
# - Description: This function is the basic piece of the keybinding subsystem, but is not a function that it is
# executed directly, instead, is put in the bashrc and reads the file $PROGRAM_KEYBINDINGS_PATH every time a terminal
# is invoked. This function and its necessary files such as $PROGRAM_KEYBINDINGS_PATH are always present during the
# execution of install. Also, for simplicity, we consider that each keybinding
# This function basically processes and applies the results of the call to add_custom_keybinding function.
# - Permissions: This function is executed always as user since it is integrated in the user .bashrc. The function
# add_custom_keybinding instead, can be called as root or user, so root and user executions can be added

# Name, Command, Binding...
# 1st argument Name of the feature
# 2nd argument Command of the feature
# 3rd argument Bind Key Combination of the feature ex(<Primary><Alt><Super>a)
# 4th argument Number of the feature array position slot of the added custom command (custom0, custom1, custom2...)

# Check if gsettings command is available
if ! command -v gsettings &> /dev/null
then
  return
fi

if ! gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings &> /dev/null; then
  return
fi


# Check if there are keybindings available
if [ -f "€{PROGRAM_KEYBINDINGS_PATH}" ]; then
  # regenerate list of active keybindings
  declare -a active_keybinds="$(echo "$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)" | sed 's/@as //g' | tr -d "," | tr "[" "(" | tr "]" ")" | tr "'" "\"")"

  # Every iteration is a line. IFS (internal field separator) set to empty
  while IFS= read -r line; do
    if [ -z "$line" ]; then
      continue
    fi
    field_command="$(echo "${line}" | cut -d ";" -f1)"
    field_binding="$(echo "${line}" | cut -d ";" -f2)"
    field_name="$(echo "${line}" | cut -d ";" -f3)"

    i=0
    isInstalled=0
    # while custom keybinding i is occupied... try to update custom keybinding i if the keybinding to add and the one in position i have same name
    while [ -n "$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ name | cut -d "'" -f2)" ]; do
      # Overwrite keybinding if there is a collision in the name with previous defined keybindings
      if [ "${field_name}" == "$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ name | tr -d "'")" ]; then
        # Overwrite
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ command "'${field_command}'"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ binding "'${field_binding}'"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ name "'${field_name}'"
        # Make sure that the keybinding data that we just uploaded is active
        isActive=0
        for active_keybind in ${active_keybinds[@]}; do
          if [ "${active_keybind}" == "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/" ]; then
            # The updated keybinding is active, mark as active to avoid further processing and escape the inner loop
            isActive=1
            break
          fi
        done
        # If is not active, active it by adding to the activated keybindings array
        if [ ${isActive} == 0 ]; then
          active_keybinds+=(/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/)
        fi
        # The keybind data was already in the table, no need for occupying a new custom keybind. Mark as installed to avoid post processing and escape de loop
        isInstalled=1
        break
      fi
      i=$((i+1))
    done
    if [ ${isInstalled} == 0 ]; then
      # No collision: This is a new keybind. Append new keybinding data in a non occupied custom keybinding in position i, which at this point is empty
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ command "'${field_command}'"
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ binding "'${field_binding}'"
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/ name "'${field_name}'"
      # Make sure that the keybinding data that we just uploaded is active
      isActive=0
      for active_keybind in ${active_keybinds[@]}; do
        if [ "${active_keybind}" == "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/" ]; then
          isActive=1
          break
        fi
      done
      # If is not active, active it by adding to the activated keybindings array
      if [ ${isActive} == 0 ]; then
        active_keybinds+=(/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/)
      fi
    fi
  done < "€{PROGRAM_KEYBINDINGS_PATH}"
  # Build string for gsettings set for the active custom keybindings from the array of active keybinds that we have been building
  active_keybinds_str="["
  for active_keybind in ${active_keybinds[@]}; do
    active_keybinds_str+="'${active_keybind}', "
  done
  # remove last comma and add the ] to close the array
  active_keybinds_str="$(echo "${active_keybinds_str}" | sed 's/, $//g')]"

  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "${active_keybinds_str}"
  #echo "gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "${active_keybinds_str}" "
fi
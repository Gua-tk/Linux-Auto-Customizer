# - Description: This functions is the basic piece of the favorites subsystem, but is not a function that it is
# executed directly, instead, is put in the bashrc and reads the file $PROGRAM_FAVORITES_PATH every time a terminal
# is invoked. This function and its necessary files such as $PROGRAM_FAVORITES_PATH are always present during the
# execution of install.
# This function basically processes and applies the results of the call to add_to_favorites function.
# - Permissions: This function is executed always as user since it is integrated in the user .bashrc. The function
# add_to_favorites instead, can be called as root or user, so root and user executions can be added

# Check if gsettings command is available
if ! command -v gsettings &> /dev/null
then
  return
fi

if [ -f "€{PROGRAM_FAVORITES_PATH}" ]; then
  while IFS= read -r line; do
    favorite_apps="$(gsettings get org.gnome.shell favorite-apps)"
    if [ -z "$(echo "${favorite_apps}" | grep -Fo "$line")" ]; then
      if [ -z "$(echo "${favorite_apps}" | grep -Fo "[]")" ]; then
        # List with at least an element
        # shellcheck disable=SC2001
        gsettings set org.gnome.shell favorite-apps "$(echo "${favorite_apps}" | sed s/.$//), '$line']"
      else
        # List empty
        gsettings set org.gnome.shell favorite-apps "['$line']"
      fi
    fi
  done < "€{PROGRAM_FAVORITES_PATH}"
fi
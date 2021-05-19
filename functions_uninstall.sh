########################################################################################################################
# - Name: Linux Auto-Customizer exclusive functions of uninstall.sh.                                                   #
# - Description: Set of functions used exclusively in uninstall.sh. Most of these functions are combined into other    #
# higher-order functions to provide the generic uninstallation of a feature.                                           #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 16/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernández Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: This script can not be executed directly, only sourced to import its functions and process its own    #
# imports. See the header of each function to see its privilege requirements                                           #
# - Arguments: No arguments                                                                                            #
# - Usage: Sourced from install.sh                                                                                     #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


# - [ ] Add special func in `uninstall` that uninstalls the file structures that the customizer creates (~/.bash_functions, ~/.bin, etc.) That cannot be removed directly using uninstall
purge_all_features()
{
  # Remove the contents of USR_BIN_FOLDER
  rm -Rf "${USR_BIN_FOLDER}"
  # Remove links in path
  for filename in ${ls "${DIR_IN_PATH}"}; do
    if [[ ! -e "${DIR_IN_PATH}/filename" ]]; then
      rm -f "${DIR_IN_PATH}/filename"
    fi
  done
}

# - [ ] Program function in `uninstall.sh` to remove bash functions
# - Argument 1: Name of the filename sourced by own .bash_functions of customizer
remove_bash_function()
{
  sed "s@source ${BASH_FUNCTIONS_FOLDER}/$1\$@@g" -i ${BASH_FUNCTIONS_PATH}
  rm -f "${BASH_FUNCTIONS_FOLDER}/$1"
}

# - [ ] Program function to remove desktop icons from the bar's favorite in `uninstall.sh`
remove_from_favorites()
{
  if [[ ${EUID} -eq 0 ]]; then
    # This code search and export the variable DBUS_SESSIONS_BUS_ADDRESS for root access to gsettings and dconf
    if [[ -z ${DBUS_SESSION_BUS_ADDRESS+x} ]]; then
      user=$(whoami)
      fl=$(find /proc -maxdepth 2 -user $user -name environ -print -quit)
      while [ -z $(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2- | tr -d '\000' ) ]
      do
        fl=$(find /proc -maxdepth 2 -user $user -name environ -newer "$fl" -print -quit)
      done
      export DBUS_SESSION_BUS_ADDRESS="$(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2-)"
    fi
  fi
  if [[ -z $(echo "$(gsettings get org.gnome.shell favorite-apps)" | grep -Fo "$1.desktop") ]]; then
    output_proxy_executioner "echo WARNING: $1 is not in favourites of the task-bar, so cannot be removed. Skipping..." ${FLAG_QUIETNESS}
  else
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s@'google-chrome.desktop'@@g" | sed "s@, ,@,@g" | sed "s@\[, @[@g" | sed "s@, \]@]@g" | sed "s@@@g"sed "s@, \]@]@g")"
  fi
}

# - [ ] Program function to unregister default opening applications on `uninstall.sh`
# First argument: name of the .desktop whose associations will be removed
remove_file_associations()
{
  if [[ -f "${MIME_ASSOCIATION_PATH}" ]]; then
    if [[ ! -z "${MIME_ASSOCIATION_PATH}" ]]; then
      sed "s@^.*=$1@@g" -i "${MIME_ASSOCIATION_PATH}"
    fi
  else
    output_proxy_executioner "echo WARNING: ${MIME_ASSOCIATION_PATH} is not present, so $1 cannot be removed from favourites. Skipping..." ${FLAG_QUIETNESS}
  fi
}

# - Argument 1: program unified name
remove_manual_feature()
{
  rm -Rf "${USR_BIN_FOLDER}/$1"
  rm -f "${DIR_IN_PATH}/$1"
  rm -f "${XDG_DESKTOP_DIR}/$1.desktop"
  rm -f "${PERSONAL_LAUNCHERS_DIR}/$1.desktop"
  rm -f "${BASH_FUNCTIONS_FOLDER}/$1.sh"

  remove_bash_function "$1"
}

if [[ -f "${DIR}/functions_common.sh" ]]; then
  source "${DIR}/functions_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_common.sh not found. Aborting..."
  exit 1
fi

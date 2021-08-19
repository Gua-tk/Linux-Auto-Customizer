#!/usr/bin/env bash
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

########################################################################################################################
############################################## UNINSTALL API FUNCTIONS #################################################
########################################################################################################################

# - Description: Removes a bash feature from the environment by removing its bash script from $FUNCTIONS_FOLDER and its
#   import line from $FUNCTIONS_PATH file.
# - Permissions: Can be called as root or as normal user presumably with the same behaviour.
# - Argument 1: Name of the bash script file in $FUNCTIONS_FOLDER.
remove_bash_function()
{
  sed "s@^source \"${FUNCTIONS_FOLDER}/$1\"\$@@g" -i "${FUNCTIONS_PATH}"
  rm -f "${FUNCTIONS_FOLDER}/$1"
}


# - Description: Removes a bash feature from the environment by removing its bash script from $INITIALIZATIONS_FOLDER
#   and its import line from $INITIALIZATIONS_PATH file.
# - Permissions: Can be called as root or as normal user presumably with the same behaviour.
# - Argument 1: Name of the bash script file in $INITIALIZATIONS_FOLDER.
remove_bash_initialization() {
  sed "s@^source \"${INITIALIZATIONS_FOLDER}/$1\"\$@@g" -i "${INITIALIZATIONS_PATH}"
  rm -f "${INITIALIZATIONS_FOLDER}/$1"
}


# - Description: Removes keybinding by removing its data from PROGRAM_KEYBINDINGS_PATH. This feeds the input for
#   keybinding subsystem, which is used to update the taskbar favorite elements on system start.
# - Permissions: can be executed indifferently as root or user.
# - Argument 1: Keybinding data to be removed
remove_keybinding() {
    sed "s@^$1\$@@g" -i "${PROGRAM_KEYBINDINGS_PATH}"
}


# - Description: Removes a program from the taskbar by using the favorites subsystem. This subsystem is executed in
#   every log in to update the favorite programs in the taskbar.
#   This is done by writing in PROGRAM_FAVORITES_PATH, which is the file used to feed this subsystem.
# - Permissions: This functions can be called indistinctly as root or user.
# - Argument 1: Name of the .desktop launcher without .desktop extension to be removed from $PROGRAM_FAVORITES_PATH.
remove_favorite() {
  sed "s@^${1}.desktop\$@@g" -i "${PROGRAM_FAVORITES_PATH}"
}


# - Description: Removes launcher that is making a program autostart. This is accomplished by removing the desktop
#   launcher from $AUTOSTART_FOLDER, which is used by the operating system to read its autostart programs.
# - Permissions: This function can be called as root or as user.
# - Argument 1: Name of the .desktop launcher to be removed without the '.desktop' extension.
remove_autostart_program() {
  rm -f "${AUTOSTART_FOLDER}/$1.desktop"
}


# - [ ] Program function to unregister default opening applications on `uninstall.sh`
# First argument: name of the .desktop whose associations will be removed
remove_file_associations()
{
  if [ -f "${MIME_ASSOCIATION_PATH}" ]; then
    if [ -n "${MIME_ASSOCIATION_PATH}" ]; then
      sed "s@^.*=$1@@g" -i "${MIME_ASSOCIATION_PATH}"
    fi
  else
    output_proxy_executioner "echo WARNING: ${MIME_ASSOCIATION_PATH} is not present, so $1 cannot be removed from favourites. Skipping..." "${FLAG_QUIETNESS}"
  fi
}






# - Argument 1: program unified name
remove_manual_feature()
{
  rm -Rf "${BIN_FOLDER:?}/$1"
  rm -f "${PATH_POINTED_FOLDER}/$1"
  rm -f "${XDG_DESKTOP_DIR}/$1.desktop"
  rm -f "${PERSONAL_LAUNCHERS_DIR}/$1.desktop"
  rm -f "${FUNCTIONS_FOLDER}/$1.sh"

  remove_bash_function "$1"
}




if [ -f "${DIR}/functions_common.sh" ]; then
  source "${DIR}/functions_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_common.sh not found. Aborting..."
  exit 1
fi


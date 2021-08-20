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
  remove_line "^source \"${FUNCTIONS_FOLDER}/$1\"\$" "${FUNCTIONS_PATH}"
  remove_file "${FUNCTIONS_FOLDER}/$1"
}


# - Description: Removes a bash feature from the environment by removing its bash script from $INITIALIZATIONS_FOLDER
#   and its import line from $INITIALIZATIONS_PATH file.
# - Permissions: Can be called as root or as normal user presumably with the same behaviour.
# - Argument 1: Name of the bash script file in $INITIALIZATIONS_FOLDER.
remove_bash_initialization() {
  remove_line "^source \"${INITIALIZATIONS_FOLDER}/$1\"\$" "${INITIALIZATIONS_PATH}"
  remove_file "${INITIALIZATIONS_FOLDER}/$1"
}


# - Description: Removes keybinding by removing its data from PROGRAM_KEYBINDINGS_PATH. This feeds the input for
#   keybinding subsystem, which is used to update the taskbar favorite elements on system start.
# - Permissions: can be executed indifferently as root or user.
# - Argument 1: Keybinding data to be removed
remove_keybinding() {
    remove_line "^$1\$" "${PROGRAM_KEYBINDINGS_PATH}"
}


# - Description: Function to delete a concrete line of a file.
# - Permissions: can be executed indifferently as root or user.
# - Argument 1: Text to be removed.
# - Argument 2: Path to the file which contains the text to be removed.
remove_line() {
  if [ -f "$2" ]; then
    sed -i "^$1\$/d" "$2"
  else
    output_proxy_executioner "echo WARNING: file $2 is not present, so the text $1 cannot be removed from the file. Skipping..." "${FLAG_QUIETNESS}"
  fi
}


# - Description: Removes a program from the taskbar by using the favorites subsystem. This subsystem is executed in
#   every log in to update the favorite programs in the taskbar.
#   This is done by writing in PROGRAM_FAVORITES_PATH, which is the file used to feed this subsystem.
# - Permissions: This functions can be called indistinctly as root or user.
# - Argument 1: Name of the .desktop launcher without .desktop extension to be removed from $PROGRAM_FAVORITES_PATH.
remove_favorite() {
  remove_line "^$1.desktop\$" "${PROGRAM_FAVORITES_PATH}"
}


# - Description: Removes launcher that is making a program autostart. This is accomplished by removing the desktop
#   launcher from $AUTOSTART_FOLDER, which is used by the operating system to read its autostart programs.
# - Permissions: This function can be called as root or as user.
# - Argument 1: Name of the .desktop launcher to be removed without the '.desktop' extension.
remove_autostart_program() {
  remove_file "${AUTOSTART_FOLDER}/$1.desktop"
}


# - Description: Removes file from system
# - Permissions: This function can be called as root or as user.
# - Argument 1: Absolute path of the file to be removed
remove_file() {
  rm -f "$1"
}


# - Description: Remove folder from system
# - Permissions: This function can be called as root or as user.
# - Argument 1: Absolute path of folder to be removed
remove_folder() {
  rm -Rf "$1"
}


# - Description: Remove launcher from system
# - Permissions: This function can be called as root or as user.
# - Argument 1: Absolute path of folder to be removed
remove_copied_launcher() {
  if [ ${EUID} == 0 ]; then
    remove_file "${ALL_USERS_LAUNCHERS_DIR}/$1"
  fi
  remove_file "${XDG_DESKTOP_DIR}/$1"
}


# - Description: Remove links from path pointed folder.
# - Permissions: This function can be called as root or as user.
# - Argument 1: Name of the command
remove_links_in_path() {
  if [ -f "${PATH_POINTED_FOLDER}/$1" ]; then
    remove_file "${PATH_POINTED_FOLDER}/$1"
  else
    remove_file "${ALL_USERS_PATH_POINTED_FOLDER}/$1"
  fi
}


# - Description: Removes manual launchers.
# - Permissions: This function can be called as root or as user.
# - Argument 1: Launcher name.
remove_manual_launcher() {
  if [ ${EUID} == 0 ]; then  # root
    remove_file "${ALL_USERS_LAUNCHERS_DIR}/$1"
  else
    remove_file "${PERSONAL_LAUNCHERS_DIR}/$1"
  fi
  remove_file "${XDG_DESKTOP_DIR}/$1"
}


# - [ ] Program function to unregister default opening applications on `uninstall.sh`
# First argument: name of the .desktop whose associations will be removed
remove_file_associations()
{
  if [ -f "${MIME_ASSOCIATION_PATH}" ]; then
    if [ -n "${MIME_ASSOCIATION_PATH}" ]; then
      remove_line "^.*=$1" "${MIME_ASSOCIATION_PATH}"
    fi
  else
    output_proxy_executioner "echo WARNING: ${MIME_ASSOCIATION_PATH} is not present, so $1 cannot be removed from favourites. Skipping..." "${FLAG_QUIETNESS}"
  fi
}


########################################################################################################################
#################################### GENERIC UNINSTALL FUNCTIONS - OPTIONAL PROPERTIES #################################
########################################################################################################################

generic_uninstall_launchers() {
  :
}

generic_uninstall_functions() {
  :
}

generic_uninstall_favorites() {
  :
}

generic_uninstall_file_associations() {
  :
}

generic_uninstall_keybindings() {
  :
}

generic_uninstall_downloads() {
  :
}

generic_uninstall_autostart() {
  :
}

generic_uninstall_pathlinks() {
  :
}

generic_uninstall_files() {
  :
}

generic_uninstall_copy_launcher() {
  :
}

generic_uninstall_initializations() {
  :
}

########################################################################################################################
#################################### GENERIC UNINSTALL FUNCTIONS - INSTALLATION TYPES ##################################
########################################################################################################################

pythonvenv_uninstallation_type() {
  :
}

repositoryclone_uninstallation_type() {
  :
}

rootgeneric_uninstallation_type() {
  :
}

userinherit_uninstallation_type() {
  :
}


########################################################################################################################
################################################## GENERIC UNINSTALL ###################################################
########################################################################################################################

# - Description: Installs a user program in a generic way relying on variables declared in data_features.sh and the name
#   of a feature. The corresponding data has to be declared following the pattern %FEATURENAME_%PROPERTIES. This is
#   because indirect expansion is used to obtain the data to install each feature of a certain program to install.
#   Depending on the properties set, some subfunctions will be activated to install related features.
#   Also performs the manual execution of paths of the feature and calls generic functions to install the common
#   part of the features such as desktop launchers, sourced .bashrc functions...
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the necessary variables such as $1_installationtype and the
#   name of the first argument in the common_data.sh table
generic_uninstall() {
  # Substitute dashes for underscores. Dashes are not allowed in variable names
  local -r featurename="${1//-/_}"
  local -r installationtype=${featurename}_installationtype
  local -r manualcontentavailable="$1_manualcontentavailable"
  if [ -n "${!installationtype}" ]; then
    if [ "$(echo "${!manualcontentavailable}" | cut -d ";" -f1)" == "1" ]; then
      "uninstall_$1_pre"
    fi
    case ${!installationtype} in
      # Using package manager such as apt-get
      packagemanager)
        rootgeneric_uninstallation_type "${featurename}" packagemanager
      ;;
      # Downloading a package and installing it using a package manager such as dpkg
      packageinstall)
        rootgeneric_uninstallation_type "${featurename}" packageinstall
      ;;
      # Download and decompress a file that contains a folder
      userinherit)
        userinherit_uninstallation_type "${featurename}"
      ;;
      # Clone a repository
      repositoryclone)
        repositoryclone_uninstallation_type "${featurename}"
      ;;
      # Create a virtual environment to install the feature
      pythonvenv)
        pythonvenv_uninstallation_type "${featurename}"
      ;;
      # Only uses the common part of the generic installation
      environmental)
        : # no-op
      ;;
      *)
        output_proxy_executioner "echo ERROR: ${!installationtype} is not a recognized installation type" "${FLAG_QUIETNESS}"
        exit 1
      ;;
    esac
    if [ "$(echo "${!manualcontentavailable}" | cut -d ";" -f2)" == "1" ]; then
      "uninstall_$1_mid"
    fi

    generic_install_downloads "${featurename}"
    generic_install_files "${featurename}"
    generic_install_launchers "${featurename}"
    generic_install_copy_launcher "${featurename}"
    generic_install_functions "${featurename}"
    generic_install_initializations "${featurename}"
    generic_install_autostart "${featurename}"
    generic_install_favorites "${featurename}"
    generic_install_file_associations "${featurename}"
    generic_install_keybindings "${featurename}"
    generic_install_pathlinks "${featurename}"


    if [ "$(echo "${!manualcontentavailable}" | cut -d ";" -f3)" == "1" ]; then
      "install_$1_post"
    fi
  fi
}

if [ -f "${DIR}/functions_common.sh" ]; then
  source "${DIR}/functions_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_common.sh not found. Aborting..."
  exit 1
fi


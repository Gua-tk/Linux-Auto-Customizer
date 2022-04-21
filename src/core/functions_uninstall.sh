#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer exclusive functions of uninstall.sh.                                                   #
# - Description: Set of functions used exclusively in uninstall.sh. Most of these functions are combined into other    #
# higher-order functions to provide the generic uninstallation of a feature.                                           #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 16/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: aleix.marine@estudiants.urv.cat                                                                             #
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
  remove_line "source \"${FUNCTIONS_FOLDER}/$1\"" "${FUNCTIONS_PATH}"
  remove_file "${FUNCTIONS_FOLDER}/$1"
}


# - Description: Removes a bash feature from the environment by removing its bash script from $INITIALIZATIONS_FOLDER
#   and its import line from $INITIALIZATIONS_PATH file.
# - Permissions: Can be called as root or as normal user presumably with the same behaviour.
# - Argument 1: Name of the bash script file in $INITIALIZATIONS_FOLDER.
remove_bash_initialization() {
  remove_line "source \"${INITIALIZATIONS_FOLDER}/$1\"" "${INITIALIZATIONS_PATH}"
  remove_file "${INITIALIZATIONS_FOLDER}/$1"
}


# - Description: Removes keybinding by removing its data from PROGRAM_KEYBINDINGS_PATH. This feeds the input for
#   keybinding subsystem, which is used to update the taskbar favorite elements on system start.
# - Permissions: can be executed indifferently as root or user.
# - Argument 1: Keybinding data to be removed
remove_keybinding() {
    remove_line "$1" "${PROGRAM_KEYBINDINGS_PATH}"
}


# - Description: Removes a program from the taskbar by using the favorites subsystem. This subsystem is executed in
#   every log in to update the favorite programs in the taskbar.
#   This is done by writing in PROGRAM_FAVORITES_PATH, which is the file used to feed this subsystem.
# - Permissions: This functions can be called indistinctly as root or user.
# - Argument 1: Name of the .desktop launcher without .desktop extension to be removed from $PROGRAM_FAVORITES_PATH.
remove_favorite() {
  remove_line "$1" "${PROGRAM_FAVORITES_PATH}"
}


# - Description: Removes launcher that is making a program autostart. This is accomplished by removing the desktop
#   launcher from $AUTOSTART_FOLDER, which is used by the operating system to read its autostart programs.
# - Permissions: This function can be called as root or as user.
# - Argument 1: Name of the .desktop launcher to be removed without the '.desktop' extension.
remove_autostart_program() {
  remove_file "${AUTOSTART_FOLDER}/$1"
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
    # We leave a dangling link in path unremoved if a feature has been installed as root but uninstalled as user.
    # We can not change the permissions of a symlink in order to allow uninstall as user a posteriori remove the symlink
    if [ ${EUID} == 0 ]; then  # root
      remove_file "${ALL_USERS_PATH_POINTED_FOLDER}/$1"
    fi
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
      remove_line ".*=$1" "${MIME_ASSOCIATION_PATH}"
    fi
  else
    output_proxy_executioner "echo WARNING: ${MIME_ASSOCIATION_PATH} is not present, so $1 cannot be removed from favourites. Skipping..." "${FLAG_QUIETNESS}"
  fi
}


remove_all_favorites() {
  remove_file "${PROGRAM_FAVORITES_PATH}"
}


remove_all_keybindings() {
  remove_file "${PROGRAM_KEYBINDINGS_PATH}"
}


remove_all_functions() {
  remove_file "${FUNCTIONS_PATH}"
}


remove_all_initializations() {
  remove_file "${INITIALIZATIONS_PATH}"
}


# - Description: Removes all structures customizer has installed.
# - Permissions: This function can be called as root or as user.
remove_structures() {
  remove_folder "${CUSTOMIZER_FOLDER}"
  remove_folder "${BIN_FOLDER}"
  remove_folder "${CACHE_FOLDER}"
  remove_folder "${TEMP_FOLDER}"
  remove_folder "${FUNCTIONS_FOLDER}"
  remove_folder "${INITIALIZATIONS_FOLDER}"
  remove_folder "${DATA_FOLDER}"

  remove_all_favorites
  remove_all_keybindings

  remove_line "${bash_functions_import}" "${BASHRC_PATH}"
  remove_line "${bash_initializations_import}" "${PROFILE_PATH}"


  export PROMPT_COMMAND=""
}


########################################################################################################################
#################################### GENERIC UNINSTALL FUNCTIONS - OPTIONAL PROPERTIES #################################
########################################################################################################################

# - Description: Expands launcher contents and deletes them to the desktop and dashboard.
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the manual launcher name to uninstall, matching the variable $1_launchercontents
generic_uninstall_manual_launchers() {
  local -r launchercontents="$1_launchercontents[@]"
  local name_suffix_anticollision=""
  for launchercontent in "${!launchercontents}"; do
    remove_manual_launcher "$1${name_suffix_anticollision}.desktop"
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}

# - Description:
# - Permissions:
# Argument 1: Feature keyname
# Argument 2:
generic_uninstall_dynamic_launcher() {
  local -r launcherkeynames="$1_launcherkeynames[@]"
  local name_suffix_anticollision=""
  for launcherkey in "${!launcherkeynames}"; do
    remove_manual_launcher "$1${name_suffix_anticollision}.desktop"
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}

# - Description: Expands function contents and remove them of .bashrc indirectly using bash_functions
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to uninstall, matching the variable $1_bashfunctions
generic_uninstall_functions() {
  local -r bashfunctions="$1_bashfunctions[@]"
  local name_suffix_anticollision=""
  for bashfunction in "${!bashfunctions}"; do
    remove_bash_function "$1${name_suffix_anticollision}.sh"
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}

# - Description: Expands launcher names and add them to the favorites subsystem if FLAG_FAVORITES is set to 0.
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to remove from favorites, matching the variable $1_launchernames
#   and the name of the first argument in the common_data.sh table.
generic_uninstall_favorites() {
  local -r launchernames="$1_launchernames[@]"
  # To add to favorites if the flag is set
  if [ "${FLAG_FAVORITES}" == "0" ]; then
    if [ -n "${!launchernames}" ]; then
      for launchername in ${!launchernames}; do
        remove_favorite "${launchername}.desktop"
      done
    else
      remove_favorite "$1.desktop"
    fi
  fi
}

# - Description: Expands file associations and remove register files association desktop launchers as default application's mimetypes
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_associatedfiletypes
#   and the name of the first argument in the common_data.sh table.
generic_uninstall_file_associations() {
  local -r associated_file_types="$1_associatedfiletypes[@]"
  for associated_file_type in ${!associated_file_types}; do
    if echo "${associated_file_type}" | grep -Fo ";"; then
      local associated_desktop=
      associated_desktop="$(echo "${associated_file_type}" | cut -d ";" -f2)"
    else
      local associated_desktop="$1"
    fi
    remove_file_associations "${associated_desktop}.desktop"
  done
}

# - Description: Expands keybinds for functions and programs and append to keybind sub-system
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_keybinds
#   and the name of the first argument in the common_data.sh table
generic_uninstall_keybindings() {
  local -r keybinds="$1_keybindings[@]"
  for keybind in "${!keybinds}"; do
    remove_keybinding "${keybind}"
  done
}

# - Description: Expands downloads to remove downloads from BIN_FOLDER/FEATUREKEYNAME
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_download
generic_uninstall_downloads() {
  local -r downloads="$1_downloads[@]"
  if [ -d "${!downloads}" ]; then
    remove_folder "${BIN_FOLDER}/$1"
  fi
}

# - Description: Expands to not autostart a program option if set to 'no' launcher names will expand to not autostart
# - Permissions: Can be executed as root or user.
# - Argument 1: Launcher name of the feature to install, matching it with the variable $1_autostart
generic_uninstall_autostart() {
  local -r launchernames="$1_launchernames[@]"
  local -r autostartlaunchers_pointer="$1_autostartlaunchers[@]"
  if [ -n "${!autostartlaunchers_pointer}" ]; then
    local name_suffix_anticollision=""
    for autostartlauncher in "${!autostartlaunchers_pointer}"; do
      remove_file "${AUTOSTART_FOLDER}/$1${name_suffix_anticollision}.desktop"
      name_suffix_anticollision="${name_suffix_anticollision}_"
    done
  # If not use the launchers that are already in the system
  elif [ -n "${!launchernames}" ]; then
    for launchername in ${!launchernames}; do
      remove_autostart_program "${launchername}.desktop"
    done
  # Fallback to keyname to try if there is a desktop launcher in the system
  else
    remove_autostart_program "$1.desktop"
  fi
}

# - Description: Expands $1_binariesinstalledpaths which contain the relative path
#   from the installation folder or the absolute path separated by ';' with the name
#   of the link created in PATH.
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the binaries of the feature to install, matching the variable $1_binariesinstalledpaths
generic_uninstall_pathlinks() {
  local -r binariesinstalledpaths="$1_binariesinstalledpaths[@]"
  for binary_install_path_and_name in ${!binariesinstalledpaths}; do
    local binary_name=
    binary_name="$(echo "${binary_install_path_and_name}" | cut -d ";" -f2)"
    # If absolute path
    if echo "${binary_name}" | grep -Eqo "^/"; then
      remove_links_in_path "${binary_name}"
    else
      remove_links_in_path "${binary_name}"
    fi
  done
}

# - Description: Expands $1_filekeys to obtain the keys which are a name of a variable
#   that has to be expanded to obtain the data of the file.
# - Permissions: Can be executed as root or user.
# - Argument 1: Absolute path of the feature to uninstall, matching the variable $1_filekeys
generic_uninstall_files() {
  local -r filekeys="$1_filekeys[@]"
  for filekey in "${!filekeys}"; do
    local path="$1_${filekey}_path"
    if echo "${!path}" | grep -Eqo "^/"; then
      remove_file "${!path}"
    else
      remove_file "${BIN_FOLDER}/$1/${!path}"
    fi
  done
}

# - Description: Creates a valid launcher for the normal user in the desktop using an already created launcher from an
# automatic install (for example using $DEFAULT_PACKAGE_MANAGER or dpkg).
# - Permissions: This function expects to be called as root since it uses the variable $SUDO_USER.
# - Argument 1: name of the desktop launcher in ALL_USERS_LAUNCHERS_DIR.
generic_uninstall_copy_launcher() {
  # Name of the launchers to be used by copy_launcher
  local -r launchernames="$1_launchernames[@]"
  # Copy launchers if defined
  for launchername in ${!launchernames}; do
    remove_copied_launcher "${launchername}.desktop"
  done
}

# - Description: Expands function system initialization relative to ${HOME_FOLDER}/.profile
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to uninstall, matching the variable $1_bashinitializations
generic_uninstall_initializations() {
  local -r bashinitializations="$1_bashinitializations[@]"
  local name_suffix_anticollision=""
  for bashinit in "${!bashinitializations}"; do
    remove_bash_initialization "$1${name_suffix_anticollision}.sh"
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}


# - Description: Expands function system initialization relative to moving files
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_movefiles
generic_uninstall_movefiles() {
  local -r movedfiles_pointer="$1_movedfiles[@]"
  for movedfiles_data in "${!movedfiles_pointer}"; do
    destinationpath="$(echo "${movedfiles_data}" | cut -d ";" -f2)"
    remove_file "${destinationpath}"
  done
}


# - Description: Expands dependency installation
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the array $1_packagedependencies
generic_uninstall_dependencies() {
# Other dependencies to install with the package manager before the main package of software if present
  local -r packagedependencies="$1_packagedependencies[*]"

  if [ "${EUID}" -ne 0 ]; then
    if [ -n "${!packagedependencies}" ]; then
      output_proxy_executioner "echo WARNING: $1 has this dependencies: ${!packagedependencies} but are not going to be uninstalled because you are not root. To uninstall them, rerun uninstallation with sudo." "${FLAG_QUIETNESS}"
      return
    fi
  fi
  # Uninstall dependency packages
  for packagedependency in ${!packagedependencies}; do
    ${PACKAGE_MANAGER_UNINSTALL} "${packagedependency}"
  done
}


########################################################################################################################
#################################### GENERIC UNINSTALL FUNCTIONS - INSTALLATION TYPES ##################################
########################################################################################################################

# - Description: Unnstalls packages using python environment.
# - Permissions: It is expected to be called as user.
# - Argument 1: Name of the program that we want to install, which will be the variable that we expand to look for its
#   installation data.
generic_uninstall_pythonVirtualEnvironment() {
  local -r pipinstallations="$1_pipinstallations[@]"
  local -r pythoncommands="$1_pythoncommands[@]"
  if [ -z "${!pipinstallations}" ] && [ -z "${!pythoncommands}" ]; then
    return
  fi
  remove_folder "${BIN_FOLDER:?}/${CURRENT_INSTALLATION_KEYNAME}"
}

# - Description: removes git repository in BIN_FOLDER
# - Permissions: It is expected to be called as user.
# - Argument 1: Name of the program that we want to install, which will be the variable that we expand to look for its
#   installation data.
generic_uninstall_cloneRepositories() {
  local -r repositoryurl="${CURRENT_INSTALLATION_KEYNAME}_repositoryurl"
  if [ -n "${!repositoryurl}" ]; then
    remove_folder "${BIN_FOLDER:?}/${CURRENT_INSTALLATION_KEYNAME}"
  fi
}

# - Description: Uninstalls a package using the package manager depending on the system.
# - Permissions: It is expected to be called as root.
generic_uninstall_packageManager() {
  local -r packagenames="${CURRENT_INSTALLATION_KEYNAME}_packagenames[@]"
  for packagename in ${!packagenames}; do
    ${PACKAGE_MANAGER_UNINSTALL} "${packagename}"
  done
}


# - Description: Remove file from BIN_FOLDER
# - Permissions: Expected to be run by normal user.
# - Argument 1: String that matches a set of variables in data_features.
generic_uninstall_downloads() {
  local -r downloads="${CURRENT_INSTALLATION_KEYNAME}_downloadKeys[@]"
  local name_suffix_anticollision=""
  for each_download in ${!downloads}; do
    local pointer_type="${CURRENT_INSTALLATION_KEYNAME}_${each_download}_type"
    local pointer_downloadPath="${CURRENT_INSTALLATION_KEYNAME}_${each_download}_downloadPath"
    local pointer_installedPackages="${CURRENT_INSTALLATION_KEYNAME}_${each_download}_installedPackages[@]"
    local pointer_doNotInherit="${CURRENT_INSTALLATION_KEYNAME}_$1_doNotInherit"

    case "${!pointer_type}" in
      "compressed")
        if [ -n "${!pointer_downloadPath}" ]; then
          if [ -n "${!pointer_doNotInherit}" ]; then
            # Decompression in place in arbitrary directory. Delete folder
            remove_folder "${!pointer_downloadPath}"
          else
            # Decompression in arbitrary directory with inheritance
            remove_folder "${!pointer_downloadPath}/${CURRENT_INSTALLATION_KEYNAME}$2"
          fi
        else
          if [ -n "${!pointer_doNotInherit}" ]; then
            # Decompression in default folder (BIN_FOLDER) but not inheriting. We cannot delete anything since we
            # would need to know the contents of the compressed file. We will remove teh feature folder.
            remove_folder "${CURRENT_INSTALLATION_FOLDER}"
          else
            # Decompression in default directory with inheritance (default case). Delete the folder feature in
            # BIN_FOLDER
            remove_folder "${CURRENT_INSTALLATION_FOLDER}"
          fi
        fi
      ;;
      "package")
        if [ -n "${!pointer_installedPackages}" ]; then
          for package in "${!pointer_installedPackages}"; do
            ${PACKAGE_MANAGER_UNINSTALL} "${package}"
          done
        fi
      ;;
      "regular")
        if [ -n "${!pointer_downloadPath}" ]; then
          remove_file "${!pointer_downloadPath}/${CURRENT_INSTALLATION_KEYNAME}_$1_file"
        else
          remove_folder "${CURRENT_INSTALLATION_FOLDER}"
        fi
      ;;
      *)
        # In this case we do not know what type of file is in the download (we would need to download it) so we can
        # at least do the logic in some safe scenarios
        if [ -n "${!pointer_downloadPath}" ]; then
          if [ -n "${!pointer_doNotInherit}" ]; then
            # Decompression in place in arbitrary directory. Delete folder.
            remove_folder "${!pointer_downloadPath}"
          else
            # Decompression in arbitrary directory with inheritance
            remove_folder "${!pointer_downloadPath}/${CURRENT_INSTALLATION_KEYNAME}${name_suffix_anticollision}"
          fi
        else
          if [ -n "${!pointer_doNotInherit}" ]; then
            # Decompression in default folder (BIN_FOLDER) but not inheriting. We cannot delete anything since we
            # would need to know the contents of the compressed file. We will remove the feature folder.
            remove_folder "${CURRENT_INSTALLATION_FOLDER}"
          else
            remove_folder "${CURRENT_INSTALLATION_FOLDER}"
          fi
        fi
      ;;
    esac

    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}


if [ -f "${DIR}/functions_common.sh" ]; then
  source "${DIR}/functions_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_common.sh not found. Aborting..."
  exit 1
fi


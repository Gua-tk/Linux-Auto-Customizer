########################################################################################################################
# - Name: Linux Auto-Customizer exclusive functions of install.sh                                                      #
# - Description: Set of functions used exclusively in install.sh. Most of these functions are combined into other      #
# higher-order functions to provide the generic installation of a feature.                                             #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 16/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernandez Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: This script can not be executed directly, only sourced to import its functions and process its own    #
# imports. See the header of each function to see its privilege requirements.                                          #
# - Arguments: No arguments                                                                                            #
# - Usage: Sourced from install.sh                                                                                     #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################

########################################################################################################################
############################################ INSTALL AUXILIAR FUNCTIONS ################################################
########################################################################################################################

# - Description: Installs a new bash feature into $BASH_FUNCTIONS_PATH which sources the script that contains the code
# for this new feature.
# - Permissions: Can be called as root or as normal user presumably with the same behaviour.
# - Argument 1: Text containing all the code that will be saved into file, which will be sourced from bash_functions.
# - Argument 2: Name of the file.
add_bash_function() {
  # Write code to bash functions folder with the name of the feature we want to install
  create_file "${BASH_FUNCTIONS_FOLDER}/$2" "$1"
  # If we are root apply permission to the file
  if [ ${EUID} == 0 ]; then
    apply_permissions "${BASH_FUNCTIONS_FOLDER}/$2"
  fi

  # Add import_line to .bash_functions (BASH_FUNCTIONS_PATH)
  if [ -z "$(cat "${BASH_FUNCTIONS_PATH}" | grep -Fo "source ${BASH_FUNCTIONS_FOLDER}/$2")" ]; then
    echo "source ${BASH_FUNCTIONS_FOLDER}/$2" >>"${BASH_FUNCTIONS_PATH}"
  fi
}


# Description: Sets keybinding adding keybinding for keybind_function bash function.
# Permissions: can be executed indifferently as root or user.
# Argument 1: Command to be run with the keyboard shortcut.
# Argument 2: Set of keys with the right format to be binded.
# Argument 3: Descriptive name of the keybinding.
add_keybinding() {
  echo "$1;$2;$3" >>"${PROGRAM_KEYBIND_PATH}"
}


# - Description: Add new program launcher to the task bar given its desktop launcher filename.
#   This is done by writing in PROGRAM_FAVORITES_PATH the 1st argument.
#   This file is the input for add_to_favorites functions which is always present in all installations and this function
#   is executed each time we source ~/.bashrc.
# - Permissions: This functions can be called indistinctly as root or user.
# - Argument 1: Name of the .desktop launcher without .desktop extension located in file in PERSONAL_LAUNCHERS_DIR or
#   ALL_USERS_LAUNCHERS_DIR.
add_to_favorites() {
  for argument in "$@"; do
    if [ -z "$(cat "${PROGRAM_FAVORITES_PATH}" | grep -Eo "${argument}")" ]; then
      if [ -f "${ALL_USERS_LAUNCHERS_DIR}/${argument}.desktop" ] || [ -f "${PERSONAL_LAUNCHERS_DIR}/${argument}.desktop" ]; then
        echo "${argument}.desktop" >>"${PROGRAM_FAVORITES_PATH}"
      else
        output_proxy_executioner "echo WARNING: The program ${argument} cannot be found in the usual place for desktop launchers favorites. Skipping" "${FLAG_QUIETNESS}"
        return
      fi
    else
      output_proxy_executioner "echo WARNING: The program ${argument} is already added to the taskbar favorites. Skipping" "${FLAG_QUIETNESS}"
    fi
  done
}


# - Description: Sets a program to autostart by giving its launcher name without .desktop extension.
#   This .desktop are searched at ALL_USERS_LAUNCHERS_DIR and PERSONAL_LAUNCHERS_DIR.
# - Permissions: This functions can be called as root or as user.
# Argument 1: Name of .desktop launcher of program file without the '.desktop' extension.
autostart_program() {
  # If absolute path
  if [ -n "$(echo "$1" | grep -Eo "^/")" ]; then
    # If it's a file, make it autostart
    if [ -f "$1" ]; then
      cp "$1" "${AUTOSTART_FOLDER}"
      if [ ${EUID} -eq 0 ]; then
        apply_permissions "$1"
      fi
    else
      output_proxy_executioner "echo WARNING: The file $1 does not exist, skipping..." ${FLAG_QUIETNESS}
      return
    fi
  else # Else relative path from ALL_USERS_LAUNCHERS_DIR or PERSONAL_LAUNCHERS_DIR
    if [ -f "${ALL_USERS_LAUNCHERS_DIR}/$1.desktop" ]; then
      cp "${ALL_USERS_LAUNCHERS_DIR}/$1.desktop" "${AUTOSTART_FOLDER}/$1.desktop"
      if [ ${EUID} -eq 0 ]; then
        apply_permissions "${AUTOSTART_FOLDER}/$1.desktop"
      fi
    elif [ -f "${PERSONAL_LAUNCHERS_DIR}/$1.desktop" ]; then
      cp "${PERSONAL_LAUNCHERS_DIR}/$1.desktop" "${AUTOSTART_FOLDER}/$1.desktop"
      if [ ${EUID} -eq 0 ]; then
        apply_permissions "$1.desktop"
      fi
    else
      output_proxy_executioner "echo WARNING: The file $1.desktop does not exist, in either ${ALL_USERS_LAUNCHERS_DIR} or ${PERSONAL_LAUNCHERS_DIR}, skipping..." ${FLAG_QUIETNESS}
      return
    fi
  fi
}


# - Description: Apply standard permissions and set owner and group to the user who called root.
# - Permissions: This functions can be called as root or user.
# Argument 1: Path to the file or directory whose permissions are changed.
apply_permissions() {
  if [ ${EUID} == 0 ]; then # root
    chgrp "${SUDO_USER}" "$1"
    chown "${SUDO_USER}" "$1"
  fi
  chmod 755 "$1"
}


# - Description: Creates the file with $1 specifying location and name of the file. Afterwards, apply permissions to it,
# to make it property of the $SUDO_USER user (instead of root), which is the user that originally ran the sudo command
# to run this script.
# - Permissions: This functions is expected to be called as root, or it will throw an error, since $SUDO_USER is not
# defined in the the scope of the normal user.
# - Argument 1: Path to the directory that we want to create.
# - Argument 2 (Optional): Content of the file we want to create.
create_file() {
  local -r folder="$(echo "$1" | rev | cut -d "/" -f2- | rev)"
  local -r filename="$(echo "$1" | rev | cut -d "/" -f1 | rev)"
  if [ -n "${filename}" ]; then
    mkdir -p "${folder}"
    echo "$2" >"$1"
    apply_permissions "$1"
  else
    output_proxy_executioner "echo WARNING: The name ${filename} is not a valid filename for a file in create_file. The file will not be created." "${FLAG_QUIETNESS}"
  fi
}


# - Description: Creates the necessary folders in order to make $1 a valid path. Afterwards, converts that dir to a
# writable folder, now property of the $SUDO_USER user (instead of root), which is the user that ran the sudo command.
# Note that by using mkdir -p we can pass a path that implies the creation of 2 or more directories without any
# problem. For example create_folder /home/user/all/directories/will/be/created.
# - Permissions: This functions is expected to be called as root, or it will throw an error, since $SUDO_USER is not
# defined in the the scope of the normal user.
# - Argument 1: Path to the directory that we want to create.
create_folder() {
  mkdir -p "$1"
  apply_permissions "$1"
}


# - Description: Creates a valid launcher for the normal user in the desktop using an already created launcher from an
# automatic install (for example using apt-get or dpkg).
# - Permissions: This function expects to be called as root since it uses the variable $SUDO_USER.
# - Argument 1: name of the desktop launcher in ALL_USERS_LAUNCHERS_DIR.
copy_launcher() {
  if [ -f "${ALL_USERS_LAUNCHERS_DIR}/$1" ]; then
    cp "${ALL_USERS_LAUNCHERS_DIR}/$1" "${XDG_DESKTOP_DIR}/$1"
    apply_permissions "${XDG_DESKTOP_DIR}/$1"
  else
    output_proxy_executioner "echo WARNING: Can't find $1 launcher in ${ALL_USERS_LAUNCHERS_DIR}." ${FLAG_QUIETNESS}
  fi
}


# - Description: This function accepts an undefined number of pairs of arguments. The first of the pair is a path to a
#   binary that will be linked to our path. The second one is the name that it will have as a terminal command.
#   This function processes the last optional arguments of the function download_and_decompress, but can be
#   used as a manual way to add binaries to the PATH, in order to add new commands to your environment.
# - Argument 1: Absolute path to the binary you want to be in the PATH.
# - Argument 2: Name of the command that will be added to your environment to execute the previous binary.
# - Argument 3 and 4, 5 and 6, 7 and 8... : Same as argument 1 and 2.
create_links_in_path() {
  while [ $# -gt 0 ]; do
    ln -sf "$1" "${DIR_IN_PATH}/$2"
    shift
    shift
  done
}


# - Description: This function creates a valid launcher in the desktop using a a given string with a given name.
# - Permissions: Can be called being root or normal user with same behaviour: when calling it as root, it will change
# the owner and group of the created launcher to the one of the $SUDO_USER.
# Argument 1: The string of the text representing the content of the desktop launcher that we want to create.
# Argument 2: The name of the launcher. This argument can be any name with no consequences.
create_manual_launcher() {
  if [ ${EUID} == 0 ]; then  # root
    create_file "${ALL_USERS_LAUNCHERS_DIR}/$2.desktop" "$1"
    cp -p "${ALL_USERS_LAUNCHERS_DIR}/$2.desktop" "${XDG_DESKTOP_DIR}"
  else
    create_file "${PERSONAL_LAUNCHERS_DIR}/$2.desktop" "$1"
    cp -p "${PERSONAL_LAUNCHERS_DIR}/$2.desktop" "${XDG_DESKTOP_DIR}"
  fi
}


# - Description:
# Argument 1: Type of decompression [zip, J, j, z].
# Argument 2: Absolute path to the file that is going to be decompressed in place. It will be deleted after the
# decompression.
# Argument 3 (optional): If argument 3 is set, it will try to get the name of a directory that is in the root of the
# compressed file. Then, after the decompressing, it will rename that directory to $3
decompress() {
  local dir_name=
  local file_name=
  # capture directory where we have to decompress
  if [ -z "$2" ]; then
    dir_name="${USR_BIN_FOLDER}"
    file_name="downloading_program"
  elif [ -n "$(echo "$2" | grep -Eo "^/")" ]; then
    # Absolute path to a file
    dir_name="$(echo "$2" | rev | cut -d "/" -f2- | rev)"
    file_name="$(echo "$2" | rev | cut -d "/" -f1 | rev)"
  else
    if [ -n "$(echo "$2" | grep -Eo "/")" ]; then
      # Relative path to a file containing subfolders
      dir_name="${USR_BIN_FOLDER}/$(echo "$2" | rev | cut -d "/" -f2- | rev)"
      file_name="$(echo "$2" | rev | cut -d "/" -f1 | rev)"
    else
      # Only a filename
      dir_name="${USR_BIN_FOLDER}"
      file_name="$2"
    fi
  fi
  if [ -n "$3" ]; then
    if [ "$1" == "zip" ]; then
      local internal_folder_name="$(unzip -l "${dir_name}/${file_name}" | head -4 | tail -1 | tr -s " " | cut -d " " -f5)"
      # The captured line ends with / so it is a valid directory
      echo
      echo
      echo
      echo AAAAAAAAAAAAAAAAAAAAA$internal_folder_name
      echo
      echo
      if [ -n "$(echo "${internal_folder_name}" | grep -Eo "/$")" ]; then
        internal_folder_name="$(echo "${internal_folder_name}" | cut -d "/" -f1)"
        echo $internal_folder_name
      else
        # Set the internal folder name empty if it is not detected
        internal_folder_name=""
      fi
    else
      # Capture root folder name
      local -r internal_folder_name=$( (tar -t"$1"f - | head -1 | cut -d "/" -f1) <"${dir_name}/${file_name}")
    fi
    # Check that variable program_folder_name is set, if not, decompress in a made up folder.
    if [ -z "${internal_folder_name}" ]; then
      # Create a folder where we will decompress the compressed file that has no directory in the root
      rm -Rf "${dir_name:?}/$3"
      create_folder "${dir_name}/$3"
      mv "${dir_name}/${file_name}" "${dir_name}/$3"
      # Reset the location of the compressed file.
      dir_name="${dir_name}/$3"
    else
      # Clean to avoid conflicts with previously installed software or aborted installation
      rm -Rf "${dir_name}/${internal_folder_name:?"ERROR: The name of the installed program could not been captured"}"
    fi
  fi
  if [ -f "${dir_name}/${file_name}" ]; then
    if [ "$1" == "zip" ]; then
      (
        cd "${dir_name}" || exit
        unzip -o "${file_name}"
      )
    else
      # Decompress in a subshell to avoid changing the working directory in the current shell
      (
        cd "${dir_name}" || exit
        tar -x"$1"f -
      ) <"${dir_name}/${file_name}"
    fi
  else
    output_proxy_executioner "echo ERROR: The function decompress did not receive a valid path to the compressed file. The path ${dir_name}/${file_name} does not exist." "${FLAG_QUIETNESS}"
    exit 1
  fi
  # Delete file now that is has been decompressed trash
  rm -f "${dir_name}/${file_name}"

  # Only enter here if they are different, if not skip since it is pointless because the folder already has the desired
  # name
  if [ -n "${internal_folder_name}" ]; then
    if [ "$3" != "${internal_folder_name}" ]; then
      # Rename folder to $3 if the argument is set
      if [ -n "$3" ]; then
        # Delete the folder that we are going to move to avoid collisions
        rm -Rf "${dir_name:?}/$3"
        mv "${dir_name}/${internal_folder_name}" "${dir_name}/$3"
      fi
    fi
  fi
}


# - Description: Downloads a file from the link provided in $1 and, if specified, with the location and name specified
#   in $2. If $2 is not defined, download into ${USR_BIN_FOLDER}/downloading_program.
# - Permissions: Can be called as root or normal user. If called as root changes the permissions and owner to the
#   $SUDO_USER user, otherwise, needs permissions to create the file $2.
# - Argument 1: Link to the file to download.
# - Argument 2 (optional): Path to the created file, allowing to download in any location and use a different filename.
#   By default the name of the file is downloading file and the PATH where is being downloaded is USR_BIN_FOLDER.
download() {
  local dir_name=
  local file_name=
  # Check if a path or name is specified
  if [ -z "$2" ]; then
    # default options
    dir_name="${USR_BIN_FOLDER}"
    file_name=downloading_program
  else
    # Custom file or folder to download
    if [ -n "$(echo "$2" | grep -Eo "^/")" ]; then
      # Absolute path
      if [ -d "$2" ]; then
        # is directory
        dir_name="$2"
        file_name=downloading_program
      else
        # maybe is the path to a file
        dir_name="$(echo "$2" | rev | cut -d "/" -f2- | rev)"
        file_name="$(echo "$2" | rev | cut -d "/" -f1 | rev)"
        if [ -z "${dir_name}" ]; then
          output_proxy_executioner "echo ERROR: the directory passed is absolute but it is not a directory and its first subdirectory does not exist" ${FLAG_QUIETNESS}
          exit
        fi
      fi
    else
      if [ -n "$(echo "$2" | grep -Eo "/")" ]; then
        # Relative path that contains subfolders
        if [ -d "$2" ]; then
          # Directory
          local -r dir_name="$2"
          local file_name=downloading_program
        else
          # maybe is a path to a file
          dir_name="$(echo "$2" | rev | cut -d "/" -f2- | rev)"
          file_name="$(echo "$2" | rev | cut -d "/" -f1 | rev)"
          if [ -z "${dir_name}" ]; then
            output_proxy_executioner "echo ERROR: the directory passed is relative but it is not a directory and its first subdirectory does not exist" ${FLAG_QUIETNESS}
            exit
          fi
        fi
      else
        # It is just actually the name of the file downloaded to default USR_BIN_FOLDER
        local -r dir_name="${USR_BIN_FOLDER}"
        local file_name="$2"
      fi
    fi
  fi

  # Download in a subshell to avoid changing the working directory in the current shell
  echo -e '\033[1;33m'
  wget --show-progress -qO "${dir_name}/${file_name}" "$1"
  echo -e '\033[0m'

  # If we are root
  if [ ${EUID} == 0 ]; then
    apply_permissions "${dir_name}/${file_name}"
  fi
}


# - Description: Downloads a .deb package temporarily into USR_BIN_FOLDER from the provided link and installs it using
#   dpkg -i.
# - Permissions: This functions needs to be executed as root: dpkg -i is an instruction that precises privileges.
# - Argument 1: Link to the package file to download.
# - Argument 2 (Optional): Tho show the name of the program downloading and thus change the name of the downloaded
#   package.
download_and_install_package() {
  download "$1" "$2"
  dpkg -i "${USR_BIN_FOLDER}/$2"
  rm -f "${USR_BIN_FOLDER}/$2"
}


# - Description: Expands launcher contents and add them to the desktop and dashboard.
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_launchercontents
#   and the name of the first argument in the common_data.sh table
generic_install_launchers() {
  local -r launchercontents="$1_launchercontents[@]"
  local name_suffix_anticollision=""
  for launchercontent in "${!launchercontents}"; do
    create_manual_launcher "${launchercontent}" "$1${name_suffix_anticollision}"
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}


# - Description: Expands function contents and add them to .bashrc indirectly using bash_functions
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_bashfunctions
#   and the name of the first argument in the common_data.sh table
generic_install_functions() {
  local -r bashfunctions="$1_bashfunctions[@]"
  name_suffix_anticollision=""
  for bashfunction in "${!bashfunctions}"; do
    add_bash_function "${bashfunction}" "$1${name_suffix_anticollision}.sh"
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}


# - Description: Expands launcher names and add them to the favorites subsystem if FLAF_FAVORITES is set to 1.
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_launchernames
#   and the name of the first argument in the common_data.sh table.
generic_install_favorites() {
  local -r launchernames="$1_launchernames[@]"

  # To add to favorites if the flag is set
  if [ "${favorite_bit}" == "1" ]; then
    if [ ! -z "${!launchernames}" ]; then
      for launchername in "${!launchernames}"; do
        add_to_favorites "${launchername}"
      done
    else
      add_to_favorites "$1"
    fi
  fi

}


# - Description: Expands file associations and register the desktop launchers as default application's mimetypes
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_associatedfiletypes
#   and the name of the first argument in the common_data.sh table.
generic_install_file_associations() {
  local -r associated_file_types="$1_associatedfiletypes[@]"
  for associated_file_type in ${!associated_file_types}; do
    register_file_associations "${associated_file_type}" "$1.desktop"
  done
}


# - Description: Expands keybinds for functions and programs and append to keybind sub-system
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_keybinds
#   and the name of the first argument in the common_data.sh table
generic_install_keybindings() {
  local -r keybinds="$1_keybinds[@]"
  for keybind in ${!keybinds}; do
    local command="$(echo "${keybind}" | cut -d ";" -f1)"
    local bind="$(echo "${keybind}" | cut -d ";" -f2)"
    local binding_name="$(echo "${keybind}" | cut -d ";" -f3)"
    add_keybinding "${command}" "${bind}" "${binding_name}"
  done
}


# - Description: Expands downloads and saves it to USR_BIN_FOLDER/FEATUREKEYNAME/NAME_OF_DOWNLOADED_FILE_i
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_downloads
#   and the name of the first argument in the common_data.sh table
generic_install_downloads() {
  local -r downloads="$1_downloads[@]"
  for download in ${!downloads}; do
    create_folder "${USR_BIN_FOLDER}/$1"
    local -r url="$(echo "${download}" | cut -d ";" -f1)"
    local -r name="$(echo "${download}" | cut -d ";" -f2)"
    download "${url}" "${USR_BIN_FOLDER}/$1/${name}"
  done
}


# - Description: Expands autostarting program option if set to 'yes' it'll expand launcher names to autostart
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_autostart
#   and associating it to all the launchers in $1_launchernames
generic_install_autostart() {
  local -r autostart="$1_autostart"
  local -r launchernames="$1_launchernames[@]"

  if [ "${!autostart}" == "yes" ]; then
    if [ -n "${!launchernames}" ]; then
      for launchername in ${!launchernames}; do
        autostart_program "${launchername}"
      done
    else
      autostart_program "$1"
    fi
  else
    if [ "${autostart_bit}" == 1 ]; then
      if [ -n "${!launchernames}" ]; then
        for launchername in ${!launchernames}; do
          autostart_program "${launchername}"
        done
      else
        autostart_program "$1"
      fi
    fi
  fi
}


# - Description: Expands $1_binariesinstalledpaths which contain the relative path
#   from the installation folder or the absolute path separated by ';' with the name
#   of the link created in PATH.
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_binariesinstalledpaths
generic_install_pathlinks() {
  # Path to the binaries to be added, with a ; with the desired name in the path
  local -r binariesinstalledpaths="$1_binariesinstalledpaths[@]"
  for binary_install_path_and_name in ${!binariesinstalledpaths}; do
    local binary_path="$(echo "${binary_install_path_and_name}" | cut -d ";" -f1)"
    local binary_name="$(echo "${binary_install_path_and_name}" | cut -d ";" -f2)"
    # Absolute path
    if [ -n "$(echo "${binary_name}" | grep -Eo "^/")" ]; then
      create_links_in_path "${binary_path}" "${binary_name}"
    else
      create_links_in_path "${USR_BIN_FOLDER}/$1/${binary_path}" "${binary_name}"
    fi
  done
}


# - Description: Expands $1_filekeys to obtain the keys which are a name of a variable
#   that has to be expanded to obtain the data of the file.
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_filekeys
generic_install_files() {
  local -r filekeys="$1_filekeys[@]"
  for filekey in "${!filekeys}"; do
    local content="$1_${filekey}_content"
    local path="$1_${filekey}_path"
    if [ -n "$(echo "${!path}" | grep -Eo "^/")" ]; then
      create_file "${!path}" "${!content}"
    else
      create_file "${USR_BIN_FOLDER}/$1/${!path}" "${!content}"
    fi
  done

}


# - Description: Installs a user program in a generic way relying on variables declared in data_features.sh and the name
#   of a feature. The corresponding data has to be declared following the pattern %FEATURENAME_%PROPERTIES. This is
#   because indirect expansion is used to obtain the data to install each feature of a certain program to install.
#   Depending on the properties set, some subfunctions will be activated to install related features.
#   Also performs the manual execution of paths of the feature and calls generic functions to install the common
#   part of the features such as desktop launchers, sourced .bashrc functions...
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the necessary variables such as $1_installationtype and the
#   name of the first argument in the common_data.sh table
generic_install() {
  # Substitute dashes for underscores. Dashes are not allowed in variable names
  local -r featurename=$(echo "$1" | sed "s@-@_@g")
  local -r installationtype=${featurename}_installationtype
  local -r manualcontentavailable="$1_manualcontentavailable"

  if [[ ! -z "${!installationtype}" ]]; then

    if [ "$(echo "${!manualcontentavailable}" | cut -d ";" -f1)" == "1" ]; then
      "install_$1_pre"
    fi

    case ${!installationtype} in
    # Using package manager such as apt-get
    packagemanager)
      rootgeneric_installation_type "${featurename}" packagemanager
      ;;
    # Downloading a package and installing it using a package manager such as dpkg
    packageinstall)
      rootgeneric_installation_type "${featurename}" packageinstall
      ;;
    # Download and decompress a file that contains a folder
    userinherit)
      userinherit_installation_type "${featurename}"
      ;;
    # Clone a repository
    repositoryclone)
      repositoryclone_installation_type "${featurename}"
      ;;
    pythonvenv)
      pythonvenv_installation_type "${featurename}"
      ;;
    # Only uses the common part of the generic installation
    environmental)
      : # no-op
      ;;
    *)
      output_proxy_executioner "echo ERROR: ${!installationtype} is not a recognized installation type" ${FLAG_QUIETNESS}
      exit 1
      ;;
    esac

    if [ "$(echo "${!manualcontentavailable}" | cut -d ";" -f2)" == "1" ]; then
      "install_$1_mid"
    fi

    generic_install_downloads "${featurename}"
    generic_install_files "${featurename}"
    generic_install_launchers "${featurename}"
    generic_install_functions "${featurename}"
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


# - Description: Installs packages using python environment.
# - Permissions: It is expected to be called as user.
# - Argument 1: Name of the program that we want to install, which will be the variable that we expand to look for its
#   installation data.
pythonvenv_installation_type() {
  rm -Rf "${USR_BIN_FOLDER}/$1"
  python3 -m venv "${USR_BIN_FOLDER}/$1"
  "${USR_BIN_FOLDER}/$1/bin/python3" -m pip install -U pip
  "${USR_BIN_FOLDER}/$1/bin/pip" install wheel

  local -r pipinstallations="$1_pipinstallations[@]"
  local -r pythoncommands="$1_pythoncommands[@]"
  for pipinstallation in ${!pipinstallations}; do
    "${USR_BIN_FOLDER}/$1/bin/pip" install "${pipinstallation}"
  done
  for pythoncommand in "${!pythoncommands}"; do
    "${USR_BIN_FOLDER}/$1/bin/python3" -m "${pythoncommand}"
  done
}


# - Description: Clones git repository in USR_BIN_FOLDER
# - Permissions: It is expected to be called as user.
# - Argument 1: Name of the program that we want to install, which will be the variable that we expand to look for its
#   installation data.
repositoryclone_installation_type() {
  local -r repositoryurl="$1_repositoryurl"
  rm -Rf "${USR_BIN_FOLDER}/$1"
  create_folder "${USR_BIN_FOLDER}/$1"
  git clone "${!repositoryurl}" "${USR_BIN_FOLDER}/$1"
}


# - Description: Installs packages using apt-get or ) + dpkg.
#   Also performs file decompression to obtain .deb if the corresponding variables are defined.
# - Permissions: Needs root permissions, but is expected to be called always as root by install.sh logic.
# - Argument 1: Name of the program that we want to install, which will be the variable that we expand to look for its
#   installation data.
# - Argument 2: Selects the type of installation between [packagemanager|packageinstall]
rootgeneric_installation_type() {
  # Declare name of variables for indirect expansion

  # Name of the launchers to be used by copy_launcher
  local -r launchernames="$1_launchernames[@]"
  # Other dependencies to install with the package manager before the main package of software if present
  local -r packagedependencies="$1_packagedependencies[@]"
  # Name of the package names to be installed with the package manager if present
  local -r packagenames="$1_packagenames[@]"
  # Used to download .deb and install it if present
  local -r packageurls="$1_packageurls[@]"
  # Used to download a compressed package where the .deb are located.
  local -r compressedfileurl="$1_compressedfileurl"
  local -r compressedfiletype="$1_compressedfiletype"

  # Install dependency packages
  for packagedependency in ${!packagedependencies}; do
    apt-get install -y "${packagedependency}"
  done

  # Download package and install using manual package manager
  if [ "$2" == packageinstall ]; then
    # Use a compressed file that contains .debs
    if [ ! -z "${!compressedfileurl}" ]; then
      download "${!compressedfileurl}" "${USR_BIN_FOLDER}/$1_downloading"
      decompress "${!compressedfiletype}" "${USR_BIN_FOLDER}/$1_downloading" "$1"
      dpkg -Ri "${USR_BIN_FOLDER}/$1"
      rm -Rf "${USR_BIN_FOLDER:?}/$1"
    else # Use directly a downloaded .deb
      for packageurl in "${!packageurls}"; do
        download_and_install_package "${packageurl}" "$1_downloading"
      done
    fi
  else # Install with default package manager
    for packagename in ${!packagenames}; do
      apt-get install -y "${packagename}"
    done
  fi

  # Copy launchers if defined
  for launchername in ${!launchernames}; do
    copy_launcher "${launchername}.desktop"
  done
}


# - Description: Download a file into USR_BIN_FOLDER, decompress it assuming that there is a directory inside it.
# - Permissions: Expected to be run by normal user.
# - Argument 1: String that matches a set of variables in data_features.
userinherit_installation_type() {
  # Declare name of variables for indirect expansion

  # Files to be downloaded that have to be decompressed
  local -r compressedfileurl="$1_compressedfileurl"
  # All decompression type options for each compressed file defined
  local -r compressedfiletype="$1_compressedfiletype"
  # Obtain override download location if present
  local -r compressedfilepathoverride="$1_compressedfilepathoverride"
  local defaultpath="${USR_BIN_FOLDER}"

  if [ ! -z "${!compressedfilepathoverride}" ]; then
    create_folder "${!compressedfilepathoverride}"
    defaultpath="${!compressedfilepathoverride}/"
  else
    defaultpath="${USR_BIN_FOLDER}/"
  fi

  download "${!compressedfileurl}" "${defaultpath}$1_downloading"
  decompress "${!compressedfiletype}" "${defaultpath}$1_downloading" "$1"
}


# - Description: Associate a file type (mime type) to a certain application using its desktop launcher.
# - Permissions: Same behaviour being root or normal user.
# - Argument 1: File types. Example: application/x-shellscript.
# - Argument 2: Application. Example: sublime_text.desktop.
register_file_associations() {
  # Check if mimeapps exists
  if [ -f "${MIME_ASSOCIATION_PATH}" ]; then
    # Check if the association between a mime type and desktop launcher is already existent
    if [ -z "$(more "${MIME_ASSOCIATION_PATH}" | grep -Eo "$1=.*$2")" ]; then
      # If mime type is not even present we can add the hole line
      if [ -z "$(more "${MIME_ASSOCIATION_PATH}" | grep -Fo "$1=")" ]; then
        sed -i "/\[Added Associations\]/a $1=$2;" "${MIME_ASSOCIATION_PATH}"
      else
        # If not, mime type is already registered. We need to register another application for it
        if [ -z "$(more "${MIME_ASSOCIATION_PATH}" | grep -Eo "$1=.*;$")" ]; then
          # File type(s) is registered without comma. Add the program at the end of the line with comma
          sed -i "s|$1=.*$|&;$2;|g" "${MIME_ASSOCIATION_PATH}"
        else
          # File type is registered with comma at the end. Just add program at end of line
          sed -i "s|$1=.*;$|&$2;|g" "${MIME_ASSOCIATION_PATH}"
        fi
      fi
    fi
  else
    output_proxy_executioner "echo WARNING: ${MIME_ASSOCIATION_PATH} is not present, so $2 cannot be associated to $1. Skipping..." "${FLAG_QUIETNESS}"
  fi
}

# - Description: Initialize common subsystems and common subfeatures
# - Permissions: Same behaviour being root or normal user.
data_and_file_structures_initialization() {
  output_proxy_executioner "echo INFO: Initializing data and file structures." "${FLAG_QUIETNESS}"
  create_folder ${USR_BIN_FOLDER}
  create_folder ${BASH_FUNCTIONS_FOLDER}
  create_folder ${DIR_IN_PATH}
  create_folder ${PERSONAL_LAUNCHERS_DIR}
  create_folder ${FONTS_FOLDER}

  # Initialize bash functions
  if [ ! -f "${BASH_FUNCTIONS_PATH}" ]; then
    create_file "${BASH_FUNCTIONS_PATH}"
    # //RF output proxy executioner stops working after sourcing ${BASH_FUNCTIONS_PATH}
    # else
    # Import bash functions to know which functions are installed (used for detecting installed alias or functions)
    # output_proxy_executioner "echo INFO: Checking the features that are already installed. This may take a while..." "${FLAG_QUIETNESS}"
    # source "${BASH_FUNCTIONS_PATH}" &>/dev/null
    # output_proxy_executioner "echo INFO: Finished." "${FLAG_QUIETNESS}"
  fi

  # Updates initializations
  # Avoid running bash functions non-interactively
  # Adds to the path the folder where we will put our soft links
  add_bash_function "${bash_functions_init}" "init.sh"
  # Create and / or update built-in favourites subsystem
  if [ ! -f "${PROGRAM_FAVORITES_PATH}" ]; then
    create_file "${PROGRAM_FAVORITES_PATH}"
  fi
  add_bash_function "${favorites_function}" "favorites.sh"

  # Create and / or update built-in keybinding subsystem
  if [ ! -f "${PROGRAM_KEYBIND_PATH}" ]; then
    create_file "${PROGRAM_KEYBIND_PATH}"
  fi
  add_bash_function "${keybind_function}" "keybind.sh"

  # Make sure that .bashrc sources .bash_functions
  if [ -z "$(cat "${BASHRC_PATH}" | grep -Fo "source "${BASH_FUNCTIONS_PATH}"")" ]; then
    echo -e "${bash_functions_import}" >>${BASHRC_PATH}
  fi
}

# - Description: Update the system using apt-get -y update or apt-get -y upgrade depending a
# - Permissions: Can be called as root or user but user will not do anything.
pre_install_update() {
  if [ ${EUID} == 0 ]; then
    if [ ${FLAG_UPGRADE} -gt 0 ]; then
      output_proxy_executioner "echo INFO: Attempting to update system via apt-get." ${FLAG_QUIETNESS}
      output_proxy_executioner "apt-get -y update" ${FLAG_QUIETNESS}
      output_proxy_executioner "echo INFO: System updated." ${FLAG_QUIETNESS}
    fi
    if [ ${FLAG_UPGRADE} == 2 ]; then
      output_proxy_executioner "echo INFO: Attempting to upgrade system via apt-get." ${FLAG_QUIETNESS}
      output_proxy_executioner "apt-get -y upgrade" ${FLAG_QUIETNESS}
      output_proxy_executioner "echo INFO: System upgraded." ${FLAG_QUIETNESS}
    fi
  fi
}

# - Description: Performs update of system fonts and bash environment.
# - Permissions: Same behaviour being root or normal user.
update_environment() {
  output_proxy_executioner "echo INFO: Rebuilding path cache" "${quietness_bit}"
  output_proxy_executioner "hash -r" "${quietness_bit}"
  output_proxy_executioner "echo INFO: Rebuilding font cache" "${quietness_bit}"
  output_proxy_executioner "fc-cache -f" "${quietness_bit}"
  output_proxy_executioner "echo INFO: Reloading bash features" "${quietness_bit}"
  output_proxy_executioner "source ${BASH_FUNCTIONS_PATH}" "${quietness_bit}" # After sourcing, output_proxy_executioner stops working unexpectedly
  #output_proxy_executioner "echo INFO: Finished execution" "${quietness_bit}"
}


if [[ -f "${DIR}/functions_common.sh" ]]; then
  source "${DIR}/functions_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_common.sh not found. Aborting..."
  exit 1
fi


# - Description: This functions is the basic piece of the favorites subsystem, but is not a function that it is
# executed directly, instead, is put in the bashrc and reads the file $PROGRAM_FAVORITES_PATH every time a terminal
# is invoked. This function and its necessary files such as $PROGRAM_FAVORITES_PATH are always present during the
# execution of install.
# This function basically processes and applies the results of the call to add_to_favorites function.
# - Permissions: This function is executed always as user since it is integrated in the user .bashrc. The function
# add_to_favorites instead, can be called as root or user, so root and user executions can be added

favorites_function="
if [[ -f ${PROGRAM_FAVORITES_PATH} ]]; then
  IFS=\$'\\n'
  for line in \$(cat ${PROGRAM_FAVORITES_PATH}); do
    favorite_apps=\"\$(gsettings get org.gnome.shell favorite-apps)\"
    if [[ -z \"\$(echo \$favorite_apps | grep -Fo \"\$line\")\" ]]; then
      if [[ -z \"\$(echo \$favorite_apps | grep -Fo \"[]\")\" ]]; then
        # List with at least an element
        gsettings set org.gnome.shell favorite-apps \"\$(echo \"\$favorite_apps\" | sed s/.\$//), '\$line']\"
      else
        # List empty
        gsettings set org.gnome.shell favorite-apps \"['\$line']\"
      fi
    fi
  done
fi
"

# https://askubuntu.com/questions/597395/how-to-set-custom-keyboard-shortcuts-from-terminal
# - Description: This function is the basic piece of the keybind subsystem, but is not a function that it is
# executed directly, instead, is put in the bashrc and reads the file $PROGRAM_KEYBIND_PATH every time a terminal
# is invoked. This function and its necessary files such as $PROGRAM_KEYBIND_PATH are always present during the
# execution of install. Also, for simplicity, we consider that each keybinding
# This function basically processes and applies the results of the call to add_custom_keybind function.
# - Permissions: This function is executed always as user since it is integrated in the user .bashrc. The function
# add_custom_keybind instead, can be called as root or user, so root and user executions can be added

# Name, Command, Binding...
# 1st argument Name of the feature
# 2nd argument Command of the feature
# 3rd argument Bind Key Combination of the feature ex(<Primary><Alt><Super>a)
# 4th argument Number of the feature array position slot of the added custom command (custom0, custom1, custom2...)
keybind_function="
# Check if there are keybinds available
if [ -f \"${PROGRAM_KEYBIND_PATH}\" ]; then
  # regenerate list of active keybinds
  declare -a active_keybinds=\"\$(echo \"\$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)\" | sed 's/@as //g' | tr -d \",\" | tr \"[\" \"(\" | tr \"]\" \")\" | tr \"'\" \"\\\"\")\"

  while IFS= read -r line; do
    if [ -z \"\$line\" ]; then
      continue
    fi
    field_command=\"\$(echo \"\${line}\" | cut -d \";\" -f1)\"
    field_binding=\"\$(echo \"\${line}\" | cut -d \";\" -f2)\"
    field_name=\"\$(echo \"\${line}\" | cut -d \";\" -f3)\"

    i=0
    isInstalled=0
    while [ -n \"\$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ name | cut -d \"'\" -f2)\" ]; do
      # Overwrite keybinding if there is a collision in the name with previous defined keybindings
      if [ \"\${field_name}\" == \"\$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ name | cut -d \"'\" -f2)\" ]; then
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ command \"'\${field_command}'\"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ binding \"'\${field_binding}'\"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ name \"'\${field_name}'\"
        # Make sure that the keybinding data that we just uploaded is active
        isActive=0
        for active_keybind in \${active_keybinds[@]}; do
          if [ \"\${active_keybind}\" == \"\'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/\'\" ]; then
            isActive=1
            break
          fi
        done
        # If is not active, active it by adding to the activated keybindings array
        if [ \${isActive} == 0 ]; then
          active_keybinds+=(\'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/\')
        fi
        # The keybind data was already in the table, no need for occupying a new custom keybind
        isInstalled=1
        break
      fi
      i=\$((i+1))
    done
    # No collision: append new keybinding data
    if [ \${isInstalled} == 0 ]; then
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ command \"'\${field_command}'\"
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ binding \"'\${field_binding}'\"
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ name \"'\${field_name}'\"
      echo fin
      # Make sure that the keybinding data that we just uploaded is active
      isActive=0
      for active_keybind in \${active_keybinds[@]}; do
        if [ \"\${active_keybind}\" == \"\'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/\'\" ]; then
          isActive=1
          break
        fi
      done
      # If is not active, active it by adding to the activated keybindings array
      if [ \${isActive} == 0 ]; then
        active_keybinds+=(\'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/\')
      fi
    fi
  done < \"${PROGRAM_KEYBIND_PATH}\"
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \"[\${active_keybinds[@]}]\"
  echo \"gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \"[\${active_keybinds[@]}]\" \"
fi
"

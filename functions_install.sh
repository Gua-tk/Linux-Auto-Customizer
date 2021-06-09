########################################################################################################################
# - Name: Linux Auto-Customizer exclusive functions of install.sh                                                      #
# - Description: Set of functions used exclusively in install.sh. Most of these functions are combined into other      #
# higher-order functions to provide the generic installation of a feature.                                             #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 16/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernández Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: This script can not be executed directly, only sourced to import its functions and process its own    #
# imports. See the header of each function to see its privilege requirements.                                          #
# - Arguments: No arguments                                                                                            #
# - Usage: Sourced from install.sh                                                                                     #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################

# - Description: Installs a new bash feature into $BASH_FUNCTIONS_PATH which sources the script that contains the code
# for this new feature. $BASH_FUNCTIONS_PATH is imported to your environment via .bashrc before entering any
# installation function.
# - Permissions: Can be called as root or as normal user presumably with the same behaviour.
# - Argument 1: Text containing all the code that will be saved into file, which will be sourced from bash_functions.
# - Argument 2: Name of the file.
add_bash_function() {
  # Write code to bash functions folder with the name of the feature we want to install
  echo -e "$1" >"${BASH_FUNCTIONS_FOLDER}/$2"

  # If we are root apply permission to the file
  if [[ ${EUID} == 0 ]]; then
    apply_permissions "${BASH_FUNCTIONS_FOLDER}/$2"
  fi

  import_line="source ${BASH_FUNCTIONS_FOLDER}/$2"
  # Add import_line to .bash_functions (BASH_FUNCTIONS_PATH)
  if [[ -z $(cat "${BASH_FUNCTIONS_PATH}" | grep -Fo "${import_line}") ]]; then
    echo "${import_line}" >>"${BASH_FUNCTIONS_PATH}"
  fi
}

# - Description: Download and install a fonts into ~/.fonts directory
# - Permissions:
# - Argument 1: Link to the font to be downloaded
# - Argument 2: Extension of the file
# - Argument 3: Name of the file
add_font() {
  rm -Rf ${FONTS_FOLDER}/$3_font
  mkdir -p ${FONTS_FOLDER}/$3_font
  download "$1" "${FONTS_FOLDER}/$3_font/$3"
  decompress "$2" "${FONTS_FOLDER}/$3_font/$3"
  fc-cache -f -v
}

# - Description: Create .desktop with custom url to open a link in favorite internet navigator
# - Permissions: This functions needs to be executed as user
# - Argument 1: Name of the program
# - Argument 2: Link of the icon of the program
add_internet_shortcut() {
  # Perform indirect variable expansion
  local -r icon=$1_icon
  local -r launcher=$1_launcher
  local -r alias=$1_alias
  local -r url=$1_url

  # Obtain icon for program
  mkdir -p "${USR_BIN_FOLDER}/$1"
  (
    cd ${USR_BIN_FOLDER}/$1
    wget -qO $1_icon.svg --show-progress ${!icon}
  )

  # Parametrize the exec and icon line of the desktop launcher
  local -r icon_exec_launcher_line="
  Exec=xdg-open ${!url}
  Icon=${USR_BIN_FOLDER}/$1/$1_icon.svg
  "
  # add the icon and exec lines to desktop launcher
  local -r launcher_complete="${!launcher}${icon_exec_launcher_line}"
  create_manual_launcher "${launcher_complete}" $1

  # Add the corresponding alias
  add_bash_function "${!alias}" "$1.sh"
}

# - Description: Add new program launcher to the task bar given its desktop launcher filename.
# - Permissions: This functions expects to be called as a non-privileged user.
# - Argument 1: Name of the .desktop launcher including .desktop extension written in file in PROGRAM_FAVORITES_PATH
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

# - Description: Apply standard permissions and set owner and group to the user who called root
# - Permissions: This functions is expected to be called as root
# Argument 1: Name of .desktop launcher of program file
autostart_program() {
  if [ -n "$(echo "$1" | grep -Eo "^/")" ]; then
    if [ -f "$1" ]; then
      cp "$1" "${AUTOSTART_FOLDER}"
      if [ ${EUID} -eq 0 ]; then
        apply_permissions "$1"
      fi
    else
      output_proxy_executioner "echo WARNING: The file $1 does not exist, skipping..." ${FLAG_QUIETNESS}
      return
    fi
  else
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

# - Description: Apply standard permissions and set owner and group to the user who called root
# - Permissions: This functions is expected to be called as root
# Argument 1: Path to the file or directory whose permissions are changed.
apply_permissions() {
  chgrp "${SUDO_USER}" "$1"
  chown "${SUDO_USER}" "$1"
  chmod 775 "$1"
}

# - Description: Creates the file with $1 specifying location and name of the file. Afterwards, apply permissions to it,
# to make it property of the $SUDO_USER user (instead of root), which is the user that originally ran the sudo command
# to run this script.
# - Permissions: This functions is expected to be called as root, or it will throw an error, since $SUDO_USER is not
# defined in the the scope of the normal user.
# - Argument 1: Path to the directory that we want to create.
# - Argument 2(Optional): Content of the file we want to create
create_file_as_root() {
  if [[ ! -z "${SUDO_USER}" ]]; then
    local -r folder=$(echo "$1" | rev | cut -d "/" -f2- | rev)
    local -r filename=$(echo "$1" | rev | cut -d "/" -f1 | rev)
    if [[ -n "${filename}" ]]; then
      mkdir -p "${folder}"
      echo "$2" >"$1"
      apply_permissions "$1"
    else
      output_proxy_executioner "echo WARNING: The name ${filename} is not a valid filename for a file in create_file_as_root. The file will not be created." "${FLAG_QUIETNESS}"
    fi
  else
    output_proxy_executioner "echo WARNING: The function create_file_as_root can not be run as normal user. The file will not be created." "${FLAG_QUIETNESS}"
  fi

}

# - Description: Creates the necessary folders in order to make $1 a valid path. Afterwards, converts that dir to a
# writable folder, now property of the $SUDO_USER user (instead of root), which is the user that ran the sudo command.
# Note that by using mkdir -p we can pass a path that implies the creation of 2 or more directories without any
# problem. For example create_folder_as_root /home/user/all/driectories/will/be/created
# - Permissions: This functions is expected to be called as root, or it will throw an error, since $SUDO_USER is not
# defined in the the scope of the normal user.
# - Argument 1: Path to the directory that we want to create.
create_folder_as_root() {
  mkdir -p "$1"
  apply_permissions "$1"
}

# - Description: Creates a valid launcher for the normal user in the desktop using an already created launcher from an
# automatic install (for example using apt-get or dpkg).
# - Permissions: This function expects to be called as root since it uses the variable $SUDO_USER
# - Argument 1: name of the desktop launcher in /usr/share/applications
copy_launcher() {
  if [[ -f "${ALL_USERS_LAUNCHERS_DIR}/$1" ]]; then
    create_file_as_root "${XDG_DESKTOP_DIR}/$1" "$(cat "${ALL_USERS_LAUNCHERS_DIR}/$1")"
  else
    output_proxy_executioner "echo WARNING: Can't find $1 launcher in ${ALL_USERS_LAUNCHERS_DIR}." ${FLAG_QUIETNESS}
  fi
}

# - Description: This function accepts an undefined number of pairs of arguments. The first of the pair is a path to a
# binary that will be linked to our path. The second one is the name that it will have as a terminal command.
# This function processes the last optional arguments of the function download_and_decompress, but can be
# used as a manual way to add binaries to the PATH, in order to add new commands to your environment.
#
# - Argument 1: Absolute path to the binary you want to be in the PATH
# - Argument 2: Name of the command that will be added to your environment to execute the previous binary
# - Argument 3 and 4, 5 and 6, 7 and 8... : Same as argument 1 and 2
create_links_in_path() {
  while [[ $# -gt 0 ]]; do
    # Clean to avoid collisions
    ln -sf "$1" ${DIR_IN_PATH}/$2
    shift
    shift
  done
}

# - Description: This function creates a valid launcher in the desktop using a a given string with a given name
# - Permissions: Can be called being root or normal user with same behaviour: when calling it as root, it will change
# the owner and group of the created launcher to the one of the $SUDO_USER.
# Argument 1: The string of the text representing the content of the desktop launcher that we want to create.
# Argument 2: The name of the launcher. This argument can be any name with no consequences.
create_manual_launcher() {
  # If user
  if [[ ${EUID} -ne 0 ]]; then
    echo -e "$1" >"${PERSONAL_LAUNCHERS_DIR}/$2.desktop"
    chmod 775 "${PERSONAL_LAUNCHERS_DIR}/$2.desktop"
    cp -p "${PERSONAL_LAUNCHERS_DIR}/$2.desktop" "${XDG_DESKTOP_DIR}"
  else # if root
    create_file_as_root "${ALL_USERS_LAUNCHERS_DIR}/$2.desktop" "$1"
    cp -p "${ALL_USERS_LAUNCHERS_DIR}/$2.desktop" "${XDG_DESKTOP_DIR}"
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
      # Return this variable via making it global
      local -r internal_folder_name="$(unzip -l "${dir_name}/${file_name}" | head -4 | tail -1 | tr -s " " | cut -d " " -f5 | cut -d "/" -f1)"
    else
      # Capture root folder name
      local -r internal_folder_name=$( (tar -t"$1"f - | head -1 | cut -d "/" -f1) < "${dir_name}/${file_name}")
    fi
    # Check that variable program_folder_name is set, if not abort
    # Clean to avoid conflicts with previously installed software or aborted installation
    rm -Rf "${dir_name}/${internal_folder_name:?"ERROR: The name of the installed program could not been captured"}"
  fi
  if [ -f "${dir_name}/${file_name}" ]; then
    if [ "$1" == "zip" ]; then
      (
        cd "${dir_name}" || exit
        unzip "${file_name}"
      )
    else
      # Decompress in a subshell to avoid changing the working directory in the current shell
      (
        cd "${dir_name}" || exit
        tar -x"$1"f -
      ) < "${dir_name}/${file_name}"
    fi
  else
    output_proxy_executioner "echo ERROR: The function decompress did not receive a valid path to the compressed file. The path ${dir_name}/${file_name} does not exist." "${FLAG_QUIETNESS}"
    exit 1
  fi

  # Only enter here if they are different, if not skip since it is pointless because the folder already has the desired
  # name
  if [ "$3" != "${internal_folder_name}" ]; then
    # Rename folder to $3 if the argument is set
    if [ -n "$3" ]; then
      # Delete the folder that we are going to move to avoid collisions
      rm -Rf "${dir_name:?}/$3"
      mv "${dir_name}/${internal_folder_name}" "${dir_name}/$3"
    fi
  fi
}

# - Description: Downloads a file from the link provided in $1 and, if specified, with the location and name specified
#   in $2. If $2 is not defined, download into ${USR_BIN_FOLDER}/downloading_program
# - Permissions: Can be called as root or normal user. If called as root changes the permissions and owner to the
#   $SUDO_USER user, otherwise, needs permissions to create the file $2.
# - Argument 1: link to the file to download
# - Argument 2 (optional): Path to the created file, allowing to download in any location and use a different filename.
#   By default the name of the file is downloading file and the PATH where is being downloaded is USR_BIN_FOLDER
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
        if [ -z "${file_name}" ]; then
          file_name=downloading_program
        fi
      fi
    fi
  fi

  # Download in a subshell to avoid changing the working directory in the current shell
  wget --show-progress -qO "${dir_name}/${file_name}" "$1"

  # If we are root
  if [ ${EUID} == 0 ]; then
    apply_permissions "${dir_name}/${file_name}"
  fi
}

#//RF
# - Description: Downloads a compressed file pointed by the provided link in $1 into $USR_BIN_FOLDER.
# We assume that this compressed file contains only one folder in the root. The name of this folder will be captured in
# order to change its name to the desired one, contained in $2.
# IF THE FORMAT OF THE COMPRESSED FILE DOES NOT HAVE A SINGLE DIRECTORY IN THE ROOT THIS FUNCTION WILL NOT WORK.
# Afterwards, it will be decompressed in a way dependent of $3, which specifies the type of compression.
# Then, all the remaining arguments are interpreted in pairs: the first one of the pair is a path to a file that we want
# to add to our path relatively from the root folder of the downloaded compressed file, the second one in the pair is
# the name that we are giving to that command in our environment.
#
# - Usage:
# For example, we download pypy.tar.gz, containing the root folder pypy-3.4.5.67, which contains the binary file pypy
# and the directory bin. The directory bin contains the binary pip:
# - pypy.tar.gz
#   - pypy-3.4.5.67
#     - bin
#       pip
#     pypy
#
# If we want to create links in the path to pypy and pip, that are called pypy3 and pypy-pip in our environment,
# we need to call this function like this:
# download_and_decompress ${link_to_compressed_file} "pypy" "z" "bin/pip" "pypy-pip" "pypy" "pypy3"
#
# - MANDATORY ARGUMENTS:
#   - Argument 1: link to the compressed file
#   - Argument 2: Final name of the folder
#   - Argument 3: Decompression options: [z, j, J, zip]
# - OPTIONAL ARGUMENTS:
# (if the first arguments of the pair is provided, then the second one is expected)
#   - Argument 4: Relative path to the selected binary to create the links in the path from the just decompressed folder
#   - Argument 5: Desired name for the link that points to the previous binary. This name will be the name for that
#   command in our environment.
# Argument 6 and 7, 8 and 9, 10 and 11... : Same as argument 4 and 5
download_and_decompress() {
  download "$1" "${USR_BIN_FOLDER}/downloading_program"

  decompress "$3" "${USR_BIN_FOLDER}/downloading_program" "$2"

  # Save the final name of the folder to regenerate the full path after the shifts
  program_folder_name="$2"
  # Shift the first 3 arguments to have only from 4th argument to the last in order to call create_links_in_path
  shift
  shift
  shift
  # Create links in the PATH. Greater that 1 to avoid the case where there are impair name of arguments
  while [[ $# -gt 1 ]]; do
    # Clean to avoid collisions
    create_links_in_path "${USR_BIN_FOLDER}/${program_folder_name}/$1" "$2"
    shift
    shift
  done
}

# - Description: Downloads a .deb package temporarily into USR_BIN_FOLDER from the provided link and installs it using
# dpkg -i.
# - Permissions: This functions needs to be executed as root: dpkg -i is an instruction that precises privileges.
# - Argument 1: Link to the package file to download
# - Argument 2 (Optional): Tho show the name of the program downloading and thus change the name of the downloaded
# package
download_and_install_package() {
  download "$1" "$2"
  dpkg -i ${USR_BIN_FOLDER}/"$2"
  rm -f ${USR_BIN_FOLDER}/"$2"
}

# - Description: Expands installation type and executes the corresponding function to install.
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the necessary variables such as $1_installationtype and the
# name of the first argument in the common_data.sh table
generic_install() {
  # Substitute dashes for underscores. Dashes are not allowed in variable names
  local -r featurename=$(echo "$1" | sed "s@-@_@g")
  local -r launchernames="${featurename}_launchernames[@]"

  local -r installationtype=${featurename}_installationtype
  if [[ ! -z "${!installationtype}" ]]; then
    case ${!installationtype} in
    packagemanager)
      rootgeneric_installation_type "${featurename}" packagemanager
      ;;
    packageinstall)
      rootgeneric_installation_type "${featurename}" packageinstall
      ;;
    *)
      output_proxy_executioner "echo ERROR: ${!installationtype} is not a recognized installation type" ${FLAG_QUIETNESS}
      exit 1
      ;;
    esac
    # To add to favorites if the flag is set
    if [ "${FLAG_FAVORITES}" == "1" ]; then
      if [ -n "${!launchernames}" ]; then
        echo "${!launchernames}"
        add_to_favorites ${!launchernames}
      else
        add_to_favorites "${featurename}"
      fi
    fi
  fi

}

# - Description: Installs packages using apt-get or ) + dpkg and also installs additional features such as
# aliases, related functions, desktop launchers including its icon and links in the path.
# - Permissions: Needs root permissions, but is expected to be called always as root by install.sh logic.
# - Argument 1: Name of the program that we want to install, which will be the variable that we expand to look for its
# installation data.
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
  # Used to call add manual launcher and create a launcher in the path and in the desktop
  local -r launchercontents="$1_launchercontents[@]"
  # Add code to be executed by bashrc
  local -r bashfunctions="$1_bashfunctions[@]"

  # Install dependency packages
  if [[ ! -z "${!packagedependencies}" ]]; then
    for packagedependency in "${!packagedependencies}"; do
      apt-get install -y "${packagedependency}"
    done
  fi

  # Select between arguments
  if [[ "$2" == packageinstall ]]; then
    # Download package and install using manual package manager
    for packageurl in "${!packageurls}"; do
      download_and_install_package "${packageurl}" "$1_downloading"
    done
  else
    # Install default packages
    for packagename in "${!packagenames}"; do
      apt-get install -y "${packagename}"
    done
  fi

  # Copy launchers if defined
  if [[ ! -z "${!launchernames}" ]]; then
    for launchername in "${!launchernames}"; do
      copy_launcher "${launchername}.desktop"
    done
  fi

  # Create new manual launchers
  local name_suffix_anticollision=""
  if [[ ! -z "${!launchercontents}" ]]; then
    for launchercontent in "${!launchercontents}"; do
      create_manual_launcher "${launchercontent}" "$1${name_suffix_anticollision}"
      name_suffix_anticollision="${name_suffix_anticollision}_"
    done
  fi

  # Install function related with the program (usually has an alias)
  name_suffix_anticollision=""
  if [[ ! -z "${!bashfunctions}" ]]; then
    for bashfunction in "${!bashfunctions}"; do
      add_bash_function "${bashfunction}" "$1${name_suffix_anticollision}.sh"
      name_suffix_anticollision="${name_suffix_anticollision}_"
    done
  fi

}

# - Permissions: Expected to be run by normal user.
# - Arguments:
# * Argument 1: String that matches a set of variables in data_features that set and change the behaviour of this
# function.
usergeneric_installation_type() {
  # First elements of necessary arrays to perform the algorithm of inheriting the directory of decompressed files.
  # These are necessary to perform the download and decompress
  local -r inheritedcompressedfileurl="$1_inheritedcompressedfileurl"
  local -r inheritedcompressedfiletype="$1inheritedcompressedfiletype"
  # This function assumes that there is a directory inside the compressed file and renames that directory to this var.
  local -r inheriteddirectoryname="$1_inheriteddirectoryname"

  # This is optional or relative
  local -r inheritedcompressedfiledownloadpath="$1_inheritedcompressedfiledownloadpath"

  # Used to detect if we have met the situation or not, basically to skip the first compressed file and folder
  if [ -z "${!inheriteddirectoryname}" ]; then
    output_proxy_executioner "echo ERROR: $1_inheriteddirectoryname is not present, so userinheritdecompress_genericinstall cannot run. Skipping..." "${FLAG_QUIETNESS}"
    exit 1
  fi
  if [ -z "${!inheritedcompressedfiletype}" ]; then
    output_proxy_executioner "echo ERROR: $1_inheritedcompressedfiletype is not present, so userinheritdecompress_genericinstall cannot run. Skipping..." "${FLAG_QUIETNESS}"
    exit 1
  fi
  if [ -z "${!inheritedcompressedfileurl}" ]; then
    output_proxy_executioner "echo ERROR: $1_inheritedcompressedfileurl is not present, so userinheritdecompress_genericinstall cannot run. Skipping..." "${FLAG_QUIETNESS}"
    exit 1
  fi

  download "${inheritedcompressedfileurl}" "${inheritedcompressedfiledownloadpath}"
  decompress "${inheritedcompressedfiletype}" "${inheritedcompressedfiledownloadpath}" "${inheriteddirectoryname}"
  # There is a file in the first position and also a default directory. We need to inherit the folder extracted.
  # Mark that the first compressed file is processed
  # Set the default directory to the directory that comes from decompressing the file
  if [ -z "$(echo "${inheritedcompressedfiledownloadpath}" | grep -Eo "^/")" ]; then
    # The location is relative to default path, which in this special case is USR_BIN_FOLDER
    # download can be renaming or not, which we assure in the following if
    if [ -d "${inheritedcompressedfiledownloadpath}" ]; then
      echo sdfsfd
      # Is a directory so it is downloaded in a file with the default name in download()
    else
      # it is a path to a file, that has been downloaded previously
      decompress "${inheritedcompressedfiletype}" "${USR_BIN_FOLDER}/${inheritedcompressedfiledownloadpath}" "${inheriteddirectoryname}"
    fi
  else
    # the location is absolute path
    download "${inheritedcompressedfileurl}" "${inheritedcompressedfiledownloadpath}"
    if [ -d "${inheritedcompressedfiledownloadpath}" ]; then
      decompress "${inheritedcompressedfiletype}" "${inheritedcompressedfiledownloadpath}/downloading_program" "${inheriteddirectoryname}"
    else
      decompress "${inheritedcompressedfiletype}" "${inheritedcompressedfiledownloadpath}" "${inheriteddirectoryname}"
    fi
  fi
  #if [  ]; then
}

# - Description: Installs a user program in a generic way relying on variables declared in feature_data.sh and the name
# of a feature. The corresponding data has to be declared following the pattern %FEATURENAME_%PROPERTIES. This is
# because indirect expansion is used to obtain the data to install each feature of a certain program to install.
# Depending on the properties set, some subfunctions will be activated to install related features. Two things can
# happen with the default directory to download and put our files:
#
# 1.- If the first position of the array $directorynames[@] is set, it will indicate the location of the
# default folder to download files while installing the current feature, but this behaviour is changed if the first
# position of the array $compresedfilesurls[@] is set. In that case, first it will download and decompress that url, but
# the call to decompress() will be special, because a third argument will be passed to that function indicating to
# detect a unique folder inside the directory, which will be renamed to the content of the first position of
# $directorynames[@] after the decompression of the first compressed file. This is used to "inherit" the folder that is
# inside the compressed file by using it as default folder directly, instead of using another folder that will be called
# the same to wrap the directory inside the compressed file. This is to avoid changing all the data that we already have
# but also to give certain freedom in the way each user feature in installed.
#
# 2.- If that is not the situation, the first value of $directorynames[@] will be the PATH to the default folder.
#
# 3.- If the first value of $directorynames[@] is not set, it will inherit $USR_BIN_FOLDER as the default folder.
#
# The algorithm of the function works as follows:
#
# The first thing that the function will do if the first situation described above is met, is decompress the first
# compressed file and convert the unique directory extracted from it, to the default folder of the currently installing
# application. If not, this behaviour will be avoided.
#
# After that it will create all directories in $directorynames[@] except the first one, which will be created only if
# there is no compressed file in the first position of the array $compressedfilesurls[@] (because it would mean that
# has been already decompressed).
#
# Then it will clone the urls to repositories using git clone from the variable $gitrepositoriesurls[@] in the locations
# in $gitrepositoriesclonedirs[@]. If not set, it will decompress into the default directory.
#
# Then it will download and decompress the files from $compressedfileurls in $compressedfiledownloadpaths[@] with
# the type $compressedfiletypes[@]. If not defined download in the default directory.
#
# After that it will add to the PATH all the binaries found in $binariesinstalledpaths[@]: The first position will be the
# relative or absolute folder from the default folder and the second position after the ; will be the name of the
# program.
#
# Add the functions defined in the array $bashfunctions[@] to .bashrc using the customizer system with
# ${BASH_FUNCTIONS_PATH}
#
# Also add the launchers if defined by using $launchercontents[@] which contains the text for all the launchers.
#
# Add the file associations to the current user defined in $recognizedfiletypes[@] and using
# register_file_associations(). The element in $launchercontents[0] will be the associated desktop used. If not defined,
# use a file in $ALL_USERS_LAUNCHERS_DIR or $PERSONAL_LAUNCHERS_DIR, if not present show a warning and continue.
#
# Finally download $fileurls[@] into $filedownloaddirs[@].
#
# Most of the paths can be absolute or relative from the default directory.
#
# - Permissions: Expected to be run by normal user.
# - Arguments:
# * Argument 1: String that matches a set of variables in data_features that set and change the behaviour of this
# function.
usergeneric_installationtype() {
  # Declare name of variables for indirect expansion

  # - If this variable has a value in the first position and there is a compressed files in the first position present
  # (in compressedfileurls): this function will assume that there is a directory in the root of this compressed file,
  # which will be renamed to the contents of this variable and will be the default folder to put downloaded files and
  # temporals during the installation of this feature. (inherit folder)

  # - If there are no compressed files in the first position defined but the this variable is present in the first
  # position, it will create as many directory as many paths are present in this variable with those names, being the
  # first one the default directory to put files in this feature.

  # - If the first place of the array is not set, the default folder to put files will be $USR_BIN_FOLDER.

  # Summarizing: The first position of this array is special, and will set the default folder. In the case that there is
  # a compressed file defined in the first position of the array $compressedfileurls[@] and also a directory defined in
  # the first position of the array below, it will assume that there is a unique directory inside the root of the
  # compressed file, which will be renamed to $1 and set to be the default folder to download files in the installation
  # of the current feature.

  local -r directorynames="$1_directorynames[@]"

  # Files to be downloaded that have to be decompressed
  local -r compressedfileurls="$1_compressedfileurls[@]"
  # Folders where compressed files have to be downloaded and decompressed. Relative from USR_BIN_FOLDER or absolute.
  local -r compressedfiledownloadpaths="$1_compressedfiledownloadpaths[@]"
  # All decompression type options for each compressed file defined
  local -r compressedfiletypes="$1_compressedfiletypes[@]"
  # Path to the binaries to be added, with a ; with the desired name in the path
  local -r binariesinstalledpaths="$1_binariesinstalledpaths[@]"
  # Code to be added to bashrc as a bash-function feature. Its name will be $1+anticollision_mark
  local -r bashfunctions="$1_bashfunctions[@]"

  # Launchers added using add_manual_launchers function. Its name will be $1+anticollision_mark
  local -r launchercontents="$1_launchercontents[@]"

  # Recognized file types, used to register application to use a certain mime type
  local -r recognizedfiletypes="$1_recognizedfiletypes[@]"

  # Generic downloads
  local -r fileurls="$1_fileurls[@]"
  local -r filedownloaddirs="$1_filedownloaddirs[@]"

  # Beginning with normal installation

  # Create directories, using USR_BIN_FOLDER as relative path if no absolute path is given
  if [ -n "${!directorynames}" ]; then
    for directoryname in "${!directorynames}"; do
      if [ "${compressed_i}" -eq "1" ]; then
        # Skip the first directory if we had decompressed
        compressed_i=2
        continue
      fi
      if [ -n "${directoryname}" ]; then
        if [ -n "$(echo "${directoryname}" | grep -Eo "^/")" ]; then
          # Absolute path
          rm -Rf "${directoryname}"
          mkdir -p "${directoryname}"
        else
          # Relative path
          rm -Rf "${USR_BIN_FOLDER}/${directoryname:?}"
          mkdir -p "${USR_BIN_FOLDER}/${directoryname}"
        fi
      fi
    done
  fi

  # Download and decompress
  if [ -n "${!compressedfileurls}" ]; then
    for compressedfileurls in "${!compressedfileurls}"; do
      if [ "${compressed_i}" -eq "2" ]; then
        # Skip the first directory if we had decompressed
        compressed_i=3
        continue
      elif [ -n "${compressedfileurls}" ]; then
        if [ -z "$(echo "${inheritedcompressedfiledownloadpath}" | grep -Eo "^/")" ]; then
          echo problem
        fi
      fi
    done
  fi
}

# - Description: Associate a file type (mime type) to a certain application using its desktop launcher.
# - Permissions: Same behaviour being root or normal user.
# - Argument 1: File types. Example: application/x-shellscript
# - Argument 2: Application. Example: sublime_text.desktop
register_file_associations() {
  # Check if mimeapps exists
  if [[ -f "${MIME_ASSOCIATION_PATH}" ]]; then
    # Check if the association between a mime type and desktop launcher is already existent
    if [[ -z "$(more "${MIME_ASSOCIATION_PATH}" | grep -Eo "$1=.*$2")" ]]; then
      # If mime type is not even present we can add the hole line
      if [[ -z "$(more "${MIME_ASSOCIATION_PATH}" | grep -Fo "$1=")" ]]; then
        sed -i "/\[Added Associations\]/a $1=$2;" "${MIME_ASSOCIATION_PATH}"
      else
        # If not, mime type is already registered. We need to register another application for it
        if [[ -z "$(more "${MIME_ASSOCIATION_PATH}" | grep -Eo "$1=.*;$")" ]]; then
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

if [[ -f "${DIR}/functions_common.sh" ]]; then
  source "${DIR}/functions_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_common.sh not found. Aborting..."
  exit 1
fi

# - Description: This functions is the basic piece of the favourites subsystem, but is not a function that it is
# executed directly, instead, is put in the bashrc and reads the file $PROGRAM_FAVORITES_PATH every time a terminal
# is invoked. This function and its necessary files such as $PROGRAM_FAVORITES_PATH are always present during the
# execution of install.
# This function basically processes and applies the results of the call to add_to_favourites function.
# - Permissions: This function is executed always as user since it is integrated in the user .bashrc. The function
# add_to_favourites instead, can be called as root or user, so root and user executions can be added
favorites_function="
if [[ -f ${PROGRAM_FAVORITES_PATH} ]]; then
  IFS=\$'\\\n'
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

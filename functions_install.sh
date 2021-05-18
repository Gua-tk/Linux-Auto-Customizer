########################################################################################################################
# - Name: Linux Auto-Customizer data of features.                                                                      #
# - Description: A set of programs, functions, aliases, templates, environment variables, wallpapers, desktop          #
# features... collected in a simple portable shell script to customize a Linux working environment.                    #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 16/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernández Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when   #
# logged as root) to install some of the features.                                                                     #
# - Arguments: Accepts behavioural arguments with one hyphen (-f, -o, etc.) and feature selection with two hyphens     #
# (--pycharm, --gcc).                                                                                                  #
# - Usage: Installs the features given by argument.                                                                    #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


################################
###### AUXILIAR FUNCTIONS ######
################################

# - Description: Add new program launcher to the task bar given its desktop launcher filename
# - Permissions: This functions expects to be called as a non-privileged user
# - Argument 1: Name of the .desktop launcher file of the program we want to add to the task bar
add_to_favorites()
{
  if [[ -f "${PERSONAL_LAUNCHERS_DIR}/$1.desktop" ]] || [[ -f "${ALL_USERS_LAUNCHERS_DIR}/$1.desktop" ]]; then
    # If root
    if [[ ${EUID} -eq 0 ]]; then
    # This code search and export the variable DBUS_SESSIONS_BUS_ADDRESS for root access to gsettings and dconf
      if [[ -z ${DBUS_SESSION_BUS_ADDRESS+x} ]]; then
        user=$(whoami)
        fl=$(find /proc -maxdepth 2 -user $user -name environ -print -quit)
        while [ -z $(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2- | tr -d '\000' ) ]; do
          fl=$(find /proc -maxdepth 2 -user $user -name environ -newer "$fl" -print -quit)
        done
        export DBUS_SESSION_BUS_ADDRESS="$(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2-)"
      fi
    fi
    if [[ -z $(echo "$(gsettings get org.gnome.shell favorite-apps)" | grep -Fo "$1.desktop") ]]; then
      gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), '$1.desktop']"
    else
      output_proxy_executioner "echo WARNING: $1 is already added to favourites. Skipping..." ${FLAG_QUIETNESS}
    fi
  else
    output_proxy_executioner "echo WARNING: $1 cannot be added to favorites because it does not exist installed. Skipping..." ${FLAG_QUIETNESS}
  fi
}

# - Description: Apply standard permissions and set owner and group to the user who
# called root
# - Permissions: This functions is expected to be called as root
# Argument 1: Path to the file or directory whose permissions are changed
apply_permissions()
{
  chgrp ${SUDO_USER} "$1"
  chown ${SUDO_USER} "$1"
  chmod 775 "$1"
}

# - Description: Creates the necessary folders in order to make $1 a valid path. Afterwards, converts that dir to a
# writable folder, now property of the $SUDO_USER user (instead of root), which is the user that ran the sudo command.
# Note that by using mkdir -p we can pass a path that implies the creation of 2 or more directories without any
# problem. For example create_folder_as_root /home/user/all/driectories/will/be/created
# - Permissions: This functions is expected to be called as root, or it will throw an error, since $SUDO_USER is not
# defined in the the scope of the normal user.
# - Argument 1: Path to the directory that we want to create.
create_folder_as_root()
{
  mkdir -p "$1"
  apply_permissions  "$1"
}

# - Description: Creates the file with $1 specifying location. Afterwards, converts that file to a
# writable folder, now property of the $SUDO_USER user (instead of root), which is the user that ran the sudo command.
# - Permissions: This functions is expected to be called as root, or it will throw an error, since $SUDO_USER is not
# defined in the the scope of the normal user.
# - Argument 1: Path to the directory that we want to create.
# - Argument 2(Optional): Content of the file we want to create
create_file_as_root()
{
  local -r folder=$(echo "$1" | rev | cut -d "/" -f2- | rev)
  local -r filename=$(echo "$1" | rev | cut -d "/" -f1 | rev)
  if [[ -d ${folder} ]]; then
    if [[ -n "${filename}" ]]; then
      echo "$2" > "$1"
      apply_permissions "$1"
    else
      output_proxy_executioner "echo ERROR: The name ${filename} is not a valid filename" ${FLAG_QUIETNESS}
    fi
  else
    output_proxy_executioner "echo ERROR: Can't find ${folder} in create_file_as_root" ${FLAG_QUIETNESS}
  fi

}
# - Description: Associate a file type (mime type) to a certain application using its desktop launcher.
# - Permissions: Same behaviour being root or normal user.
# - Argument 1: File types. Example: application/x-shellscript
# - Argument 2: Application. Example: sublime_text.desktop
register_file_associations()
{
# Check if mimeapps exists
if [[ -f "${MIME_ASSOCIATION_PATH}" ]]; then
  # Check if the association between a mime type and desktop launcher is already existent
  if [[ -z "$(more "${MIME_ASSOCIATION_PATH}" | grep -Eo "$1=.*$2" )" ]]; then
    # If mime type is not even present we can add the hole line
    if [[ -z "$(more "${MIME_ASSOCIATION_PATH}" | grep -Fo "$1=" )" ]]; then
      sed -i "/\[Added Associations\]/a $1=$2;" ${HOME_FOLDER}/.config/mimeapps.list
    else
      # If not, mime type is already registered. We need to register another application for it
      if [[ -z "$(more "${MIME_ASSOCIATION_PATH}" | grep -Eo "$1=.*;$" )" ]]; then
        # File type(s) is registered without comma. Add the program at the end of the line with comma
        sed -i "s|$1=.*$|&;$2;|g" "${MIME_ASSOCIATION_PATH}"
      else
        # File type is registered with comma at the end. Just add program at end of line
        sed -i "s|$1=.*;$|&$2;|g" "${MIME_ASSOCIATION_PATH}"
      fi
    fi
  fi
else
  output_proxy_executioner "echo WARNING: ${MIME_ASSOCIATION_PATH} is not present, so $2 cannot be associated to $1. Skipping..." ${FLAG_QUIETNESS}
fi
}

# - Description: Installs a program that uses package manager relying on declared variables
# - Permissions: This functions expects to be called as root
# - Argument 1: Name of the feature to install
packagemanager_installation_type()
{
  local -r packagedependencies=$1_packagedependencies
  local -r packagename=$1_packagename
  local -r launchername=$1_launchername

  if [[ ! -z "${!packagedependencies}" ]]; then
    apt-get install -y "${!packagedependencies}"
  fi
  apt-get install -y "${!packagename}"
  if [[ ! -z "${!launchername}" ]]; then
    copy_launcher "${!launchername}.desktop"
  fi

}

# - Description:
# - Permissions:
# - Argument 1:
packageinstall_installation_type()
{
  local -r packagedependencies=$1_packagedependencies
  local -r packageurl=$1_packageurl
  local -r launchername=$1_launchername

  if [[ ! -z "${!packagedependencies}" ]]; then
    apt-get install -y "${!packagedependencies}"
  fi
  download_and_install_package "${!packageurl}"
  if [[ ! -z "${!launchername}" ]]; then
    copy_launcher "${!launchername}.desktop"
  fi
  if [[ ! -z "${!launchername}" ]]; then
    copy_launcher "${!launchername}.desktop"
  fi

}


# - Description: Creates a valid launcher for the normal user in the desktop using an already created launcher from an
# automatic install (for example using apt-get or dpkg).
# - Permissions: This function expects to be called as root since it uses the variable $SUDO_USER
# - Argument 1: name of the desktop launcher in /usr/share/applications
copy_launcher()
{
  if [[ -f "${ALL_USERS_LAUNCHERS_DIR}/$1" ]]; then
    create_file_as_root "${XDG_DESKTOP_DIR}/$1" "$(cat "${ALL_USERS_LAUNCHERS_DIR}/$1")"
  else
    output_proxy_executioner "echo WARNING: Can't find $1 launcher in ${ALL_USERS_LAUNCHERS_DIR}." ${FLAG_QUIETNESS}
  fi
}

# - Description: This function creates a valid launcher in the desktop using a a given string with a given name
# - Permissions: Can be called being root or normal user with same behaviour: when calling it as root, it will change
# the owner and group of the created launcher to the one of the $SUDO_USER.
# Argument 1: The string of the text representing the content of the desktop launcher that we want to create.
# Argument 2: The name of the launcher. This argument can be any name with no consequences.
create_manual_launcher()
{
  # If user
  if [[ ${EUID} -ne 0 ]]; then
    echo -e "$1" > "${PERSONAL_LAUNCHERS_DIR}/$2.desktop"
    chmod 775 "${PERSONAL_LAUNCHERS_DIR}/$2.desktop"
    cp -p "${PERSONAL_LAUNCHERS_DIR}/$2.desktop" "${XDG_DESKTOP_DIR}"
  else  # if root
    create_file_as_root "${ALL_USERS_LAUNCHERS_DIR}/$2.desktop" "$1"
    cp -p "${ALL_USERS_LAUNCHERS_DIR}/$2.desktop" "${XDG_DESKTOP_DIR}"
  fi
}

# Argument 1: link to download into usr bin folder
# Argument 2 (optional): final name for the file
download()
{
  # Check if a name is specified
  if [[ -z "$2" ]]; then
    local -r temporalname=downloading_program
  else
    local -r temporalname="$2"
  fi
  # Clean to avoid conflicts with previously installed software or aborted installation
  rm -f "${USR_BIN_FOLDER}/${temporalname}"
  # Download in a subshell to avoid changing the working directory in the current shell
  (cd ${USR_BIN_FOLDER}; wget -qO "${temporalname}" --show-progress "$1")
}

# Argument 1: Type of decompression
# Argument 2: If present ssume that there is a unique folder inside the compressed file. Capture folder name and
# rename it to the third argument
#
decompress()
{
  if [[ "${3}" == "zip" ]]; then
    program_folder_name="$( unzip -l "${USR_BIN_FOLDER}/downloading_program" | head -4 | tail -1 | tr -s " " | cut -d " " -f5 | cut -d "/" -f1 )"
    unzip -l "${USR_BIN_FOLDER}/downloading_program"
  else
    # Capture root folder name
    program_folder_name=$( (tar -t$3f - | head -1 | cut -d "/" -f1) < "${USR_BIN_FOLDER}/downloading_program")
  fi

  # Check that variable program_folder_name is set, if not abort
  # Clean to avoid conflicts with previously installed software or aborted installation
  rm -Rf "${USR_BIN_FOLDER}/${program_folder_name:?"ERROR: The name of the installed program could not been captured"}"
  if [[ "${3}" == "zip" ]]; then
    (cd "${USR_BIN_FOLDER}"; unzip "${USR_BIN_FOLDER}/downloading_program" )  # To avoid collisions
  else
    # Decompress in a subshell to avoid changing the working directory in the current shell
    (cd "${USR_BIN_FOLDER}"; tar -x$3f -) < "${USR_BIN_FOLDER}/downloading_program"
  fi
  # Delete downloaded files which will be no longer used
  rm -f "${USR_BIN_FOLDER}/downloading_program"
  # Clean older installation to avoid conflicts
  if [[ "${program_folder_name}" != "$2" ]]; then
    rm -Rf "${USR_BIN_FOLDER}/$2"
    # Rename folder for coherence
    mv "${USR_BIN_FOLDER}/${program_folder_name}" "${USR_BIN_FOLDER}/$2"
  fi
}

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
download_and_decompress()
{
  # Clean to avoid conflicts with previously installed software or aborted installation
  rm -f ${USR_BIN_FOLDER}/downloading_program
  # Download in a subshell to avoid changing the working directory in the current shell
  (cd ${USR_BIN_FOLDER}; wget -qO "downloading_program" --show-progress "$1")



  if [[ "${3}" == "zip" ]]; then
    program_folder_name="$( unzip -l "${USR_BIN_FOLDER}/downloading_program" | head -4 | tail -1 | tr -s " " | cut -d " " -f5 | cut -d "/" -f1 )"
    unzip -l "${USR_BIN_FOLDER}/downloading_program"
  else
    # Capture root folder name
    program_folder_name=$( (tar -t$3f - | head -1 | cut -d "/" -f1) < "${USR_BIN_FOLDER}/downloading_program")
  fi

  # Check that variable program_folder_name is set, if not abort
  # Clean to avoid conflicts with previously installed software or aborted installation
  rm -Rf "${USR_BIN_FOLDER}/${program_folder_name:?"ERROR: The name of the installed program could not been captured"}"
  if [[ "${3}" == "zip" ]]; then
    (cd "${USR_BIN_FOLDER}"; unzip "${USR_BIN_FOLDER}/downloading_program" )  # To avoid collisions
  else
    # Decompress in a subshell to avoid changing the working directory in the current shell
    (cd "${USR_BIN_FOLDER}"; tar -x$3f -) < "${USR_BIN_FOLDER}/downloading_program"
  fi
  # Delete downloaded files which will be no longer used
  rm -f "${USR_BIN_FOLDER}/downloading_program"
  # Clean older installation to avoid conflicts
  if [[ "${program_folder_name}" != "$2" ]]; then
    rm -Rf "${USR_BIN_FOLDER}/$2"
    # Rename folder for coherence
    mv "${USR_BIN_FOLDER}/${program_folder_name}" "${USR_BIN_FOLDER}/$2"
  fi



  # Save the final name of the folder to regenerate the full path after the shifts
  program_folder_name="$2"
  # Shift the first 3 arguments to have only from 4th argument to the last in order to call create_links_in_path
  shift
  shift
  shift
  # Create links in the PATH
  while [[ $# -gt 0 ]]; do
    # Clean to avoid collisions
    create_links_in_path "${USR_BIN_FOLDER}/${program_folder_name}/$1" "$2"
    shift
    shift
  done
}

# - Description: This function accepts an undefined number of pairs of arguments. The first of the pair is a path to a
# binary that will be linked to our path. The second one is the name that it will have as a terminal command.
# This function processes the last optional arguments of the function download_and_decompress, but can be
# used as a manual way to add binaries to the PATH, in order to add new commands to your environment.
#
# - Argument 1: Absolute path to the binary you want to be in the PATH
# - Argument 2: Name of the hard-link that will be created in the path
# - Argument 3 and 4, 5 and 6, 7 and 8... : Same as argument 1 and 2
create_links_in_path()
{
  while [[ $# -gt 0 ]]; do
    # Clean to avoid collisions
    ln -sf "$1" ${DIR_IN_PATH}/$2
    shift
    shift
  done
}

# - Description: Installs a new bash feature into $BASH_FUNCTIONS_PATH which sources the script that contains the code
# for this new feature. $BASH_FUNCTIONS_PATH is imported to your environment via .bashrc.
# - Permissions: Can be called as root or as normal user with presumably with the same behaviour.
# - Argument 1: Text containing all the code that will be saved into file, which will be sourced from bash_functions
# - Argument 2: Name of the file.
add_bash_function()
{
  # Write code to bash functions folder with the name of the feature we want to install
  echo -e "$1" > ${BASH_FUNCTIONS_FOLDER}/$2

  if [[ ${EUID} == 0 ]]; then
    apply_permissions "${BASH_FUNCTIONS_FOLDER}/$2"
  fi

  import_line="source ${BASH_FUNCTIONS_FOLDER}/$2"
  # Add import_line to .bash_functions (BASH_FUNCTIONS_PATH)
  if [[ -z $(cat ${BASH_FUNCTIONS_PATH} | grep -Fo "${import_line}") ]]; then
    echo ${import_line} >> ${BASH_FUNCTIONS_PATH}
  fi
}

# - Description: Downloads a .deb package temporarily into USR_BIN_FOLDER from the provided link and installs it using
# dpkg -i.
# - Permissions: This functions needs to be executed as root: dpkg -i is an instruction that precises privileges.
# - Argument 1: Link to the package file to download
download_and_install_package()
{
  rm -f ${USR_BIN_FOLDER}/downloading_package
  (cd ${USR_BIN_FOLDER}; wget -qO downloading_package --show-progress $1)
  dpkg -i ${USR_BIN_FOLDER}/downloading_package
  rm -f ${USR_BIN_FOLDER}/downloading_package
}

# - Description: Create .desktop with custom url to open a link in favorite internet navigator
# - Permissions: This functions needs to be executed as user
# - Argument 1: Name of the program
# - Argument 2: Link of the icon of the program
add_internet_shortcut()
{
  # Perform indirect variable expansion
  local -r icon=$1_icon
  local -r launcher=$1_launcher
  local -r alias=$1_alias
  local -r url=$1_url

  # Obtain icon for program
  mkdir -p "${USR_BIN_FOLDER}/$1"
  (cd ${USR_BIN_FOLDER}/$1; wget -qO $1_icon.svg --show-progress ${!icon})

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

# - Description: Expands installation type and executes the corresponding function
# - Permissions:
# - Argument 1:
generic_install()
{
  # Substitute dashes for underscores. Dashes are not allowed in variable names
  local -r featurename=$(echo "$1" | sed "s@-@_@g")

  local -r installationtype=$featurename_installationtype
  if [[ ! -z "${!installationtype}" ]]; then
    case ${!installationtype} in
      packagemanager)
        packagemanager_installation_type "${featurename}"
      ;;
      packageinstall)
        packageinstall_installation_type "${featurename}"
      ;;
      *)
        output_proxy_executioner "echo ERROR: ${!installationtype} is not a recognized installation type" ${FLAG_QUIETNESS}
        exit 1
      ;;
    esac
  fi
}


if [[ -f "${DIR}/functions_common.sh" ]]; then
  source "${DIR}/functions_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_common.sh not found. Aborting..."
  exit 1
fi
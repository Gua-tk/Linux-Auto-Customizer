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
add_bash_function()
{
  # Write code to bash functions folder with the name of the feature we want to install
  echo -e "$1" > "${BASH_FUNCTIONS_FOLDER}/$2"

  # If we are root apply permission to the file
  if [[ ${EUID} == 0 ]]; then
    apply_permissions "${BASH_FUNCTIONS_FOLDER}/$2"
  fi

  import_line="source ${BASH_FUNCTIONS_FOLDER}/$2"
  # Add import_line to .bash_functions (BASH_FUNCTIONS_PATH)
  if [[ -z $(cat "${BASH_FUNCTIONS_PATH}" | grep -Fo "${import_line}") ]]; then
    echo "${import_line}" >> "${BASH_FUNCTIONS_PATH}"
  fi
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

# - Description: Add new program launcher to the task bar given its desktop launcher filename.
# - Permissions: This functions expects to be called as a non-privileged user.
# - Argument 1: Name of the .desktop launcher file (without the .desktop extension) of the program we want to add to the
# task bar, apparently using .desktop files from ALL_USERS_LAUNCHERS_DIR and PERSONAL_LAUNCHERS_DIR.
add_to_favorites()
{
  if [[ -f "${PERSONAL_LAUNCHERS_DIR}/$1.desktop" ]] || [[ -f "${ALL_USERS_LAUNCHERS_DIR}/$1.desktop" ]]; then
    # If we are root
    if [[ ${EUID} -eq 0 ]]; then
    # We need to search and export the variable DBUS_SESSIONS_BUS_ADDRESS for root access to gsettings and dconf
      if [[ -z ${DBUS_SESSION_BUS_ADDRESS+x} ]]; then
        user="${SUDO_USER}"
        fl=$(find /proc -maxdepth 2 -user $user -name environ -print -quit)
        while [ -z "$(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2- | tr -d '\000' )" ]; do
          fl=$(find /proc -maxdepth 2 -user $user -name environ -newer "$fl" -print -quit)
        done
        export DBUS_SESSION_BUS_ADDRESS="$(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2-)"
      fi
    fi
    if [[ -z $(echo "$(gsettings get org.gnome.shell favorite-apps)" | grep -Fo "$1.desktop") ]]; then
      gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), '$1.desktop']"
    else
      output_proxy_executioner "echo WARNING: $1 is already added to favourites. Skipping..." "${FLAG_QUIETNESS}"
    fi
  else
    output_proxy_executioner "echo WARNING: $1 cannot be added to favorites because it does not exist installed. Skipping..." "${FLAG_QUIETNESS}"
  fi
}

# - Description: Apply standard permissions and set owner and group to the user who called root
# - Permissions: This functions is expected to be called as root
# Argument 1: Path to the file or directory whose permissions are changed.
apply_permissions()
{
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
create_file_as_root()
{
  if [[ ! -z "${SUDO_USER}" ]]; then
    local -r folder=$(echo "$1" | rev | cut -d "/" -f2- | rev)
    local -r filename=$(echo "$1" | rev | cut -d "/" -f1 | rev)
    if [[ -n "${filename}" ]]; then
      mkdir -p "${folder}"
      echo "$2" > "$1"
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
create_folder_as_root()
{
  mkdir -p "$1"
  apply_permissions  "$1"
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

# - Description: This function accepts an undefined number of pairs of arguments. The first of the pair is a path to a
# binary that will be linked to our path. The second one is the name that it will have as a terminal command.
# This function processes the last optional arguments of the function download_and_decompress, but can be
# used as a manual way to add binaries to the PATH, in order to add new commands to your environment.
#
# - Argument 1: Absolute path to the binary you want to be in the PATH
# - Argument 2: Name of the command that will be added to your environment to execute the previous binary
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

# - Description:
# Argument 1: Type of decompression [zip, J, j, z].
# Argument 2: Absolute path to the file that is going to be decompressed in place. It will be deleted after the
# decompression.
# Argument 3 (optional): If argument 3 is set, it will try to get the name of a directory that is in the root of the
# compressed file. Then, after the decompressing, it will rename that directory to $3
decompress()
{
  if [ -n "$3" ]; then
    if [ "$1" == "zip" ]; then
      # Return this variable via making it global
      local -r internal_folder_name="$(unzip -l "$2" | head -4 | tail -1 | tr -s " " | cut -d " " -f5 | cut -d "/" -f1)"
    else
      # Capture root folder name
      local -r internal_folder_name=$( (tar -t"$1"f - | head -1 | cut -d "/" -f1) < "$2")
    fi
    # Check that variable program_folder_name is set, if not abort
    # Clean to avoid conflicts with previously installed software or aborted installation
    rm -Rf "${USR_BIN_FOLDER}/${internal_folder_name:?"ERROR: The name of the installed program could not been captured"}"
  fi

  local -r dir_name="$(echo "$2" | rev | cut -d "/" -f2- | rev)"
  if [ -f "$2" ]; then
    if [ "$1" == "zip" ]; then
      (cd "${dir_name}"; unzip "$2" )
    else
      # Decompress in a subshell to avoid changing the working directory in the current shell
      (cd "${dir_name}"; tar -x"$1"f -) < "$2"
    fi
  else
    output_proxy_executioner "echo ERROR: The function decompress did not receive a valid path to the compressed file. The path ${dir_name} does not exist." "${FLAG_QUIETNESS}"
    exit 1
  fi

  # Delete downloaded files which will be no longer used
  rm -f "$2"
  # Rename folder to $3 if the argument is set
  if [ -n "$3" ]; then
    mv "${dir_name}/${internal_folder_name}" "${dir_name}/$3"
  fi

}


# - Description: Downloads a file from the link provided in $1 and, if specified, with the location and name specified
#   in $2. If $2 is not defined, download into ${USR_BIN_FOLDER}/downloading_program
# - Permissions: Can be called as root or normal user. If called as root changes the permissions and owner to the
#   $SUDO_USER user, otherwise, needs permissions to create the file $2.
# - Argument 1: link to the file to download
# - Argument 2 (optional): Path to the created file, allowing to download in any location and use a different filename.
#   By default the name of the file is downloading file and the PATH where is being downloaded is USR_BIN_FOLDER
download()
{
  # Check if a name is specified
  if [ -z "$2" ]; then
    local -r dir_name="${USR_BIN_FOLDER}"
    local -r file_name=downloading_program
  else
    local -r dir_name="$(echo "$2" | rev | cut -d "/" -f2- | rev)"
    local -r file_name="$(echo "$2" | rev | cut -d "/" -f1 | rev)"
  fi

  # Download in a subshell to avoid changing the working directory in the current shell
  wget --show-progress -qO "${dir_name}/${file_name}" "$1"

  # If we are root
  if [ ${EUID} == 0 ]; then
    apply_permissions "${dir_name}/${file_name}"
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
download_and_install_package()
{
  rm -f ${USR_BIN_FOLDER}/downloading_package
  (cd ${USR_BIN_FOLDER}; wget -qO downloading_package --show-progress $1)
  dpkg -i ${USR_BIN_FOLDER}/downloading_package
  rm -f ${USR_BIN_FOLDER}/downloading_package
}



# - Description: Expands installation type and executes the corresponding function
# - Permissions:
# - Argument 1:
generic_install()
{
  # Substitute dashes for underscores. Dashes are not allowed in variable names
  local -r featurename=$(echo "$1" | sed "s@-@_@g")

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
  fi
}

# - Description: Installs packages using apt-get or ) + dpkg and also installs additional features such as
# aliases, related functions, desktop launchers including its icon and links in the path.
# - Permissions: Needs root permissions, but is expected to be called always as root by install.sh logic
# - Argument 1: Name of the program that we want to install, which will be the variable that we expand to look for its
# installation data.
# - Argument 2: Selects the type of installation between [packagemanager|packageinstall]
rootgeneric_installation_type()
{
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
      download_and_install_package "${packageurl}"
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


#* First it will create a directory with the name of the currently installing feature in USR_BIN_FOLDER if directory_final_names is not defined.
# If creating the directory, then downloads from $NAME_compressedpackagenames inside that directory if we created it. If we do not create the folder it will downloaded in USR_BIN_FOLDER

#* After that check the optional variable $NAME_clonableurls to clone inside it. Throw an error if there is more than one clone in this case.
# If not CD to USR_BIN_FOLDER and clone all there.

#* Then it will download in the just created directory if directory_final_names not defined
#* After downloading it will decompress depending on $NAME_decompressionoptions.
#* If directoryfinalnames is defined try to detect a root folder and rename that root folder to direcotryfilenames
#* Create links in pairs by using relative paths selecting the binary (from the folder that we just decompressed and renamed) or absolute paths from the variable $NAME_pairpathtobinaries
#* Call add bash functions to add aliases or other code to badge using another variable $NAME_bashfunctions
#* Create manual launchers calling create manual launchers and using  $NAME_launchercontents
#* Also use an array of pair of values to indicate the location and destination of files to copy. They can be absolute or from the relative paths from the folder we just created.
#* optional Manual manipulation of icon or Exec line of a launcher
#* Register file associations
#* Add to favourites\*
usergeneric_installationtype()
{
  # Declare name of variables for indirect expansion

  # Relative paths are from USR_BIN_FOLDER!

  # If this variable has a value in the first position and there is a compressed files in the first position present
  # (in compressedfileurls): this function will assume that there is a directory in the root of this compressed file,
  # which will be renamed to the contents of this variable and will be the default folder to put downloaded files and
  # temporals during the installation of this feature.
  # If there are no compressed files defined but the this variable is present in the first position, it will create
  # as many directory as many paths are present in this variable with those names, being the first one the default
  # directory to put files in this feature.
  # If this variable is not present the default place to put files will be USR_BIN_FOLDER
  # Summarizing: The first position of this array is special, and will set the default folder. This folder will be
  # the final name of the folder inside the compressed file, assuming there is such structure.
  # To skip this feature define the data of the arrays from the second position, leaving the first one blank
  # Also note that paths to directories can be relative from USR_BIN_FOLDER or be absolute.
  local -r directorynames="$1_directorynames[@]"

  # Files to be downloaded that have to be decompressed
  local -r compressedfileurls="$1_compressedfileurls[@]"
  local -r compressedfileurls_num="$1_compressedfileurls[*]"
  # Folders where compressed files have to be downloaded and decompressed. Relative from USR_BIN_FOLDER or absolute.
  local -r compressedfiledownloadlocations="$1_compressedfiledownloadlocations[@]"
  # All decompression type options for each compressed file defined
  local -r compressedfiletypes="$1_compressedfiletypes[@]"

  # Path to the binaries to be added, with a ; with the desired name in the path
  local -r pathaddedbinaries="$1_pathaddedbinaries[@]"
  local -r pathaddedbinaries_num="$1_pathaddedbinaries[*]"

  # Code to be added to bashrc as a bash-function feature. Its name will be $1+anticollision_mark
  local -r bashfunctions="$1_bashfunctions[@]"
  local -r bashfunctions_num="$1_bashfunctions[*]"

  # Launchers added using add_manual_launchers function. Its name will be $1+anticollision_mark
  local -r launchercontents="$1_launchercontents[@]"
  local -r launchercontents_num="$1_launchercontents[*]"

  # Recognized file types, used to register application to use a certain mime type
  local -r recognizedfiletypes="$1_recognizedfiletypes[@]"
  local -r recognizedfiletypes_num="$1_recognizedfiletypes[*]"

  # Generic downloads
  local -r fileurls="$1_fileurls[@]"
  local -r filedownloadlocations="$1_filedownloadlocations[@]"

  # First elements of necessary arrays to perform the algorithm of inherit the directory of decompressed files.
  local -r firstcompressedfileurl="$1_compressedfileurls[0]"
  local -r firstcompressedfiletype="$1_compressedfiletypes[0]"
  local -r firstcompressedfiledownloadlocation="$1_compressedfiledownloadlocations[0]"
  local -r firstdirectoryname="$1_directorynames[0]"

  local default_directory=""

  local compressed_i=0
  if [ -z "${!firstdirectoryname}" ]; then
    # There is no default directory, so use USR_BIN_FOLDER
    default_directory="${USR_BIN_FOLDER}"
  else
    # There is a file in the first position and also a default directory. We need to inherit the folder extracted.
    if [ -n "${!firstcompressedfiledownloadlocation}" ]; then
      # Mark that the first compressed file is processed
      compressed_i=1
      if [ -n "${firstcompressedfileurl}" ]; then
        # Set the default directory to the directory that comes from decompressing the file
        if [ -z "$(echo "${firstcompressedfiledownloadlocation}" | grep -Eo "^/")" ]; then
          download "${firstcompressedfileurl}" "${USR_BIN_FOLDER}/${firstcompressedfiledownloadlocation}"
          decompress "${firstcompressedfiletype}" "${USR_BIN_FOLDER}/${firstcompressedfiledownloadlocation}" "${firstdirectoryname}"
          default_directory="${USR_BIN_FOLDER}/${firstcompressedfiledownloadlocation}"
        else
          download "${firstcompressedfileurl}" "${firstcompressedfiledownloadlocation}"
          decompress "${firstcompressedfiletype}" "${firstcompressedfiledownloadlocation}" "${firstdirectoryname}"
          default_directory="${firstcompressedfiledownloadlocation}"
        fi
      fi
    else
      # Set the default directory if we do not have to inherit
      mkdir -p "${USR_BIN_FOLDER}/${firstdirectoryname}"
      default_directory="${USR_BIN_FOLDER}/${firstdirectoryname}"
    fi
  fi

  # Beginning with normal installation

  # Create directories, using USR_BIN_FOLDER as relative path if no absolute path is given
  if [ -n "${!directorynames}" ]; then
    for directoryname in "${!directorynames}"; do
      if [ -n "${directoryname}" ]; then
        if [ -n "$(echo "${directoryname}" | grep -Eo "^/")" ]; then
          rm -Rf "${directoryname}"
          mkdir -p "${directoryname}"
        else
          rm -Rf "${USR_BIN_FOLDER}/${directoryname:?}"
          mkdir -p "${USR_BIN_FOLDER}/${directoryname}"
        fi
      fi
    done
  fi

  # Download and decompress
  if [ -n "${!compressedfileurls}" ]; then
    for compressedfileurls in "${!compressedfileurls}"; do
      if [ "${compressed_i}" == "0" ]
        if [ -n "${compressedfileurls}" ]; then
          if [ -z "$(echo "${firstcompressedfiledownloadlocation}" | grep -Eo "^/")" ]; then
            

          fi
        fi
      else
        compressed_i=0
      fi
    done
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

# - Description: Installs a program that uses package manager relying on declared variables
# - Permissions: This functions expects to be called as root
# - Argument 1: Name of the feature to install
packagemanager_installation_type()
{
  # Declare name of variables for indirect expansion
  local -r packagedependencies="$1_packagedependencies[@]"
  local -r packagenames="$1_packagenames[@]"
  local -r launchernames="$1_launchernames[@]"

  # Install dependency packages
  if [[ ! -z "${!packagedependencies}" ]]; then
    for packagedependency in "${!packagedependencies}"; do
      apt-get install -y "${packagedependency}"
    done
  fi

  # Install default packages
  for packagename in "${!packagenames}"; do
    apt-get install -y "${packagename}"
  done

  # Copy launchers
  if [[ ! -z "${!launchernames}" ]]; then
    for launchername in "${!launchernames}"; do
      copy_launcher "${launchername}.desktop"
    done
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
      sed -i "/\[Added Associations\]/a $1=$2;" "${MIME_ASSOCIATION_PATH}"
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
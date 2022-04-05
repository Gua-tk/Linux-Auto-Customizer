#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer exclusive functions of install.sh                                                      #
# - Description: Set of functions used exclusively in install.sh. Most of these functions are combined into other      #
# higher-order functions to provide the generic installation of a feature.                                             #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 17/9/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: aleix.marine@estudiants.urv.cat                                                                             #
# - Permissions: This script can not be executed directly, only sourced to import its functions and process its own    #
# imports. See the header of each function to see its privilege requirements.                                          #
# - Arguments: No arguments                                                                                            #
# - Usage: Not executed directly, sourced from install.sh                                                              #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################

########################################################################################################################
################################################ INSTALL API FUNCTIONS #################################################
########################################################################################################################

# - Description: Installs a bash feature into the environment by adding a bash script into $FUNCTIONS_FOLDER which will
#   be sourced from $FUNCTIONS_PATH file by adding an import line for it. These structures are always present and
#   $FUNCTIONS_PATH file is always sourced by bashrc, which is run every time a bash interpreter is invoked.
# - Permissions: Can be called as root or as normal user presumably with the same behaviour.
# - Argument 1: Text containing all the code that will be saved into file, which will be sourced from bash_functions.
# - Argument 2: Name of the bash script file in $FUNCTIONS_FOLDER.
# - Argument 3 (optional): Contains a relative path from the repository folder to a file that is copied in the desired
#   path. If set argument 1 is ignored.
add_bash_function() {
  # Write code to bash functions folder with the name of the feature we want to install
  create_file "${FUNCTIONS_FOLDER}/$2" "$1" "$3"
  # If we are root apply permission to the file
  if [ "${EUID}" == 0 ]; then
    apply_permissions "${FUNCTIONS_FOLDER}/$2"
  fi

  # Add import_line to .bash_functions (FUNCTIONS_PATH)
  if ! grep -Fqo "source \"${FUNCTIONS_FOLDER}/$2\"" "${FUNCTIONS_PATH}"; then
    echo "source \"${FUNCTIONS_FOLDER}/$2\"" >> "${FUNCTIONS_PATH}"
  fi
}


# - Description: Installs a bash feature into the environment by adding a bash script into $INITIALIZATIONS_FOLDER which
#   will be sourced from $INITIALIZATIONS_PATH file by adding to it an import line. These structures are always present
#   and $INITIALIZATIONS_PATH file is always sourced by profile, which is run once when the system starts.
# - Permissions: Can be called as root or as normal user presumably with the same behaviour.
# - Argument 1: Text containing all the code that will be saved into file, which will be sourced from bash_functions.
# - Argument 2: Name of the file.
# - Argument 3 (optional): Contains a relative path from the repository folder to a file that is copied in the desired
#   path. If set argument 1 is ignored.
add_bash_initialization() {
  # Write code to bash initializations folder with the name of the feature we want to install
  create_file "${INITIALIZATIONS_FOLDER}/$2" "$1" "$3"
  # If we are root apply permission to the file
  if [ "${EUID}" == 0 ]; then
    apply_permissions "${INITIALIZATIONS_FOLDER}/$2"
  fi

  # Add import_line to .bash_profile (INITIALIZATIONS_PATH)
  if ! grep -Fqo "source \"${INITIALIZATIONS_FOLDER}/$2\"" "${INITIALIZATIONS_PATH}"; then
    echo "source \"${INITIALIZATIONS_FOLDER}/$2\"" >> "${INITIALIZATIONS_PATH}"
  fi
}


# - Description: Adds a new keybinding by adding its data to PROGRAM_KEYBINDINGS_PATH if not already present. This feeds
#   the input for the keybinding subsystem, which is executed on system start to update the available keybindings. This
#   subsystem is present for all every installation.
# - Permissions: Can be executed indifferently as root or user.
# - Argument 1: Command to be run with the keyboard shortcut.
# - Argument 2: Set of keys with the right format to be bind.
# - Argument 3: Descriptive name of the keybinding.
add_keybinding() {
  if ! grep -Fqo "$1;$2;$3" "${PROGRAM_KEYBINDINGS_PATH}"; then
    echo "$1;$2;$3" >> "${PROGRAM_KEYBINDINGS_PATH}"
  fi
}


# - Description: Add new program launcher to the task bar given its desktop launcher filename by using favorites
#   subsystem. This is done by writing the first argument in PROGRAM_FAVORITES_PATH.
#   This file is the input for the favorites subsystem which is always present in all installations. This subsystem
#   is executed on system start to update the favorites in the taskbar.
# - Permissions: This function can be called indistinctly as root or user.
# - Argument 1: Name of the .desktop launcher without .desktop extension located in file in PERSONAL_LAUNCHERS_DIR or
#   ALL_USERS_LAUNCHERS_DIR.
add_to_favorites() {
  for argument in "$@"; do
    if ! grep -Eqo "${argument}" "${PROGRAM_FAVORITES_PATH}"; then
      if [ -f "${ALL_USERS_LAUNCHERS_DIR}/${argument}.desktop" ] || [ -f "${PERSONAL_LAUNCHERS_DIR}/${argument}.desktop" ]; then
        echo "${argument}.desktop" >> "${PROGRAM_FAVORITES_PATH}"
      else
        output_proxy_executioner "echo WARNING: The program ${argument} cannot be found in the usual place for desktop launchers favorites. Skipping" "${FLAG_QUIETNESS}"
        return
      fi
    fi
  done
}


# - Description: Sets a program to autostart on every boot by giving its launcher name without .desktop extension as an
#   argument. These .desktop files are searched in ALL_USERS_LAUNCHERS_DIR and PERSONAL_LAUNCHERS_DIR.
# - Permissions: This function can be called as root or as user.
# - Argument 1: Name of the .desktop launcher of program without the '.desktop' extension.
autostart_program() {
  # If absolute path
  if echo "$1" | grep -Eqo "^/"; then
    # If it is a file, make it autostart
    if [ -f "$1" ]; then
      cp "$1" "${AUTOSTART_FOLDER}"
      if [ ${EUID} -eq 0 ]; then
        apply_permissions "$1"
      fi
    else
      output_proxy_executioner "echo WARNING: The file $1 does not exist, skipping..." "${FLAG_QUIETNESS}"
      return
    fi
  else # Else relative path from ALL_USERS_LAUNCHERS_DIR or PERSONAL_LAUNCHERS_DIR
  echo "${AUTOSTART_FOLDER}"
    if [ -f "${ALL_USERS_LAUNCHERS_DIR}/$1.desktop" ]; then
      cp "${ALL_USERS_LAUNCHERS_DIR}/$1.desktop" "${AUTOSTART_FOLDER}/$1.desktop"
      if [ ${EUID} -eq 0 ]; then
        apply_permissions "${AUTOSTART_FOLDER}/$1.desktop"
      fi
    elif [ -f "${PERSONAL_LAUNCHERS_DIR}/$1.desktop" ]; then
      cp "${PERSONAL_LAUNCHERS_DIR}/$1.desktop" "${AUTOSTART_FOLDER}/$1.desktop"
      if [ ${EUID} -eq 0 ]; then
        apply_permissions "${AUTOSTART_FOLDER}/$1.desktop"
      fi
    else
      output_proxy_executioner "echo WARNING: The file $1.desktop does not exist, in either ${ALL_USERS_LAUNCHERS_DIR} or ${PERSONAL_LAUNCHERS_DIR}, skipping..." "${FLAG_QUIETNESS}"
      return
    fi
  fi
}


# - Description: Change ownership of folders recursively.
# - Permission: Can be run as root.
# - Argument 1: user
# - Argument 2: Path
custom_permission()
{
  chown -R "$1:$1" "$2"
}


# - Description: Applies the user permissions recursively on all the files and directories contained recursively in the
#   folder received by argument.
# - Permissions: Can be called as root or user. It will put chmod 755 to all the files recursively in the received
#   directory, but as root it will also change their group and owner to the one invoking sudo, by consulting variable
#   SUDO_USER.
apply_permissions_recursively()
{
  if [ -d "$1" ]; then
    if [ ${EUID} == 0 ]; then  # directory
      chgrp -R "${SUDO_USER}" "$1"
      chown -R "${SUDO_USER}" "$1"
    fi
    chmod 755 -R "$1"
  else
    output_proxy_executioner "echo WARNING: This functions only accepts a directory as an argument, Skipping..." "${FLAG_QUIETNESS}"
  fi
}


# - Description: Apply standard permissions and set owner and group to the user who called root.
# - Permissions: This functions can be called as root or user.
# - Arguments:
#   * Argument 1: Path to the file or directory whose permissions are changed.
#   * Argument 2 (optional): Custom mask of permissions
apply_permissions()
{
  if [ -z "$2" ]; then
    permission_mask="755"
  else
    permission_mask="$2"
  fi

  if [ -f "$1" ]; then
    if [ ${EUID} == 0 ]; then  # file
      chgrp "${SUDO_USER}" "$1"
      chown "${SUDO_USER}" "$1"
    fi
    chmod "${permission_mask}" "$1"
  elif [ -d "$1" ]; then
    if [ ${EUID} == 0 ]; then  # directory
      chgrp "${SUDO_USER}" "$1"
      chown "${SUDO_USER}" "$1"
    fi
    chmod "${permission_mask}" "$1"
  else
    output_proxy_executioner "echo WARNING: The file or directory $1 does not exist and its permissions could not have been changed. Skipping..." "${FLAG_QUIETNESS}"
  fi
  unset permission_mask
}


# - Description: Creates the file with $1 specifying location and name of the file. Afterwards, apply permissions to it,
# to make it property of the $SUDO_USER user (instead of root), which is the user that originally ran the sudo command
# to run this script.
# - Permissions: This functions is expected to be called as root, or it will throw an error, since $SUDO_USER is not
# defined in the the scope of the normal user.
# - Argument 1: Path to the file that we want to create.
# - Argument 2 (Optional): Content of the file we want to create.
# - Argument 3 (Optional): Relative path from customizer repository to the file that will be copied to create the file.
#   By using this option the function will ignore data of argument 2.
create_file()
  {
  local -r folder="$(echo "$1" | rev | cut -d "/" -f2- | rev)"
  local -r filename="$(echo "$1" | rev | cut -d "/" -f1 | rev)"
  if [ -n "$3" ]; then
    if [ -f "$3" ]; then
      create_folder "${folder}"
      cp "$3" "$1"
      apply_permissions "$1"
      translate_variables "$1"
    else
      output_proxy_executioner "echo WARNING: The specified path to a customizer internal file $3 does not exist. It will be skipped" "${FLAG_QUIETNESS}"
    fi
  else
    if [ -n "${filename}" ]; then
      create_folder "${folder}"
      echo -n "$2" > "$1"
      apply_permissions "$1"
    else
      output_proxy_executioner "echo WARNING: The name ${filename} is not a valid filename for a file in create_file. The file will not be created." "${FLAG_QUIETNESS}"
    fi
  fi
}


# - Description: Creates the necessary folders in order to make $1 a valid path. Afterwards, converts that dir to a
# writable folder, now property of the $SUDO_USER user (instead of root), which is the user that ran the sudo command.
# Note that by using mkdir -p we can pass a path that implies the creation of 2 or more directories without any
# problem. For example create_folder /home/user/all/directories/will/be/created.
# - Permissions: This functions is expected to be called as root, or it will throw an error, since $SUDO_USER is not
# defined in the the scope of the normal user.
# - Argument 1: Path to the directory that we want to create.
# - Argument 2: Mask permission for the folder.
create_folder() {
  mkdir -p "$1"
  apply_permissions "$1" "$2"
}


# - Description: Creates a valid launcher for the normal user in the desktop using an already created launcher from an
# automatic install (for example using $DEFAULT_PACKAGE_MANAGER or dpkg).
# - Permissions: This function expects to be called as root since it uses the variable $SUDO_USER.
# - Argument 1: name of the desktop launcher in ALL_USERS_LAUNCHERS_DIR.
copy_launcher() {
  if [ -f "${ALL_USERS_LAUNCHERS_DIR}/$1" ]; then
    cp "${ALL_USERS_LAUNCHERS_DIR}/$1" "${XDG_DESKTOP_DIR}/$1"
    apply_permissions "${XDG_DESKTOP_DIR}/$1"
  elif [ -f "${PERSONAL_LAUNCHERS_DIR}/$1" ]; then
    cp "${PERSONAL_LAUNCHERS_DIR}/$1" "${XDG_DESKTOP_DIR}/$1"
    apply_permissions "${XDG_DESKTOP_DIR}/$1"
  else
    output_proxy_executioner "echo WARNING: Can't find $1 launcher in ${ALL_USERS_LAUNCHERS_DIR} or ${PERSONAL_LAUNCHERS_DIR}." "${FLAG_QUIETNESS}"
  fi
}


# - Description: This function accepts an undefined number of pairs of arguments. The first of the pair is a path to a
#   binary that will be linked to our path. The second one is the name that it will have as a terminal command.
#   This function processes the last optional arguments of the function decompress, but can be
#   used as a manual way to add binaries to the PATH, in order to add new commands to your environment.
# - Argument 1: Absolute path to the binary you want to be in the PATH.
# - Argument 2: Name of the command that will be added to your environment to execute the previous binary.
# - Argument 3 and 4, 5 and 6, 7 and 8... : Same as argument 1 and 2.
create_links_in_path() {
  if [ ${EUID} == 0 ]; then  # user
    local -r directory="${ALL_USERS_PATH_POINTED_FOLDER}"
  else
    local -r directory="${PATH_POINTED_FOLDER}"
  fi
  while [ $# -gt 0 ]; do
    ln -sf "$1" "${directory}/$2"
    apply_permissions "${directory}/$2"
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


# - Description: This function guesses the mimetype of a file and decompresses it accordingly. Currently it recognises
#   zip, tar.gz, tar.bz2, tar.xz. The function can receive a path to the desired file to decompress:
#     * Absolute path to a file: (path beginning with /) This file will be decompressed.
#     * Empty argument: The file $USR_BIN_FOLDER/downloading_program will be decompressed.
#     * Relative path to a file: Relative from $USR_BIN_FOLDER, so the file $USR_BIN_FOLDER/$1 will be decompressed,
#       where $1 is a sub-path that can contain folders.
#     * Only a filename: Relative from $USR_BIN_FOLDER, so the file file $USR_BIN_FOLDER/$1 will be decompressed.
# - Arguments:
#   * Argument 1: Path to the file to decompress.
#   * Argument 2: If argument 2 is set, it will try to get the name of a directory that is in the root of the
#     compressed file. Then, after the decompressing, it will rename that directory to $2. If a single directory is
#     not detected inside of the root of the decompressed file, it will be created manually and the decompressed file
#     will be extracted INSIDE of this created directory.
decompress() {
  local dir_name=
  local file_name=
  # capture directory where we have to decompress
  if [ -z "$1" ]; then
    dir_name="${BIN_FOLDER}"
    file_name="downloading_program"
  elif echo "$1" | grep -Eqo "^/"; then
    # Absolute path to a file
    dir_name="$(echo "$1" | rev | cut -d "/" -f2- | rev)"
    file_name="$(echo "$1" | rev | cut -d "/" -f1 | rev)"
  else
    if echo "$1" | grep -Eqo "/"; then
      # Relative path to a file containing subfolders
      dir_name="${BIN_FOLDER}/$(echo "$1" | rev | cut -d "/" -f2- | rev)"
      file_name="$(echo "$1" | rev | cut -d "/" -f1 | rev)"
    else
      # Only a filename
      dir_name="${BIN_FOLDER}"
      file_name="$1"
    fi
  fi

  # We have to inherit if $2 is set. Try to capture the name of the internal folder in the compressed fileho
  local mime_type=
  mime_type="$(file --mime-type "${dir_name}/${file_name}" | cut -d ":" -f2 | tr -d " ")"
  if [ -n "$2" ]; then
    # Detect internal_folder_name
    case "${mime_type}" in
      "application/zip")
        local internal_folder_name=
        internal_folder_name="$(unzip -l "${dir_name}/${file_name}" | head -4 | tail -1 | tr -s " " | cut -d " " -f5)"
        # The captured line ends with / so it is a valid directory
        if echo "${internal_folder_name}" | grep -Eqo "/$"; then
          internal_folder_name="$(echo "${internal_folder_name}" | cut -d "/" -f1)"
        else
          # Set the internal folder name empty if it is not detected
          internal_folder_name=""
        fi
      ;;
      "application/x-bzip-compressed-tar" | "application/x-bzip2")
        local -r internal_folder_name=$( (tar -tjf - | head -1 | cut -d "/" -f1) < "${dir_name}/${file_name}")
      ;;
      "application/gzip")
        local -r internal_folder_name=$( (tar -tzf - | head -1 | cut -d "/" -f1) < "${dir_name}/${file_name}")
      ;;
      "application/x-xz")
        local -r internal_folder_name=$( (tar -tJf - | head -1 | cut -d "/" -f1) < "${dir_name}/${file_name}")
      ;;
      *)
        output_proxy_executioner "echo ERROR: ${mime_type} is not a recognised mime type for the compressed file in ${dir_name}/${file_name}" "${FLAG_QUIETNESS}"
        exit 1
      ;;
    esac

    # Check that variable internal_folder_name is set, if not, decompress in a made up folder.
    if [ -z "${internal_folder_name}" ]; then
      # Create a folder where we will decompress the compressed file that has no directory in the root
      rm -Rf "${dir_name:?}/$2"
      create_folder "${dir_name}/$2"
      mv "${dir_name}/${file_name}" "${dir_name}/$2"  # Move compressed file to a folder where we will decompress it
      # Reset the directory location of the compressed file.
      dir_name="${dir_name}/$2"
    else
      # Clean to avoid conflicts with previously installed software or aborted installation
      rm -Rf "${dir_name}/${internal_folder_name:?"ERROR: The name of the installed program could not been captured."}"
    fi
  fi

  # Use mimetype for extraction
  if [ -f "${dir_name}/${file_name}" ]; then
    case "${mime_type}" in
      "application/zip")
        (
          cd "${dir_name}" || exit
          unzip -o "${file_name}"
        )
      ;;
      "application/x-bzip-compressed-tar" | "application/x-bzip2")
      # Decompress in a subshell to avoid changing the working directory in the current shell
        (
          cd "${dir_name}" || exit
          tar -xjf -
        ) < "${dir_name}/${file_name}"
      ;;
      "application/gzip")
        (
          cd "${dir_name}" || exit
          tar -xzf -
        ) < "${dir_name}/${file_name}"
      ;;
      "application/x-xz")
        (
          cd "${dir_name}" || exit
          tar -xJf -
        ) < "${dir_name}/${file_name}"
      ;;
      *)
        output_proxy_executioner "echo ERROR: ${mime_type} is not a recognised mime type for the compressed file in ${dir_name}/${file_name}" "${FLAG_QUIETNESS}"
        exit 1
      ;;
    esac
  else
    output_proxy_executioner "echo ERROR: The function decompress did not receive a valid path to the compressed file. The path ${dir_name}/${file_name} does not exist" "${FLAG_QUIETNESS}"
    exit 1
  fi
  # Delete file. Now that it has been decompressed is just trash
  rm -f "${dir_name}/${file_name}"

  # Now we need to change the name of the decompressed folder and the existence of $2 in order to change the name of the
  # decompressed folder. We only enter here if they are different, if not skip since it is pointless because the
  # folder already has the desired name.
  if [ -n "${internal_folder_name}" ]; then
    # Check if we know the name of the folder that is in the root of the compressed file
    if [ "$2" != "${internal_folder_name}" ]; then
      # If the name of the internal folder of the compressed is not $3, then rename to $3
      if [ -n "$2" ]; then
        # Delete the folder that we are going to move to avoid collisions
        rm -Rf "${dir_name:?}/$2"
        mv "${dir_name}/${internal_folder_name}" "${dir_name}/$2"
      fi
    fi
  fi
}


# - Description: Downloads a file from the link provided in $1 and, if specified, with the location and name specified
#   in $2. If $2 is not defined, the file is downloaded into ${BIN_FOLDER}/downloading_program.
# - Permissions: Can be called as root or normal user. If called as root changes the permissions and owner to the
#   $SUDO_USER user, otherwise, needs permissions to create the file $2.
# - Argument 1: Link to the file to download.
# - Argument 2 (optional): Path to the created file, allowing to download in any location and use a different filename.
#   By default the name of the file is "downloading_file" and the PATH where is being downloaded is $BIN_FOLDER.
download() {
  local dir_name=
  local file_name=
  # Check if a path or name is specified
  if [ -z "$2" ]; then
    # default options
    dir_name="${BIN_FOLDER}"
    file_name=downloading_program
  else
    # Custom file or folder to download
    if echo "$2" | grep -Eqo "^/"; then
      # Absolute path
      if [ -d "$2" ]; then
        # is directory
        dir_name="$2"
        file_name=downloading_program
      else
        # maybe is the path to a file
        dir_name="$(echo "$2" | rev | cut -d "/" -f2- | rev)"
        file_name="$(echo "$2" | rev | cut -d "/" -f1 | rev)"
        if [ ! -d "${dir_name}" ]; then
          output_proxy_executioner "echo ERROR: the directory passed is absolute but it is not a directory and its first subdirectory does not exist" "${FLAG_QUIETNESS}"
          exit
        fi
      fi
    else
      if echo "$2" | grep -Eqo "/"; then
        # Relative path that contains subfolders
        if [ -d "${BIN_FOLDER}/$2" ]; then
          # Directory
          local -r dir_name="${BIN_FOLDER}/$2"
          local file_name=downloading_program
        else
          # maybe is a path to a file
          dir_name="${BIN_FOLDER}/$(echo "$2" | rev | cut -d "/" -f2- | rev)"
          file_name="$(echo "$2" | rev | cut -d "/" -f1 | rev)"
          if [ ! -d "${dir_name}" ]; then
            output_proxy_executioner "echo ERROR: the directory passed is relative but it is not a directory and its first subdirectory does not exist" "${FLAG_QUIETNESS}"
            exit
          fi
        fi
      else
        # It is just actually the name of the file downloaded to default BIN_FOLDER
        local -r dir_name="${BIN_FOLDER}"
        local file_name="$2"
      fi
    fi
  fi

  # Check if it is cached
  if [ -f "${CACHE_FOLDER}/${file_name}" ] && [ "${FLAG_CACHE}" -eq 1 ]; then
    cp "${CACHE_FOLDER}/${file_name}" "${dir_name}/${file_name}"
    if [ "${EUID}" -eq 0 ]; then
        apply_permissions "${dir_name}/${file_name}"
    fi
  else  # Not cached or we do not use cache: we have to download
    echo -en '\033[1;33m'
    wget --show-progress --no-check-certificate -O "${TEMP_FOLDER}/${file_name}" "$1"
    echo -en '\033[0m'

    if [ "${FLAG_CACHE}" -eq 1 ]; then
      # Move to cache folder to construct cache
      mv "${TEMP_FOLDER}/${file_name}" "${CACHE_FOLDER}/${file_name}"
      # If we are root change permissions
      if [ "${EUID}" -eq 0 ]; then
        apply_permissions "${CACHE_FOLDER}/${file_name}"
      fi
      # Copy file to the desired place of download
      cp "${CACHE_FOLDER}/${file_name}" "${dir_name}/${file_name}"
      if [ "${EUID}" -eq 0 ]; then
        apply_permissions "${dir_name}/${file_name}"
      fi
    else
      # Move directly to the desired place of download
      mv "${TEMP_FOLDER}/${file_name}" "${dir_name}/${file_name}"
      # If we are root change permissions
      if [ "${EUID}" -eq 0 ]; then
        apply_permissions "${dir_name}/${file_name}"
      fi
    fi

  fi
}


# - Description: Associate a file type (mime type) to a certain application using its desktop launcher.
# - Permissions: Same behaviour being root or normal user.
# - Argument 1: File types. Example: application/x-shellscript.
# - Argument 2: Application. Example: sublime_text.desktop.
register_file_associations() {
  # Check if mimeapps exists
  if [ -f "${MIME_ASSOCIATION_PATH}" ]; then
    # Check if the association between a mime type and desktop launcher is already existent
    if ! grep -Eqo "$1=.*$2" "${MIME_ASSOCIATION_PATH}"; then
      # If mime type is not even present we can add the hole line
      if grep -Fqo "$1=" "${MIME_ASSOCIATION_PATH}"; then
        sed -i "/\[Added Associations\]/a $1=$2;" "${MIME_ASSOCIATION_PATH}"
      else
        # If not, mime type is already registered. We need to register another application for it
        if ! grep -Eqo "$1=.*;$" "${MIME_ASSOCIATION_PATH}"; then
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


# - Description: Receives the file path of a file text which contents will be evaluated by this function to look for
#   variables with the € format (€{variable}) and translate its symbol by the actual value in running memory.
# - Permissions: Needs writing permission to the received file because it will be overwritten in place.
# - Arguments:
#   * Argument 1: Absolute path to the file which will be parsed and its € variables translated.
translate_variables()
{
  if [ ! -f "$1" ]; then
    output_proxy_executioner "echo WARNING: The file $1 is not present or is not accesible"
    return
  fi
  detected_variables=($(grep -Eo "€{([A-Z]|[a-z]|_)*}" < "$1" | uniq))
  for variable in "${detected_variables[@]}"; do
    # Obtain only the variable name
    real_variable_name="$(echo "${variable}" | cut -d "{" -f2 | cut -d "}" -f1)"
    # Change variable for its real value
    sed "s@${variable}@${!real_variable_name}@g" -i "$1"
  done
}



# - Description: Returns the exec field from the received launcher keyname of the CURRENT_INSTALLATION_KEYNAME
# - Permission: Does not need special permissions
# - Arguments:
#   * Argument 1: launcher keyname
dynamic_launcher_deduce_exec()
{
  # Exec binariesinstalledpaths
  local -r override_exec="${CURRENT_INSTALLATION_KEYNAME}_$1_exec"
  local -r metadata_exec_temp="${CURRENT_INSTALLATION_KEYNAME}_binariesinstalledpaths[0]"
  local -r metadata_exec="$(echo "${!metadata_exec_temp}" | cut -d ';' -f2 )"
  if [ ! -z "${!override_exec}" ]; then
    echo "${!override_exec}"
  else
    echo "${metadata_exec}"
  fi
}


# - Description: Returns the icon field (path to icon) from the received launcher keyname of the
#   CURRENT_INSTALLATION_KEYNAME loaded in the CURRENT_INSTALLATION_FOLDER folder.
# - Permission: Does need to create the icon in the CURRENT_INSTALLATION_FOLDER
# - Arguments:
#   * Argument 1: launcher keyname
dynamic_launcher_deduce_icon()
{
  override_icon="${CURRENT_INSTALLATION_KEYNAME}_$1_icon"
  metadata_icon="${CURRENT_INSTALLATION_KEYNAME}_icon"
  if [ ! -z "${!override_icon}" ]; then
    create_folder "${CURRENT_INSTALLATION_FOLDER}"
    cp "${CUSTOMIZER_PROJECT_FOLDER}/data/static/${CURRENT_INSTALLATION_KEYNAME}/${!override_icon}" "${CURRENT_INSTALLATION_FOLDER}"
    apply_permissions "${CURRENT_INSTALLATION_FOLDER}/${!override_icon}"
    echo "${CURRENT_INSTALLATION_FOLDER}/${!override_icon}"
  else
    create_folder "${CURRENT_INSTALLATION_FOLDER}"
    cp "${CUSTOMIZER_PROJECT_FOLDER}/data/static/${CURRENT_INSTALLATION_KEYNAME}/${!metadata_icon}" "${CURRENT_INSTALLATION_FOLDER}"
    apply_permissions "${CURRENT_INSTALLATION_FOLDER}/${!metadata_icon}"
    echo "${CURRENT_INSTALLATION_FOLDER}/${!metadata_icon}"
  fi
}


# - Description: Override .desktop Desktop launchers feature properties
# - Permissions:
# Argument 1: Launcher keyname
# Argument 2: Program keyname
# Argument 3:
create_dynamic_launcher() {
  # feature name
  override_name="$2_$1_name"
  metadata_name="$2_name"
  text="[Desktop Entry]
Type=Application
Encoding=UTF-8
NoDisplay=false"
  if [ ! -z "${!override_name}" ]; then
    text+=$'\n'"Name=${!override_name}"
  else
    text+=$'\n'"Name=${!metadata_name}"
  fi

  # Version
  override_version="$2_$1_version"
  metadata_version="$2_version"
  if [ ! -z "${!override_version}" ]; then
    text+=$'\n'"Version=${!override_version}"
  else
    text+=$'\n'"Version=${!metadata_version}"
  fi

  override_genericname_pointer="$2_$1_description"
  metadata_genericname_pointer="$2_description"
  if [ ! -z "${!override_genericname_pointer}" ]; then
    text+=$'\n'"GenericName=${!override_genericname_pointer}"
  else
    text+=$'\n'"GenericName=${!metadata_genericname_pointer}"
  fi

  # Commentary
  override_commentary="$2_$1_commentary"
  metadata_commentary="$2_commentary"
  if [ ! -z "${!override_commentary}" ]; then
    text+=$'\n'"Comment=${!override_commentary}"
  else
    text+=$'\n'"Comment=${!metadata_commentary}"
  fi

  # Tags
  override_tags="$2_$1_tags[@]"
  metadata_tags="$2_tags[@]"
  if [ ! -z "${!override_tags}" ]; then
    text+=$'\n'"Keywords="
    for tag_override in "${!override_tags}"; do
      text+="${tag_override};"
    done
  else
    text+=$'\n'"Keywords="
    for tag_metadata in "${!metadata_tags}"; do
      text+="${tag_metadata};"
    done
  fi

  # Icon
  local icon_temp=
  icon_temp="$(dynamic_launcher_deduce_icon "$1")"
  text+=$'\n'"Icon=${icon_temp}"

  # Categories from systemcategories
  override_systemcategories="$2_$1_systemcategories[@]"
  metadata_systemcategories="$2_systemcategories[@]"
  if [ ! -z "${!override_systemcategories}" ]; then
    text+=$'\n'"Categories="
    for category_override in "${!override_systemcategories}"; do
      text+="${category_override};"
    done
  else
    text+=$'\n'"Categories="
    for category_metadata in "${!metadata_systemcategories}"; do
      text+="${category_metadata};"
    done
  fi

  # Exec and Tryexec from binariesinstalledpaths
  local exec_temp=
  exec_temp="$(dynamic_launcher_deduce_exec "$1")"
  text+=$'\n'"Exec=${exec_temp}"
  if echo "${exec_temp}" | grep -qE " " ; then
    text+=$'\n'"TryExec=$(echo "${exec_temp}" | cut -d " " -f1)"
  else
    text+=$'\n'"TryExec=${exec_temp}"
  fi

  # Terminal by default is set to false, true if overridden
  local -r override_terminal="$2_$1_terminal"
  if [ ! -z "${!override_terminal}" ]; then
    text+=$'\n'"Terminal=${!override_terminal}"
  else
    text+=$'\n'"Terminal=false"
  fi

  # Override mimetypes over associatedfiletypes
  override_mime="$2_$1_mimetypes[@]"
  metadata_mime="$2_associatedfiletypes[@]"
  if [ ! -z "${!override_mime}" ]; then
    text+=$'\n'"MimeType="
    for mime_override in "${!override_mime}"; do
      text+="${mime_override};"
    done
  else
    text+=$'\n'"MimeType="
    for mime_metadata in "${!metadata_mime}"; do
      text+="${mime_metadata};"
    done
  fi

  # Override start up notify over the default true
  local -r override_notify="$2_$1_notify"
  if [ ! -z "${!override_notify}" ]; then
    text+=$'\n'"StartupNotify=${!override_notify}"
  else
    text+=$'\n'"StartupNotify=true"
  fi

  # Override Windows Manager Class over the default with the feature keyname
  local -r override_windowclass="$2_$1_windowclass"
  if [ ! -z "${!override_windowclass}" ]; then
    text+=$'\n'"StartupWMClass=${!override_windowclass}"
  else
    text+=$'\n'"StartupWMClass=$2"
  fi

  # https://askubuntu.com/questions/1370616/whats-the-point-of-a-desktop-file-with-nodisplay-true
  # Override nodisplay option over the default true
  local -r override_nodisplay="$2_$1_nodisplay"
  if [ ! -z "${!override_nodisplay}" ]; then
    text+=$'\n'"NoDisplay=${!override_nodisplay}"
  else
    text+=$'\n'"NoDisplay=false"
  fi

  # https://unix.stackexchange.com/questions/491299/understanding-autostartcondition-key-in-desktop-files
  # Override autostart condition over the default nothing
  local -r override_autostartcondition="$2_$1_autostartcondition"
  if [ ! -z "${!override_autostartcondition}" ]; then
    text+=$'\n'"AutostartCondition=${!override_autostartcondition}"
  fi

  # //RF Maybe deprecated?
  # Override the X-GNOME-AutoRestart over the default nothing
  local -r override_autorestart="$2_$1_autorestart"
  if [ ! -z "${!override_autorestart}" ]; then
    text+=$'\n'"X-GNOME-AutoRestart=${!override_autorestart}"
  fi

  # //RF Maybe deprecated?
  # Override the X-GNOME-AutoRestart over the default nothing
  local -r override_autorestartdelay="$2_$1_autorestartdelay"
  if [ ! -z "${!override_autorestartdelay}" ]; then
    text+=$'\n'"X-GNOME-Autostart-Delay=${!override_autorestartdelay}"
  fi

  # Add actions for this particular launcher
  override_actionkeynames="$2_$1_actionkeynames[@]"
  if [ ! -z "$(echo "${!override_actionkeynames}" )" ]; then
    text+=$'\n'"Actions="
    for actionkeyname_override in "${!override_actionkeynames}"; do
      text+="${actionkeyname_override};"
    done

    for actionkeyname_override in $(echo "${!override_actionkeynames}"); do
      local actionkeyname_name="$2_$1_${actionkeyname_override}_name"
      local actionkeyname_exec="$2_$1_${actionkeyname_override}_exec"
      local actionkeyname_icon="$2_$1_${actionkeyname_override}_icon"
      text+=$'\n'$'\n'"[Desktop Action ${actionkeyname_override}]"
      text+=$'\n'"Name=${!actionkeyname_name}"
      text+=$'\n'"Exec=${!actionkeyname_exec}"
      local action_icon=""
      local feature_icon_pointer="$2_icon"
      if [ -z "${!actionkeyname_icon}" ]; then
        if [ -z "${!feature_icon_pointer}" ]; then
          action_icon="${CUSTOMIZER_PROJECT_FOLDER}/.github/logo.png"
        else
          action_icon="${CUSTOMIZER_PROJECT_FOLDER}/data/static/$2/${!feature_icon_pointer}"
        fi
      else
        action_icon="${CUSTOMIZER_PROJECT_FOLDER}/data/static/$2/${!actionkeyname_icon}"
      fi
      text+=$'\n'"Icon=${action_icon}"
    done
  fi

  create_manual_launcher "${text}" "$3"
}


# - Description: Creates a Windows desktop launcher (an .ink file) using the provided launcherkeyname and the
#   ${CURRENT_INSTALLATION_KEYNAME}
# - Permissions: Can be executed as root or user. Needs to be able to write into ${HOME_FOLDER_WSL2}/Desktop, which in
#   this environment is pointed by ${XDG_DESKTOP_DIR}
# - Arguments:
#    * Argument 1: Launcher key name from which we will obtain information of this launcher
#    * Argument 2: suffix anticollision. To not overwrite files by having the same name if the current installation has
#      more than one desktop launcher.
create_WSL2_dynamic_launcher() {
  # Deduce exec field of the launcher
  local -r exec_command="$(dynamic_launcher_deduce_exec "$1")"
  # Deduce icon field of the launcher
  local -r icon_path="$(dynamic_launcher_deduce_icon "$1")"
  echo "ikon path:::  ${icon_path}"
  ls "${icon_path}"
  # Ensure convert dependency is present
  if ! which convert &>/dev/null; then
    if [ $EUID != 0 ]; then
      echo "ERROR: Icon could not be created due to convert is not installed, install it or run again with sudo"
      return
    else
      "${PACKAGE_MANAGER_INSTALL}" imagemagick
    fi
  fi
  # Convert icon from customizer project to .ico
  # TODO: Do convert uses .svg and .png (and .xpm)?; the formats that customizer uses to store icons? test
  convert -background none -define icon:auto-resize="256,128,96,64,48,32,24,16" "${icon_path}" "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.ico"

  # Content of the file that will be executing the WSL2 linux executable from Windows, create it in the
  # ${CURRENT_INSTALLATION_FOLDER}
  local -r vbscript_content="set shell = CreateObject(\"WScript.Shell\")
comm = \"wsl nohup ${exec_command} &>/dev/null\"
shell.Run comm,0"
  create_file "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.vbs" "${vbscript_content}"

  # Content of the cmd script that will be executed from Windows cmd to create a .vbs file that will be executed from
  # the cmd script and then deleted. This inner .vbs file is the one that creates the final .ink file using the binary
  # to execute, the icon path, the working directory (the current installation folder) and the position of the .ink,
  # which will be the Windows Desktop folder.
  # TODO: is \\wsl.localhost\Debian\home\.customizer\bin\KEYNAME equivalent to
  # TODO: \"\\\\wsl.localhost\\${WSL2_SUBSYSTEM}$(convert_to_windows_path "${CURRENT_INSTALLATION_FOLDER}"
  # TODO: Is this path correct from the VBS script to access the WSL2 subsystem from Windows?
  cmdscript_content="@echo on && set SCRIPT=\"%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs\" && echo Set oWS = WScript.CreateObject(\"WScript.Shell\") >> %SCRIPT% && echo sLinkFile = \"%SYSTEMDRIVE%\\Users\\${WSL2_USER}\\Desktop\\${CURRENT_INSTALLATION_KEYNAME}$2.lnk\" >> %SCRIPT% && echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT% && echo oLink.TargetPath = \"\\\\wsl.localhost\\${WSL2_SUBSYSTEM}$(convert_to_windows_path "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.vbs") >> %SCRIPT% && echo oLink.IconLocation = \"\\\\wsl.localhost\\${WSL2_SUBSYSTEM}$(convert_to_windows_path "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.ico") >> %SCRIPT% && echo oLink.WorkingDirectory = \"\\\\wsl.localhost\\${WSL2_SUBSYSTEM}$(convert_to_windows_path "${CURRENT_INSTALLATION_FOLDER}") >> %SCRIPT% && echo oLink.Save >> %SCRIPT% && cscript /logo %SCRIPT% && del %SCRIPT%"
  #create_file "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.bat" "${cmdscript_content}"


  # Call cmd of Windows to execute the .bat file that will create the .vbs file that will be executed to create the
  # link file in the Windows Desktop
  # TODO: Is this system call working? test calling the cmd from WSL2 with a dummy command and with root or user privileges
  echo "mama ${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.bat"
  #/mnt/c/windows/system32/cmd.exe "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.bat"
  /mnt/c/windows/system32/cmd.exe /C "@echo on && set SCRIPT=\"%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs\" && echo %SCRIPT% && echo basuko >> %SCRIPT%"
  /mnt/c/windows/system32/cmd.exe /C "${cmdscript_content}"
}


########################################################################################################################
################################## GENERIC INSTALL FUNCTIONS - OPTIONAL PROPERTIES #####################################
########################################################################################################################


# - Description: Expands launcher contents and add them to the desktop and dashboard.
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_launchercontents
#   and the name of the first argument in the common_data.sh table
generic_install_manual_launchers() {
  local -r launchercontents="$1_launchercontents[@]"
  local name_suffix_anticollision=""
  for launchercontent in "${!launchercontents}"; do
    create_manual_launcher "${launchercontent}" "$1${name_suffix_anticollision}"
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}


# - Description: Create a dynamic launcher for each keyname
# - Permissions: Does not need any permission.
generic_install_dynamic_launcher() {
  local -r launcherkeynames="${CURRENT_INSTALLATION_KEYNAME}_launcherkeynames[@]"
  local name_suffix_anticollision=""

  for launcherkeyname in "${!launcherkeynames}"; do
    create_dynamic_launcher "${launcherkeyname}" "${CURRENT_INSTALLATION_KEYNAME}${name_suffix_anticollision}"
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}


# - Description: Creates a WSL2 dynamic desktop launcher for each keyname
# - Permissions: Does not need any permission
generic_install_WSL2_dynamic_launcher() {
  local -r launcherkeynames="${CURRENT_INSTALLATION_KEYNAME}_launcherkeynames[@]"
  local name_suffix_anticollision=""

  for launcherkeyname in "${!launcherkeynames}"; do
    create_WSL2_dynamic_launcher "${launcherkeyname}" "${name_suffix_anticollision}"
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}


# - Description: Expands launcher names and add them to the favorites subsystem if FLAG_FAVORITES is set to 1.
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_launchernames
#   and the name of the first argument in the common_data.sh table.
generic_install_favorites() {
  local -r launchernames="$1_launchernames[@]"

  # To add to favorites if the flag is set
  if [ "${FLAG_FAVORITES}" == "1" ]; then
    if [ -n "${!launchernames}" ]; then
      for launchername in ${!launchernames}; do
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
    if echo "${associated_file_type}" | grep -Fo ";"; then
      local associated_desktop=
      associated_desktop="$(echo "${associated_file_type}" | cut -d ";" -f2)"
    else
      local associated_desktop="$1"
    fi
    register_file_associations "${associated_file_type}" "${associated_desktop}.desktop"
  done
}


# - Description: Expands keybinds for functions and programs and append to keybind sub-system
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_keybinds
#   and the name of the first argument in the common_data.sh table
generic_install_keybindings() {
  local -r keybinds="$1_keybindings[@]"
  for keybind in "${!keybinds}"; do
    local command=
    command="$(echo "${keybind}" | cut -d ";" -f1)"
    local bind=
    bind="$(echo "${keybind}" | cut -d ";" -f2)"
    local binding_name=
    binding_name="$(echo "${keybind}" | cut -d ";" -f3)"
    add_keybinding "${command}" "${bind}" "${binding_name}"
  done
}


# - Description: Expands downloads and saves it to BIN_FOLDER/FEATUREKEYNAME/NAME_OF_DOWNLOADED_FILE_i
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_downloads
#   and the name of the first argument in the common_data.sh table
generic_install_downloads() {
  local -r downloads="$1_downloads[@]"
  for each_download in ${!downloads}; do
    create_folder "${BIN_FOLDER}/$1"
    local -r url="$(echo "${each_download}" | cut -d ";" -f1)"
    local -r name="$(echo "${each_download}" | cut -d ";" -f2)"
    download "${url}" "${BIN_FOLDER}/$1/${name}"
  done
}


# - Description: Expands autostarting program option if set to 'yes' it'll expand launcher names to autostart
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_autostart
#   and associating it to all the launchers in $1_launchernames
generic_install_autostart() {
  local -r launchernames="$1_launchernames[@]"
  local -r autostartlaunchers_pointer="$1_autostartlaunchers[@]"
  if [ "${FLAG_AUTOSTART}" -eq 1 ]; then
    # If we have autostart launchers use them
    if [ -n "${!autostartlaunchers_pointer-}" ]; then
      local name_suffix_anticollision=""
      for autostartlauncher in "${!autostartlaunchers_pointer}"; do
        create_file "${AUTOSTART_FOLDER}/$1${name_suffix_anticollision}.desktop" "${autostartlauncher}"
        name_suffix_anticollision="${name_suffix_anticollision}_"
      done
    # If not use the launchers that are already in the system
    elif [ -n "${!launchernames-}" ]; then
      for launchername in ${!launchernames}; do
        autostart_program "${launchername}"
      done
    # Fallback to keyname to try if there is a desktop launcher in the system
    else
      autostart_program "$1"
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
    local binary_path=
    binary_path="$(echo "${binary_install_path_and_name}" | cut -d ";" -f1)"
    local binary_name=
    binary_name="$(echo "${binary_install_path_and_name}" | cut -d ";" -f2)"
    # Absolute path
    if echo "${binary_name}" | grep -Eqo "^/"; then
      create_links_in_path "${binary_path}" "${binary_name}"
    else
      create_links_in_path "${BIN_FOLDER}/$1/${binary_path}" "${binary_name}"
    fi
  done
}


# - Description: Expands $1_copy_launcher to obtain the name of the launcher to be copied explicitly
#   from /usr/share/applications
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_launchernames
generic_install_copy_launcher() {
 # Name of the launchers to be used by copy_launcher
  local -r launchernames="$1_launchernames[@]"
  # Copy launchers if defined
  for launchername in ${!launchernames}; do
    copy_launcher "${launchername}.desktop"
  done
}


# - Description: Expands function system initialization relative to ${HOME_FOLDER}/.profile
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_bashinitializations
#   and the name of the first argument in the common_data.sh table
generic_install_initializations() {
  local -r bashinitializations="$1_bashinitializations[@]"
  local name_suffix_anticollision=""
  for bashinit in "${!bashinitializations}"; do
    if [[ "${bashinit}" = *$'\n'* ]]; then
      # More than one line, we can guess its a content
      add_bash_initialization "${bashinit}" "$1${name_suffix_anticollision}.sh"
    else
      add_bash_initialization "" "$1${name_suffix_anticollision}.sh" "${CUSTOMIZER_PROJECT_FOLDER}/src/features/${CURRENT_INSTALLATION_KEYNAME}/${bashinit}"
    fi
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}


# - Description: Expands function contents and add them to .bashrc indirectly using bash_functions
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_bashfunctions
#   and the name of the first argument in the common_data.sh table
generic_install_functions() {
  local -r bashfunctions="$1_bashfunctions[@]"
  local name_suffix_anticollision=""
  for bashfunction in "${!bashfunctions}"; do
    if [[ "${bashfunction}" = *$'\n'* ]]; then
      # More than one line, we can guess its a content
      add_bash_function "${bashfunction}" "$1${name_suffix_anticollision}.sh"
    else
      # Only one line we guess it is a partial path
      add_bash_function "" "$1${name_suffix_anticollision}.sh" "${CUSTOMIZER_PROJECT_FOLDER}/src/features/${CURRENT_INSTALLATION_KEYNAME}/${bashfunction}"
    fi
    name_suffix_anticollision="${name_suffix_anticollision}_"
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
    if echo "${!path}" | grep -Eqo "^/"; then
      local destiny_path="${!path}"
    else
      local destiny_path="${BIN_FOLDER}/$1/${!path}"
    fi
    if [[ "${!content}" = *$'\n'* ]]; then
      # More than one line, we can guess its a content
      create_file "${destiny_path}" "${!content}"
    else
      # Only one line we guess it is a path
      create_file "${destiny_path}" "" "${CUSTOMIZER_PROJECT_FOLDER}/src/features/${CURRENT_INSTALLATION_KEYNAME}/${!content}"
    fi
  done
}


# - Description: Expands function system initialization relative to moving files
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_movefiles
generic_install_movefiles() {
  local -r movefiles="$1_movefiles[@]"
  local origin_files=""
  local destiny_directory=""
  for movedata in "${!movefiles}"; do
    origin_files="$(echo "${movedata}" | cut -d ";" -f1)"
    destiny_directory="$(echo "${movedata}" | cut -d ";" -f2)"
    create_folder "${destiny_directory}"
    if echo "${origin_files}" | grep -q '\*' ; then
      for filename in "${BIN_FOLDER}/$1/"${origin_files}; do
        mv -f "${filename}" "${destiny_directory}"
        if [ ${EUID} -eq 0 ]; then
          apply_permissions "${filename}"
        fi
      done
    else
      mv "${BIN_FOLDER}/$1/${origin_files}" "${destiny_directory}"
      if [ ${EUID} -eq 0 ]; then
        apply_permissions "${destiny_directory}/${origin_files}"
      fi
    fi 
  done
}


# - Description: Expands dependency installation
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the array $1_packagedependencies
generic_install_dependencies() {
  # Other dependencies to install with the package manager before the main package of software if present
  local -r packagedependencies="$1_packagedependencies[*]"
  if [ "${EUID}" -ne 0 ]; then
    if [ -n "${!packagedependencies}" ]; then
      output_proxy_executioner "echo WARNING: $1 has this dependencies: ${!packagedependencies} but are not going to be installed because you are not root. To install them, rerun installation with sudo." "${FLAG_QUIETNESS}"
      return
    fi
  fi
  # Install dependency packages
  for packagedependency in ${!packagedependencies}; do
    ${PACKAGE_MANAGER_FIXBROKEN}
    ${PACKAGE_MANAGER_INSTALL} "${packagedependency}"
  done
}


# - Description: Clones a repository in the desired place and caches it if the bit is active.
# - Permissions: Can be executed as root or user.
# - Argument 1: Keyname of the feature to install
# - Argument 2: URL to clone
generic_install_clone() {
   # Check if it is cached
  if [ -d "${CACHE_FOLDER}/$1_repository" ] && [ "${FLAG_CACHE}" -eq 1 ]; then
    rm -Rf "${BIN_FOLDER:?}/$1"
    cp -r "${CACHE_FOLDER}/$1_repository" "${BIN_FOLDER}/$1"
    if [ "${EUID}" -eq 0 ]; then
      apply_permissions_recursively "${BIN_FOLDER}/$1"
    fi
  else  # Not cached or we do not use cache: we have to download

    rm -Rf "${TEMP_FOLDER}/$1_repository"
    create_folder "${TEMP_FOLDER}/$1_repository"

    echo -en '\033[1;33m'
    git clone "$2" "${TEMP_FOLDER}/$1_repository"
    echo -en '\033[0m'

    if [ "${FLAG_CACHE}" -eq 1 ]; then
      # Move to cache folder to construct cache
      rm -Rf "${CACHE_FOLDER}/$1_repository"
      cp -r "${TEMP_FOLDER}/$1_repository" "${CACHE_FOLDER}"
      rm -Rf "${TEMP_FOLDER}/$1_repository"
      # If we are root change permissions
      if [ "${EUID}" -eq 0 ]; then
        apply_permissions_recursively "${CACHE_FOLDER}/$1_repository"
      fi

      # Avoid collisions
      rm -Rf "${BIN_FOLDER:?}/$1"
      # Copy file to the desired place of download
      cp -r "${CACHE_FOLDER}/$1_repository" "${BIN_FOLDER}/$1"
      if [ "${EUID}" -eq 0 ]; then
        apply_permissions_recursively "${BIN_FOLDER}/$1"
      fi
    else
      # Move directly to the desired place of download
      rm -Rf "${BIN_FOLDER:?}/$1"
      cp -r "${TEMP_FOLDER}/$1_repository" "${BIN_FOLDER}/$1"
      # Do not construct cache
      rm -Rf "${TEMP_FOLDER}/$1_repository"

      # If we are root change permissions
      if [ "${EUID}" -eq 0 ]; then
        apply_permissions_recursively "${BIN_FOLDER}/$1"
      fi
    fi
  fi
}


# - Description: Downloads a .deb package temporarily into BIN_FOLDER from the provided link and installs it using
#   dpkg -i.
# - Permissions: This functions needs to be executed as root: dpkg -i is an instruction that precises privileges.
# - Argument 1: Link to the package file to download.
# - Argument 2 (Optional): Tho show the name of the program downloading and thus change the name of the downloaded
#   package.
download_and_install_package() {
  if [ -z "$2" ]; then
    local file_name="${RANDOM}_package_file"
  else
    local file_name="$2"
  fi
  download "$1" "${BIN_FOLDER}/${file_name}"

  local mime_type=
  mime_type="$(mimetype "${BIN_FOLDER}/${file_name}" | cut -d ":" -f2 | tr -d " ")"
  echo MARCAAAA
  case "${mime_type}" in
    "application/zip"|"application/x-bzip-compressed-tar"|"application/gzip"|"application/x-xz")
      decompress "${BIN_FOLDER}/${file_name}" "${file_name}_decompressed"  # Decompressing
      ${PACKAGE_MANAGER_FIXBROKEN}
      ${PACKAGE_MANAGER_INSTALLPACKAGES} "${BIN_FOLDER}/${file_name}_decompressed"  # Notice the S at the end of this variable...
      ${PACKAGE_MANAGER_FIXBROKEN}
      # Remove decompressed folder that contains the installable packages
      rm -Rf "${BIN_FOLDER:?}/${file_name}_decompressed"
    ;;
    "application/vnd.debian.binary-package")
      ${PACKAGE_MANAGER_FIXBROKEN}
      ${PACKAGE_MANAGER_INSTALLPACKAGE} "${BIN_FOLDER}/${file_name}"  # ...is not the same as this variable.
      ${PACKAGE_MANAGER_FIXBROKEN}
    ;;
    *)
      output_proxy_executioner "echo ERROR: ${mime_type} is not a recognised mime type for the package file in ${dir_name}/${file_name}" "${FLAG_QUIETNESS}"
      exit 1
    ;;
  esac
}


########################################################################################################################
################################## GENERIC INSTALL FUNCTIONS - INSTALLATION TYPES ######################################
########################################################################################################################

# - Description: Installs packages using the default low-level package installation transparently. In the case of
#   apt-get it will be dpkg, and in the case of yum it will be rpm.
# - Permissions: Expected to be run by root.
# - Argument 1: String that matches a set of variables in data_features.
packageinstall_installation_type() {
  echo MARCA2
  local -r packageurls="$1_packageurls[@]"
  local name_suffix_anticollision=""
  for packageurl in "${!packageurls}"; do
    download_and_install_package "${packageurl}" "$1_package_file${name_suffix_anticollision}"
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done

}

# - Description: Installs packages using python environment.
# - Permissions: It is expected to be called as user.
# - Argument 1: Name of the program that we want to install, which will be the variable that we expand to look for its
#   installation data.
pythonvenv_installation_type() {
  rm -Rf "${BIN_FOLDER:?}/$1"
  python3 -m venv "${BIN_FOLDER}/$1"
  "${BIN_FOLDER}/$1/bin/python3" -m pip install -U pip
  "${BIN_FOLDER}/$1/bin/pip" install wheel

  local -r pipinstallations="$1_pipinstallations[@]"
  local -r pythoncommands="$1_pythoncommands[@]"
  for pipinstallation in ${!pipinstallations}; do
    "${BIN_FOLDER}/$1/bin/pip" install "${pipinstallation}"
  done
  for pythoncommand in "${!pythoncommands}"; do
    "${BIN_FOLDER}/$1/bin/python3" -m "${pythoncommand}"
  done

  # If we are root change permissions
  if [ "${EUID}" -eq 0 ]; then
    apply_permissions_recursively "${BIN_FOLDER:?}/$1"
  fi
}


# - Description: Clones git repository in BIN_FOLDER
# - Permissions: It is expected to be called as user.
# - Argument 1: Name of the program that we want to install, which will be the variable that we expand to look for its
#   installation data.
repositoryclone_installation_type() {
  local -r repositoryurl="$1_repositoryurl"
  generic_install_clone "$1" "${!repositoryurl}"
}



# - Description: Installs packages using $DEFAULT_PACKAGE_MANAGER
# - Permissions: Expected to be run by normal user.
# - Argument 1: String that matches a variable in data_features.
packagemanager_installation_type() {
  # Name of the package names to be installed with the package manager if present
  local -r packagenames="$1_packagenames[@]"

  for packagename in ${!packagenames}; do
    ${PACKAGE_MANAGER_INSTALL} "${packagename}"
    ${PACKAGE_MANAGER_FIXBROKEN}
  done
}


# - Description: Download a file into BIN_FOLDER, decompress it assuming that there is a directory inside it.
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
  # Pointer for expanding inheritance
  local -r donotinherit_pointer="$1_donotinherit"
  local defaultpath="${BIN_FOLDER}"

  if [ -n "${!compressedfilepathoverride}" ]; then
    create_folder "${!compressedfilepathoverride}"
    defaultpath="${!compressedfilepathoverride}"
  fi

  create_folder "${defaultpath}"
  download "${!compressedfileurl}" "${defaultpath}/$1_compressed_file"
  if [ "${!donotinherit_pointer}" == "yes" ]; then
    decompress "${defaultpath}/$1_compressed_file"
    apply_permissions_recursively "${defaultpath}"
  else
    decompress "${defaultpath}/$1_compressed_file" "$1"
    apply_permissions_recursively "${defaultpath}/$1"
  fi
}


########################################################################################################################
############################################## INSTALL MAIN FUNCTIONS ##################################################
########################################################################################################################

# - Description: Initialize common subsystems and common subfeatures
# - Permissions: Same behaviour being root or normal user.
data_and_file_structures_initialization() {
  output_proxy_executioner "echo INFO: Initializing data and file structures." "${FLAG_QUIETNESS}"

  if [ "${EUID}" == 0 ]; then
    if [ "${OS_NAME}" == "TermuxUbuntu" ]; then
      if ! users | grep -q "Android"; then
        # TODO: Add user non-interactively with no error output
        adduser "Android"
        usermod -aG sudo "Android"
        echo "Android  ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/Android
        yes | passwd "Android"
      fi
    fi
  fi

  # Customizer inner folders
  create_folder "${CUSTOMIZER_FOLDER}"
  create_folder "${CACHE_FOLDER}"
  create_folder "${TEMP_FOLDER}"
  create_folder "${DATA_FOLDER}"
  create_folder "${BIN_FOLDER}"
  create_folder "${FUNCTIONS_FOLDER}"
  create_folder "${INITIALIZATIONS_FOLDER}"

  # PATHs used to install subfeatures of each installation
  create_folder "${PATH_POINTED_FOLDER}"
  create_folder "${PERSONAL_LAUNCHERS_DIR}"
  create_folder "${FONTS_FOLDER}"
  create_folder "${XDG_DESKTOP_DIR}"
  create_folder "${XDG_PICTURES_DIR}"
  create_folder "${XDG_TEMPLATES_DIR}"

  # Initialize whoami file
  if [ "${OS_NAME}" == "WSL2" ]; then
    if [ ${EUID} != 0 ]; then
      username_wsl2="$(/mnt/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' | sed -e 's/\r//g')"
      if [ -z "${username_wsl2}" ]; then
        echo "ERROR: The user of Windows could not have been captured"
        exit 1
      else
        create_file "${CUSTOMIZER_PROJECT_FOLDER}/whoami" "${username_wsl2}"
      fi
    fi
  fi

  # Initialize bash functions
  if [ ! -f "${FUNCTIONS_PATH}" ]; then
    create_file "${FUNCTIONS_PATH}"
  fi
  # Initialize ${HOME_FOLDER}/.profile initializations
  if [ ! -f "${INITIALIZATIONS_PATH}" ]; then
    create_file "${INITIALIZATIONS_PATH}"
  fi

  # Initialize INSTALLED_FEATURES file pointing $DATA_FOLDER/installed_features.txt
  if [ ! -f "${INSTALLED_FEATURES}" ]; then
    create_file "${INSTALLED_FEATURES}"
  fi

  # Updates initializations
  # Avoid running bash functions non-interactively
  # Adds to the path the folder where we will put our soft links
  add_bash_function "${bash_functions_init}" "init.sh"
  # Create and / or update built-in favourites subsystem
  if [ ! -f "${PROGRAM_FAVORITES_PATH}" ]; then
    create_file "${PROGRAM_FAVORITES_PATH}"
  fi
  add_bash_initialization "${favorites_function}" "favorites.sh"

  # Create and / or update built-in keybinding subsystem
  if [ ! -f "${PROGRAM_KEYBINDINGS_PATH}" ]; then
    create_file "${PROGRAM_KEYBINDINGS_PATH}"
  fi
  add_bash_initialization "${keybinding_function}" "keybinding.sh"

  # We source from the bashrc of the current user or all the users depending on out permissions with priority
  # in being sourced from BASHRC_ALL_USERS_PATH
  if ! grep -Fo "source \"${FUNCTIONS_PATH}\"" "${BASHRC_ALL_USERS_PATH}" &>/dev/null; then
    if [ "${EUID}" == 0 ]; then
      echo "source \"${FUNCTIONS_PATH}\"" >> "${BASHRC_ALL_USERS_PATH}"
      if grep -Fo "source \"${FUNCTIONS_PATH}\"" "${BASHRC_PATH}" &>/dev/null; then
        remove_line "source \"${FUNCTIONS_PATH}\"" "${BASHRC_PATH}"
      fi
    else
      if ! grep -Fo "source \"${FUNCTIONS_PATH}\"" "${BASHRC_PATH}" &>/dev/null; then
        echo "source \"${FUNCTIONS_PATH}\"" >> "${BASHRC_PATH}"
      fi
    fi
  fi

  # Make sure that .profile sources .bash_initializations
  if ! grep -Fqo "${bash_initializations_import}" "${PROFILE_PATH}"; then
    echo -e "${bash_initializations_import}" >> "${PROFILE_PATH}"
  fi
}

# - Description: Update the system using $DEFAULT_PACKAGE_MANAGER -y update or $DEFAULT_PACKAGE_MANAGER -y upgrade depending a
# - Permissions: Can be called as root or user but user will not do anything.
pre_install_update() {
  if [ "${EUID}" == 0 ]; then
    if [ "${FLAG_UPGRADE}" -gt 0 ]; then
      output_proxy_executioner "echo INFO: Attempting to update system via ${DEFAULT_PACKAGE_MANAGER}." "${FLAG_QUIETNESS}"
      output_proxy_executioner "${PACKAGE_MANAGER_UPDATE}" "${FLAG_QUIETNESS}"
      output_proxy_executioner "echo INFO: System updated." "${FLAG_QUIETNESS}"
    fi
    if [ "${FLAG_UPGRADE}" == 2 ]; then
      output_proxy_executioner "echo INFO: Attempting to upgrade system via ${DEFAULT_PACKAGE_MANAGER}." "${FLAG_QUIETNESS}"
      output_proxy_executioner "${PACKAGE_MANAGER_UPGRADE}" "${FLAG_QUIETNESS}"
      output_proxy_executioner "echo INFO: System upgraded." "${FLAG_QUIETNESS}"
    fi
  fi
}

# - Description: Performs update of system fonts and bash environment.
# - Permissions: Same behaviour being root or normal user.
update_environment() {
  output_proxy_executioner "echo INFO: Rebuilding path cache" "${FLAG_QUIETNESS}"
  output_proxy_executioner "hash -r" "${FLAG_QUIETNESS}"
  output_proxy_executioner "echo INFO: Rebuilding font cache" "${FLAG_QUIETNESS}"
  output_proxy_executioner "fc-cache -f" "${FLAG_QUIETNESS}"
  output_proxy_executioner "echo INFO: Reloading bash features" "${FLAG_QUIETNESS}"
  output_proxy_executioner "source ${FUNCTIONS_PATH}" "${FLAG_QUIETNESS}"
  output_proxy_executioner "echo INFO: Finished execution" "${FLAG_QUIETNESS}"
}


if [ -f "${DIR}/functions_common.sh" ]; then
  # shellcheck source=./functions_common.sh
  source "${DIR}/functions_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_common.sh not found. Aborting..."
  exit 1
fi


########################################################################################################################
######################################### INSTALL SUBSYSTEMS FUNCTIONS #################################################
########################################################################################################################

# - Description: This functions is the basic piece of the favorites subsystem, but is not a function that it is
# executed directly, instead, is put in the bashrc and reads the file $PROGRAM_FAVORITES_PATH every time a terminal
# is invoked. This function and its necessary files such as $PROGRAM_FAVORITES_PATH are always present during the
# execution of install.
# This function basically processes and applies the results of the call to add_to_favorites function.
# - Permissions: This function is executed always as user since it is integrated in the user .bashrc. The function
# add_to_favorites instead, can be called as root or user, so root and user executions can be added

favorites_function="
# Check if gsettings command is available
if ! command -v gsettings &> /dev/null
then
  return
fi

if [ -f \"${PROGRAM_FAVORITES_PATH}\" ]; then
  while IFS= read -r line; do
    favorite_apps=\"\$(gsettings get org.gnome.shell favorite-apps)\"
    if [ -z \"\$(echo \$favorite_apps | grep -Fo \"\$line\")\" ]; then
      if [ -z \"\$(echo \$favorite_apps | grep -Fo \"[]\")\" ]; then
        # List with at least an element
        gsettings set org.gnome.shell favorite-apps \"\$(echo \"\$favorite_apps\" | sed s/.\$//), '\$line']\"
      else
        # List empty
        gsettings set org.gnome.shell favorite-apps \"['\$line']\"
      fi
    fi
  done < \"${PROGRAM_FAVORITES_PATH}\"
fi
"

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
keybinding_function="
# Check if gsettings command is available
if ! command -v gsettings &> /dev/null
then
  return
fi

if ! gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings &> /dev/null; then
  return
fi


# Check if there are keybindings available
if [ -f \"${PROGRAM_KEYBINDINGS_PATH}\" ]; then
  # regenerate list of active keybindings
  declare -a active_keybinds=\"\$(echo \"\$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)\" | sed 's/@as //g' | tr -d \",\" | tr \"[\" \"(\" | tr \"]\" \")\" | tr \"'\" \"\\\"\")\"

  # Every iteration is a line. IFS (internal field separator) set to empty
  while IFS= read -r line; do
    if [ -z \"\$line\" ]; then
      continue
    fi
    field_command=\"\$(echo \"\${line}\" | cut -d \";\" -f1)\"
    field_binding=\"\$(echo \"\${line}\" | cut -d \";\" -f2)\"
    field_name=\"\$(echo \"\${line}\" | cut -d \";\" -f3)\"

    i=0
    isInstalled=0
    # while custom keybinding i is occupied... try to update custom keybinding i if the keybinding to add and the one in position i have same name
    while [ -n \"\$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ name | cut -d \"'\" -f2)\" ]; do
      # Overwrite keybinding if there is a collision in the name with previous defined keybindings
      if [ \"\${field_name}\" == \"\$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ name | tr -d \"'\")\" ]; then
        # Overwrite
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ command \"'\${field_command}'\"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ binding \"'\${field_binding}'\"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ name \"'\${field_name}'\"
        # Make sure that the keybinding data that we just uploaded is active
        isActive=0
        for active_keybind in \${active_keybinds[@]}; do
          if [ \"\${active_keybind}\" == \"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/\" ]; then
            # The updated keybinding is active, mark as active to avoid further processing and escape the inner loop
            isActive=1
            break
          fi
        done
        # If is not active, active it by adding to the activated keybindings array
        if [ \${isActive} == 0 ]; then
          active_keybinds+=(/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/)
        fi
        # The keybind data was already in the table, no need for occupying a new custom keybind. Mark as installed to avoid post processing and escape de loop
        isInstalled=1
        break
      fi
      i=\$((i+1))
    done
    if [ \${isInstalled} == 0 ]; then
      # No collision: This is a new keybind. Append new keybinding data in a non occupied custom keybinding in position i, which at this point is empty
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ command \"'\${field_command}'\"
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ binding \"'\${field_binding}'\"
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/ name \"'\${field_name}'\"
      # Make sure that the keybinding data that we just uploaded is active
      isActive=0
      for active_keybind in \${active_keybinds[@]}; do
        if [ \"\${active_keybind}\" == \"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/\" ]; then
          isActive=1
          break
        fi
      done
      # If is not active, active it by adding to the activated keybindings array
      if [ \${isActive} == 0 ]; then
        active_keybinds+=(/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\${i}/)
      fi
    fi
  done < \"${PROGRAM_KEYBINDINGS_PATH}\"
  # Build string for gsettings set for the active custom keybindings from the array of active keybinds that we have been building
  active_keybinds_str=\"[\"
  for active_keybind in \${active_keybinds[@]}; do
    active_keybinds_str+=\"'\${active_keybind}', \"
  done
  # remove last comma and add the ] to close the array
  active_keybinds_str=\"\$(echo \"\${active_keybinds_str}\" | sed 's/, $//g')]\"

  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \"\${active_keybinds_str}\"
  #echo \"gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \"\${active_keybinds_str}\" \"
fi
"

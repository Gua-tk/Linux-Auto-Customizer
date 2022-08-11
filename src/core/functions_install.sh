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
  if isRoot; then
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
  if isRoot; then
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
# TODO refactor using get_dynamic launcher and serving the flag favorite the samw way that we serve the flag autostart
add_to_favorites() {
  for argument in "$@"; do
    if ! grep -Eqo "${argument}" "${PROGRAM_FAVORITES_PATH}"; then
      if [ -f "${ALL_USERS_LAUNCHERS_DIR}/${argument}.desktop" ] || [ -f "${PERSONAL_LAUNCHERS_DIR}/${argument}.desktop" ]; then
        echo "${argument}.desktop" >> "${PROGRAM_FAVORITES_PATH}"
      else
        output_proxy_executioner "The program ${argument} cannot be found in the usual place for desktop launchers favorites. Skipping" "WARNING"
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
      if isRoot; then
        apply_permissions "$1"
      fi
    else
      output_proxy_executioner "The file $1 does not exist, skipping..." "WARNING"
      return
    fi
  else # Else relative path from ALL_USERS_LAUNCHERS_DIR or PERSONAL_LAUNCHERS_DIR
    if [ -f "${ALL_USERS_LAUNCHERS_DIR}/$1.desktop" ]; then
      cp "${ALL_USERS_LAUNCHERS_DIR}/$1.desktop" "${AUTOSTART_FOLDER}/$1.desktop"
      if isRoot; then
        apply_permissions "${AUTOSTART_FOLDER}/$1.desktop"
      fi
    elif [ -f "${PERSONAL_LAUNCHERS_DIR}/$1.desktop" ]; then
      cp "${PERSONAL_LAUNCHERS_DIR}/$1.desktop" "${AUTOSTART_FOLDER}/$1.desktop"
      if isRoot; then
        apply_permissions "${AUTOSTART_FOLDER}/$1.desktop"
      fi
    else
      output_proxy_executioner "The file $1.desktop does not exist, in either ${ALL_USERS_LAUNCHERS_DIR} or ${PERSONAL_LAUNCHERS_DIR}, skipping..." "WARNING"
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
    if isRoot; then  # directory
      chgrp -R "${SUDO_USER}" "$1"
      chown -R "${SUDO_USER}" "$1"
    fi
    chmod 755 -R "$1"
  else
    output_proxy_executioner "This functions only accepts a directory as an argument, Skipping..." "WARNING"
  fi
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
      output_proxy_executioner "The specified path to a customizer internal file $3 does not exist. It will be skipped" "WARNING"
    fi
  else
    if [ -n "${filename}" ]; then
      create_folder "${folder}"
      echo -n "$2" > "$1"
      apply_permissions "$1"
    else
      output_proxy_executioner "The name ${filename} is not a valid filename for a file in create_file. The file will not be created." "WARNING"
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
    output_proxy_executioner "Can't find $1 launcher in ${ALL_USERS_LAUNCHERS_DIR} or ${PERSONAL_LAUNCHERS_DIR}." "WARNING"
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
  if isRoot; then  # user
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
  if isRoot; then  # root
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
        output_proxy_executioner "${mime_type} is not a recognised mime type for the compressed file in ${dir_name}/${file_name}" "ERROR"
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
        output_proxy_executioner "${mime_type} is not a recognised mime type for the compressed file in ${dir_name}/${file_name}" "ERROR"
      ;;
    esac
  else
    output_proxy_executioner "The function decompress did not receive a valid path to the compressed file. The path ${dir_name}/${file_name} does not exist" "ERROR"
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
          output_proxy_executioner "the directory passed is absolute but it is not a directory and its first subdirectory does not exist" "ERROR"
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
            output_proxy_executioner "the directory passed is relative but it is not a directory and its first subdirectory does not exist" "ERROR"
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
    if isRoot; then
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
      if isRoot; then
        apply_permissions "${CACHE_FOLDER}/${file_name}"
      fi
      # Copy file to the desired place of download
      cp "${CACHE_FOLDER}/${file_name}" "${dir_name}/${file_name}"
      if isRoot; then
        apply_permissions "${dir_name}/${file_name}"
      fi
    else
      # Move directly to the desired place of download
      mv "${TEMP_FOLDER}/${file_name}" "${dir_name}/${file_name}"
      # If we are root change permissions
      if isRoot; then
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
    output_proxy_executioner "${MIME_ASSOCIATION_PATH} is not present, so $2 cannot be associated to $1. Skipping..." "WARNING"
  fi
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

  local chosen_exec=
  if [ ! -z "${!override_exec}" ]; then
    chosen_exec="${!override_exec}"
  else
    chosen_exec="${metadata_exec}"
  fi
  echo "${chosen_exec}"
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
  create_folder "${CURRENT_INSTALLATION_FOLDER}"
  if [ ! -z "${!override_icon}" ]; then
    cp "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${!override_icon}" "${CURRENT_INSTALLATION_FOLDER}"
    apply_permissions "${CURRENT_INSTALLATION_FOLDER}/${!override_icon}"
    echo "${CURRENT_INSTALLATION_FOLDER}/${!override_icon}"
  elif [ ! -z "${!metadata_icon}" ]; then
    create_folder "${CURRENT_INSTALLATION_FOLDER}"
    cp "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${!metadata_icon}" "${CURRENT_INSTALLATION_FOLDER}"
    apply_permissions "${CURRENT_INSTALLATION_FOLDER}/${!metadata_icon}"
    echo "${CURRENT_INSTALLATION_FOLDER}/${!metadata_icon}"
  else
    if [ -f "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${CURRENT_INSTALLATION_KEYNAME}.png" ]; then
      create_folder "${CURRENT_INSTALLATION_FOLDER}"
      cp "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${CURRENT_INSTALLATION_KEYNAME}.png" "${CURRENT_INSTALLATION_FOLDER}"
      apply_permissions "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}.png"
      echo "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}.png"
    elif [ -f "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${CURRENT_INSTALLATION_KEYNAME}.svg" ]; then
      create_folder "${CURRENT_INSTALLATION_FOLDER}"
      cp "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${CURRENT_INSTALLATION_KEYNAME}.svg" "${CURRENT_INSTALLATION_FOLDER}"
      apply_permissions "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}.svg"
      echo "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}.svg"
    elif [ -f "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${CURRENT_INSTALLATION_KEYNAME}.xpm" ]; then
      create_folder "${CURRENT_INSTALLATION_FOLDER}"
      cp "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${CURRENT_INSTALLATION_KEYNAME}.xpm" "${CURRENT_INSTALLATION_FOLDER}"
      apply_permissions "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}.xpm"
      echo "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}.xpm"
    else
      create_folder "${CURRENT_INSTALLATION_FOLDER}"
      cp "${CUSTOMIZER_PROJECT_FOLDER}/.github/logo.png" "${CURRENT_INSTALLATION_FOLDER}"
      apply_permissions "${CURRENT_INSTALLATION_FOLDER}/logo.png"
      echo "${CURRENT_INSTALLATION_FOLDER}/logo.png"
    fi
  fi
}


# - Description: Override .desktop Desktop launchers feature properties
# - Permissions:
# Argument 1: Launcher keyname
get_dynamic_launcher() {
  # feature name
  override_name="${CURRENT_INSTALLATION_KEYNAME}_$1_name"
  metadata_name="${CURRENT_INSTALLATION_KEYNAME}_name"
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
  override_version="${CURRENT_INSTALLATION_KEYNAME}_$1_version"
  metadata_version="${CURRENT_INSTALLATION_KEYNAME}_version"
  if [ ! -z "${!override_version}" ]; then
    text+=$'\n'"Version=${!override_version}"
  else
    text+=$'\n'"Version=${!metadata_version}"
  fi

  override_genericname_pointer="${CURRENT_INSTALLATION_KEYNAME}_$1_description"
  metadata_genericname_pointer="${CURRENT_INSTALLATION_KEYNAME}_description"
  if [ ! -z "${!override_genericname_pointer}" ]; then
    text+=$'\n'"GenericName=${!override_genericname_pointer}"
  else
    text+=$'\n'"GenericName=${!metadata_genericname_pointer}"
  fi

  # Commentary
  override_commentary="${CURRENT_INSTALLATION_KEYNAME}_$1_commentary"
  metadata_commentary="${CURRENT_INSTALLATION_KEYNAME}_commentary"
  if [ ! -z "${!override_commentary}" ]; then
    text+=$'\n'"Comment=${!override_commentary}"
  else
    text+=$'\n'"Comment=${!metadata_commentary}"
  fi

  # Tags
  override_tags="${CURRENT_INSTALLATION_KEYNAME}_$1_tags[@]"
  metadata_tags="${CURRENT_INSTALLATION_KEYNAME}_tags[@]"
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
  override_systemcategories="${CURRENT_INSTALLATION_KEYNAME}_$1_systemcategories[@]"
  metadata_systemcategories="${CURRENT_INSTALLATION_KEYNAME}_systemcategories[@]"
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
  local -r override_terminal="${CURRENT_INSTALLATION_KEYNAME}_$1_terminal"
  if [ ! -z "${!override_terminal}" ]; then
    text+=$'\n'"Terminal=${!override_terminal}"
  else
    text+=$'\n'"Terminal=false"
  fi

  # Override mimetypes over associatedfiletypes
  override_mime="${CURRENT_INSTALLATION_KEYNAME}_$1_mimetypes[@]"
  metadata_mime="${CURRENT_INSTALLATION_KEYNAME}_associatedfiletypes[@]"
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
  local -r override_notify="${CURRENT_INSTALLATION_KEYNAME}_$1_notify"
  if [ ! -z "${!override_notify}" ]; then
    text+=$'\n'"StartupNotify=${!override_notify}"
  else
    text+=$'\n'"StartupNotify=true"
  fi

  # Override Windows Manager Class over the default with the feature keyname
  local -r override_windowclass="${CURRENT_INSTALLATION_KEYNAME}_$1_windowclass"
  if [ ! -z "${!override_windowclass}" ]; then
    text+=$'\n'"StartupWMClass=${!override_windowclass}"
  else
    text+=$'\n'"StartupWMClass=${CURRENT_INSTALLATION_KEYNAME}"
  fi

  # https://askubuntu.com/questions/1370616/whats-the-point-of-a-desktop-file-with-nodisplay-true
  # Override nodisplay option over the default true
  local -r override_nodisplay="${CURRENT_INSTALLATION_KEYNAME}_$1_nodisplay"
  if [ ! -z "${!override_nodisplay}" ]; then
    text+=$'\n'"NoDisplay=${!override_nodisplay}"
  else
    text+=$'\n'"NoDisplay=false"
  fi

  # https://unix.stackexchange.com/questions/491299/understanding-autostartcondition-key-in-desktop-files
  # Override autostart condition over the default nothing
  local -r override_autostartcondition="${CURRENT_INSTALLATION_KEYNAME}_$1_autostartcondition"
  if [ ! -z "${!override_autostartcondition}" ]; then
    text+=$'\n'"AutostartCondition=${!override_autostartcondition}"
  fi

  # //RF Maybe deprecated?
  # Override the X-GNOME-AutoRestart over the default nothing
  local -r override_autorestart="${CURRENT_INSTALLATION_KEYNAME}_$1_autorestart"
  if [ ! -z "${!override_autorestart}" ]; then
    text+=$'\n'"X-GNOME-AutoRestart=${!override_autorestart}"
  fi

  # //RF Maybe deprecated?
  # Override the X-GNOME-AutoRestart over the default nothing
  local -r override_autorestartdelay="${CURRENT_INSTALLATION_KEYNAME}_$1_autorestartdelay"
  if [ ! -z "${!override_autorestartdelay}" ]; then
    text+=$'\n'"X-GNOME-Autostart-Delay=${!override_autorestartdelay}"
  fi

  # //RF Maybe deprecated?
  # Override the X-GNOME-AutoRestart over the default nothing
  local -r overrideUbuntuGetText="${CURRENT_INSTALLATION_KEYNAME}_$1_ubuntuGetText"
  if [ ! -z "${!overrideUbuntuGetText}" ]; then
    text+=$'\n'"X-Ubuntu-Gettext-Domain=${!overrideUbuntuGetText}"
  fi

  # //RF Maybe deprecated?
  # Override the OnlyShowIn over the default nothing
  local -r overrideOnlyShowIn="${CURRENT_INSTALLATION_KEYNAME}_$1_OnlyShowIn[@]"
  if [ ! -z "$(echo "${!overrideOnlyShowIn}")" ]; then
    text+=$'\n'"OnlyShowIn="
    for mime_override in "${!overrideOnlyShowIn}"; do
      text+="${mime_override};"
    done
  fi

  # XMultipleArgs  X-MultipleArgs=false
  local -r overrideXMultipleArgs="${CURRENT_INSTALLATION_KEYNAME}_$1_XMultipleArgs"
  if [ ! -z "${!overrideXMultipleArgs}" ]; then
    text+=$'\n'"X-MultipleArgs=${!overrideXMultipleArgs}"
  fi

  # usesNotifications X-GNOME-UsesNotifications
  local -r overrideusesNotifications="${CURRENT_INSTALLATION_KEYNAME}_$1_usesNotifications"
  if [ ! -z "${!overrideusesNotifications}" ]; then
    text+=$'\n'"X-GNOME-UsesNotifications=${!overrideusesNotifications}"
  fi

  # dBusActivatable DBusActivatable
  local -r overridedBusActivatable="${CURRENT_INSTALLATION_KEYNAME}_$1_dBusActivatable"
  if [ ! -z "${!overridedBusActivatable}" ]; then
    text+=$'\n'"DBusActivatable=${!overridedBusActivatable}"
  fi

  # path Path
  local -r overridepath="${CURRENT_INSTALLATION_KEYNAME}_$1_path"
  if [ ! -z "${!overridepath}" ]; then
    text+=$'\n'"Path=${!overridepath}"
  fi

  # protocols X-KDE-Protocols
  local -r overrideprotocols="${CURRENT_INSTALLATION_KEYNAME}_$1_protocols"
  if [ ! -z "${!overrideprotocols}" ]; then
    text+=$'\n'"X-KDE-Protocols=${!overrideprotocols}"
  fi

  # Add actions for this particular launcher
  override_actionkeynames="${CURRENT_INSTALLATION_KEYNAME}_$1_actionkeynames[@]"
  if [ ! -z "$(echo "${!override_actionkeynames}" )" ]; then
    text+=$'\n'"Actions="
    for actionkeyname_override in "${!override_actionkeynames}"; do
      text+="${actionkeyname_override};"
    done

    for actionkeyname_override in $(echo "${!override_actionkeynames}"); do
      local actionkeyname_name="${CURRENT_INSTALLATION_KEYNAME}_$1_${actionkeyname_override}_name"
      local actionkeyname_exec="${CURRENT_INSTALLATION_KEYNAME}_$1_${actionkeyname_override}_exec"
      local actionkeyname_icon="${CURRENT_INSTALLATION_KEYNAME}_$1_${actionkeyname_override}_icon"
      local actionkeyname_onlyShowIn="${CURRENT_INSTALLATION_KEYNAME}_$1_${actionkeyname_override}_onlyShowIn"
      text+=$'\n'$'\n'"[Desktop Action ${actionkeyname_override}]"
      text+=$'\n'"Name=${!actionkeyname_name}"
      text+=$'\n'"Exec=${!actionkeyname_exec}"
      text+=$'\n'"OnlyShowIn=${!actionkeyname_onlyShowIn}"

      local action_icon=""
      local feature_icon_pointer="${CURRENT_INSTALLATION_KEYNAME}_icon"
      if [ -z "${!actionkeyname_icon}" ]; then
        if [ -z "${!feature_icon_pointer}" ]; then
          cp "${CUSTOMIZER_PROJECT_FOLDER}/.github/logo.png" "${CURRENT_INSTALLATION_FOLDER}"
          action_icon="${CURRENT_INSTALLATION_FOLDER}/logo.png"
        else
          cp "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${!feature_icon_pointer}" "${CURRENT_INSTALLATION_FOLDER}"
          action_icon="${CURRENT_INSTALLATION_FOLDER}/${!feature_icon_pointer}"
        fi
      else
        cp "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${!actionkeyname_icon}" "${CURRENT_INSTALLATION_FOLDER}"
        action_icon="${CURRENT_INSTALLATION_FOLDER}/${!actionkeyname_icon}"
      fi
      text+=$'\n'"Icon=${action_icon}"
    done
  fi
  text+=$'\n'
  echo "${text}"
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
  local exec_command="$(dynamic_launcher_deduce_exec "$1")"
  if echo "${exec_command}" | tr -s " " | cut -d " " -f2 | grep -qE "^%"; then
    exec_command="$(echo "${exec_command}" | tr -s " " |  cut -d " " -f1)"
  fi

  # Deduce icon field of the launcher
  local -r icon_path="$(dynamic_launcher_deduce_icon "$1")"

  # Ensure convert dependency is present
  if ! which convert &>/dev/null; then
    if ! isRoot; then
      echo "ERROR: Icon could not be created due to convert is not installed, install it or run again with sudo"
      return
    else
      "${PACKAGE_MANAGER_INSTALL}" imagemagick
    fi
  fi
  # Convert icon from customizer project to .ico
  mkdir -p "${HOME_FOLDER_WSL2}/.customizer/${CURRENT_INSTALLATION_KEYNAME}"
  convert -background none -define icon:auto-resize="256,128,96,64,48,32,24,16" "${icon_path}" "${HOME_FOLDER_WSL2}/.customizer/${CURRENT_INSTALLATION_KEYNAME}/${CURRENT_INSTALLATION_KEYNAME}$2.ico"

  # Content of the vbs script that will be executed from Windows cscript.exe to create a shortcut to our command to
  # execute the binary. This .vbs script is the one that creates the final .ink file using the binary to execute, the
  # icon path, the working directory (the current installation folder) and the position of the .ink, which will be the
  # Windows Desktop folder.
  cmdscript_content="
Set oWS = WScript.CreateObject(\"WScript.Shell\")
sLinkFile = \"C:\\Users\\${WSL2_USER}\\Desktop\\${CURRENT_INSTALLATION_KEYNAME}$2.lnk\"
Set oLink = oWS.CreateShortcut(sLinkFile)
oLink.TargetPath = \"\\\\wsl.localhost\\${WSL2_SUBSYSTEM}$(convert_to_windows_path "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.vbs")\"
oLink.IconLocation = \"C:\\Users\\${WSL2_USER}\\.customizer\\${CURRENT_INSTALLATION_KEYNAME}\\${CURRENT_INSTALLATION_KEYNAME}$2.ico\"
oLink.WorkingDirectory = \"\\\\wsl.localhost\\${WSL2_SUBSYSTEM}$(convert_to_windows_path "${CURRENT_INSTALLATION_FOLDER}")\"
oLink.Save
"
  create_file "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.vbs" "${cmdscript_content}"
  /mnt/c/windows/system32/cscript.exe /nologo "\\\\wsl.localhost\\${WSL2_SUBSYSTEM}$(convert_to_windows_path "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.vbs")"
    # Content of the file that will be executing the WSL2 linux executable from Windows, create it in the
  local -r vbscript_content="set shell = CreateObject(\"WScript.Shell\")
comm = \"wsl bash -c 'source ${FUNCTIONS_PATH}; nohup ${exec_command} &>/dev/null'\"
shell.Run comm,0"
  create_file "${CURRENT_INSTALLATION_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.vbs" "${vbscript_content}"
}


########################################################################################################################
################################## GENERIC INSTALL FUNCTIONS - OPTIONAL PROPERTIES #####################################
########################################################################################################################


# - Description: Create a dynamic launcher for each keyname
# - Permissions: Does not need any permission.
generic_install_dynamic_launcher() {
  local -r launcherkeynames="${CURRENT_INSTALLATION_KEYNAME}_launcherkeynames[@]"
  local name_suffix_anticollision=""

  if [ ! -n "$(echo "${!launcherkeynames}")" ]; then
    return
  fi
  local is_autostart_attended=
  if [ ${FLAG_AUTOSTART} -eq 1 ]; then
    is_autostart_attended=0
  else
    is_autostart_attended=1
  fi

  for launcherkeyname in "${!launcherkeynames}"; do
    # create_manual_launcher "${text}" "$2"
    autostart_pointer="${CURRENT_INSTALLATION_KEYNAME}_${launcherkeyname}_autostart"
    if [ "${!autostart_pointer}" == "yes" ]; then
      current_launcher="$(get_dynamic_launcher "${launcherkeyname}")"
      create_file "${AUTOSTART_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}${name_suffix_anticollision}.desktop" "${current_launcher}"
      is_autostart_attended=1
    else
      current_launcher="$(get_dynamic_launcher "${launcherkeyname}")"
      create_manual_launcher "${current_launcher}" "${CURRENT_INSTALLATION_KEYNAME}${name_suffix_anticollision}"

    fi
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done

  if [ "${is_autostart_attended}" -eq 1 ]; then
    return
  fi

  # Implicitly this feature has no autostart launcher, choosing the first one arbitrarily
  local -r first_launcher_keyname="$(echo "${launcherkeynames}" | cut -d ' ' -f1)"
  create_file "${AUTOSTART_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}${name_suffix_anticollision}.desktop" "$(get_dynamic_launcher "${first_launcher_keyname}")"
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
# TODO refactor
generic_install_favorites() {
  local -r launchernames="${CURRENT_INSTALLATION_KEYNAME}_launchernames[@]"

  # To add to favorites if the flag is set
  if [ "${FLAG_FAVORITES}" == "1" ]; then
    if [ -n "${!launchernames}" ]; then
      for launchername in ${!launchernames}; do
        add_to_favorites "${launchername}"
      done
    else
      add_to_favorites "${CURRENT_INSTALLATION_KEYNAME}"
    fi
  fi
}


# - Description: Expands file associations and register the desktop launchers as default application's mimetypes
# - Permissions: Can be executed as root or user.
generic_install_file_associations() {
  local -r associated_file_types="${CURRENT_INSTALLATION_KEYNAME}_associatedfiletypes[@]"
  for associated_file_type in ${!associated_file_types}; do
    if echo "${associated_file_type}" | grep -Fo ";"; then
      local associated_desktop=
      associated_desktop="$(echo "${associated_file_type}" | cut -d ";" -f2)"
    else
      local associated_desktop="${CURRENT_INSTALLATION_KEYNAME}"
    fi
    register_file_associations "${associated_file_type}" "${associated_desktop}.desktop"
  done
}


# - Description: Expands keybinds for functions and programs and append to keybind sub-system
# - Permissions: Can be executed as root or user.
generic_install_keybindings() {
  local -r keybinds="${CURRENT_INSTALLATION_KEYNAME}_keybindings[@]"
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


# - Description: Expands $1_binariesinstalledpaths which contain the relative path
#   from the installation folder or the absolute path separated by ';' with the name
#   of the link created in PATH.
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the variable $1_binariesinstalledpaths
generic_install_pathlinks() {
  # Path to the binaries to be added, with a ; with the desired name in the path
  local -r binariesinstalledpaths="${CURRENT_INSTALLATION_KEYNAME}_binariesinstalledpaths[@]"
  for binary_install_path_and_name in ${!binariesinstalledpaths}; do
    local binary_path=
    binary_path="$(echo "${binary_install_path_and_name}" | cut -d ";" -f1)"
    local binary_name=
    binary_name="$(echo "${binary_install_path_and_name}" | cut -d ";" -f2)"
    # Absolute path
    if echo "${binary_name}" | grep -Eqo "^/"; then
      create_links_in_path "${binary_path}" "${binary_name}"
    else
      create_links_in_path "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}/${binary_path}" "${binary_name}"
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

# Description: Add a gpg signature to GPG_TRUSTED_FOLDER from an URL
# Permissions: Can only be executed as root.
# Argument 1: URL of the gpg signature file
# Argument 2: suffix_anticollision
add_gpgSignature() {
  download "$1" "${TEMP_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.gpg"
  gpg --dearmor < "${TEMP_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.gpg" > "${GPG_TRUSTED_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.gpg"
  remove_file "${TEMP_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.gpg"
}

# Description: Iterates into urls of gpg keys to add them to GPG_TRUSTED_FOLDER
# Permissions: Can only be executed as root
generic_install_gpgSignatures() {
  # TODO: Key is stored in legacy trusted.gpg keyring (/etc/apt/trusted.gpg)
  if ! isRoot; then
    return
  fi

  local -r gpgSignatures="${CURRENT_INSTALLATION_KEYNAME}_gpgSignatures[@]"
  local collision=""
  for sign in ${!gpgSignatures}; do
    add_gpgSignature "${sign}" "${collision}"
    collision="${collision}_"
  done
  ${PACKAGE_MANAGER_UPDATE}
}

# Description: Add apt source to APT_SOURCES_LIST_FOLDER/{aptSourceName}.list from an URL
# Permissions: Can only be executed as root.
# Argument 1: URL of the apt source
# Argument 2: suffix_anticollision
add_source() {
  echo "$1" > "${APT_SOURCES_LIST_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}$2.list"
}

# Description: Iterates into urls of apt keys to add them to APT_SOURCES_LIST_FOLDER/{aptSourceName}.list
# Permissions: Can only be executed as root
generic_install_sources() {
  if ! isRoot; then
    return
  fi

  local -r sources="${CURRENT_INSTALLATION_KEYNAME}_sources[@]"
  local collision=""
  for sign in "${!sources}"; do
    add_source "${sign}" "${collision}"
    collision="${collision}_"
  done
  ${PACKAGE_MANAGER_UPDATE}
}

# - Description: Expands function system initialization relative to ${HOME_FOLDER}/.profile
# - Permissions: Can be executed as root or user.
generic_install_initializations() {
  local -r bashinitializations="${CURRENT_INSTALLATION_KEYNAME}_bashinitializations[@]"
  local name_suffix_anticollision=""
  for bashinit in "${!bashinitializations}"; do
    if [[ "${bashinit}" = *$'\n'* ]]; then
      # More than one line, we can guess its a content
      add_bash_initialization "${bashinit}" "$1${name_suffix_anticollision}.sh"
    elif ! echo "${bashinit}" | grep -Eq "/"; then
      # Only one line we guess it is a partial path
      add_bash_initialization "" "${CURRENT_INSTALLATION_KEYNAME}${name_suffix_anticollision}.sh" "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${bashinit}"
    else
      add_bash_initialization "" "${CURRENT_INSTALLATION_KEYNAME}${name_suffix_anticollision}.sh" "${bashinit}"
    fi
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}


# - Description: Expands function contents and add them to .bashrc indirectly using bash_functions
# - Permissions: Can be executed as root or user.
generic_install_functions() {
  local -r bashfunctions="${CURRENT_INSTALLATION_KEYNAME}_bashfunctions[@]"
  local name_suffix_anticollision=""
  for bashfunction in "${!bashfunctions}"; do
    if [[ "${bashfunction}" = *$'\n'* ]]; then
      # More than one line, we can guess its a content
      add_bash_function "${bashfunction}" "${CURRENT_INSTALLATION_KEYNAME}${name_suffix_anticollision}.sh"
    elif [ "${bashfunction}" == "silentFunction" ]; then
      local -r launcherkeynames="${CURRENT_INSTALLATION_KEYNAME}_launcherkeynames[@]"
      local selectedKeyname=
      for launcherkeyname in "${!launcherkeynames}"; do
        autostart_pointer="${CURRENT_INSTALLATION_KEYNAME}_${launcherkeyname}_autostart"
        terminal_pointer="${CURRENT_INSTALLATION_KEYNAME}_${launcherkeyname}_terminal"
        if [ "${!autostart_pointer}" != "yes" ] && [ "${!terminal_pointer}" != "true" ]; then
          selectedKeyname="${launcherkeyname}"
          break
        fi
      done
      if [ -z "${selectedKeyname}" ]; then
        continue
      fi

      local silent_exec="$(dynamic_launcher_deduce_exec "${selectedKeyname}")"
      local -r silent_exec_first_word="$(echo "${silent_exec}" | cut -d " " -f1)"
      if [ "${silent_exec_first_word}" == "bash" ] || [ "${silent_exec_first_word}" == "nohup" ]; then
        silent_exec="$(echo "${silent_exec}" | cut -d " " -f2)"
        if echo "${silent_exec}" | grep -Eq "/"; then
          silent_exec="$(echo "${silent_exec}" | rev | cut -d "/" -f1 | rev | cut -d "." -f1)"
        fi
      elif ! echo "${silent_exec}" | grep -Eq "/"; then
        silent_exec="$(echo "${silent_exec}" | cut -d " " -f1)"
      else
        local -r binariesPointer="${CURRENT_INSTALLATION_KEYNAME}_binariesinstalledpaths[0]"
        if [ ! -z "$(echo "${!binariesPointer}")" ]; then
          silent_exec="$(echo "${!binariesPointer}" | cut -d ";" -f2)"
        else
          # We do not have any info so we expect the keyname to be the binary
          silent_exec="${CURRENT_INSTALLATION_KEYNAME}"
        fi
      fi

      local -r silent_function="#!/usr/bin/env bash
${silent_exec}()
{
  nohup ${silent_exec} \$@ &> /dev/null &
}
"
      add_bash_function "${silent_function}" "${CURRENT_INSTALLATION_KEYNAME}${name_suffix_anticollision}.sh"

    elif ! echo "${bashfunction}" | grep -Eq "/"; then
      # Only one line we guess it is a partial path
      add_bash_function "" "${CURRENT_INSTALLATION_KEYNAME}${name_suffix_anticollision}.sh" "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${bashfunction}"
    else
      add_bash_function "" "${CURRENT_INSTALLATION_KEYNAME}${name_suffix_anticollision}.sh" "${bashfunction}"
    fi
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}


# - Description: Expands ${CURRENT_INSTALLATION_KEYNAME}_filekeys to obtain the keys which are a name of a variable
#   that has to be expanded to obtain the data of the file.
# - Permissions: Can be executed as root or user.
generic_install_files() {
  local -r filekeys="${CURRENT_INSTALLATION_KEYNAME}_filekeys[@]"
  for filekey in "${!filekeys}"; do
    local content="${CURRENT_INSTALLATION_KEYNAME}_${filekey}_content"
    local path="${CURRENT_INSTALLATION_KEYNAME}_${filekey}_path"
    if echo "${!path}" | grep -Eqo "^/"; then
      local destiny_path="${!path}"
    else
      local destiny_path="${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}/${!path}"
    fi
    if [[ "${!content}" = *$'\n'* ]]; then
      # More than one line, we can guess its a content
      create_file "${destiny_path}" "${!content}"
    else
      # Only one line we guess it is a path
      create_file "${destiny_path}" "" "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${CURRENT_INSTALLATION_KEYNAME}/${!content}"
    fi
  done
}


# - Description: Expands function system initialization relative to moving files
# - Permissions: Can be executed as root or user.
generic_install_movefiles() {
  local -r movefiles="${CURRENT_INSTALLATION_KEYNAME}_movefiles[@]"
  local origin_files=""
  local destiny_directory=""
  for movedata in "${!movefiles}"; do
    origin_files="$(echo "${movedata}" | cut -d ";" -f1)"
    destiny_directory="$(echo "${movedata}" | cut -d ";" -f2)"
    create_folder "${destiny_directory}"
    if echo "${origin_files}" | grep -q '\*' ; then
      for filename in "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}/"${origin_files}; do
        mv -f "${filename}" "${destiny_directory}"
        if isRoot; then
          apply_permissions "${filename}"
        fi
      done
    else
      mv "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}/${origin_files}" "${destiny_directory}"
      if isRoot; then
        apply_permissions "${destiny_directory}/${origin_files}"
      fi
    fi 
  done
}


# - Description: Expands dependency installation
# - Permissions: Can be executed as root or user.
generic_install_dependencies() {
  if [ "${FLAG_IGNORE_DEPENDENCIES}" -eq 1 ]; then
    return
  fi

  # Other dependencies to install with the package manager before the main package of software if present
  local -r packagedependencies="${CURRENT_INSTALLATION_KEYNAME}_packagedependencies[*]"
  if ! isRoot; then
    if [ -n "${!packagedependencies}" ]; then
      output_proxy_executioner "${CURRENT_INSTALLATION_KEYNAME} has this dependencies to install with the package manager: ${!packagedependencies} but they are not going to be installed because you are not root. To install them, rerun installation with sudo." "WARNING"
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
# - Argument 1: URL to clone
generic_install_clone() {
   # Check if it is cached
  if [ -d "${CACHE_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}_repository" ] && [ "${FLAG_CACHE}" -eq 1 ]; then
    rm -Rf "${BIN_FOLDER:?}/${CURRENT_INSTALLATION_KEYNAME}"
    cp -r "${CACHE_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}_repository" "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}"
    if isRoot; then
      apply_permissions_recursively "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}"
    fi
  else  # Not cached or we do not use cache: we have to download

    rm -Rf "${TEMP_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}_repository"
    create_folder "${TEMP_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}_repository"

    echo -en '\033[1;33m'
    git clone "$1" "${TEMP_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}_repository"
    echo -en '\033[0m'

    if [ "${FLAG_CACHE}" -eq 1 ]; then
      # Move to cache folder to construct cache
      rm -Rf "${CACHE_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}_repository"
      cp -r "${TEMP_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}_repository" "${CACHE_FOLDER}"
      rm -Rf "${TEMP_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}_repository"
      # If we are root change permissions
      if isRoot; then
        apply_permissions_recursively "${CACHE_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}_repository"
      fi

      # Avoid collisions
      rm -Rf "${BIN_FOLDER:?}/${CURRENT_INSTALLATION_KEYNAME}"
      # Copy file to the desired place of download
      cp -r "${CACHE_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}_repository" "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}"
      if isRoot; then
        apply_permissions_recursively "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}"
      fi
    else
      # Move directly to the desired place of download
      rm -Rf "${BIN_FOLDER:?}/${CURRENT_INSTALLATION_KEYNAME}"
      cp -r "${TEMP_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}_repository" "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}"
      # Do not construct cache
      rm -Rf "${TEMP_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}_repository"

      # If we are root change permissions
      if isRoot; then
        apply_permissions_recursively "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}"
      fi
    fi
  fi
}


# - Description: Installs packages using $DEFAULT_PACKAGE_MANAGER which corresponds to the the preferred package
#   manager depending on the operating system.
# - Permissions: Expected to be run by root user.
generic_install_packageManager() {
  # Name of the package names to be installed with the package manager if present
  local -r packagenames="${CURRENT_INSTALLATION_KEYNAME}_packagenames[@]"
  if ! isRoot; then
    if [ ! -z "${!packagenames}" ]; then
      output_proxy_executioner "${CURRENT_INSTALLATION_KEYNAME} needs to install the following packages using the package manager: ${!packagenames} but they are not going to be installed because you are not root. To install them, rerun installation with sudo." "WARNING"
      return
    fi
  fi
  for packagename in ${!packagenames}; do
    ${PACKAGE_MANAGER_FIXBROKEN}
    ${PACKAGE_MANAGER_INSTALL} "${packagename}"
    ${PACKAGE_MANAGER_FIXBROKEN}
  done
}

########################################################################################################################
################################## GENERIC INSTALL FUNCTIONS - INSTALLATION TYPES ######################################
########################################################################################################################

# Argument 1: download key
# Argument 2: anticollisioner
generic_install_download()
{
  local -r pointer_url="${CURRENT_INSTALLATION_KEYNAME}_$1_URL"
  local -r pointer_type="${CURRENT_INSTALLATION_KEYNAME}_$1_type"
  local -r pointer_downloadPath="${CURRENT_INSTALLATION_KEYNAME}_$1_downloadPath"


  local defaultName="${CURRENT_INSTALLATION_KEYNAME}_$1_file"
  local defaultpath="${BIN_FOLDER}"
  if [ -n "${!pointer_downloadPath}" ]; then
    if echo "${!pointer_downloadPath}" | grep -Eq "/\$"; then
      # Is a folder ending with /
      defaultpath="$(echo "${!pointer_downloadPath}" | rev | cut -d "/" -f1- | rev)"
    elif echo "${!pointer_downloadPath}" | grep -Eq "^/"; then
      defaultpath="$(echo "${!pointer_downloadPath}" | rev | cut -d "/" -f2- | rev)"
      defaultName="$(echo "${!pointer_downloadPath}" | rev | cut -d "/" -f1 | rev)"
    elif ! echo "${!pointer_downloadPath}" | grep -Eq "/"; then
      defaultName="${!pointer_downloadPath}"
      defaultpath="${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}"
    fi
  fi

  create_folder "${defaultpath}"
  download "${!pointer_url}" "${defaultpath}/${defaultName}"

  if [ -n "${!pointer_type}" ]; then
    case "${!pointer_type}" in
      "compressed")
        # Setting the mime_type as an arbitrary compressed file so it enters in the correct case
        local mime_type="application/zip"
      ;;
      "package")
        local true_mime="$(file --mime-type "${defaultpath}/${defaultName}" | cut -d ":" -f2 | tr -d " ")"
        if [ "${true_mime}" == "application/zip" ] || [ "${true_mime}" == "application/x-bzip-compressed-tar" ] || [ "${true_mime}" == "application/x-bzip2" ] || [ "${true_mime}" == "application/gzip" ] || [ "${true_mime}" == "application/x-xz" ]; then
          local mime_type="packageInCompressed"
        else
          local mime_type="application/vnd.debian.binary-package"
        fi
      ;;
      *)
        # Fill with some value different of a mimetype so it goes to a regular file
        local mime_type="somethingElse"
      ;;
    esac
  else
    mime_type="$(file --mime-type "${defaultpath}/${defaultName}" | cut -d ":" -f2 | tr -d " ")"
  fi

  case "${mime_type}" in
    "application/zip" | "application/x-bzip-compressed-tar" | "application/x-bzip2" | "application/gzip" | "application/x-xz")
      local pointer_doNotInherit="${CURRENT_INSTALLATION_KEYNAME}_$1_doNotInherit"
      if [ -n "${!pointer_doNotInherit}" ]; then
        decompress "${defaultpath}/${defaultName}"
        apply_permissions_recursively "${defaultpath}"
      else
        decompress "${defaultpath}/${defaultName}" "${CURRENT_INSTALLATION_KEYNAME}$2"
        apply_permissions_recursively "${defaultpath}/${CURRENT_INSTALLATION_KEYNAME}$2"
      fi
    ;;
    "application/vnd.debian.binary-package")
      ${PACKAGE_MANAGER_FIXBROKEN}
      ${PACKAGE_MANAGER_INSTALLPACKAGE} "${defaultpath}/${defaultName}"  # Notice that this variable is not the same as the next
      ${PACKAGE_MANAGER_FIXBROKEN}
    ;;
    "packageInCompressed")
      decompress "${defaultpath}/${defaultName}" "${defaultName}_decompressed"
      ${PACKAGE_MANAGER_FIXBROKEN}
      ${PACKAGE_MANAGER_INSTALLPACKAGES} "${defaultpath}/${defaultName}_decompressed"  # Notice the S at the end of this variable...
      ${PACKAGE_MANAGER_FIXBROKEN}
      # Remove decompressed folder that contains the installable packages
      rm -Rf "${defaultpath}/${defaultName}_decompressed"
    ;;
    *)
      # Move only if we are not overriding the download path. We do it like this because if not we can not decompress
      if [ -z "${!pointer_downloadPath}" ]; then
        rm -Rf "${CURRENT_INSTALLATION_FOLDER}"
        create_folder "${CURRENT_INSTALLATION_FOLDER}"
        mv "${defaultpath}/${defaultName}" "${CURRENT_INSTALLATION_FOLDER}"
      fi
    ;;
  esac
}


# - Description: Downloads
# - Permissions: Can be executed as root or user, but if a downloaded file requires package installation the function
#   needs to be run as root.
generic_install_downloads() {
  local -r downloads="${CURRENT_INSTALLATION_KEYNAME}_downloadKeys[@]"
  local name_suffix_anticollision=""
  for each_download in ${!downloads}; do
    generic_install_download "${each_download}" "${name_suffix_anticollision}"
    name_suffix_anticollision="${name_suffix_anticollision}_"
  done
}


# - Description: Installs packages using python environment.
# - Permissions: It is expected to be called as user.
generic_install_pythonVirtualEnvironment() {
  local -r pipinstallations="${CURRENT_INSTALLATION_KEYNAME}_pipinstallations[@]"
  local -r pythoncommands="${CURRENT_INSTALLATION_KEYNAME}_pythoncommands[@]"
  if [ -z "${!pipinstallations}" ] && [ -z "${!pythoncommands}" ]; then
    return
  fi

  rm -Rf "${BIN_FOLDER:?}/${CURRENT_INSTALLATION_KEYNAME}"
  python3 -m venv "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}"
  "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}/bin/python3" -m pip install -U pip
  "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}/bin/pip" install wheel

  for pipinstallation in ${!pipinstallations}; do
    "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}/bin/pip" install "${pipinstallation}"
  done
  for pythoncommand in "${!pythoncommands}"; do
    "${BIN_FOLDER}/${CURRENT_INSTALLATION_KEYNAME}/bin/python3" -m "${pythoncommand}"
  done

  # If we are root change permissions
  if isRoot; then
    apply_permissions_recursively "${BIN_FOLDER:?}/${CURRENT_INSTALLATION_KEYNAME}"
  fi
}


# - Description: Clones git repository in BIN_FOLDER
# - Permissions: It is expected to be called as user.
# - Argument 1: Name of the program that we want to install, which will be the variable that we expand to look for its
#   installation data.
# TODO: do for many repositories
generic_install_cloneRepositories() {
  local -r repositoryurl="${CURRENT_INSTALLATION_KEYNAME}_repositoryurl"
  if [ -n "${!repositoryurl}" ]; then
    generic_install_clone "${!repositoryurl}"
  fi
}











########################################################################################################################
############################################## INSTALL MAIN FUNCTIONS ##################################################
########################################################################################################################

# - Description: Initialize common subsystems and common subfeatures
# - Permissions: Same behaviour being root or normal user.
data_and_file_structures_initialization() {
  output_proxy_executioner "Initializing data and file structures." "INFO"

  if isRoot; then
    if [ "${OS_NAME}" == "TermuxUbuntu" ]; then
      if ! users | grep -q "Android"; then
        adduser --gecos "" --disabled-password "Android"
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

  # Ensure that customizer_option.sh exists in DATA_FOLDER, but do not overwrite it if exists. Then source its content
  # for user custom options, flags and features
  if [ ! -f "${DATA_FOLDER}/customizer_options.sh" ]; then
    cp "${CUSTOMIZER_PROJECT_FOLDER}/data/core/customizer_options.sh" "${DATA_FOLDER}/customizer_options.sh"
  fi
  apply_permissions "${DATA_FOLDER}/customizer_options.sh"

  if [ ! -f "${PROGRAM_KEYBINDINGS_PATH}" ]; then
    create_file "" "${PROGRAM_KEYBINDINGS_PATH}"
  fi

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
    if ! isRoot; then
      username_wsl2="$(/mnt/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' 2> /dev/null | sed -e 's/\r//g')"
      if [ -z "${username_wsl2}" ]; then
        echo "ERROR: The user of Windows could not have been captured"
        exit 1
      else
        create_file "${CUSTOMIZER_PROJECT_FOLDER}/whoami" "${username_wsl2}"
      fi
      unset username_wsl2
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
  add_bash_function "" "init.sh" "${CUSTOMIZER_PROJECT_FOLDER}/src/core/subsystems/init.sh"

  add_bash_initialization "" "favorites.sh" "${CUSTOMIZER_PROJECT_FOLDER}/src/core/subsystems/favorites.sh"

  add_bash_initialization "" "keybindings.sh" "${CUSTOMIZER_PROJECT_FOLDER}/src/core/subsystems/keybindings.sh"

  # We source from the bashrc of the current user or all the users depending on out permissions with priority
  # in being sourced from BASHRC_ALL_USERS_PATH
  if ! grep -Fo "source \"${FUNCTIONS_PATH}\"" "${BASHRC_ALL_USERS_PATH}" &>/dev/null; then
    if isRoot; then
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
  if isRoot; then
    if [ "${FLAG_UPGRADE}" -gt 0 ]; then
      output_proxy_executioner "Attempting to update system via ${DEFAULT_PACKAGE_MANAGER}." "INFO"
      output_proxy_executioner "${PACKAGE_MANAGER_UPDATE}" "COMMAND"
      output_proxy_executioner "System updated." "INFO"
    fi
    if [ "${FLAG_UPGRADE}" == 2 ]; then
      output_proxy_executioner "Attempting to upgrade system via ${DEFAULT_PACKAGE_MANAGER}." "INFO"
      output_proxy_executioner "${PACKAGE_MANAGER_UPGRADE}" "COMMAND"
      output_proxy_executioner "System upgraded." "INFO"
    fi
  fi
}

# - Description: Performs update of system fonts and bash environment.
# - Permissions: Same behaviour being root or normal user.
update_environment() {
  output_proxy_executioner "echo INFO: Rebuilding path cache" "INFO"
  output_proxy_executioner "hash -r" "COMMAND"
  output_proxy_executioner "echo INFO: Rebuilding font cache" "INFO"
  output_proxy_executioner "fc-cache -f" "COMMAND"
  output_proxy_executioner "echo INFO: Reloading bash features" "INFO"
  output_proxy_executioner "source ${FUNCTIONS_PATH}" "COMMAND"
  output_proxy_executioner "echo INFO: Finished execution" "INFO"
}


if [ -f "${DIR}/functions_common.sh" ]; then
  # shellcheck source=./functions_common.sh
  source "${DIR}/functions_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_common.sh not found. Aborting..."
  exit 1
fi
#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer installation of features.                                                              #
# - Description: A set of programs, functions, aliases, templates, environment variables, wallpapers, desktop          #
# features... collected in a simple portable shell script to customize a Linux working environment.                    #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 10/5/21                                                                                             #
# - Author: Aleix Mariné-Tena                                                                                          #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when   #
# logged as root) to install some of the features.                                                                     #
# - Arguments: Accepts behavioural arguments with one hyphen (-f, -o, etc.) and feature selection with two hyphens     #
# (--pycharm, --gcc).                                                                                                  #
# - Usage: Installs the features given by argument.                                                                    #
# - License: GPL                                                                                                       #
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
    # This code search and export the variable DBUS_SESSIONS_BUS_ADDRESS for root access to gsettings and dconf
    if [ -z ${DBUS_SESSION_BUS_ADDRESS+x} ]; then
      user=$(whoami)
      fl=$(find /proc -maxdepth 2 -user $user -name environ -print -quit)
      while [ -z $(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2- | tr -d '\000' ) ]
      do
        fl=$(find /proc -maxdepth 2 -user $user -name environ -newer "$fl" -print -quit)
      done
      export DBUS_SESSION_BUS_ADDRESS="$(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2-)"
    fi

    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), '$1.desktop']"
  else
    output_proxy_executioner "echo WARNING: $1 cannot be added to favorites because it does not exist installed. Skipping..." 0
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
  # Convert folder to a SUDO_ROOT user
  chgrp ${SUDO_USER} "$1"
  chown ${SUDO_USER} "$1"
  chmod 775 "$1"
}

# - Description: Associate a file type (mime type) to a certain application using its desktop launcher.
# - Permissions: Same behaviour being root or normal user.
# - Argument 1: File types. Example: application/x-shellscript
# - Argument 2: Application. Example: sublime_text.desktop
register_file_associations()
{
# Check if mimeapps exists
if [[ -f ${HOME}/.config/mimeapps.list ]]; then
  # Check if the association between a mime type and desktop launcher is already existent
  if [[ -z "$(more ${HOME_FOLDER}/.config/mimeapps.list | grep -Eo "$1=.*$2" )" ]]; then
    # If mime type is not even present we can add the hole line
    if [[ -z "$(more ${HOME_FOLDER}/.config/mimeapps.list | grep -Fo "$1=" )" ]]; then
      sed -i "/\[Added Associations\]/a $1=$2;" ${HOME_FOLDER}/.config/mimeapps.list
    else
      # If not, mime type is already registered. We need to register another application for it
      if [[ -z "$(more ${HOME_FOLDER}/.config/mimeapps.list | grep -Eo "$1=.*;$" )" ]]; then
        # File type(s) is registered without comma. Add the program at the end of the line with comma
        sed -i "s|$1=.*$|&;$2;|g" ${HOME_FOLDER}/.config/mimeapps.list
      else
        # File type is registered with comma at the end. Just add program at end of line
        sed -i "s|$1=.*;$|&$2;|g" ${HOME_FOLDER}/.config/mimeapps.list
      fi
    fi
  fi
fi
}

# - Description: Creates a valid launcher for the normal user in the desktop using an already created launcher from an
# automatic install (for example using apt-get or dpkg).
# - Permissions: This function expects to be called as root since it uses the variable $SUDO_USER
# - Argument 1: name of the desktop launcher in /usr/share/applications
copy_launcher()
{
  if [[ -f "${ALL_USERS_LAUNCHERS_DIR}/$1" ]]; then
    cp "${ALL_USERS_LAUNCHERS_DIR}/$1" "${XDG_DESKTOP_DIR}"
    chmod 775 "${XDG_DESKTOP_DIR}/$1"
    chgrp "${SUDO_USER}" "${XDG_DESKTOP_DIR}/$1"
    chown "${SUDO_USER}" "${XDG_DESKTOP_DIR}/$1"
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
  echo -e "$1" > "${ALL_USERS_LAUNCHERS_DIR}/$2.desktop"
  chmod 775 "${ALL_USERS_LAUNCHERS_DIR}/$2.desktop"
  chgrp "${SUDO_USER}" "${ALL_USERS_LAUNCHERS_DIR}/$2.desktop"
  chown "${SUDO_USER}" "${ALL_USERS_LAUNCHERS_DIR}/$2.desktop"
  cp -p "${ALL_USERS_LAUNCHERS_DIR}/$2.desktop" "${XDG_DESKTOP_DIR}"
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
  rm -f ${USR_BIN_FOLDER}/downloading_program*
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
  rm -f "${USR_BIN_FOLDER}/downloading_program*"
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
    chgrp ${SUDO_USER} ${BASH_FUNCTIONS_FOLDER}/$2
    chown ${SUDO_USER} ${BASH_FUNCTIONS_FOLDER}/$2
    chmod 775 ${BASH_FUNCTIONS_FOLDER}/$2
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
  rm -f ${USR_BIN_FOLDER}/downloading_package*
  (cd ${USR_BIN_FOLDER}; wget -qO downloading_package --show-progress $1)
  dpkg -i ${USR_BIN_FOLDER}/downloading_package
  rm -f ${USR_BIN_FOLDER}/downloading_package*
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

############################
###### ROOT FUNCTIONS ######
############################

install_audacity()
{
  apt-get install -y audacity
  copy_launcher audacity.desktop
}

install_AutoFirma()
{
  apt-get install -y libnss3-tools

  rm -f ${USR_BIN_FOLDER}/downloading_package*
  (cd ${USR_BIN_FOLDER}; wget -qO downloading_package --show-progress "${autofirma_downloader}")
  rm -Rf ${USR_BIN_FOLDER}/autOfirma
  (cd ${USR_BIN_FOLDER}; unzip downloading_package -d autOfirma)  # To avoid collisions
  rm -f ${USR_BIN_FOLDER}/downloading_package
  dpkg -i ${USR_BIN_FOLDER}/autOfirma/AutoFirma*.deb
  rm -Rf ${USR_BIN_FOLDER}/autOfirma

  copy_launcher "afirma.desktop"
}

install_atom()
{
  download_and_install_package ${atom_downloader}
  copy_launcher atom.desktop
}

install_caffeine()
{
  apt-get install -y caffeine
  copy_launcher caffeine-indicator.desktop
}

install_calibre()
{
  apt-get install -y calibre
  copy_launcher calibre-gui.desktop
}

install_cheese()
{
  apt-get install -y cheese
  copy_launcher org.gnome.Cheese.desktop
}

install_clementine()
{
  apt-get install -y clementine
  copy_launcher clementine.desktop
}

install_clonezilla()
{
  apt-get install -y clonezilla
  create_manual_launcher "${clonezilla_launcher}" "clonezilla"
}

install_cmatrix()
{
  apt-get install -y cmatrix
  create_manual_launcher "${cmatrix_launcher}" "cmatrix"
}

install_curl()
{
  apt-get install -y curl
}

# Dropbox desktop client and integration
install_dropbox()
{
  # Dependency
  apt-get -y install python3-gpg

  download_and_install_package ${dropbox_downloader}
  copy_launcher dropbox.desktop
}

install_copyq()
{
  apt-get install -y copyq
  copy_launcher "com.github.hluk.copyq.desktop"
}

install_ffmpeg()
{
  apt-get install -y ffmpeg
}

install_firefox()
{
  apt-get install -y firefox
  copy_launcher "firefox.desktop"
}

install_f-irc()
{
  apt-get install -y f-irc
  create_manual_launcher "${firc_launcher}" f-irc
}

install_freecad()
{
  apt-get install -y freecad
  copy_launcher "freecad.desktop"
}

install_gcc()
{
  apt-get install -y gcc
  add_bash_function "${gcc_function}" "gcc_function.sh"
}

install_geany()
{
  apt-get install -y geany
  copy_launcher geany.desktop
}

install_gimp()
{
  apt-get install -y gimp
  copy_launcher "gimp.desktop"
}

# Install GIT and all its related utilities (gitk e.g.)
install_git()
{
  apt-get install -y git-all
  apt-get install -y git-lfs
}

install_gnome-chess()
{
  apt-get install -y gnome-chess
  copy_launcher "org.gnome.Chess.desktop"
}

install_parallel()
{
  apt-get -y install parallel
}

install_gparted()
{
  apt-get install -y gparted
  copy_launcher "gparted.desktop"
}

install_google-chrome()
{
  # Dependencies
  apt-get install -y libxss1 libappindicator1 libindicator7

  download_and_install_package ${google_chrome_downloader}
  copy_launcher "google-chrome.desktop"
}

install_gvim()
{
  apt-get -y install vim-gtk3
  copy_launcher "gvim.desktop"
}

install_gpaint()
{
  apt-get -y install gpaint
  copy_launcher "gpaint.desktop"
  sed "s|Icon=gpaint.svg|Icon=${gpaint_icon_path}|" -i ${XDG_DESKTOP_DIR}/gpaint.desktop
}

install_iqmol()
{
  download_and_install_package ${iqmol_downloader}
  create_folder_as_root ${USR_BIN_FOLDER}/iqmol
  # Obtain icon for iqmol
  (cd ${USR_BIN_FOLDER}/iqmol; wget -q -O iqmol_icon.png ${iqmol_icon})
  create_manual_launcher "${iqmol_launcher}" iqmol
  add_bash_function "${iqmol_alias}" "iqmol_alias.sh"
}

install_inkscape()
{
  apt-get install -y inkscape
  copy_launcher "inkscape.desktop"
}

install_latex()
{
  # Dependencies
  apt-get install -y perl-tk texlive-latex-extra texmaker
  copy_launcher "texmaker.desktop"
  copy_launcher "texdoctk.desktop"
  echo "Icon=/usr/share/icons/Yaru/256x256/mimetypes/text-x-tex.png" >> ${XDG_DESKTOP_DIR}/texdoctk.desktop
}

install_libxcb-xtest0()
{
  apt-get install -y libxcb-xtest0
}

install_gnome-mahjongg()
{
  apt-get install -y gnome-mahjongg
  copy_launcher "org.gnome.Mahjongg.desktop"
}

# megasync + megasync nautilus.
install_megasync()
{
  # Dependencies
  apt-get install -y nautilus libc-ares2 libmediainfo0v5 libqt5x11extras5 libzen0v5

  download_and_install_package ${megasync_downloader}
  download_and_install_package ${megasync_integrator_downloader}
  copy_launcher megasync.desktop
}

# Mendeley Dependencies
install_mendeley_dependencies()
{
  # Mendeley dependencies
  apt-get install -y gconf2 qt5-default qt5-doc qt5-doc-html qtbase5-examples qml-module-qtwebengine
}

install_gnome-mines()
{
  apt-get install -y gnome-mines
  copy_launcher "org.gnome.Mines.desktop"
}

# Automatic install + Creates desktop launcher in launcher and in desktop.
# Deprecated app, is not maintained by google anymore
install_musicmanager()
{
  download_and_install_package ${music_manager_downloader}
  copy_launcher "google-musicmanager.desktop"
}

install_nemo()
{
  # Delete Nautilus, the default desktop manager to avoid conflicts
  apt-get purge -y nautilus gnome-shell-extension-desktop-icons
  apt-get install -y nemo dconf-editor gnome-tweak-tool
  # Create special launcher to execute nemo daemon at system start
  echo -e "${nemo_desktop_launcher}" > /etc/xdg/autostart/nemo-autostart.desktop
  # nemo configuration
  xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
  gsettings set org.gnome.desktop.background show-desktop-icons false
  gsettings set org.nemo.desktop show-desktop-icons true

  copy_launcher "nemo.desktop"
}

install_net-tools()
{
  apt-get install -y net-tools
}

install_notepadqq()
{
  apt-get install -y notepadqq
  copy_launcher notepadqq.desktop
}

install_openoffice()
{
  # Delete old versions of openoffice to avoid conflicts
  apt-get remove -y libreoffice-base-core libreoffice-impress libreoffice-calc libreoffice-math libreoffice-common libreoffice-ogltrans libreoffice-core libreoffice-pdfimport libreoffice-draw libreoffice-style-breeze libreoffice-gnome libreoffice-style-colibre libreoffice-gtk3 libreoffice-style-elementary libreoffice-help-common libreoffice-style-tango libreoffice-help-en-us libreoffice-writer
  echo $?

  rm -f ${USR_BIN_FOLDER}/office*
  (cd ${USR_BIN_FOLDER}; wget -q --show-progress -O office ${openoffice_downloader})

  echo $?
  rm -Rf ${USR_BIN_FOLDER}/en-US
  echo si
  (cd ${USR_BIN_FOLDER}; tar -xzf -) < ${USR_BIN_FOLDER}/office
  echo no
  rm -f ${USR_BIN_FOLDER}/office

  dpkg -i ${USR_BIN_FOLDER}/en-US/DEBS/*.deb
  dpkg -i ${USR_BIN_FOLDER}/en-US/DEBS/desktop-integration/*.deb
  rm -Rf ${USR_BIN_FOLDER}/en-US

  copy_launcher "openoffice4-base.desktop"
  copy_launcher "openoffice4-calc.desktop"
  copy_launcher "openoffice4-draw.desktop"
  copy_launcher "openoffice4-math.desktop"
  copy_launcher "openoffice4-writer.desktop"
}

install_obs-studio()
{
  install_ffmpeg

  apt-get install -y obs-studio
  copy_launcher com.obsproject.Studio.desktop
}

install_okular()
{
  apt-get -y install okular
  copy_launcher "org.kde.okular.desktop"
}

install_pacman()
{
  apt-get install -y pacman
  copy_launcher "pacman.desktop"
}

install_pdfgrep()
{
  apt-get install -y pdfgrep
}

install_psql()
{
  apt-get install -y postgresql-client-12	postgresql-12 libpq-dev postgresql-server-dev-12
}

install_pluma()
{
  apt-get install -y pluma
  copy_launcher "pluma.desktop"
  add_to_favorites "pluma"
}

install_pypy3_dependencies()
{
  apt-get install -y -qq pkg-config libfreetype6-dev libpng-dev libffi-dev
}

install_python3()
{
  apt-get install -y python3-dev python-dev python3-pip
}

install_shotcut()
{
  apt-get install -y shotcut
  create_manual_launcher "${shotcut_desktop_launcher}" shotcut
}

install_skype()
{
  download_and_install_package ${skype_downloader}
  copy_launcher "skypeforlinux.desktop"
}

install_slack()
{
  download_and_install_package ${slack_repository}
  copy_launcher "slack.desktop"
}

install_spotify()
{
  download_and_install_package ${spotify_downloader}
  copy_launcher "spotify.desktop"
}

install_aisleriot()
{
  apt-get install -y aisleriot
  copy_launcher sol.desktop
}

# steam ubuntu client
install_steam()
{
  download_and_install_package ${steam_downloader}
  copy_launcher steam.desktop
}

install_gnome-sudoku()
{
  apt-get install -y gnome-sudoku
  copy_launcher org.gnome.Sudoku.desktop
}

install_teams()
{
  download_and_install_package ${teams_downloader}
  copy_launcher "teams.desktop"
}

install_terminator()
{
  apt-get -y install terminator
  copy_launcher terminator.desktop
}

install_thunderbird()
{
  apt-get install -y thunderbird
  copy_launcher thunderbird.desktop
}

install_tilix()
{
  apt-get install -y tilix
  copy_launcher com.gexperts.Tilix.desktop
}

install_tmux()
{
  apt-get install -y tmux
  create_manual_launcher "${tmux_launcher}" tmux
}

install_tor()
{
  apt-get install -y torbrowser-launcher
  copy_launcher "torbrowser.desktop"
}

install_transmission()
{
  apt-get install -y transmission
  copy_launcher "transmission-gtk.desktop"
  create_links_in_path "$(which transmission-gtk)" transmission
}

install_uget()
{
  # Dependencies
  apt-get install -y aria2
  apt-get install -y uget
  copy_launcher uget-gtk.desktop
}

install_vlc()
{
  apt-get -y install vlc
  copy_launcher "vlc.desktop"
}

install_virtualbox()
{
  # Dependencies
  apt-get install -y libqt5opengl5
  
  download_and_install_package ${virtualbox_downloader}
  copy_launcher "virtualbox.desktop"
}

install_wireshark()
{
  # Used to install wireshark without prompt
  echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
  DEBIAN_FRONTEND=noninteractive

  apt-get install -y wireshark
  copy_launcher "wireshark.desktop"
  sed -i 's-Icon=.*-Icon=/usr/share/icons/hicolor/scalable/apps/wireshark.svg-' ${XDG_DESKTOP_DIR}/wireshark.desktop
}



#####################################
###### USER SOFTWARE FUNCTIONS ######
#####################################

install_ant()
{
  download_and_decompress ${ant_downloader} "apache_ant" "z" "bin/ant" "ant"
}

install_libgtkglext1()
{
  apt-get install -y libgtkglext1
}

install_anydesk()
{
  download_and_decompress ${anydesk_downloader} "anydesk" "z" "anydesk" "anydesk"
  create_manual_launcher "${anydesk_launcher}" "anydesk"
}

install_studio()
{
  download_and_decompress ${android_studio_downloader} "android-studio" "z" "bin/studio.sh" "studio"

  create_manual_launcher "${android_studio_launcher}" "Android_Studio"

  add_bash_function "${android_studio_alias}" "studio_alias.sh"
}

install_clion()
{
  download_and_decompress ${clion_downloader} "clion" "z" "bin/clion.sh" "clion"

  create_manual_launcher "${clion_launcher}" "clion"

  register_file_associations "text/x-c++hdr" "clion.desktop"
  register_file_associations "text/x-c++src" "clion.desktop"
  register_file_associations "text/x-chdr" "clion.desktop"
  register_file_associations "text/x-csrc" "clion.desktop"

  add_bash_function "${clion_alias}" "clion_alias.sh"
}

# Does not work because the root directory of the compressed is called ".". Wait until the developers change it
install_codium()
{
  download_and_decompress ${codium_downloader} "codium" "z" "bin/codium" "codium"
  create_manual_launcher "${codium_launcher}" "codium"
}

# discord desktop client
# Permissions: user
install_discord()
{
  download_and_decompress ${discord_downloader} "discord" "z" "Discord" "discord"

  create_manual_launcher "${discord_launcher}" "discord"
}

install_docker()
{
    download_and_decompress ${docker_downloader} "docker" "z" "docker" "docker" "containerd" "containerd" "containerd-shim" "containerd-shim" "containerd-shim-runc-v2" "containerd-shim-runc-v2" "ctr" "ctr" "dockerd" "dockerd" "docker-init" "docker-init" "docker-proxy" "docker-proxy" "runc" "runc"
}

# Install Eclipse IDE
install_eclipse()
{
  download_and_decompress ${eclipse_downloader} "eclipse" "z" "eclipse" "eclipse"

  create_manual_launcher "${eclipse_launcher}" "eclipse"
}

install_geogebra()
{

  download_and_decompress ${geogebra_downloader} "geogebra" "zip" "GeoGebra" "geogebra"

  wget "${geogebra_icon}" -q --show-progress -O ${USR_BIN_FOLDER}/geogebra/GeoGebra.svg

  create_manual_launcher "${geogebra_desktop}" "geogebra"
}


# Install IntelliJ Community
install_ideac()
{
  download_and_decompress ${intellij_community_downloader} "idea-ic" "z" "bin/idea.sh" "ideac"

  create_manual_launcher "${intellij_community_launcher}" "ideac"

  register_file_associations "text/x-java" "ideac.desktop"

  add_bash_function "${ideac_alias}" "ideac_alias.sh"
}

# Install IntelliJ Ultimate
install_ideau()
{
  download_and_decompress ${intellij_ultimate_downloader} "idea-iu" "z" "bin/idea.sh" "ideau"

  create_manual_launcher "${intellij_ultimate_launcher}" "ideau"

  register_file_associations "text/x-java" "ideau.desktop"

  add_bash_function "${ideau_alias}" "ideau_alias.sh"
}

install_java()
{
  download_and_decompress ${java_downloader} "jdk8" "z" "bin/java" "java"
  add_bash_function "${java_globalvar}" "java_javahome.sh"
}

install_mvn()
{
  download_and_decompress ${maven_downloader} "maven" "z" "bin/mvn" "mvn"
}

# Manual install, creating launcher in the launcher and in desktop. Modifies .desktop file provided by the software
install_mendeley()
{
  download_and_decompress ${mendeley_downloader} "mendeley" "j" "bin/mendeleydesktop" "mendeley"

  # Create Desktop launcher
  cp ${USR_BIN_FOLDER}/mendeley/share/applications/mendeleydesktop.desktop ${XDG_DESKTOP_DIR}
  chmod 775 ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
  # Modify Icon line
  sed -i s-Icon=.*-Icon=${HOME}/.bin/mendeley/share/icons/hicolor/128x128/apps/mendeleydesktop.png- ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
  # Modify exec line
  sed -i 's-Exec=.*-Exec=mendeley %f-' ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
  # Copy to desktop  launchers of the current user
  cp -p ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop ${PERSONAL_LAUNCHERS_DIR}
}

# Installs pycharm, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharm()
{
  download_and_decompress ${pycharm_downloader} "pycharm-community" "z" "bin/pycharm.sh" "pycharm"

  create_manual_launcher "$pycharm_launcher" "pycharm"

  register_file_associations "text/x-python" "pycharm.desktop"
  register_file_associations "text/x-python3" "pycharm.desktop"
  register_file_associations "text/x-sh" "pycharm.desktop"

  add_bash_function "${pycharm_alias}" "pycharm_alias.sh"
}

# Installs pycharm professional, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharmpro()
{
  download_and_decompress ${pycharm_professional_downloader} "pycharm-professional" "z" "bin/pycharm.sh" "pycharmpro"

  create_manual_launcher "$pycharm_professional_launcher" "pycharm-pro"

  register_file_associations "text/x-sh" "pycharm-pro.desktop"
  register_file_associations "text/x-python" "pycharm-pro.desktop"
  register_file_associations "text/x-python3" "pycharm-pro.desktop"

  add_bash_function "${pycharmpro_alias}" "pycharmpro_alias.sh"
}

# Installs pypy3 dependencies, pypy3 and basic modules (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
# Links it to the path
install_pypy3()
{
  download_and_decompress ${pypy3_downloader} "pypy3" "J"

  # Install modules using pip
  ${USR_BIN_FOLDER}/pypy3/bin/pypy3 -m ensurepip

  # Forces download of pip and of modules
  ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 --no-cache-dir -q install --upgrade pip
  ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 --no-cache-dir install cython numpy
  # Currently not supported
  # ${USR_BIN_FOLDER}/${pypy3_version}/bin/pip3.6 --no-cache-dir install matplotlib

  create_links_in_path "${USR_BIN_FOLDER}/pypy3/bin/pypy3" "pypy3" ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 pypy3-pip
}

# Install Sublime text 3
install_sublime()
{
  download_and_decompress ${sublime_text_downloader} "sublime-text" "j" "sublime_text" "sublime"

  create_manual_launcher "${sublime_text_launcher}" "sublime"

  # register file associations
  register_file_associations "text/x-sh" "sublime.desktop"
  register_file_associations "text/x-c++hdr" "sublime.desktop"
  register_file_associations "text/x-c++src" "sublime.desktop"
  register_file_associations "text/x-chdr" "sublime.desktop"
  register_file_associations "text/x-csrc" "sublime.desktop"
  register_file_associations "text/x-python" "sublime.desktop"
  register_file_associations "text/x-python3" "sublime.desktop"

  add_bash_function "${sublime_alias}" "sublime_alias.sh"
  add_to_favorites "sublime"
}

install_screenshots()
{
  mkdir -p ${XDG_PICTURES_DIR}/screenshots
  add_bash_function "${screenshots_function}" "screenshots.sh"
}

install_telegram()
{
  download_and_decompress ${telegram_downloader} "telegram" "J" "Telegram" "telegram"

  wget ${telegram_icon} -q --show-progress -O ${USR_BIN_FOLDER}/telegram/telegram.svg

  create_manual_launcher "${telegram_launcher}" "telegram"
}

# Microsoft Visual Studio Code
install_code()
{
  download_and_decompress ${visualstudiocode_downloader} "visual-studio" "z" "code" "code"

  create_manual_launcher "${visualstudiocode_launcher}" "code"

  add_bash_function "${code_alias}" "code_alias.sh"
}

install_youtube-dl()
{
  wget ${youtubedl_downloader} -q --show-progress -O ${USR_BIN_FOLDER}/youtube-dl
  chmod a+rx ${USR_BIN_FOLDER}/youtube-dl
  create_links_in_path ${USR_BIN_FOLDER}/youtube-dl youtube-dl
  add_bash_function "${youtubewav_alias}" youtube-wav_alias.sh

  hash -r
}

install_zoom()
{
  download_and_decompress ${zoom_downloader} "zoom" "J" "zoom" "zoom" "ZoomLauncher" "ZoomLauncher"

  create_manual_launcher "${zoom_launcher}" "zoom"

  wget ${zoom_icon_downloader} -q --show-progress -O ${USR_BIN_FOLDER}/zoom/zoom_icon.ico
}

#######################################
###### USER-ENVIRONMENT FEATURES ######
#######################################
# Most (all) of them just use user permissions





install_alert()
{
  add_bash_function "${alert_alias}" alert.sh
}

install_chwlppr()
{
  # Install script changer to be executed manually or with crontab automatically
  echo "${wallpapers_changer_script}" > ${USR_BIN_FOLDER}/wallpaper_changer.sh
  chmod 775 ${USR_BIN_FOLDER}/wallpaper_changer.sh
  ln -sf ${USR_BIN_FOLDER}/wallpaper_changer.sh ${DIR_IN_PATH}/chwlppr

  echo "${wallpapers_cronjob}" > ${BASH_FUNCTIONS_FOLDER}/wallpapers_cronjob
  crontab ${BASH_FUNCTIONS_FOLDER}/wallpapers_cronjob


  # Download and install wallpaper
  rm -Rf ${XDG_PICTURES_DIR}/wallpapers
  mkdir -p ${XDG_PICTURES_DIR}/wallpapers
  git clone ${wallpapers_downloader} ${XDG_PICTURES_DIR}/wallpapers

  $(cd ${XDG_PICTURES_DIR}/wallpapers; tar -xzf *.tar.gz)
  rm -f ${XDG_PICTURES_DIR}/wallpapers/*.tar.gz

  for filename in $(ls /usr/share/backgrounds); do
    if [[ -f "/usr/share/backgrounds/${filename}" ]]; then
      cp "/usr/share/backgrounds/${filename}" "${XDG_PICTURES_DIR}/wallpapers"
    fi
  done
}

install_cheat()
{
  # Rf
  rm -f ${USR_BIN_FOLDER}/cheat.sh
  (cd ${USR_BIN_FOLDER}; wget -q --show-progress -O cheat.sh ${cheat_downloader})
  chmod 755 ${USR_BIN_FOLDER}/cheat.sh
  create_links_in_path ${USR_BIN_FOLDER}/cheat.sh cheat
}

install_converters()
{
  rm -Rf ${USR_BIN_FOLDER}/converters
  mkdir -p ${USR_BIN_FOLDER}/converters
  git clone ${converters_downloader} ${USR_BIN_FOLDER}/converters

  for converter in $(ls ${USR_BIN_FOLDER}/converters/converters); do
    create_links_in_path ${USR_BIN_FOLDER}/converters/converters/${converter} "$(echo ${converter} | cut -d "." -f1)"
  done

  add_bash_function "${converters_functions}" converters.sh
}

install_document()
{
  add_internet_shortcut document
}

install_drive()
{
  add_internet_shortcut drive
}


install_extract()
{
  add_bash_function "${extract_function}" extract.sh
}

install_forms()
{
  add_internet_shortcut forms
}

install_git_aliases()
{
  add_bash_function "${git_aliases_function}" git_aliases.sh
  rm -Rf ${USR_BIN_FOLDER}/.bash-git-prompt
  git clone https://github.com/magicmonty/bash-git-prompt.git ${USR_BIN_FOLDER}/.bash-git-prompt --depth=1
}


install_github()
{
  add_internet_shortcut github
}

install_gmail()
{
  add_internet_shortcut gmail
}

install_google-calendar()
{
  add_internet_shortcut google-calendar
}

install_history_optimization()
{
  add_bash_function "${shell_history_optimization_function}" history.sh
}

install_ipe()
{
  add_bash_function "${ipe_function}" ipe.sh
}

install_keep()
{
  add_internet_shortcut keep
}

install_l()
{
  add_bash_function "${l_function}" l.sh
}

install_L()
{
  add_bash_function "${L_function}" L.sh
}

install_onedrive()
{
  add_internet_shortcut onedrive
}

install_outlook()
{
  add_internet_shortcut outlook
}

install_overleaf()
{
  add_internet_shortcut overleaf
}

install_netflix()
{
  add_internet_shortcut netflix
}

install_presentation()
{
  add_internet_shortcut presentation
}

install_prompt()
{
  add_bash_function "${prompt_function}" prompt.sh
}

install_s()
{
  add_bash_function "${s_function}" s.sh
}

install_spreadsheets()
{
  add_internet_shortcut spreadsheets
}

install_shortcuts()
{
  add_bash_function "${shortcut_aliases}" shortcuts.sh
}

# Install templates (available files in the right click --> new --> ...)
install_templates()
{
  echo -e "${bash_file_template}" > ${XDG_TEMPLATES_DIR}/shell_script.sh
  echo -e "${python_file_template}" > ${XDG_TEMPLATES_DIR}/python3_script.py
  echo -e "${latex_file_template}" > ${XDG_TEMPLATES_DIR}/latex_document.tex
  echo -e "${makefile_file_template}" > ${XDG_TEMPLATES_DIR}/makefile
  echo "${c_file_template}" > ${XDG_TEMPLATES_DIR}/c_script.c
  echo "${c_header_file_template}" > ${XDG_TEMPLATES_DIR}/c_script_header.h
  > ${XDG_TEMPLATES_DIR}/empty_text_file.txt
  chmod 775 ${XDG_TEMPLATES_DIR}/*
}

install_terminal_background()
{
  local -r profile_terminal=$(dconf list /org/gnome/terminal/legacy/profiles:/)
  if [[ ! -z "${profile_terminal}" ]]; then
    dconf write /org/gnome/terminal/legacy/profiles:/${profile}/background-color "'rgb(0,0,0)'"
  fi
}

install_whatsapp()
{
  add_internet_shortcut whatsapp
}

install_youtube()
{
  add_internet_shortcut youtube
}

install_youtubemusic()
{
  add_internet_shortcut youtubemusic
}


################################
###### AUXILIAR FUNCTIONS ######
################################

# Common piece of code in the execute_installation function
# Argument 1: forceness_bit
# Argument 2: quietness_bit
# Argument 3: program_function
execute_installation_install_feature()
{
  feature_name=$( echo "$3" | cut -d "_" -f2- )
  if [[ $1 == 1 ]]; then
    set +e
  else
    set -e
  fi
  output_proxy_executioner "echo INFO: Attemptying to install ${feature_name}." $2
  output_proxy_executioner $3 $2
  output_proxy_executioner "echo INFO: ${feature_name} installed." $2
  set +e
}

execute_installation_wrapper_install_feature()
{
  if [[ $1 == 1 ]]; then
    execute_installation_install_feature $2 $3 $4
  else
    type "${program_name}" &>/dev/null
    if [[ $? != 0 ]]; then
      execute_installation_install_feature $2 $3 $4
    else
      output_proxy_executioner "echo WARNING: $5 is already installed. Skipping... Use -o to overwrite this program" $3
    fi
  fi
}

execute_installation()
{
  # Double for to perform the installation in same order as the arguments
  for (( i = 1 ; i != ${NUM_INSTALLATION} ; i++ )); do
    # Loop through all the elements in the common data table
    for program in ${installation_data[@]}; do
      # Installation bit processing
      installation_bit=$( echo ${program} | cut -d ";" -f1 )

      if [[ ${installation_bit} == ${i} ]]; then
        forceness_bit=$( echo ${program} | cut -d ";" -f2 )
        quietness_bit=$( echo ${program} | cut -d ";" -f3 )
        overwrite_bit=$( echo ${program} | cut -d ";" -f4 )
        program_function=$( echo ${program} | cut -d ";" -f6 )
        program_privileges=$( echo ${program} | cut -d ";" -f5 )

        program_name=$( echo ${program_function} | cut -d "_" -f2- )
        if [[ ${program_privileges} == 1 ]]; then
          if [[ ${EUID} -ne 0 ]]; then
            output_proxy_executioner "echo WARNING: ${program_name} needs root permissions to be installed. Skipping." ${quietness_bit}
          else
            execute_installation_wrapper_install_feature ${overwrite_bit} ${forceness_bit} ${quietness_bit} ${program_function} ${program_name}
          fi
        elif [[ ${program_privileges} == 0 ]]; then
          if [[ ${EUID} -ne 0 ]]; then
            execute_installation_wrapper_install_feature ${overwrite_bit} ${forceness_bit} ${quietness_bit} ${program_function} ${program_name}
          else
            output_proxy_executioner "echo WARNING: ${program_name} needs user permissions to be installed. Skipping." ${quietness_bit}
          fi
        else  # This feature does not care about permissions, ${program_privileges} == 2
          execute_installation_wrapper_install_feature ${overwrite_bit} ${forceness_bit} ${quietness_bit} ${program_function} ${program_name}
        fi
        break
      fi
    done
  done
}

##################
###### MAIN ######
##################
main()
{
  if [[ ${EUID} == 0 ]]; then  # root
    create_folder_as_root ${USR_BIN_FOLDER}
    create_folder_as_root ${BASH_FUNCTIONS_FOLDER}
    create_folder_as_root ${DIR_IN_PATH}
    create_folder_as_root ${PERSONAL_LAUNCHERS_DIR}

    if [[ ! -f ${BASH_FUNCTIONS_PATH} ]]; then
      echo "${bash_functions_init}" > "${BASH_FUNCTIONS_PATH}"
      chgrp ${SUDO_USER} ${BASH_FUNCTIONS_PATH}
      chown ${SUDO_USER} ${BASH_FUNCTIONS_PATH}
      chmod 775 ${BASH_FUNCTIONS_PATH}
      # Make sure that PATH is pointing to ${DIR_IN_PATH} (where we will put our soft links to the software)
      if [[ -z "$(echo "${PATH}" | grep -Eo "(.*:.*)*${DIR_IN_PATH}")" ]]; then  # If it is not in PATH, add to bash functions
        echo "export PATH=$PATH:${DIR_IN_PATH}" >> ${BASH_FUNCTIONS_PATH}
      fi
    fi
  else  # user
    mkdir -p ${USR_BIN_FOLDER}
    mkdir -p ${DIR_IN_PATH}
    mkdir -p ${PERSONAL_LAUNCHERS_DIR}
    mkdir -p ${BASH_FUNCTIONS_FOLDER}

    # If $BASH_FUNCTION_PATH does not exist, create the exit point when running not interactively.
    if [[ ! -f ${BASH_FUNCTIONS_PATH} ]]; then
      echo "${bash_functions_init}" > "${BASH_FUNCTIONS_PATH}"
    else
      # Import bash functions to know which functions are installed (used for detecting installed alias or functions)
      source ${BASH_FUNCTIONS_PATH}
    fi

    # Make sure that PATH is pointing to ${DIR_IN_PATH} (where we will put our soft links to the software)
    if [[ -z "$(echo "${PATH}" | grep -Eo "(.*:.*)*${DIR_IN_PATH}")" ]]; then  # If it is not in PATH, add to bash functions
      echo "export PATH=$PATH:${DIR_IN_PATH}" >> ${BASH_FUNCTIONS_PATH}
    fi
  fi

  # Make sure .bash_functions and its structure is present
  if [[ -z "$(cat ${BASHRC_PATH} | grep -Fo "source ${BASH_FUNCTIONS_PATH}" )" ]]; then  # .bash_functions not added
    echo -e "${bash_functions_import}" >> ${BASHRC_PATH}
  fi


  ###### ARGUMENT PROCESSING ######

  while [[ $# -gt 0 ]]; do
    key="$1"

    case ${key} in
      ### BEHAVIOURAL ARGUMENTS ###
      -v|--verbose)
        FLAG_QUIETNESS=0
      ;;
      -q|--quiet)
        FLAG_QUIETNESS=1
      ;;
      -Q|--Quiet)
        FLAG_QUIETNESS=2
      ;;

      -o|--overwrite|--overwrite-if-present)
        FLAG_OVERWRITE=1
      ;;
      -s|--skip|--skip-if-installed)
        FLAG_OVERWRITE=0
      ;;

      -i|--ignore|--ignore-errors)
        FLAG_IGNORE_ERRORS=1
      ;;
      -e|--exit|--exit-on-error)
        FLAG_IGNORE_ERRORS=0
      ;;

      # Force is the two previous active behaviours in one
      -f|--force)
        FLAG_IGNORE_ERRORS=1
        FLAG_OVERWRITE=1
      ;;

      -d|--dirty|--no-autoclean)
        FLAG_AUTOCLEAN=0
      ;;
      -c|--clean)
        FLAG_AUTOCLEAN=1
      ;;
      -C|--Clean)
        FLAG_AUTOCLEAN=2
      ;;

      -U|--upgrade|--Upgrade)
        FLAG_UPGRADE=2
      ;;
      -u|--update)
        FLAG_UPGRADE=1
      ;;
      -k|--keep-system-outdated)
        FLAG_UPGRADE=0
      ;;

      -n|--not|-!)
        FLAG_INSTALL=0
      ;;
      -y|--yes)
        FLAG_INSTALL=${NUM_INSTALLATION}
      ;;

      -h)
        output_proxy_executioner "echo ${help_common}${help_simple}" ${FLAG_QUIETNESS}
        exit 0
      ;;

      -H|--help)
        output_proxy_executioner "echo ${help_common}${help_arguments}" ${FLAG_QUIETNESS}
        exit 0
      ;;

      ### WRAPPER ARGUMENTS ###
      --custom1)
        add_programs "${custom1[@]}"
      ;;
      --iochem)
        add_programs "${iochem[@]}"
      ;;
      --user|--regular|--normal)
        add_programs_with_x_permissions 0
      ;;
      --root|--superuser|--su)
        add_programs_with_x_permissions 1
      ;;
      --ALL|--all|--All)
        add_programs_with_x_permissions 2
      ;;

      *)  # Individual argument
        found=0
        for program in "${installation_data[@]}"; do
          program_arguments=$(echo ${program} | cut -d ";" -f1)
          numargs=$(echo ${program_arguments} | tr "|" " " | wc -w)
          for (( i=0; i<${numargs}; i++ )); do
            arg_i=$(echo ${program_arguments} | cut -d "|" -f$((i+1)) )
            if [[ ${arg_i} == ${key} ]]; then
              function_name=$(echo ${program} | rev | cut -d ";" -f1 | rev)
              add_program ${function_name}
              found=1
            fi
          done
        done
        if [[ ${found} == 0 ]]; then
          output_proxy_executioner "echo WARNING: ${key} is not a recognized command. Skipping this argument." ${FLAG_QUIETNESS}
        fi
      ;;
    esac
    shift
  done

  # If we don't receive arguments we try to install everything that we can given our permissions
  if [[ ${NUM_INSTALLATION} == 0 ]]; then
    output_proxy_executioner "echo ERROR: No arguments provided to install feature. Displaying help and finishing..." ${FLAG_QUIETNESS}
    output_proxy_executioner "echo ${help_message}" ${FLAG_QUIETNESS}
    exit 0
  fi

  ####### EXECUTION #######

  ### PRE-INSTALLATION UPDATE ###

  if [[ ${EUID} == 0 ]]; then
    if [[ ${FLAG_UPGRADE} -gt 0 ]]; then
      output_proxy_executioner "echo INFO: Attempting to update system via apt-get." ${FLAG_QUIETNESS}
      output_proxy_executioner "apt-get -y update" ${FLAG_QUIETNESS}
      output_proxy_executioner "echo INFO: System updated." ${FLAG_QUIETNESS}
    fi
    if [[ ${FLAG_UPGRADE} == 2 ]]; then
      output_proxy_executioner "echo INFO: Attempting to upgrade system via apt-get." ${FLAG_QUIETNESS}
      output_proxy_executioner "apt-get -y upgrade" ${FLAG_QUIETNESS}
      output_proxy_executioner "echo INFO: System upgraded." ${FLAG_QUIETNESS}
    fi
  fi


  ### INSTALLATION ###

  execute_installation

  ###############################
  ### POST-INSTALLATION CLEAN ###
  ###############################

  if [[ ${EUID} == 0 ]]; then
    if [[ ${FLAG_AUTOCLEAN} -gt 0 ]]; then
      output_proxy_executioner "echo INFO: Attempting to clean orphaned dependencies via apt-get autoremove." ${FLAG_QUIETNESS}
      output_proxy_executioner "apt-get -y autoremove" ${FLAG_QUIETNESS}
      output_proxy_executioner "echo INFO: Finished." ${FLAG_QUIETNESS}
    fi
    if [[ ${FLAG_AUTOCLEAN} == 2 ]]; then
      output_proxy_executioner "echo INFO: Attempting to delete useless files in cache via apt-get autoremove." ${FLAG_QUIETNESS}
      output_proxy_executioner "apt-get -y autoclean" ${FLAG_QUIETNESS}
      output_proxy_executioner "echo INFO: Finished." ${FLAG_QUIETNESS}
    fi
  fi

  # Make the bell sound at the end
  echo -en "\07"; echo -en "\07"; echo -en "\07"
}


# Import file of common variables in a relative way, so customizer can be called system-wide
# RF, duplication in uninstall. Common extraction in the future in the common endpoint customizer.sh
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then
  DIR="${PWD}"
fi



if [[ -f "${DIR}/data_install.sh" ]]; then
  source "${DIR}/data_install.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: data_install.sh not found. Aborting..."
  exit 1
fi
# Call main function
main "$@"

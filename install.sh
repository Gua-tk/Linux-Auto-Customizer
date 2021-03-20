#!/usr/bin/env bash
# A simple portable shell script to initialize and customize a Linux working environment. Needs root permission for some features.
# Author: Aleix Mariné (aleix.marine@estudiants.urv.cat)
# Created on 28/5/19
# Last Update 11/3/2021

# //RF:
# using .bash_functions for shell features: converters,

# common //RF:
# missing {} around var
# wget not used with -O and in subshell to avoid cd
# tar not used in a subshell to avoid cd
# echo or err directly used instead of using output_proxy_executioner
# desktop launchers created manually as user created ONLY in the desktop and not also in the user launchers folder
# desktop launchers created manually as root created ONLY in the desktop and not in the all users launchers folder
# Files or folders created as root that only change their permissions, and not also its group and owner, using chgrp and chown
# using ~ or $HOME instead of HOME_FOLDER
# console feature installed directly in bashrc instead of using the structure provided by the customizer using .bash_functions

# other //RF:
# unify the format of .desktop launchers

################################
###### AUXILIAR FUNCTIONS ######
################################


create_folder_as_root()
{
  mkdir -p $1
  # Convert folder to a SUDO_ROOT user
  chgrp ${SUDO_USER} $1
  chown ${SUDO_USER} $1
  chmod 775 $1
}


# Associate a file type (mime type) to a certain application using its desktop launcher.
# Argument 1: File types. Example: application/x-shellscript
# Argument 2: Application. Example: sublime_text.desktop
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

# Creates a valid launcher for the normal user in the desktop using an
# already created launcher from an automatic install (using apt or dpkg).
# This function does not need to have root permissions for its instructions,
# but is expected to be call as root since it uses the variable $SUDO_USER 
# Argument 1: name of the desktop launcher in /usr/share/applications
copy_launcher()
{
  if [[ -f ${ALL_USERS_LAUNCHERS_DIR}/$1 ]]; then
    cp ${ALL_USERS_LAUNCHERS_DIR}/$1 ${XDG_DESKTOP_DIR}
    chmod 775 ${XDG_DESKTOP_DIR}/$1
    chgrp ${SUDO_USER} ${XDG_DESKTOP_DIR}/$1
    chown ${SUDO_USER} ${XDG_DESKTOP_DIR}/$1
  fi
}

# This function creates a valid launcher in the desktop using a a given string with the given name
# Argument 1: The string of the text of the desktop.
# Argument 2: The name of the launcher.
create_manual_launcher()
{
# If user
if [[ ${EUID} -ne 0 ]]; then
  echo -e "$1" > ${PERSONAL_LAUNCHERS_DIR}/$2.desktop
  chmod 775 ${PERSONAL_LAUNCHERS_DIR}/$2.desktop
  cp -p ${PERSONAL_LAUNCHERS_DIR}/$2.desktop ${XDG_DESKTOP_DIR}
else  # if root
  echo -e "$1" > ${ALL_USERS_LAUNCHERS_DIR}/$2.desktop
  chmod 775 ${ALL_USERS_LAUNCHERS_DIR}/$2.desktop
  chgrp ${SUDO_USER} ${ALL_USERS_LAUNCHERS_DIR}/$2.desktop
  chown ${SUDO_USER} ${ALL_USERS_LAUNCHERS_DIR}/$2.desktop
  cp -p ${ALL_USERS_LAUNCHERS_DIR}/$2.desktop ${XDG_DESKTOP_DIR}
fi
}

# Download and decompress a compressed file pointed by the provided link into USR_BIN_FOLDER.
# We assume that this compressed file contains only one folder in the root.
# Argument 1: link to the compressed file
# Argument 2: Final name of the folder
# Argument 3: Decompression options: [z, j, J]
# Argument 4: Relative path to the selected binary to create the links in the path from the just decompressed folder
# Argument 5: Desired name for the hard-link that points to the previous binary
# Argument 6 and 7, 8 and 9, 10 and 11... : Same as argument 4 and 5
download_and_decompress()
{
  # Clean to avoid conflicts with previously installed software or aborted installation
  rm -f ${USR_BIN_FOLDER}/downloaded_program*
  # Download in a subshell to avoid changing the working directory in the current shell
  (cd ${USR_BIN_FOLDER}; wget -O "downloaded_program" $1)
  # Capture root folder name
  program_folder_name=$( (tar -t$3f - | head -1 | cut -d "/" -f1) < ${USR_BIN_FOLDER}/downloaded_program)
  # Clean to avoid conflicts with previously installed software or aborted installation
  rm -Rf "${USR_BIN_FOLDER}/${program_folder_name}"
  # Decompress in a subshell to avoid changing the working directory in the current shell
  (cd ${USR_BIN_FOLDER}; tar -x$3f -) < ${USR_BIN_FOLDER}/downloaded_program
  # Delete downloaded files which will be no longer used
  rm -f ${USR_BIN_FOLDER}/downloaded_program*
  # Clean older installation to avoid conflicts
  rm -Rf "${USR_BIN_FOLDER}/$2"
  # Rename folder for coherence
  mv "${USR_BIN_FOLDER}/${program_folder_name}" "${USR_BIN_FOLDER}/$2"
  # Save the final name of the folder to regenerate the full path after the shifts
  program_folder_name="$2"
  # Shift the first 3 arguments to have only from 4th argument to the last in order to call create_links_in_path
  shift
  shift
  shift
  # Create links in the PATH
  while [[ $# -gt 0 ]]; do
    # Clean to avoid collisions
    create_links_in_path "${USR_BIN_FOLDER}/${program_folder_name}/$1" $2
    shift
    shift
  done
}


# Argument 1: Absolute path to the binary you want to be in the PATH
# Argument 2: Name of the hard-link that will be created in the path
# Argument 3 and 4, 5 and 6, 7 and 8... : Same as argument 1 and 2
create_links_in_path()
{
  while [[ $# -gt 0 ]]; do
    # Clean to avoid collisions
    ln -sf "$1" ${DIR_IN_PATH}/$2
    shift
    shift
  done
}


#############################################
###### SOFTWARE INSTALLATION FUNCTIONS ######
#############################################


install_studio()
{
  download_and_decompress ${android_studio_downloader} "android-studio" "z" "bin/studio.sh" "studio"

  # Create launcher
  create_manual_launcher "${android_studio_launcher}" "Android_Studio"
}


install_clion()
{
  download_and_decompress ${clion_downloader} "clion" "z" "bin/clion.sh" "clion"

  # Create launcher for clion in the desktop and in the launcher menu
  create_manual_launcher "${clion_launcher}" "clion"

  # register file associations
  register_file_associations "text/x-c++hdr" "clion.desktop"
  register_file_associations "text/x-c++src" "clion.desktop"
  register_file_associations "text/x-chdr" "clion.desktop"
  register_file_associations "text/x-csrc" "clion.desktop"
}


# discord desktop client
# Permissions: user
install_discord()
{
  download_and_decompress ${discord_downloader} "discord" "z" "Discord" "discord"

  # Create launchers in launcher and in desktop
  create_manual_launcher "${discord_launcher}" "discord"
}


# Install IntelliJ Community
install_ideac()
{
  download_and_decompress ${intellij_community_downloader} "idea-ic" "z" "bin/idea.sh" "ideac"

  # Create desktop launcher entry for intelliJ community
  create_manual_launcher "${intellij_community_launcher}" "ideac"

  # register file associations
  register_file_associations "text/x-java" "ideac.desktop"
}


# Install IntelliJ Ultimate
install_ideau()
{
  download_and_decompress ${intellij_ultimate_downloader} "idea-iu" "z" "bin/idea.sh" "ideau"

  # Create desktop launcher entry for intellij ultimate
  create_manual_launcher "${intellij_ultimate_launcher}" "ideau"

  # register file associations
  register_file_associations "text/x-java" "ideau.desktop"
}


# Manual install, creating launcher in the launcher and in desktop. Modifies .desktop file provided by the software
install_mendeley()
{
  download_and_decompress ${mendeley_downloader} "mendeley" "j" "bin/idea.sh" "mendeley"

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

  # Create launcher for pycharm in the desktop and in the launcher menu
  create_manual_launcher "$pycharm_launcher" "pycharm"

  # register file associations
  register_file_associations "text/x-python" "pycharm.desktop"
  register_file_associations "text/x-python3" "pycharm.desktop"
  register_file_associations "text/x-sh" "pycharm.desktop"
}


# Installs pycharm professional, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharmpro()
{
  download_and_decompress ${pycharm_professional_downloader} "pycharm-professional" "z" "bin/pycharm.sh" "pycharmpro"

  # Create launcher for pycharm in the desktop and in the launcher menu
  create_manual_launcher "$pycharm_professional_launcher" "pycharm-pro"

  # register file associations
  register_file_associations "text/x-sh" "pycharm-pro.desktop"
  register_file_associations "text/x-python" "pycharm-pro.desktop"
  register_file_associations "text/x-python3" "pycharm-pro.desktop"
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

  # Create links to the PATH
  create_links_in_path "${USR_BIN_FOLDER}/pypy3/bin/pypy3" "pypy3" ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 pypy3-pip
}


# Install Sublime text 3
install_sublime()
{
  download_and_decompress ${sublime_text_downloader} "sublime-text" "j" "sublime_text" "sublime"

  # Create desktop launcher entry for sublime text
  create_manual_launcher "${sublime_text_launcher}" "sublime"

  # register file associations
  register_file_associations "text/x-sh" "sublime-text.desktop"
  register_file_associations "text/x-c++hdr" "sublime-text.desktop"
  register_file_associations "text/x-c++src" "sublime-text.desktop"
  register_file_associations "text/x-chdr" "sublime-text.desktop"
  register_file_associations "text/x-csrc" "sublime-text.desktop"
  register_file_associations "text/x-python" "sublime-text.desktop"
  register_file_associations "text/x-python3" "sublime-text.desktop"
}


# Telegram installation
install_telegram()
{
  download_and_decompress ${telegram_downloader} "telegram" "J" "Telegram" "telegram"

  # Create desktop launcher entry for telegram
  create_manual_launcher "${telegram_launcher}" "telegram"
}


# Microsoft Visual Studio Code
install_code()
{
  download_and_decompress ${visualstudiocode_downloader} "visual-studio" "z" "code" "code"

  # Create desktop launcher entry
  create_manual_launcher "${visualstudiocode_launcher}" "code"
}


############################
###### ROOT FUNCTIONS ######
############################

# Download a package temporarily in USR_BIN_FOLDER and install it using dpkg or other package manager.
# Argument 1: Link to the package file to download
download_and_install_package()
{
  rm -f ${USR_BIN_FOLDER}/downloading_package*
  (cd ${USR_BIN_FOLDER}; wget -O downloading_package $1)
  dpkg -i ${USR_BIN_FOLDER}/downloading_package
  rm -f ${USR_BIN_FOLDER}/downloading_package*
}

install_audacity()
{
  apt-get install -y audacity
  copy_launcher audacity.desktop
}


install_atom()
{
  download_and_install_package ${atom_downloader}
  copy_launcher atom.desktop
}


install_caffeine()
{
  apt install -y caffeine
  copy_launcher caffeine-indicator.desktop
}


install_calibre()
{
  apt install -y calibre
  copy_launcher calibre-gui.desktop
}


# there's a curl dependency to use cht.sh
install_cheat()
{
  rm -f ${USR_BIN_FOLDER}/cheat.sh
  (cd ${USR_BIN_FOLDER}; wget -O cheat.sh ${cheat_downloader})

  create_links_in_path ${USR_BIN_FOLDER}/cheat.sh cheat
}


install_cheese()
{
  apt install -y cheese
  copy_launcher org.gnome.Cheese.desktop
}


install_clementine()
{
  apt install -y clementine
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

install_codium()
{
  download_and_decompress ${codium_downloader} "codium" "z" "bin/codium" "codium"
  create_manual_launcher "${codium_launcher}" "codium"
}

install_copyq()
{
  apt-get install -y copyq
  copy_launcher "com.github.hluk.copyq.desktop"
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
  apt install -y freecad
  copy_launcher "freecad.desktop"
}


# Install gcc (C compiler)
# Needs root permission
install_gcc()
{
  apt install -y gcc
}


install_geany()
{
  apt install -y geany
  copy_launcher geany.desktop
}


# Install GIMP
install_gimp()
{
  apt install -y gimp
  copy_launcher "gimp.desktop"
}


# Install GIT and all its related utilities (gitk e.g.)
# Needs root permission
install_git()
{
  apt install -y git-all
  apt-get install -y git-lfs
}


install_gnome-chess()
{
  apt-get install -y gnome-chess
  copy_launcher "org.gnome.Chess.desktop"
}


# Install GNU parallel
install_parallel()
{
  apt-get -y install parallel
}


# Install gparted
install_gparted()
{
  apt install -y gparted
  copy_launcher "gparted.desktop"
}


# Checks if Google Chrome is already installed and installs it and its dependencies
# Needs root permission
install_google-chrome()
{
  # Dependencies
  apt-get install -y libxss1 libappindicator1 libindicator7

  download_and_install_package ${google_chrome_downloader}
  copy_launcher "google-chrome.desktop"
}


install_gvim()
{
  apt -y install vim-gtk3
  copy_launcher "gvim.desktop"
}


install_gpaint()
{
  apt -y install gpaint
  copy_launcher "gpaint.desktop"
  sed "s|Icon=gpaint.svg|Icon=${gpaint_icon_path}|" -i ${XDG_DESKTOP_DIR}/gpaint.desktop
}


install_inkscape()
{
  apt install -y inkscape
  copy_launcher "inkscape.desktop"
}


install_java()
{
  apt -y install default-jdk
}


install_latex()
{
  # Dependencies
  apt-get install -y perl-tk texlive-latex-extra texmaker
  copy_launcher "texmaker.desktop"
  copy_launcher "texdoctk.desktop"
  echo "Icon=/usr/share/icons/Yaru/256x256/mimetypes/text-x-tex.png" >> ${XDG_DESKTOP_DIR}/texdoctk.desktop
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
  apt-get install -y libc-ares2 libmediainfo0v5 libqt5x11extras5 libzen0v5

  download_and_install_package ${megasync_downloader}
  download_and_install_package ${megasync_integrator_downloader}
  copy_launcher megasync.desktop
}


# Mendeley Dependencies
install_mendeley_dependencies()
{
  # Mendeley dependencies
  apt-get -y install gconf2 qt5-default qt5-doc qt5-doc-html qtbase5-examples qml-module-qtwebengine
}


install_gnome-mines()
{
  apt-get install -y gnome-mines
  copy_launcher "org.gnome.Mines.desktop"
}


# Automatic install + Creates desktop launcher in launcher and in desktop. 
install_musicmanager()
{
  download_and_install_package ${music_manager_downloader}
  copy_launcher "google-musicmanager.desktop"
}


install_nemo()
{
  # Delete Nautilus, the default desktop manager to avoid conflicts
  apt purge -y nautilus gnome-shell-extension-desktop-icons
  apt -y install nemo dconf-editor gnome-tweak-tool
  # Create special launcher to execute nemo daemon at system start
  echo -e "${nemo_desktop_launcher}" > /etc/xdg/autostart/nemo-autostart.desktop
  # nemo configuration
  xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
  gsettings set org.gnome.desktop.background show-desktop-icons false
  gsettings set org.nemo.desktop show-desktop-icons true

  copy_launcher "nemo.desktop"
}


install_notepadqq()
{
  apt install -y notepadqq
  copy_launcher notepadqq.desktop
}


install_openoffice()
{
  # Delete old versions of openoffice to avoid conflicts
  apt remove -y libreoffice-base-core libreoffice-impress libreoffice-calc libreoffice-math libreoffice-common libreoffice-ogltrans libreoffice-core libreoffice-pdfimport libreoffice-draw libreoffice-style-breeze libreoffice-gnome libreoffice-style-colibre libreoffice-gtk3 libreoffice-style-elementary libreoffice-help-common libreoffice-style-tango libreoffice-help-en-us libreoffice-writer
  apt autoremove -y

  rm -f office*
  (cd ${USR_BIN_FOLDER}; wget -O office ${openoffice_downloader})

  rm -Rf en-US
  (cd ${USR_BIN_FOLDER}; tar -xzf -) < ${USR_BIN_FOLDER}/office
  rm -f office

  $(cd en-US/DEBS/; dpkg -i *.deb; cd desktop-integration/; dpkg -i *.deb  )
  rm -Rf en-US

  copy_launcher "openoffice4-base.desktop"
  copy_launcher "openoffice4-calc.desktop"
  copy_launcher "openoffice4-draw.desktop"
  copy_launcher "openoffice4-math.desktop"
  copy_launcher "openoffice4-writer.desktop"
}


install_obs-studio()
{
  # Dependencies
  apt install -y ffmpeg

  apt install -y obs-studio
  create_manual_launcher "${obs_desktop_launcher}" obs-studio
}


install_okular()
{
  apt-get -y install okular
}


install_pacman()
{
  apt-get install -y pacman
  copy_launcher "pacman.desktop"
}


install_pdfgrep()
{
  apt-get -y install pdfgrep
}


install_pluma()
{
  apt install -y pluma
  copy_launcher "pluma.desktop"
}


install_pypy3_dependencies()
{
  apt-get install -y -qq pkg-config
  apt-get install -y -qq libfreetype6-dev
  apt-get install -y -qq libpng-dev
  apt-get install -y -qq libffi-dev
}


install_python3()
{
  apt install -y python3-dev python-dev python3-pip
}


install_shotcut()
{
  apt install -y shotcut
  create_manual_launcher "${shotcut_desktop_launcher}" shotcut
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
  copy_launcher tilix.desktop
}


install_tmux()
{
  apt-get -y install tmux
  create_manual_launcher ${tmux_launcher} tmux
}


install_torbrowser()
{
  apt-get install -y torbrowser-launcher
  copy_launcher "torbrowser.desktop"
}


install_transmission()
{
  apt-get install -y transmission
  copy_launcher "transmission-gtk.desktop"
  create_links_in_path $(which transmission-gtk) transmission
}


install_uget()
{
  # Dependencies
  apt-get install -y aria2
  apt-get install -y uget
  copy_launcher uget-gtk.desktop
}


# install VLC
install_vlc()
{
  apt-get -y install vlc
  copy_launcher "vlc.desktop"
}


# VirtualBox
install_virtualbox()
{
  # Dependencies
  apt-get install libqt5opengl5
  
  download_and_install_package ${virtualbox_downloader}
  copy_launcher "virtualbox.desktop"
}


#############################
###### SYSTEM FEATURES ######
#############################
# Most (all) of them just use user permissions

### AUXILIAR FUNCTIONS ###
# Installs a new bash feature, installing its script into your environment using .bashrc, which uses .bash_functions
# Argument 1: Text containing all the code that will be saved into file, which will be sourced from bash_functions
# Argument 2: Name of the file.
add_bash_function()
{
  # Write code to bash functions folder with the name of the feature we want to install
  echo -e "$1" > ${BASH_FUNCTIONS_FOLDER}/$2
  import_line="source ${BASH_FUNCTIONS_FOLDER}/$2"
  # Add import_line to .bash_functions (BASH_FUNCTIONS_PATH)
  echo $import_line
  if [[ -z $(cat ${BASH_FUNCTIONS_PATH} | grep -Fo "${import_line}") ]]; then
    echo ${import_line} >> ${BASH_FUNCTIONS_PATH}
  fi
}



install_converters()
{
  rm -Rf ${USR_BIN_FOLDER}/converters
  git clone ${converters_downloader} ${USR_BIN_FOLDER}

  for converter in $(ls ${USR_BIN_FOLDER}/converters); do
    create_links_in_path ${USR_BIN_FOLDER}/converters/${converter} $(echo ${converter} | cut -d "." -f1)
  done

  add_bash_function ${converters_functions} converters.sh
}


# Install templates (available files in the right click --> new --> ...)
# Python3, bash shell scripts, latex documents
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


# Forces l as alias for ls -lAh
install_l()
{
  add_bash_function "${l_function}" l.sh
}


# Defines a function to extract all types of compressed files
install_extract()
{
  add_bash_function "${extract_function}" extract.sh
}


# Increases file history size, size of the history and forces to append to history, never overwrite
# Ignore repeated commands and simple commands
# Store multiline comments in just one command
install_history_optimization()
{
  add_bash_function "${shell_history_optimization_function}" history.sh
}


install_git_aliases()
{
  add_bash_function "${git_aliases_function}" git_aliases.sh
  rm -Rf ${USR_BIN_FOLDER}/.bash-git-prompt
  git clone https://github.com/magicmonty/bash-git-prompt.git ${USR_BIN_FOLDER}/.bash-git-prompt --depth=1
}


install_shortcuts()
{
  add_bash_function "${shortcut_aliases}" shortcuts.sh
}


install_prompt()
{
  add_bash_function "${prompt_function}" prompt.sh
}


install_terminal_background()
{
  dconf write /org/gnome/terminal/legacy/profiles:/$(dconf list /org/gnome/terminal/legacy/profiles:/)/background-color "'rgb(0,0,0)'"
}


###### AUXILIAR FUNCTIONS ######

# Common piece of code in the execute_installation function
# Argument 1: forceness_bit
# Argument 2: quietness_bit
# Argument 3: program_function
execute_installation_install_feature()
{
  feature_name=$( echo $3 | cut -d "_" -f2- )
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
      output_proxy_executioner "echo WARNING: $5 is already installed. Skipping..." $3
    fi
  fi
}

execute_installation()
{
  space=" "
  for program in ${installation_data[@]}; do
    # Installation bit processiong
    installation_bit=$( echo ${program} | cut -d ";" -f1 )
    if [[ ${installation_bit} == 1 ]]; then
      forceness_bit=$( echo ${program} | cut -d ";" -f2 )
      quietness_bit=$( echo ${program} | cut -d ";" -f3 )
      overwrite_bit=$( echo ${program} | cut -d ";" -f4 )
      program_function=$( echo ${program} | cut -d ";" -f6 )
      program_privileges=$( echo ${program} | cut -d ";" -f5 )

      program_name=$( echo ${program_function} | cut -d "_" -f2- )
      if [[ ${program_privileges} == 1 ]]; then
        if [[ ${EUID} -ne 0 ]]; then
          output_proxy_executioner "echo WARNING: $program_name needs root permissions to be installed. Skipping." ${quietness_bit}
        else
          execute_installation_wrapper_install_feature ${overwrite_bit} ${forceness_bit} ${quietness_bit} ${program_function} ${program_name}
        fi
      elif [[ ${program_privileges} == 0 ]]; then
        if [[ ${EUID} -ne 0 ]]; then
          execute_installation_wrapper_install_feature ${overwrite_bit} ${forceness_bit} ${quietness_bit} ${program_function} ${program_name}
        else
          output_proxy_executioner "echo WARNING: $program_name needs user permissions to be installed. Skipping." ${quietness_bit}
        fi
      fi
    fi
  done
}

# Receives a list of feature function name (install_pycharm, install_vlc...) and applies the current flags to it,
# modifying the corresponding line of installation_data
add_program()
{
  while [[ $# -gt 0 ]]; do
    ANY_INSTALLED=1  # Tells if there is any installed feature in order to determine if implicit to --all should be called
    total=${#installation_data[*]}
    for (( i=0; i<$(( ${total} )); i++ )); do
      program_name=$(echo "${installation_data[$i]}" | rev | cut -d ";" -f1 | rev )

      if [[ "$1" == "${program_name}" ]]; then
        # Cut static bits
        rest=$(echo "${installation_data[$i]}" | cut -d ";" -f5- )
        # Append static bits to the state of the flags
        new="${FLAG_INSTALL};${FLAG_IGNORE_ERRORS};${FLAG_QUIETNESS};${FLAG_OVERWRITE};${rest}"
        installation_data[$i]=${new}
      fi
    done
    shift
  done
}

##################
###### MAIN ######
##################
main()
{
  if [[ ${EUID} == 0 ]]; then
    create_folder_as_root ${USR_BIN_FOLDER}
    create_folder_as_root ${BASH_FUNCTIONS_FOLDER}
    create_folder_as_root ${DIR_IN_PATH}
    create_folder_as_root ${PERSONAL_LAUNCHERS_DIR}

    if [[ ! -f ${BASH_FUNCTIONS_PATH} ]]; then
      >${BASH_FUNCTIONS_PATH}
      chgrp ${SUDO_USER} ${BASH_FUNCTIONS_PATH}
      chown ${SUDO_USER} ${BASH_FUNCTIONS_PATH}
      chmod 775 ${BASH_FUNCTIONS_PATH}
    fi
  else
    mkdir -p ${USR_BIN_FOLDER}
    mkdir -p ${DIR_IN_PATH}
    mkdir -p ${PERSONAL_LAUNCHERS_DIR}
    mkdir -p ${BASH_FUNCTIONS_FOLDER}

    if [[ ! -f ${BASH_FUNCTIONS_PATH} ]]; then
      >${BASH_FUNCTIONS_PATH}
    else
      # Import bash functions to know which functions are installed (used for detecting installed alias or functions)
      source ${BASH_FUNCTIONS_PATH}
    fi
    
    # Make sure that PATH is pointing to ${DIR_IN_PATH} (where we will put our soft links to the software)
    if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "${DIR_IN_PATH}" )" ]]; then
      echo "export PATH=$PATH:${DIR_IN_PATH}" >> ${BASHRC_PATH}
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
        SILENT=0
      ;;
      -q|--quiet)
        FLAG_QUIETNESS=1
        SILENT=1
      ;;
      -Q|--Quiet)
        FLAG_QUIETNESS=2
        SILENT=2
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
        AUTOCLEAN=0
      ;;
      -c|--clean)
        AUTOCLEAN=1
      ;;
      -C|--Clean)
        AUTOCLEAN=2
      ;;

      -U|--upgrade|--Upgrade)
        UPGRADE=2
      ;;
      -u|--update)
        UPGRADE=1
      ;;
      -k|--keep-system-outdated)
        UPGRADE=0
      ;;

      -n|--not|-!)
        FLAG_INSTALL=0
      ;;
      -y|--yes)
        FLAG_INSTALL=1
      ;;

      -h|--help)
        output_proxy_executioner "echo ${help_message}" ${SILENT}
        exit 0
      ;;


      ### INDIVIDUAL ARGUMENTS ###
      # Sorted alphabetically by function name:
      --android|--AndroidStudio|--androidstudio|--studio|--android-studio|--android_studio|--Androidstudio)
        add_program install_studio
      ;;
      --audacity|--Audacity)
        add_program install_audacity
      ;;
      --atom|--Atom)
        add_program install_atom
      ;;
      --curl|--Curl)
        add_program install_curl
      ;;
      --discord|--Discord|--disc)
        add_program install_discord
      ;;
      --dropbox|--Dropbox|--DropBox|--Drop-box|--drop-box|--Drop-Box)
        add_program install_dropbox
      ;;
      --gcc|--GCC)
        add_program install_gcc
      ;;
      --caffeine|--Caffeine|--cafe|--coffee)
        add_program install_caffeine
      ;;
      --calibre|--Calibre|--cali)
        add_program install_calibre
      ;;
      --cheat|--cheat.sh|--Cheat.sh|--che)
        add_program install_cheat
      ;;
      --cheese|--Cheese)
        add_program install_cheese
      ;;
      --clementine|--Clementine)
        add_program install_clementine
      ;;
      --clion|--Clion|--CLion)
        add_program install_clion
      ;;
      --cmatrix|--Cmatrix)
        add_program install_cmatrix
      ;;
      --converters|--Converters)
        add_program install_converters
      ;;
      --clonezilla|--CloneZilla|--cloneZilla)
        add_program install_clonezilla
      ;;
      --codium|--vscodium)
        add_program install_codium
      ;;
      --copyq|--copy-q|--copy_q|--copqQ|--Copyq|--copy-Q)
        add_program install_copyq
      ;;
      --extract-function|-extract_function)
        add_program install_extract
      ;;
      --f-irc|--firc|--Firc|--irc)
        add_program install_f-irc
      ;;
      --firefox|--Firefox)
        add_program install_firefox
      ;;
      --freecad|--FreeCAD|--freeCAD)
        add_program install_freecad
      ;;
      --games|--Gaming|--Games)
        add_program install_games
      ;;
      --google-play-music|--musicmanager|--music-manager|--MusicManager|--playmusic|--GooglePlayMusic|--play-music|--google-playmusic|--Playmusic|--google-music)
        add_program install_musicmanager
      ;;
      --gpaint|--paint|--Gpaint)
        add_program install_gpaint
      ;;
      --geany|--Geany)
        add_program install_geany
      ;;
      --git)
        add_program install_git
      ;;
      --git-aliases|--git_aliases|--git-prompt)
        add_program install_git_aliases
      ;;
      --GIMP|--gimp|--Gimp)
        add_program install_gimp
      ;;
      --GNOME_Chess|--gnome_Chess|--gnomechess|--chess)
        add_program install_gnome-chess
      ;;
      --GParted|--gparted|--GPARTED|--Gparted)
        add_program install_gparted
      ;;
      --gvim|--vim-gtk3|--Gvim|--GVim)
        add_program install_gvim
      ;;
      --history-optimization)
        add_program install_history_optimization
      ;;
      --parallel|--gnu_parallel|--GNUparallel|--GNUParallel|--gnu-parallel)
        add_program install_parallel
      ;;
      --chrome|--Chrome|--google-chrome|--Google-Chrome)
        add_program install_google-chrome
      ;;
      --inkscape|--ink-scape|--Inkscape|--InkScape)
        add_program install_inkscape
      ;;
      --intellijcommunity|--intelliJCommunity|--intelliJ-Community|--intellij-community|--ideac)
        add_program install_ideac
      ;;
      --intellijultimate|--intelliJUltimate|--intelliJ-Ultimate|--intellij-ultimate|--ideau)
        add_program install_ideau
      ;;
      --java|--javadevelopmentkit|--java-development-kit|--java-development-kit-11|--java-development-kit11|--jdk|--JDK|--jdk11|--JDK11|--javadevelopmentkit-11)
        add_program install_java
      ;;
      --latex|--LaTeX|--tex|--TeX)
        add_program install_latex
      ;;
      --alias-l|--alias-ls|--l-alias|--ls-alias|--l)
        add_program install_l
      ;;
      --mahjongg|--Mahjongg|--gnome-mahjongg)
        add_program install_gnome-mahjongg
      ;;
      --mega|--Mega|--MEGA|--MegaSync|--MEGAsync|--MEGA-sync|--megasync)
        add_program install_megasync
      ;;
      --Mendeley|--mendeley|--mendeleyDesktop|--mendeley-desktop|--Mendeley-Desktop)
        add_program install_mendeley
      ;;
      --MendeleyDependencies|--mendeleydependencies|--mendeleydesktopdependencies|--mendeley-desktop-dependencies|--Mendeley-Desktop-Dependencies)
        add_program install_mendeley_dependencies
      ;;
      --mines|--Mines|--GNU-mines|--gnome-mines|--gnomemines)
        add_program install_gnome-mines
      ;;
      --nemo|--nemo-desktop|--Nemo-Desktop|--Nemodesktop|--nemodesktop|--Nemo|--Nemodesk|--NemoDesktop)
        add_program install_nemo
      ;;
      --notepadqq|--Notepadqq|--notepadQQ|--NotepadQQ|--notepadQq|--notepadQq|--NotepadQq|--NotepadqQ)
        add_program install_notepadqq
      ;;
      --office|--Openoffice|--OpenOffice|--openOfice|--open_office|--Office)
        add_program install_openoffice
      ;;
      --OBS|--obs|--obs-studio|--obs_studio|--obs_Studio|--OBS_studio|--obs-Studio|--OBS_Studio|--OBS-Studio)
        add_program install_obs-studio
      ;;
      --okular|--Okular|--okularpdf)
        add_program install_okular
      ;;
      --pdfgrep|--findpdf|--pdf)
        add_program install_pdfgrep
      ;;
      --pluma)
        add_program install_pluma
      ;;
      --prompt)
        add_program install_prompt
      ;;
      --pycharmcommunity|--pycharmCommunity|--pycharm_community|--pycharm|--pycharm-community)
        add_program install_pycharm
      ;;
      --pycharmpro|--pycharmPro|--pycharm_pro|--pycharm-pro|--Pycharm-Pro|--PyCharm-pro)
        add_program install_pycharmpro
      ;;
      -p|--python|--python3|--Python3|--Python)
        add_program install_python3
      ;;
      --pypy|--pypy3|--PyPy3|--PyPy)
        add_program install_pypy3
      ;;
      --dependencies|--pypy3_dependencies|--pypy3Dependencies|--PyPy3Dependencies|--pypy3dependencies|--pypy3-dependencies)
        add_program install_pypy3_dependencies
      ;;
      --shotcut|--ShotCut|--Shotcut|--shot-cut|--shot_cut)
        add_program install_shotcut
      ;;
      --shortcuts)
        add_program install_shortcuts
      ;;
      --sudoku|--Sudoku|--gnome-sudoku)
        add_program install_gnome-sudoku
      ;;
      --solitaire|--Solitaire|--gnome-solitaire|--aisleriot)
        add_program install_aisleriot
      ;;
      --sublime|--sublimeText|--sublime_text|--Sublime|--sublime-Text|--sublime-text)
        add_program install_sublime
      ;;
      --sudoku|--Sudoku|--GNU-sudoku|--gnome-sudoku|--gnomesudoku)
        add_program install_sudoku
      ;;
      --steam|--Steam|--STEAM)
        add_program install_steam
      ;;
      --Telegram|--telegram)
        add_program install_telegram
      ;;
      --templates)
        add_program install_templates
      ;;
      --terminal-background|--terminal_background)
        add_program install_terminal_background
      ;;
      --Terminator|--terminator)
        add_program install_terminator
      ;;
      --Tilix|--tilix)
        add_program install_tilix
      ;;
      --tmux|--Tmux)
        add_program install_tmux
      ;;
      --thunderbird|--mozillathunderbird|--mozilla-thunderbird|--Thunderbird|--thunder-bird)
        add_program install_thunderbird
      ;;
      --tor|--torbrowser|--tor_browser|--TOR|--TOR-browser|--TOR-BROSWER|--TORBROWSER|--TOR_BROWSER|--TOR_browser)
        add_program install_torbrowser
      ;;
      --transmission|--transmission-gtk|--Transmission)
        add_program install_transmission
      ;;
      --uget)
        add_program install_uget
      ;;
      --virtualbox|--virtual-box|--VirtualBox|--virtualBox|--Virtual-Box|--Virtualbox)
        add_program install_virtualbox
      ;;
      --visualstudiocode|--visual-studio-code|--code|--Code|--visualstudio|--visual-studio)
        add_program install_code
      ;;
      --vlc|--VLC|--Vlc)
        add_program install_vlc
      ;;

      ### WRAPPER ARGUMENTS ###
      --user|--regular|--normal)
        add_user_programs
      ;;
      --root|--superuser|--su)
        add_root_programs
      ;;
      --ALL|--all|--All)
        add_all_programs
      ;;
      *)    # unknown option
        output_proxy_executioner "echo ERROR: ${key} is not a recognized command. Skipping this argument." ${SILENT}
      ;;
    esac
    shift
  done

  # If we don't receive arguments we try to install everything that we can given our permissions
  if [[ ${ANY_INSTALLED} == 0 ]]; then
    output_proxy_executioner "echo ERROR: No arguments provided to install feature. Displaying help and finishing..." ${SILENT}
    output_proxy_executioner "echo ${help_message}" ${SILENT}
    exit 0
  fi

  ####### EXECUTION #######

  ### PRE-INSTALLATION UPDATE ###

  if [[ ${EUID} == 0 ]]; then
    if [[ ${UPGRADE} -gt 0 ]]; then
      output_proxy_executioner "echo INFO: Attempting to update system via apt-get." ${SILENT}
      output_proxy_executioner "apt-get -y update" ${SILENT}
      output_proxy_executioner "echo INFO: System updated." ${SILENT}
    fi
    if [[ ${UPGRADE} == 2 ]]; then
      output_proxy_executioner "echo INFO: Attempting to upgrade system via apt-get." ${SILENT}
      output_proxy_executioner "apt-get -y upgrade" ${SILENT}
      output_proxy_executioner "echo INFO: System upgraded." ${SILENT}
    fi
  fi


  ### INSTALLATION ###

  execute_installation


  ### POST-INSTALLATION CLEAN ###

  if [[ ${EUID} == 0 ]]; then
    if [[ ${AUTOCLEAN} -gt 0 ]]; then
      output_proxy_executioner "echo INFO: Attempting to clean orphaned dependencies via apt-get autoremove." ${SILENT}
      output_proxy_executioner "apt-get -y autoremove" ${SILENT}
      output_proxy_executioner "echo INFO: Finished." ${SILENT}
    fi
    if [[ ${AUTOCLEAN} == 2 ]]; then
      output_proxy_executioner "echo INFO: Attempting to delete useless files in cache via apt-get autoremove." ${SILENT}
      output_proxy_executioner "apt-get -y autoclean" ${SILENT}
      output_proxy_executioner "echo INFO: Finished." ${SILENT}
    fi
  fi
}


# Import file of common variables in a relative way to themselves so they alw
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then
  DIR="${PWD}"
fi
source "${DIR}/common_data.sh"

# Call main function
main "$@"

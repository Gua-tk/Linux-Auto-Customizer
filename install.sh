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

# Prints the given arguments to the stderr //RF
err()
{
  echo "$*" >&2
}

#############################################
###### SOFTWARE INSTALLATION FUNCTIONS ######
#############################################


install_android_studio()
{
  rm -f ${USR_BIN_FOLDER}/android_studio*.tar.gz*
  # Download in a subshell to avoid changing the working directory in the current shell
  (cd ${USR_BIN_FOLDER}; wget -O "android_studio" ${android_studio_downloader})
  # Decompress in a subshell to avoid changing the working directory in the current shell
  rm -Rf ${USR_BIN_FOLDER}/android-studio
  (cd ${USR_BIN_FOLDER}; tar -xzf -) < ${USR_BIN_FOLDER}/android_studio
  rm -f ${USR_BIN_FOLDER}/android_studio*

  # Create links to the PATH
  rm -f ${DIR_IN_PATH}/studio
  ln -s ${USR_BIN_FOLDER}/android-studio/bin/studio.sh ${DIR_IN_PATH}/studio
  # Create launcher
  create_manual_launcher "${android_studio_launcher}" "Android_Studio"
}


install_clion()
{
  # Folder and file are called the same
  rm -f ${USR_BIN_FOLDER}/clion*
  rm -Rf ${USR_BIN_FOLDER}/Clion*
  # Download in a subshell to avoid changing the working directory in the current shell
  (cd "${USR_BIN_FOLDER}"; wget -O "clion" "${clion_downloader}")
  # Decompress in a subshell to avoid changing the working directory in the current shell
  (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/clion
  rm -f ${USR_BIN_FOLDER}/clion
  # Modify folder name for coherence
  mv ${USR_BIN_FOLDER}/Clion* ${USR_BIN_FOLDER}/clion

  # Create links in the PATH
  rm -f ${DIR_IN_PATH}/clion
  ln -s ${USR_BIN_FOLDER}/clion/bin/clion.sh ${DIR_IN_PATH}/clion

  # Create launcher for clion in the desktop and in the launcher menu
  create_manual_launcher "${clion_launcher}" "clion"

  # register file associations
  register_file_associations "text/x-c++hdr" "clion.desktop"
  register_file_associations "text/x-c++src" "clion.desktop"
  register_file_associations "text/x-chdr" "clion.desktop"
  register_file_associations "text/x-csrc" "clion.desktop"
}


install_converters()
{
  rm -Rf ${USR_BIN_FOLDER}/converters
  git clone ${converters_downloader} ${USR_BIN_FOLDER}


  rm -f ${DIR_IN_PATH}/dectohex
  rm -f ${DIR_IN_PATH}/hextodec
  rm -f ${DIR_IN_PATH}/bintodec
  rm -f ${DIR_IN_PATH}/dectobin
  rm -f ${DIR_IN_PATH}/dectoutf
  rm -f ${DIR_IN_PATH}/dectooct
  rm -f ${DIR_IN_PATH}/utftodec

  ln -s ${USR_BIN_FOLDER}/converters/dectohex.py ${DIR_IN_PATH}/dectohex
  ln -s ${USR_BIN_FOLDER}/converters/hextodec.py ${DIR_IN_PATH}/hextodec
  ln -s ${USR_BIN_FOLDER}/converters/bintodec.py ${DIR_IN_PATH}/bintodec
  ln -s ${USR_BIN_FOLDER}/converters/dectobin.py ${DIR_IN_PATH}/dectobin
  ln -s ${USR_BIN_FOLDER}/converters/dectoutf.py ${DIR_IN_PATH}/dectoutf
  ln -s ${USR_BIN_FOLDER}/converters/dectooct.py ${DIR_IN_PATH}/dectooct
  ln -s ${USR_BIN_FOLDER}/converters/utftodec.py ${DIR_IN_PATH}/utftodec

  # //RF
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "${converters_bashrc_call}" )" ]]; then
    echo -e "$converters_bashrc_call" >> ${BASHRC_PATH}
  else
  err "WARNING: converters functions are already installed. Skipping"
  fi
  echo "${converters_links}" > ${HOME}/.bash_functions
}


# discord desktop client
install_discord()
{
  rm -f ${USR_BIN_FOLDER}/disc*
  # Download in a subshell to avoid changing the working directory in the current shell
  (cd "${USR_BIN_FOLDER}"; wget -O "disc" ${discord_downloader})
  rm -Rf ${USR_BIN_FOLDER}/discord*
  rm -Rf ${USR_BIN_FOLDER}/Discord*
  # Decompress in a subshell to avoid changing the working directory in the current shell
  (cd ${USR_BIN_FOLDER}; tar -xzf -) < ${USR_BIN_FOLDER}/disc
  rm -f ${USR_BIN_FOLDER}/disc*
  # Modify name for coherence
  mv ${USR_BIN_FOLDER}/Discord ${USR_BIN_FOLDER}/discord

  # Create links in the PATH
  rm -f ${DIR_IN_PATH}/discord
  ln -s ${USR_BIN_FOLDER}/discord/Discord ${DIR_IN_PATH}/discord

  # Create launchers in launcher and in desktop
  create_manual_launcher "${discord_launcher}" "discord"
}


# Install IntelliJ Community
install_intellij_community()
{
  rm -f ${USR_BIN_FOLDER}/ideac*
  # Download in a subshell to avoid changing the working directory in the current shell
  (cd ${USR_BIN_FOLDER}; wget -O ideac ${intellij_community_downloader})
  rm -Rf ${USR_BIN_FOLDER}/idea-IC*
  rm -Rf ${USR_BIN_FOLDER}/idea-ic*
  # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
  (cd ${USR_BIN_FOLDER}; tar -xzf -) < ${USR_BIN_FOLDER}/ideac
  rm -f ${USR_BIN_FOLDER}/ideac*
  # Modify name for coherence
  mv ${USR_BIN_FOLDER}/idea-IC* ${USR_BIN_FOLDER}/idea-ic

  # Create link in the PATH
  rm -f ${DIR_IN_PATH}/ideac*
  ln -s ${USR_BIN_FOLDER}/ideac/bin/idea.sh ${DIR_IN_PATH}/ideac

  # Create desktop launcher entry for intelliJ community
  create_manual_launcher "${intellij_community_launcher}" "ideac"

  # register file associations
  register_file_associations "text/x-java" "ideac.desktop"
}


# Install IntelliJ Ultimate
install_intellij_ultimate()
{
  rm -f ${USR_BIN_FOLDER}/ideau*
  # Download in a subshell to avoid changing the working directory in the current shell
  (cd ${USR_BIN_FOLDER}; wget -O ideau ${intellij_ultimate_downloader})
  rm -Rf ${USR_BIN_FOLDER}/idea-IU*
  rm -Rf ${USR_BIN_FOLDER}/idea-iu*
  # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
  (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/ideau
  rm -f ${USR_BIN_FOLDER}/ideau*
  # Modify name for coherence
  mv ${USR_BIN_FOLDER}/idea-IU* ${USR_BIN_FOLDER}/idea-iu

  # Create link in the PATH
  rm -f ${DIR_IN_PATH}/ideau*
  ln -s ${USR_BIN_FOLDER}/ideau/bin/idea.sh ${DIR_IN_PATH}/ideau

  # Create desktop launcher entry for intellij ultimate
  create_manual_launcher "${intellij_ultimate_launcher}" "ideau"

  # register file associations
  register_file_associations "text/x-java" "ideau.desktop"
}


# Manual install, creating launcher in the launcher and in desktop. Modifies .desktop file provided by the software
install_mendeley()
{
  rm -Rf ${USR_BIN_FOLDER}/mendeley*
  # Download in a subshell to avoid changing the working directory in the current shell
  (cd ${USR_BIN_FOLDER}; wget -O "mendeley" ${mendeley_downloader})
  rm -Rf ${USR_BIN_FOLDER}/mendeley*
  # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
  (cd ${USR_BIN_FOLDER}; tar -xjf -) < ${USR_BIN_FOLDER}/mendeley
  rm -f ${USR_BIN_FOLDER}/mendeley*
  # Rename folder for coherence
  mv ${USR_BIN_FOLDER}/mendeley* ${USR_BIN_FOLDER}/mendeley

  # Create link in the PATH
  rm -f ${DIR_IN_PATH}/mendeley*
  ln -s ${USR_BIN_FOLDER}/mendeley/bin/mendeleydesktop ${DIR_IN_PATH}/mendeley

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
install_pycharm_community()
{
  rm -f ${USR_BIN_FOLDER}/pycharm*
  # Download in a subshell to avoid changing the working directory in the current shell
  (cd ${USR_BIN_FOLDER}; wget -O "pycharm" ${pycharm_downloader})
  rm -Rf ${USR_BIN_FOLDER}/pycharm-community*
  # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
  (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/pycharm
  rm -f ${USR_BIN_FOLDER}/pycharm*
  # Rename folder for coherence
  mv ${USR_BIN_FOLDER}/pycharm-community* ${USR_BIN_FOLDER}/pycharm-community

  # Create links in the PATH
  rm -f ${DIR_IN_PATH}/pycharm
  ln -s ${USR_BIN_FOLDER}/pycharm-community/bin/pycharm.sh ${DIR_IN_PATH}/pycharm

  # Create launcher for pycharm in the desktop and in the launcher menu
  create_manual_launcher "$pycharm_launcher" "pycharm"

  # register file associations
  register_file_associations "text/x-python" "pycharm.desktop"
  register_file_associations "text/x-python3" "pycharm.desktop"
  register_file_associations "text/x-sh" "pycharm.desktop"
}


# Installs pycharm professional, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharm_professional()
{
  # Avoid error due to possible previous aborted installations
  rm -f ${USR_BIN_FOLDER}/pycharmpro*
  # Download in a subshell to avoid changing the working directory in the current shell
  (cd ${USR_BIN_FOLDER}; wget -O "pycharmpro" ${pycharm_professional_downloader})
  rm -Rf ${USR_BIN_FOLDER}/pycharm-[0-9]*
  rm -Rf ${USR_BIN_FOLDER}/pycharm-pro
  # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
  (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/pycharmpro
  rm -f ${USR_BIN_FOLDER}/pycharmpro*
  # Rename folder for coherence
  mv ${USR_BIN_FOLDER}/pycharm-[0-9]* ${USR_BIN_FOLDER}/pycharm-professional

  # Create links in the PATH
  rm -f ${DIR_IN_PATH}/pycharmpro
  ln -s ${USR_BIN_FOLDER}/pycharm-professional/bin/pycharm.sh ${DIR_IN_PATH}/pycharm-pro

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
  # Avoid error due to possible previous aborted installations
  rm -f ${USR_BIN_FOLDER}/${pypy3_version}.tar.bz2*
  # Download pypy
  wget -P ${USR_BIN_FOLDER} ${pycharm_downloader}
  rm -Rf ${USR_BIN_FOLDER}/${pypy3_version}
  rm -Rf ${USR_BIN_FOLDER}/pypy3
  # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
  (cd "${USR_BIN_FOLDER}"; tar -xjf -) < ${USR_BIN_FOLDER}/${pypy3_version}.tar.bz2
  rm -f ${USR_BIN_FOLDER}/${pypy3_version}.tar.bz2*
  # Rename folder for coherence
  mv ${USR_BIN_FOLDER}/${pypy3_version} ${USR_BIN_FOLDER}/pypy3

  # Install modules using pip
  ${USR_BIN_FOLDER}/pypy3/bin/pypy3 -m ensurepip

  # Forces download of pip and of modules
  ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 --no-cache-dir -q install --upgrade pip
  ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 --no-cache-dir install cython numpy
  # Currently not supported
  # ${USR_BIN_FOLDER}/${pypy3_version}/bin/pip3.6 --no-cache-dir install matplotlib

  # Create links to the PATH
  rm -f ${DIR_IN_PATH}/pypy3
  ln -s ${USR_BIN_FOLDER}/pypy3/bin/pypy3 ${DIR_IN_PATH}/pypy3
  rm -f ${DIR_IN_PATH}/pypy3-pip
  ln -s ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 ${DIR_IN_PATH}/pypy3-pip
}


# Install Sublime text 3
install_sublime_text()
{
  # Avoid error due to possible previous aborted installations
  rm -f ${USR_BIN_FOLDER}/${sublime_text_version}.tar.bz2*
  rm -Rf ${USR_BIN_FOLDER}/${sublime_text_version}
  # Download sublime_text
  wget -P ${USR_BIN_FOLDER} https://download.sublimetext.com/${sublime_text_version}.tar.bz2
  # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
  (cd "${USR_BIN_FOLDER}"; tar -xjf -) < ${USR_BIN_FOLDER}/${sublime_text_version}.tar.bz2
  # Clean
  rm -f ${USR_BIN_FOLDER}/${sublime_text_version}.tar.bz2*
  # Rename folder for coherence
  mv ${USR_BIN_FOLDER}/sublime_text_3 ${USR_BIN_FOLDER}/sublime-text
  # Create link to the PATH
  rm -f ${DIR_IN_PATH}/sublime
  ln -s ${USR_BIN_FOLDER}/sublime-text/sublime_text ${DIR_IN_PATH}/sublime
  # Create desktop launcher entry for sublime text
  echo -e "${sublime_launcher}" > ${PERSONAL_LAUNCHERS_DIR}/sublime-text.desktop
  chmod 775 ${PERSONAL_LAUNCHERS_DIR}/sublime-text.desktop
  # Copy launcher to the desktop
  cp -p ${PERSONAL_LAUNCHERS_DIR}/sublime-text.desktop ${XDG_DESKTOP_DIR}

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
  # Avoid error due to possible previous aborted installations
  rm -f ${USR_BIN_FOLDER}/linux*
  rm -Rf ${USR_BIN_FOLDER}/Telegram
  # Download telegram
  wget -P ${USR_BIN_FOLDER} https://telegram.org/dl/desktop/linux
  # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
  (cd "${USR_BIN_FOLDER}"; tar xJf -) < ${USR_BIN_FOLDER}/linux
  # Clean
  rm -f ${USR_BIN_FOLDER}/linux*
  # Rename folder for coherence
  mv ${USR_BIN_FOLDER}/Telegram ${USR_BIN_FOLDER}/telegram
  # Download icon for telegram
  wget -P ${USR_BIN_FOLDER}/telegram https://www.iconfinder.com/icons/986956/download/png/512
  mv ${USR_BIN_FOLDER}/telegram/512 ${USR_BIN_FOLDER}/telegram/telegram.png
  # Create link to the PATH
  rm -f ${DIR_IN_PATH}/telegram
  ln -s ${USR_BIN_FOLDER}/telegram/Telegram ${DIR_IN_PATH}/telegram
  # Create desktop launcher entry for telegram
  echo -e "${telegram_launcher}" > ${PERSONAL_LAUNCHERS_DIR}/telegram.desktop
  chmod 775 ${PERSONAL_LAUNCHERS_DIR}/telegram.desktop
  # Copy launcher to the desktop
  cp -p ${PERSONAL_LAUNCHERS_DIR}/telegram.desktop ${XDG_DESKTOP_DIR}
}


# Microsoft Visual Studio Code
install_visualstudiocode()
{
  # Avoid error due to possible previous aborted installations
  rm -Rf ${USR_BIN_FOLDER}/VSCode-linux-x64*
  rm -Rf ${USR_BIN_FOLDER}/visual-studio-code
  rm -Rf visualstudiocode.tar.gz
  # Download
  (cd "${USR_BIN_FOLDER}"; wget -O "visualstudiocode.tar.gz" "${visualstudiocode_downloader}")
  # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
  (cd "${USR_BIN_FOLDER}"; tar xzf -) < ${USR_BIN_FOLDER}/visualstudiocode.tar.gz
  # Clean
  rm -f ${USR_BIN_FOLDER}/visualstudiocode.tar.gz*
  # Rename folder for coherence
  mv ${USR_BIN_FOLDER}/VSCode-linux-x64 ${USR_BIN_FOLDER}/visual-studio-code
  # Create link to the PATH
  rm -f ${DIR_IN_PATH}/code
  ln -s ${USR_BIN_FOLDER}/visual-studio-code/code ${DIR_IN_PATH}/code
  # Create desktop launcher entry
  echo -e "${visualstudiocode_launcher}" > ${PERSONAL_LAUNCHERS_DIR}/visual-studio-code.desktop
  chmod 775 ${PERSONAL_LAUNCHERS_DIR}/visual-studio-code.desktop
  # Copy launcher to the desktop
  cp -p ${PERSONAL_LAUNCHERS_DIR}/visual-studio-code.desktop ${XDG_DESKTOP_DIR}
}


############################
###### ROOT FUNCTIONS ######
############################

install_audacity()
{
  apt install -y audacity
  copy_launcher audacity.desktop
}


install_atom()
{
    (cd "${USR_BIN_FOLDER}"; wget ${atom_downloader} -O atom.deb; dpkg -i atom.deb; rm -f atom.deb*;)
    copy_launcher atom.desktop
}


install_caffeine()
{
  apt install -y caffeine
  copy_launcher "caffeine-indicator.desktop"
}


install_calibre()
{
  apt install -y calibre
  copy_launcher calibre-gui.desktop
}


install_cheat()
{
  # there's a curl dependency to use cht.sh
  apt-get install -y curl

  rm -f ${USR_BIN_FOLDER}/cht.sh
  rm -f ${USR_BIN_FOLDER}/:cht.sh
  wget -P ${USR_BIN_FOLDER} https://cht.sh/:cht.sh
  mv ${USR_BIN_FOLDER}/:cht.sh ${USR_BIN_FOLDER}/cht.sh
  chmod +x ${USR_BIN_FOLDER}/cht.sh
  chgrp ${SUDO_USER} ${USR_BIN_FOLDER}/cht.sh
  chown ${SUDO_USER} ${USR_BIN_FOLDER}/cht.sh

  rm -f /home/${SUDO_USER}/.local/bin/cheat
  ln -s ${USR_BIN_FOLDER}/cht.sh /home/${SUDO_USER}/.local/bin/cheat
  chmod +x /home/${SUDO_USER}/.local/bin/cheat
  chgrp ${SUDO_USER} /home/${SUDO_USER}/.local/bin/cheat
  chown ${SUDO_USER} /home/${SUDO_USER}/.local/bin/cheat
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


#Install CloneZilla
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


# Dropbox desktop client and integration
install_dropbox()
{
  # Dependency
  apt-get -y install python3-gpg

  rm -f dropbox_${dropbox_version}_amd64.deb*
  wget -O ${dropbox_version}.deb "https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb"
  dpkg -i ${dropbox_version}.deb
  rm -f ${dropbox_version}.deb*

  copy_launcher dropbox.desktop
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
  echo -e "${firc_launcher}" > ${XDG_DESKTOP_DIR}/f-irc.desktop
  chmod 775 ${XDG_DESKTOP_DIR}/f-irc.desktop
}


install_freecad()
{
  apt install -y freecad
  copy_launcher "freecad.desktop"
}


install_games()
{
  apt-get install -y pacman
  copy_launcher "pacman.desktop"
  apt-get install -y gnome-mines
  copy_launcher "org.gnome.Mines.desktop"
  apt-get install -y aisleriot
  copy_launcher "sol.desktop"
  apt-get install -y gnome-mahjongg
  copy_launcher "org.gnome.Mahjongg.desktop"
  apt-get install -y gnome-sudoku
  copy_launcher "org.gnome.Sudoku.desktop"
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
install_GNU_parallel()
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
install_google_chrome()
{
  # Chrome dependencies
  apt-get install -y -qq libxss1 libappindicator1 libindicator7
  # Delete possible collisions with previous installation
  rm -f google-chrome*.deb*
  # Download
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

  # Install downloaded version
  apt install -y -qq ./google-chrome-stable_current_amd64.deb
  # Clean
  rm -f google-chrome*.deb*

  # Create launcher and change its permissions (we are root)
  copy_launcher "google-chrome.desktop"
  #cp /home/${SUDO_USER}/.local/share/applications/chrome* ${XDG_DESKTOP_DIR}
  #chmod 775 ${XDG_DESKTOP_DIR}/chrome*
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
  echo "Attempting to install inkscape"
  apt install -y inkscape
  copy_launcher "inkscape.desktop"
}


install_jdk11()
{
  apt -y install default-jdk
}


# Install latex
# Needs root permission
install_latex()
{
    apt-get install -y perl-tk
    apt -y install texlive-latex-extra texmaker
    copy_launcher "texmaker.desktop"
    copy_launcher "texdoctk.desktop"
    echo "Icon=/usr/share/icons/Yaru/256x256/mimetypes/text-x-tex.png" >> ${XDG_DESKTOP_DIR}/texdoctk.desktop
}


# Automatic install of megasync + megasync nautilus. creates launcher in the desktop 
install_megasync()
{
  apt-get install -y libc-ares2 libmediainfo0v5 libqt5x11extras5 libzen0v5

  rm -f ${megasync_version}.deb*
  wget -O ${megasync_version}.deb "${megasync_repository}${megasync_version}"

  rm -f ${megasync_integrator_version}.deb*
  wget -O ${megasync_integrator_version}.deb "${megasync_repository}${megasync_integrator_version}"

  dpkg -i ${megasync_version}.deb
  dpkg -i ${megasync_integrator_version}.deb

  rm -f ${megasync_integrator_version}.deb*
  rm -f ${megasync_version}.deb*

  copy_launcher megasync.desktop
}


# Mendeley Dependencies
install_mendeley_dependencies()
{
  # Mendeley dependencies
  apt-get -y install gconf2 qt5-default qt5-doc qt5-doc-html qtbase5-examples qml-module-qtwebengine
}


# Automatic install + Creates desktop launcher in launcher and in desktop. 
install_musicmanager()
{
  # Delete possible collisions with previous installation
  rm -f google-musicmanager*.deb*
  # Download
  wget https://dl.google.com/linux/direct/google-musicmanager-beta_current_amd64.deb

  # Install downloaded version
  apt install -y -qq ./google-musicmanager-beta_current_amd64.deb
  # Clean
  rm -f google-musicmanager*.deb*

  # Create launcher and change its permissions (we are root)
  copy_launcher "google-musicmanager.desktop"
}


install_nemo()
{
  apt purge -y nautilus gnome-shell-extension-desktop-icons
  apt -y install nemo
  apt -y install dconf-editor gnome-tweak-tool
  echo -e "${nemo_desktop_launcher}" > /etc/xdg/autostart/nemo-autostart.desktop
  #for nautilus_command in "${nautilus_conf[@]}"; do
   # if [[ ! -z "$(more /home/${SUDO_USER}/.profile | grep -Fo "${nautilus_command}" )" ]]; then
    #  sed "s:${nautilus_command}::g" -i /home/${SUDO_USER}/.profile
    #fi
  #done
  for nemo_command in "${nemo_conf[@]}"; do
    #if [[ -z "$(more /home/${SUDO_USER}/.profile | grep -Fo "${nemo_command}" )" ]]; then
     # echo "${nemo_command}" >> /home/${SUDO_USER}/.profile
      $nemo_command
    #fi
  done
  copy_launcher "nemo.desktop"
}


install_notepadqq()
{
  apt install -y notepadqq
  copy_launcher notepadqq.desktop
}


install_openoffice()
{
  apt remove -y libreoffice-base-core libreoffice-impress libreoffice-calc libreoffice-math libreoffice-common libreoffice-ogltrans libreoffice-core libreoffice-pdfimport libreoffice-draw libreoffice-style-breeze libreoffice-gnome libreoffice-style-colibre libreoffice-gtk3 libreoffice-style-elementary libreoffice-help-common libreoffice-style-tango libreoffice-help-en-us libreoffice-writer
  apt autoremove -y
  rm -f office.tar.gz*
  wget -O "office.tar.gz" "${openoffice_downloader}"
  rm -Rf en-US
  tar -xvf "office.tar.gz"
  rm -f office.tar.gz*
  cd en-US/DEBS/
  dpkg -i *.deb
  cd desktop-integration/
  dpkg -i *.deb
  cd ../../..
  rm -Rf en-US

  copy_launcher "openoffice4-base.desktop"
  copy_launcher "openoffice4-calc.desktop"
  copy_launcher "openoffice4-draw.desktop"
  copy_launcher "openoffice4-math.desktop"
  copy_launcher "openoffice4-writer.desktop"
}


install_obs-studio()
{
  apt install -y ffmpeg
  apt install -y obs-studio
  echo -e "${obs_desktop_launcher}" > ${XDG_DESKTOP_DIR}/obs-studio.desktop
  chmod 775 ${XDG_DESKTOP_DIR}/obs-studio.desktop
}


install_okular()
{
  apt-get -y install okular
}


# Install pdf grep
install_pdfgrep()
{
  apt-get -y install pdfgrep
}


install_pluma()
{
  apt install -y pluma
  copy_launcher "pluma.desktop"

}
# Needs roots permission
install_pypy3_dependencies()
{
  # pypy3 module dependencies
  apt-get install -y -qq pkg-config
  apt-get install -y -qq libfreetype6-dev
  apt-get install -y -qq libpng-dev
  apt-get install -y -qq libffi-dev
}


# Install Python3
# Needs root permission
install_python3()
{
  apt install -y python3-dev python-dev python3-pip
}


install_shotcut()
{
  apt install -y shotcut
  echo -e "${shotcut_desktop_launcher}" > ${XDG_DESKTOP_DIR}/shotcut.desktop
  chmod 775 ${XDG_DESKTOP_DIR}/shotcut.desktop
}


# steam ubuntu client
install_steam()
{
  apt-get install curl
  # Avoid collision from possible previous interrumped installations
  rm -f steam.deb*
  # Download steam
  wget -O steam.deb https://steamcdn-a.akamaihd.net/client/installer/steam.deb
  # Install
  dpkg -i steam.deb
  # Clean after
  rm -f steam.deb*
  copy_launcher "steam.desktop"
}


install_terminator()
{
  apt-get -y install terminator
  copy_launcher terminator.desktop
}


install_thunderbird()
{
  apt-get install -y thunderbird
  copy_launcher "thunderbird.desktop"
}


install_tilix()
{
  apt-get install -y tilix
  copy_launcher tilix.desktop
}


install_tmux()
{
  apt-get -y install tmux
  echo -e "${tmux_launcher}" > ${XDG_DESKTOP_DIR}/tmux.desktop
  chmod 775 ${XDG_DESKTOP_DIR}/tmux.desktop
  cp -p ${XDG_DESKTOP_DIR}/tmux.desktop /home/${SUDO_USER}/.local/share/applications
}


install_transmission()
{
  apt-get install -y transmission
  copy_launcher "transmission-gtk.desktop"
  rm -f /home/${SUDO_USER}/.local/bin/transmission
  ln -s $(which transmission-gtk) /home/${SUDO_USER}/.local/bin/transmission
  chgrp ${SUDO_USER} /home/${SUDO_USER}/.local/bin/transmission
  chown ${SUDO_USER} /home/${SUDO_USER}/.local/bin/transmission
}


install_uget()
{
  #Does not install proper //RF
  apt install -y uget aria2
  copy_launcher "uget.desktop"
}

# install VLC
install_vlc()
{
  apt-get -y install vlc
}


# VirtualBox
install_virtualbox()
{
  rm -f virtualbox*.deb*
  wget -O virtualbox.deb ${virtualbox_downloader}
  dpkg -i virtualbox.deb
  rm -f virtualbox*.deb*
  copy_launcher "virtualbox.desktop"
}

#############################
###### SYSTEM FEATURES ######
#############################
# Most (all) of them just use user permissions

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
install_ls_alias()
{
  #lsdisplay=$(ls -lhA | tr -s " ")
  #dudisplay=$(du -shxc .[!.]* * | sort -h | tr -s "\t" " ")
  #IFS=$'\n'
  #for linels in ${lsdisplay}; do
  #  if [[ $linels =~ ^d.* ]]; then
  #    foldername=$(echo $linels | cut -d " " -f9)
  #    for linedu in ${dudisplay}; do
  #      if [[ "$(echo ${linedu} | cut -d " " -f2)" = ${foldername} ]]; then
  #        # Replace $lsdisplay with values in folder size 
  #        break
  #      fi
  #    done
  #  fi
  #done

  echo ""


  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "alias l=" )" ]]; then
    echo "alias l=\"ls -lAh --color=auto\"" >> ${BASHRC_PATH}
  else
    sed -i 's/^alias l=.*/alias l=\"ls -lAh \"/' ${BASHRC_PATH}
  fi

  #alias a="echo '---------------Alias----------------';alias"
  #alias c="clear"
  #alias h="history | grep $1"
  #du -shxc .[!.]* * | sort -h
}

# Defines a function to extract all types of compressed files
install_extract_function()
{
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "extract () {" )" ]]; then
    echo -e "$extract_function" >> ${BASHRC_PATH}
  else
  	err "WARNING: Extract function is already installed. Skipping"
  fi
}

# Increases file history size, size of the history and forces to append to history, never overwrite
# Ignore repeated commands and simple commands
# Store multiline comments in just one command
install_shell_history_optimization()
{
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "HISTSIZE=" )" ]]; then
    echo "export HISTSIZE=10000" >> ${BASHRC_PATH}
    
  else
    sed -i 's/HISTSIZE=.*/HISTSIZE=10000/' ${BASHRC_PATH}
  fi

  # Increase File history size
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "HISTFILESIZE=" )" ]]; then
    echo "export HISTFILESIZE=100000" >> ${BASHRC_PATH}
  else
    sed -i 's/HISTFILESIZE=.*/HISTFILESIZE=100000/' ${BASHRC_PATH}
  fi

  # Append and not overwrite history
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "shopt -s histappend" )" ]]; then
    echo "shopt -s histappend" >> ${BASHRC_PATH}
  fi

  # Ignore repeated commands
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "HISTCONTROL=" )" ]]; then
    echo "HISTCONTROL=ignoredups" >> ${BASHRC_PATH}
  else
    sed -i 's/HISTCONTROL=.*/HISTCONTROL=ignoredups/' ${BASHRC_PATH}
  fi

  # Ignore simple commands
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "HISTIGNORE=" )" ]]; then
    echo "HISTIGNORE=\"ls:ps:history:l:pwd:top:gitk\"" >> ${BASHRC_PATH}
  else
    sed -i 's/HISTIGNORE=.*/HISTIGNORE=\"ls:ps:history:l:pwd:top:gitk\"/' ${BASHRC_PATH}
  fi

  # store multiline commands in just one command
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "shopt -s cmdhist" )" ]]; then
    echo "shopt -s cmdhist" >> ${BASHRC_PATH}
  fi
}

install_git_aliases()
{
  # Force "gitk" as alias for gitk --all --date-order
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "alias gitk=" )" ]]; then
    echo "alias gitk=\"gitk --all --date-order \"" >> ${BASHRC_PATH}
  else
    sed -Ei 's/^alias gitk=.*/alias gitk=\"gitk --all --date-order \"/' ${BASHRC_PATH}
  fi

  # Create alias for dummycommit
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "alias dummycommit=" )" ]]; then
    echo "alias dummycommit=\"git add -A; git commit -am \"changes\"; git push \"" >> ${BASHRC_PATH}
  else
    sed -Ei 's/^alias dummycommit=.*/alias dummycommit=\"git add -A; git commit -am \"changes\"; git push \"/' ${BASHRC_PATH}
  fi
}

install_environment_aliases()
{

  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "export DESK=" )" ]]; then
    echo "export DESK=${XDG_DESKTOP_DIR}" >> ${BASHRC_PATH}
  else
    err "WARNING: DESK environment alias is already installed. Skipping"
  fi
  
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "export PS1=" )" ]]; then
    echo "export PS1=\"${PS1_custom}\"" >> ${BASHRC_PATH}
  else
    err "WARNING: PS1 environment alias is already installed. Skipping"
  fi
  echo $(dconf list /org/gnome/terminal/legacy/profiles:/)
  dconf write /org/gnome/terminal/legacy/profiles:/$(dconf list /org/gnome/terminal/legacy/profiles:/)background-color "'rgb(0,0,0)'"
  
  # Install git bash prompt
  if [[ "$(whoami)" != "root" ]]; then
    if [[ -d "${USR_BIN_FOLDER}/.bash-git-prompt" ]]; then
      rm -Rf ${USR_BIN_FOLDER}/.bash-git-prompt
      git clone https://github.com/magicmonty/bash-git-prompt.git ${USR_BIN_FOLDER}/.bash-git-prompt --depth=1
    else
      git clone https://github.com/magicmonty/bash-git-prompt.git ${USR_BIN_FOLDER}/.bash-git-prompt --depth=1
      echo "${bash_git_prompt_bashrc}" >> ${BASHRC_PATH}
    fi
  else
    err "WARNING: Could not install bash prompt you should be normal user. Skipping"
  fi
}

add_root_programs()
{
  for program in ${installation_data[@]}; do
    permissions=$(echo ${program} | cut -d ";" -f4)
    if [[ ${permissions} != 0 ]]; then
      name=$(echo ${program} | cut -d ";" -f5)
      add_program ${name}
    fi
  done
}

add_user_programs()
{
  for program in ${installation_data[@]}; do
    permissions=$(echo ${program} | cut -d ";" -f4)
    if [[ ${permissions} != 1 ]]; then
      name=$(echo ${program} | cut -d ";" -f5)
      add_program ${name}
    fi
  done
}

add_all_programs()
{
  for program in ${installation_data[@]}; do
    name=$(echo ${program} | cut -d ";" -f5)
    add_program $name
  done
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
      program_name=$( echo ${program_function} | cut -d "_" -f2- )
      program_privileges=$( echo ${program} | cut -d ";" -f5 )
      if [[ ${program_privileges} == 1 ]]; then
        if [[ ${EUID} -ne 0 ]]; then
          output_proxy_executioner "echo WARNING: $program_name needs root permissions to be installed. Skipping." ${quietness_bit}
        else
          if [[ ${overwrite_bit} == 1 ]]; then
            execute_installation_install_feature ${forceness_bit} ${quietness_bit} ${program_function}
          else
            which ${program_name} >/dev/null
            if [[ $? != 0 ]]; then
              execute_installation_install_feature ${forceness_bit} ${quietness_bit} ${program_function}
            else
              output_proxy_executioner "echo WARNING: ${program_name} is already installed. Skipping" ${quietness_bit}
            fi
          fi
        fi
      elif [[ ${program_privileges} == 0 ]]; then
        if [[ ${EUID} -ne 0 ]]; then
          if [[ ${overwrite_bit} == 1 ]]; then
            execute_installation_install_feature ${forceness_bit} ${quietness_bit} ${program_function}
          else
            which ${program_name}
            if [[ $? != 0 ]]; then
              execute_installation_install_feature ${forceness_bit} ${quietness_bit} ${program_function}
            else
              output_proxy_executioner "echo WARNING: ${program_name} is already installed." ${quietness_bit}
            fi
          fi
        else
          output_proxy_executioner "echo WARNING: $program_name needs user permissions to be installed. Skipping." ${quietness_bit}
        fi
      fi
    fi
  done
}

add_program()
{
  while [[ $# -gt 0 ]]; do
    FLAG_ANY_INSTALLED=1  # Tells if there is any installed feature in order to determine if implicit to --all should be called
    total=${#installation_data[*]}
    for (( i=0; i<$(( ${total} )); i++ )); do
      program_name=$(echo "${installation_data[$i]}" | rev | cut -d ";" -f1 | rev )

      if [[ "$1" == "${program_name}" ]]; then
        # Add bit of installation yes/no
        rest=$(echo "${installation_data[$i]}" | cut -d ";" -f5- )
        new="${FLAG_INSTALL};${FLAG_FORCENESS};${FLAG_QUIETNESS};${FLAG_OVERWRITE};${rest}"
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
    # Make sure USR_BIN_FOLDER is present
    mkdir -p ${USR_BIN_FOLDER}
    # Convert USR_BIN_FOLDER to a SUDO_ROOT user
    chgrp ${SUDO_USER} ${USR_BIN_FOLDER}
    chown ${SUDO_USER} ${USR_BIN_FOLDER}
    chmod 775 ${USR_BIN_FOLDER}

    # Make sure that DIR_IN_PATH is present
    mkdir -p ${DIR_IN_PATH}
    # Convert DIR_IN_PATH to a SUDO_ROOT user
    chgrp ${SUDO_USER} ${DIR_IN_PATH}
    chown ${SUDO_USER} ${DIR_IN_PATH}
    chmod 775 ${DIR_IN_PATH}

    # Make sure that folder for user launchers is present
    mkdir -p ${PERSONAL_LAUNCHERS_DIR}
    # Convert PERSONAL_LAUNCHERS_DIR to a SUDO_ROOT user
    chgrp ${SUDO_USER} ${PERSONAL_LAUNCHERS_DIR}
    chown ${SUDO_USER} ${PERSONAL_LAUNCHERS_DIR}
    chmod 775 ${PERSONAL_LAUNCHERS_DIR}


  else
    # Make sure USR_BIN_FOLDER is present
    mkdir -p ${USR_BIN_FOLDER}

    # Make sure that ${DIR_IN_PATH} is present
    mkdir -p ${DIR_IN_PATH}

    # Make sure that folder for user launchers is present
    mkdir -p ${PERSONAL_LAUNCHERS_DIR}

    # Make sure that PATH is pointing to ${DIR_IN_PATH} (where we will put our soft links to the software)
    #//RF
    if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "${DIR_IN_PATH}" )" ]]; then
      echo "export PATH=$PATH:${DIR_IN_PATH}" >> ${BASHRC_PATH}
    fi

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

      -f|--force)
        FLAG_FORCENESS=1
      ;;
      -e|--exit|--exit-on-error)
        FLAG_FORCENESS=0
      ;;

      -d|--dirty)
        AUTOCLEAN=0
      ;;
      -c|--clean)
        AUTOCLEAN=1
      ;;
      -C|--Clean)
        AUTOCLEAN=2
      ;;

      -o|--overwrite)
        FLAG_OVERWRITE=1
      ;;
      -s|--skip)
        FLAG_OVERWRITE=0
      ;;

      -n|--not|-!)
        FLAG_INSTALL=0
      ;;
      -y|--yes)
        FLAG_INSTALL=1
      ;;

      -h|--help)
        echo -e ${help_text}
        exit 0
      ;;


      ### INDIVIDUAL ARGUMENTS ###
      # Sorted alphabetically by function name:
      --android|--AndroidStudio|--androidstudio|--studio|--android-studio|--android_studio|--Androidstudio)
        add_program install_android_studio
      ;;
      --audacity|--Audacity)
        add_program install_audacity
      ;;
      --atom|--Atom)
        add_program install_atom
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
      --copyq|--copy-q|--copy_q|--copqQ|--Copyq|--copy-Q)
        add_program install_copyq
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
      --parallel|--gnu_parallel|--GNUparallel|--GNUParallel|--gnu-parallel)
        add_program install_GNU_parallel
      ;;
      --chrome|--Chrome|--google-chrome|--Google-Chrome)
        add_program install_google_chrome
      ;;
      --inkscape|--ink-scape|--Inkscape|--InkScape)
        add_program install_inkscape
      ;;
      --intellijcommunity|--intelliJCommunity|--intelliJ-Community|--intellij-community|--ideac)
        add_program install_intellij_community
      ;;
      --intellijultimate|--intelliJUltimate|--intelliJ-Ultimate|--intellij-ultimate|--ideau)
        add_program install_intellij_ultimate
      ;;
      --java|--javadevelopmentkit|--java-development-kit|--java-development-kit-11|--java-development-kit11|--jdk|--JDK|--jdk11|--JDK11|--javadevelopmentkit-11)
        add_program install_jdk11
      ;;
      --latex|--LaTeX|--tex|--TeX)
        add_program install_latex
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
      --pycharmcommunity|--pycharmCommunity|--pycharm_community|--pycharm|--pycharm-community)
        add_program install_pycharm_community
      ;;
      --pycharmpro|--pycharmPro|--pycharm_pro|--pycharm-pro|--Pycharm-Pro|--PyCharm-pro)
        add_program install_pycharm_professional
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
      --shell|--shellCustomization|--shellOptimization|--environment|--environmentaliases|--environment_aliases|--environmentAliases|--alias|--Aliases)  # Considered "shell" in order
        add_program install_shell_history_optimization
        add_program install_ls_alias
        add_program install_git_aliases
        add_program install_environment_aliases
        add_program install_extract_function
      ;;
      --shotcut|--ShotCut|--Shotcut|--shot-cut|--shot_cut)
        add_program install_shotcut
      ;;
      --sublime|--sublimeText|--sublime_text|--Sublime|--sublime-Text|--sublime-text)
        add_program install_sublime_text
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
        add_program install_visualstudiocode
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
    add_all_programs
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

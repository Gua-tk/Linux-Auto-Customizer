#!/usr/bin/env bash
# A simple portable shell script to initialize and customize a Linux working environment. Needs root permission for some features.
# Author: Aleix Mariné (aleix.marine@estudiants.urv.cat)
# Created on 28/5/19
# Last Update 19/4/2020register_file_associations

################################
###### AUXILIAR FUNCTIONS ######
################################

# Associate a file type (mime type) to a certaina application.
# Argument 1: File types. Example: application/x-shellscript
# Argument 2: Application. Example: sublime_text.desktop
register_file_associations()
{
if [[ -f ${HOME}/.config/mimeapps.list ]]; then
  # Check if the association is already existent
  if [[ -z "$(more ~/.config/mimeapps.list | grep -Eo "$1=.*$2" )" ]]; then
    if [[ -z "$(more ~/.config/mimeapps.list | grep -Fo "$1=" )" ]]; then
      # File type is not registered so we can add the hole line
      sed -i "/\[Added Associations\]/a $1=$2;" ~/.config/mimeapps.list
    else
      # File type is already registered. We need to register another application for it
      if [[ -z "$(more ~/.config/mimeapps.list | grep -Eo "$1=.*;$" )" ]]; then
        # File type is registered without comma. Add the program at the end of the line with comma
        sed -i "s|$1=.*$|&;$2;|g" ~/.config/mimeapps.list
      else
        # File type is registered with comma at the end. Just add program at end of line
        sed -i "s|$1=.*;$|&$2;|g" ~/.config/mimeapps.list
      fi
    fi
  else
    err "WARNING: File association between $1 and $2 is already done"
  fi
else
  err "WARNING: File association between $1 and $2 can not be done because ~/.config/mimeaps.list does not exist."
fi
}

# Creates a valid launcher for the normal user in the desktop using an
# already created launcher from an automatic install (using apt or dpkg).
# This function does not need to have root permissions for its instructions,
# but is expected to be call as root since it uses the variable $SUDO_USER 
# Argument 1: name of the desktop launcher in /usr/share/applications
copy_launcher()
{
  if [[ -f /usr/share/applications/$1 ]]; then
    cp /usr/share/applications/$1 ${XDG_DESKTOP_DIR}
    chmod 775 ${XDG_DESKTOP_DIR}/$1
    chgrp ${SUDO_USER} ${XDG_DESKTOP_DIR}/$1
    chown ${SUDO_USER} ${XDG_DESKTOP_DIR}/$1
  fi
}

#############################################
###### SOFTWARE INSTALLATION FUNCTIONS ######
#############################################


install_android_studio()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "WARNING: Could not install Android Studio. You should be normal user. Skipping..."
  else
    echo "Attempting to install Android Studio"
    if [[ -z "$(which studio)" ]]; then
      # avoid collisions
      rm -f ${USR_BIN_FOLDER}/${android_studio_version}.tar.gz*
      # Download
      wget -P ${USR_BIN_FOLDER} https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.1.2.0/${android_studio_version}.tar.gz
      
      # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
      (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/${android_studio_version}.tar.gz
      # Clean
      rm -f ${USR_BIN_FOLDER}/${android_studio_version}.tar.gz*
      
      # Create links to the PATH
      rm -f ${HOME}/.local/bin/studio
      ln -s ${USR_BIN_FOLDER}/android-studio/bin/studio.sh ${HOME}/.local/bin/studio
      
      # Create launcher
      echo -e "${android_studio_launcher}" > "${HOME}/.local/share/applications/Android Studio.desktop"
      chmod 775 "${HOME}/.local/share/applications/Android Studio.desktop"
      cp -p "${HOME}/.local/share/applications/Android Studio.desktop" ${XDG_DESKTOP_DIR}
    else
      err "WARNING: Android Studio is already installed. Skipping"
    fi
    echo "Finished"
  fi
}

install_clion()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "WARNING: Could not install clion. You should be normal user. Skipping..."
  else
    echo "Attempting to install $clion_version"

    if [[ -z $(which clion) ]]; then
      # Avoid error due to possible previous aborted installations
      rm -f ${USR_BIN_FOLDER}/${clion_version}.tar.gz*
      rm -Rf ${USR_BIN_FOLDER}/${clion_version}
      # Download CLion
      wget -P ${USR_BIN_FOLDER} https://download.jetbrains.com/cpp/${clion_version}.tar.gz
      # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
      (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/${clion_version}.tar.gz
      # Clean
      rm -f ${USR_BIN_FOLDER}/${clion_version}.tar.gz*
      # Modify folder name for coherence
      mv ${USR_BIN_FOLDER}/clion* ${USR_BIN_FOLDER}/clion
      # Create links to the PATH
      rm -f ${HOME}/.local/bin/clion
      ln -s ${USR_BIN_FOLDER}/clion/bin/clion.sh ${HOME}/.local/bin/clion
      # Create launcher for clion in the desktop and in the launcher menu
      echo -e "$clion_launcher" > ${HOME}/.local/share/applications/clion.desktop
      chmod 775 ${HOME}/.local/share/applications/clion.desktop
      cp -p ${HOME}/.local/share/applications/clion.desktop ${XDG_DESKTOP_DIR}

      # register file associations
      register_file_associations "text/x-c++hdr" "clion.desktop"
      register_file_associations "text/x-c++src" "clion.desktop"
      register_file_associations "text/x-chdr" "clion.desktop"
      register_file_associations "text/x-csrc" "clion.desktop"
    
    else
      err "WARNING: CLion is already installed. Skipping"
    fi
  fi
}


install_converters()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "ERROR: you need to be user"
  else
    echo "Attempting to install converters"
    rm -Rf ${USR_BIN_FOLDER}/converters
    git clone ${converters_downloader} ${USR_BIN_FOLDER}/converters
    
    rm -f ${HOME}/.local/bin/dectohex
    rm -f ${HOME}/.local/bin/hextodec
    rm -f ${HOME}/.local/bin/bintodec
    rm -f ${HOME}/.local/bin/dectobin
    rm -f ${HOME}/.local/bin/dectoutf
    rm -f ${HOME}/.local/bin/dectooct
    rm -f ${HOME}/.local/bin/utftodec
    ln -s ${USR_BIN_FOLDER}/converters/dectohex.py ${HOME}/.local/bin/dectohex
    ln -s ${USR_BIN_FOLDER}/converters/hextodec.py ${HOME}/.local/bin/hextodec
    ln -s ${USR_BIN_FOLDER}/converters/bintodec.py ${HOME}/.local/bin/bintodec
    ln -s ${USR_BIN_FOLDER}/converters/dectobin.py ${HOME}/.local/bin/dectobin
    ln -s ${USR_BIN_FOLDER}/converters/dectoutf.py ${HOME}/.local/bin/dectoutf
    ln -s ${USR_BIN_FOLDER}/converters/dectooct.py ${HOME}/.local/bin/dectooct
    ln -s ${USR_BIN_FOLDER}/converters/utftodec.py ${HOME}/.local/bin/utftodec
    
    # //RF
    if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "${converters_bashrc_call}" )" ]]; then
      echo -e "$converters_bashrc_call" >> ${BASHRC_PATH}
    else
  	err "WARNING: converters functions are already installed. Skipping"
    fi
    echo "${converters_links}" > ${HOME}/.bash_functions
    echo "converters installed"
  fi

}

# discord desktop client
install_discord()
{
  if [[ "$(whoami)" != "root" ]]; then
    echo "Attempting to install discord"
    if [[ -z $(which discord) ]]; then
      rm -f ${USR_BIN_FOLDER}/discord.tar.gz*
      (cd "${USR_BIN_FOLDER}"; wget -O discord.tar.gz "https://discord.com/api/download?platform=linux&format=tar.gz")
      rm -Rf "${USR_BIN_FOLDER}/discord"
      (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/discord.tar.gz
      rm -f ${USR_BIN_FOLDER}/discord*.tar.gz*
      mv ${USR_BIN_FOLDER}/Discord ${USR_BIN_FOLDER}/discord
      # Create links in the PATH
      rm -f ${HOME}/.local/bin/discord
      ln -s ${USR_BIN_FOLDER}/discord/Discord ${HOME}/.local/bin/discord
      # Create launchers in launcher and in desktop
      echo -e "${discord_launcher}" > ${XDG_DESKTOP_DIR}/discord.desktop
      chmod 755 ${XDG_DESKTOP_DIR}/discord.desktop
      cp -p ${XDG_DESKTOP_DIR}/discord.desktop ${HOME}/.local/share/applications
    else
      err "WARNING: discord is already installed. Skipping"
    fi
    echo "Finished"
  else
    echo "WARNING: Could not install discord. You should be normal user. Skipping..."
  fi
}


# Install IntelliJ Community
install_intellij_community()
{
  if [[ "$(whoami)" != "root" ]]; then
    echo "Attempting to install ${intellij_community_version}"
    if [[ -z $(which ideac) ]]; then
      # Avoid error due to possible previous aborted installations
      rm -f ${USR_BIN_FOLDER}/${intellij_community_version}.tar.gz*
      rm -Rf ${USR_BIN_FOLDER}/idea-IC
      # Download intellij community
      wget -P ${USR_BIN_FOLDER} https://download.jetbrains.com/idea/${intellij_community_version}.tar.gz
      # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
      (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/${intellij_community_version}.tar.gz
      # Clean
      rm -f ${USR_BIN_FOLDER}/${intellij_community_version}.tar.gz*
      # Modify name for coherence
      mv ${USR_BIN_FOLDER}/idea-IC* ${USR_BIN_FOLDER}/idea-IC
      # Create link to the PATH
      rm -f ${HOME}/.local/bin/ideac
      ln -s ${USR_BIN_FOLDER}/idea-IC/bin/idea.sh ${HOME}/.local/bin/ideac
      # Create desktop launcher entry for intelliJ community
      echo -e "${intellij_community_launcher}" > ${HOME}/.local/share/applications/ideac.desktop
      chmod 775 ${HOME}/.local/share/applications/ideac.desktop
      # Copy launcher to the desktop
      cp -p ${HOME}/.local/share/applications/ideac.desktop ${XDG_DESKTOP_DIR}

      # register file associations
      register_file_associations "text/x-java" "ideac.desktop"
    else
      err "WARNING: intelliJ is already installed. Skipping"
    fi

    echo "Finished" 
  else
    echo "WARNING: Could not install intelliJ Community. You should be normal user. Skipping..."
  fi
}


# Install IntelliJ Ultimate
install_intellij_ultimate()
{
  if [[ "$(whoami)" != "root" ]]; then
    echo "Attempting to install ${intellij_ultimate_version}"
    if [[ -z $(which ideau) ]]; then
      # Avoid error due to possible previous aborted installations
      rm -f ${USR_BIN_FOLDER}/${intellij_ultimate_version}.tar.gz*
      rm -Rf ${USR_BIN_FOLDER}/idea-IU
      # Download intellij ultimate
      wget -P ${USR_BIN_FOLDER} https://download.jetbrains.com/idea/${intellij_ultimate_version}.tar.gz
      # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
      (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/${intellij_ultimate_version}.tar.gz
      # Clean
      rm -f ${USR_BIN_FOLDER}/${intellij_ultimate_version}.tar.gz*
      # Modify name for coherence
      mv ${USR_BIN_FOLDER}/idea-IU* ${USR_BIN_FOLDER}/idea-IU
      # Create link to the PATH
      rm -f ${HOME}/.local/bin/ideau
      ln -s ${USR_BIN_FOLDER}/idea-IU/bin/idea.sh ${HOME}/.local/bin/ideau
      # Create desktop launcher entry for intellij ultimate
      echo -e "${intellij_ultimate_launcher}" > ${HOME}/.local/share/applications/ideau.desktop
      chmod 775 ${HOME}/.local/share/applications/ideau.desktop
      # Copy launcher to the desktop
      cp -p ${HOME}/.local/share/applications/ideau.desktop ${XDG_DESKTOP_DIR}
      # register file associations
      register_file_associations "text/x-java" "ideau.desktop"
    else
      err "WARNING: intelliJ is already installed. Skipping"
    fi

    echo "Finished"
  else
    echo "WARNING: Could not install intelliJ Ultimate. You should be normal user. Skipping..."
  fi
}


# Manual install, creating launcher in the launcher and in desktop. Modifies .desktop file provided by the software
install_mendeley()
{
  if [[ "$(whoami)" != "root" ]]; then
    echo "Attempting to install Mendeley"
    if [[ -z $(which mendeley) ]]; then

      # Avoid error due to possible previous aborted installations
      rm -f ${USR_BIN_FOLDER}/stable-incoming*
      rm -Rf ${USR_BIN_FOLDER}/mendeley*
      # Download mendeley
      wget -P ${USR_BIN_FOLDER} https://www.mendeley.com/autoupdates/installer/Linux-x64/stable-incoming
      # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
      (cd "${USR_BIN_FOLDER}"; tar -xjf -) < ${USR_BIN_FOLDER}/stable-incoming
      rm -f ${USR_BIN_FOLDER}/stable-incoming
      # Rename folder for coherence
      mv ${USR_BIN_FOLDER}/mendeley* ${USR_BIN_FOLDER}/mendeley
      # Create link to the PATH
      rm -f ${HOME}/.local/bin/mendeley
      ln -s ${USR_BIN_FOLDER}/mendeley/bin/mendeleydesktop ${HOME}/${SUDO_USER}/.local/bin/mendeley
      # Create Desktop launcher
      cp ${USR_BIN_FOLDER}/mendeley/share/applications/mendeleydesktop.desktop ${XDG_DESKTOP_DIR}
      chmod 775 ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
      # Modify Icon line
      sed -i s-Icon=.*-Icon=${HOME}/.bin/mendeley/share/icons/hicolor/128x128/apps/mendeleydesktop.png- ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
      # Modify exec line
      sed -i 's-Exec=.*-Exec=mendeley %f-' ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
      # Copy to desktop  launchers of the current user
      cp -p ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop ${HOME}/.local/share/applications
    else
      err "WARNING: Mendeley is already installed. Skipping"
    fi
  else
    echo "WARNING: Could not install Mendeley. You should be normal user. Skipping..."
  fi
  echo "Finished"
}


# Installs pycharm, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharm_community()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "WARNING: Could not install pycharm community. You should be normal user. Skipping..."
  else
    echo "Attempting to install pycharm community"
    if [[ -z $(which pycharm) ]]; then
      # Avoid error due to possible previous aborted installations
      rm -f ${USR_BIN_FOLDER}/${pycharm_version}.tar.gz*
      rm -Rf ${USR_BIN_FOLDER}/${pycharm_version}
      # Download pycharm
      wget -P ${USR_BIN_FOLDER} https://download.jetbrains.com/python/${pycharm_version}.tar.gz
      # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
      (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/${pycharm_version}.tar.gz
      # Clean
      rm -f ${USR_BIN_FOLDER}/${pycharm_version}.tar.gz*
      # Rename folder for coherence
      mv ${USR_BIN_FOLDER}/pycharm-community* ${USR_BIN_FOLDER}/pycharm-community
      # Create links to the PATH
      rm -f ${HOME}/.local/bin/pycharm
      ln -s ${USR_BIN_FOLDER}/pycharm-community/bin/pycharm.sh ${HOME}/.local/bin/pycharm

      # Create launcher for pycharm in the desktop and in the launcher menu
      echo -e "$pycharm_launcher" > ${HOME}/.local/share/applications/pycharm.desktop
      chmod 775 ${HOME}/.local/share/applications/pycharm.desktop
      cp -p ${HOME}/.local/share/applications/pycharm.desktop ${XDG_DESKTOP_DIR}

      # register file associations
      register_file_associations "text/x-python" "pycharm.desktop"
      register_file_associations "text/x-python3" "pycharm.desktop"
      register_file_associations "text/x-sh" "pycharm.desktop"

    else
      err "WARNING: pycharm is already installed. Skipping"
    fi
    echo "Finished"
  fi
}


# Installs pycharm professional, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharm_professional()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "WARNING: Could not install pycharm pro. You should be normal user. Skipping..."
  else
    echo "Attempting to install pycharm pro"
    if [[ -z $(which pycharm-pro) ]]; then
      # Avoid error due to possible previous aborted installations
      rm -f ${USR_BIN_FOLDER}/${pycharm_professional_version}.tar.gz*
      rm -Rf ${USR_BIN_FOLDER}/${pycharm_professional_version}
      # Download pycharm
      wget -P ${USR_BIN_FOLDER} https://download.jetbrains.com/python/${pycharm_professional_version}.tar.gz
      # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
      (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/${pycharm_professional_version}.tar.gz
      # Clean
      rm -f ${USR_BIN_FOLDER}/${pycharm_professional_version}.tar.gz*
      # Rename folder for coherence
      mv ${USR_BIN_FOLDER}/pycharm-[0-9]* ${USR_BIN_FOLDER}/pycharm-pro
      # Create links to the PATH
      rm -f ${HOME}/.local/bin/pycharm-pro
      ln -s ${USR_BIN_FOLDER}/pycharm-pro/bin/pycharm.sh ${HOME}/.local/bin/pycharm-pro
      # Create launcher for pycharm in the desktop and in the launcher menu
      echo -e "$pycharm_professional_launcher" > ${HOME}/.local/share/applications/pycharm-pro.desktop
      chmod 775 ${HOME}/.local/share/applications/pycharm-pro.desktop
      cp -p ${HOME}/.local/share/applications/pycharm-pro.desktop ${XDG_DESKTOP_DIR}

      # register file associations
      register_file_associations "text/x-sh" "pycharm-pro.desktop"
      register_file_associations "text/x-python" "pycharm-pro.desktop"
      register_file_associations "text/x-python3" "pycharm-pro.desktop"
    else
      err "WARNING: pycharm-pro is already installed. Skipping"
    fi
    echo "Finished"
  fi
}


# Installs pypy3 dependencies, pypy3 and basic modules (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
# Links it to the path
install_pypy3()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "WARNING: Could not install pypy3. You should be normal user. Skipping..."
  else
    echo "Attempting to install pypy3"
    if [[ -z $(which pypy3) ]]; then
      # Avoid error due to possible previous aborted installations
      rm -f ${USR_BIN_FOLDER}/${pypy3_version}.tar.bz2*
      rm -Rf ${USR_BIN_FOLDER}/${pypy3_version}
      rm -Rf ${USR_BIN_FOLDER}/pypy3
      # Download pypy
      wget -P ${USR_BIN_FOLDER} https://downloads.python.org/pypy/${pypy3_version}.tar.bz2
      # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
      (cd "${USR_BIN_FOLDER}"; tar -xjf -) < ${USR_BIN_FOLDER}/${pypy3_version}.tar.bz2
      # Clean
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
      rm -f ${HOME}/.local/bin/pypy3
      ln -s ${USR_BIN_FOLDER}/pypy3/bin/pypy3 ${HOME}/.local/bin/pypy3
      rm -f ${HOME}/.local/bin/pypy3-pip
      ln -s ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 ${HOME}/.local/bin/pypy3-pip

    else
      err "WARNING: pypy3 is already installed. Skipping"
    fi
    echo "Finished"
  fi
}


# Install Sublime text 3
install_sublime_text()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "WARNING: Could not install sublime text. You should be normal user. Skipping..."
  else
    echo "Attempting to install sublime text"
      if [[ -z $(which sublime) ]]; then
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
      rm -f ${HOME}/.local/bin/sublime
      ln -s ${USR_BIN_FOLDER}/sublime-text/sublime_text ${HOME}/.local/bin/sublime
      # Create desktop launcher entry for sublime text
      echo -e "${sublime_launcher}" > ${HOME}/.local/share/applications/sublime-text.desktop
      chmod 775 ${HOME}/.local/share/applications/sublime-text.desktop
      # Copy launcher to the desktop
      cp -p ${HOME}/.local/share/applications/sublime-text.desktop ${XDG_DESKTOP_DIR}

      # register file associations
      register_file_associations "text/x-sh" "sublime-text.desktop"
      register_file_associations "text/x-c++hdr" "sublime-text.desktop"
      register_file_associations "text/x-c++src" "sublime-text.desktop"
      register_file_associations "text/x-chdr" "sublime-text.desktop"
      register_file_associations "text/x-csrc" "sublime-text.desktop"
      register_file_associations "text/x-python" "sublime-text.desktop"
      register_file_associations "text/x-python3" "sublime-text.desktop"
    else
      err "WARNING: sublime text is already installed. Skipping"
    fi
    echo "Finished"
  fi
}


# Telegram installation
install_telegram()
{
  if [[ "$(whoami)" != "root" ]]; then
    echo "Attempting to install telegram"
    if [[ -z $(which telegram) ]]; then
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
      rm -f ${HOME}/.local/bin/telegram
      ln -s ${USR_BIN_FOLDER}/telegram/Telegram ${HOME}/.local/bin/telegram
      # Create desktop launcher entry for telegram
      echo -e "${telegram_launcher}" > ${HOME}/.local/share/applications/telegram.desktop
      chmod 775 ${HOME}/.local/share/applications/telegram.desktop
      # Copy launcher to the desktop
      cp -p ${HOME}/.local/share/applications/telegram.desktop ${XDG_DESKTOP_DIR}
    else
      err "WARNING: Telegram is already installed. Skipping"
    fi
    echo "Finished"
  else
    echo "WARNING: Could not install telegram. You should be normal user. Skipping..."
  fi
}


# Microsoft Visual Studio Code
install_visualstudiocode()
{
  if [[ "$(whoami)" != "root" ]]; then
    echo "Attempting to install Visual Studio Code"
    if [[ -z $(which code) ]]; then
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
      rm -f ${HOME}/.local/bin/code
      ln -s ${USR_BIN_FOLDER}/visual-studio-code/code ${HOME}/.local/bin/code
      # Create desktop launcher entry 
      echo -e "${visualstudiocode_launcher}" > ${HOME}/.local/share/applications/visual-studio-code.desktop
      chmod 775 ${HOME}/.local/share/applications/visual-studio-code.desktop
      # Copy launcher to the desktop
      cp -p ${HOME}/.local/share/applications/visual-studio-code.desktop ${XDG_DESKTOP_DIR}
    else
      err "WARNING: Visual Studio Code is already installed. Skipping"
    fi
    echo "Finished"
  else
    echo "WARNING: Could not install Visual Studio Code. You should be normal user. Skipping..."
  fi
}


############################
###### ROOT FUNCTIONS ######
############################

install_audacity()
{
  if [[ "$(whoami)" != "root" ]]; then
    echo "WARNING: Could not install audacity. You should be root. Skipping..."
  else
    echo "Attempting to install audacity"
    apt install -y audacity
    copy_launcher "audacity.desktop"
  fi
}


install_cheat()
{
  if [[ "$(whoami)" != "root" ]]; then
    echo "WARNING: Could not install cheat.sh. You should be root. Skipping..."
  else
    echo "Attempting to install cheat.sh"
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
  fi
}


#Install CloneZilla
install_clonezilla()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install clonezilla"
    apt-get install -y clonezilla
    echo -e "${clonezilla_launcher}" > ${XDG_DESKTOP_DIR}/clonezilla.desktop
    chmod 775 ${XDG_DESKTOP_DIR}/clonezilla.desktop
    chgrp ${SUDO_USER} ${XDG_DESKTOP_DIR}/clonezilla.desktop
    chown ${SUDO_USER} ${XDG_DESKTOP_DIR}/clonezilla.desktop
    cp ${XDG_DESKTOP_DIR}/clonezilla.desktop /home/${SUDO_USER}/.local/share/applications
    echo "Finished"
  else
    echo "WARNING: Could not install clonezilla. You need root permissions. Skipping..."
  fi
}


install_cmatrix()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install cmatrix"
    apt-get install -y cmatrix
    echo -e "${cmatrix_launcher}" > ${XDG_DESKTOP_DIR}/cmatrix.desktop
    chmod 775 ${XDG_DESKTOP_DIR}/cmatrix.desktop
    echo "Finished"
  else
    echo "WARNING: Could not install cmatrix. You need root permissions. Skipping..."
  fi
}


# Dropbox desktop client and integration
install_dropbox()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attemptying to install dropbox"
    if [[ -z $(which dropbox) ]]; then
      # Dependency
      apt-get -y install python3-gpg
      
      rm -f dropbox_${dropbox_version}_amd64.deb*

      wget -O ${dropbox_version}.deb "https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb"

      dpkg -i ${dropbox_version}.deb

      rm -f ${dropbox_version}.deb*

      copy_launcher dropbox.desktop
    else
      err "WARNING: dropbox is already installed. Skipping"
    fi
    echo "Finished"
  else
    echo "WARNING: Could not install dropbox. You should be root."
  fi
}


install_firefox()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install firefox"
    apt-get install -y firefox
    copy_launcher "firefox.desktop"
    echo "Finished"
  else
    echo "WARNING: Could not install firefox. You need root permissions. Skipping..."
  fi
}


install_f-irc()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install f-irc"
    apt-get install -y f-irc
    echo "Finished"
  else
    echo "WARNING: Could not install f-irc. You need root permissions. Skipping..."
  fi
}


install_games()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install games"

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

    echo "Finished"
  else
    echo "WARNING: Could not install games. You need root permissions. Skipping..."
  fi
}


# Install gcc (C compiler)
# Needs root permission
install_gcc()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install gcc"
    apt install -y gcc
    echo "Finished"
  else
    echo "WARNING: Could not install gcc. You need root permissions. Skipping..."
  fi
}


# Install GIMP
install_gimp()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install gimp"
    apt install -y gimp
    copy_launcher "gimp.desktop"
    echo "Finished"
  else
    echo "WARNING: Could not install gimp. You need root permissions. Skipping..."
  fi
}


# Install GIT and all its related utilities (gitk e.g.)
# Needs root permission
install_git()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install GIT"
    apt install -y git-all
    apt-get install -y git-lfs
    echo "Finished"
  else
    echo "WARNING: Could not install git. You need root permissions. Skipping..."
  fi
}


# Install GNU parallel
install_GNU_parallel()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install GNU-parallel"
    apt-get -y install parallel
    echo "Finished"
  else
    echo "WARNING: Could not install GNU parallel. You need root permissions. Skipping..."
  fi
}


# Install gparted
install_gparted()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install gparted"
    apt install -y gparted
    copy_launcher "gparted.desktop"
    echo "Finished"
  else
    echo "WARNING: Could not install gparted. You need root permissions. Skipping..."
  fi
}


# Checks if Google Chrome is already installed and installs it and its dependencies
# Needs root permission
install_google_chrome()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install Google Chrome"
    # Chrome dependencies
    apt-get install -y -qq libxss1 libappindicator1 libindicator7

    if [[ -z "$(which google-chrome)" ]]; then
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

    else
      err "WARNING: Google Chrome is already installed. Skipping"
    fi
    echo "Finished"
  else
    echo "WARNING: Could not install google chrome. You need root permissions. Skipping..."
  fi
}

install_gvim()
{
  if [[ "$(whoami)" == "root" ]]; then
    apt -y install vim-gtk3
    copy_launcher "gvim.desktop"
  else
    echo "WARNING: Could not install gvim. You should be root."
  fi

}


install_jdk11()
{
  if [[ "$(whoami)" == "root" ]]; then
    apt -y install default-jdk
  else
    echo "WARNING: Could not install java development kit 11. You should be root."
  fi
}


# Install latex
# Needs root permission
install_latex()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install latex"
    apt-get install -y perl-tk
    apt -y install texlive-latex-extra texmaker
    copy_launcher "texmaker.desktop"
    copy_launcher "texdoctk.desktop"
    echo "Icon=/usr/share/icons/Yaru/256x256/mimetypes/text-x-tex.png" >> ${XDG_DESKTOP_DIR}/texdoctk.desktop
    echo "Finished"
  else
    echo "WARNING: Could not install latex. You need root permissions. Skipping..."
  fi
}


# Automatic install of megasync + megasync nautilus. creates launcher in the desktop 
install_megasync()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attemptying to install megasync"
    if [[ -z $(which megasync) ]]; then
      # Dependencies
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
    else
      err "WARNING: megasync is already installed. Skipping"
    fi
    echo "Finished"
  else
    echo "WARNING: Could not install megasync. You should be root user. Skipping..."
  fi
}


# Mendeley Dependencies
install_mendeley_dependencies()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install mendeley dependencies"
    # Mendeley dependencies
    apt-get -y install gconf2 qt5-default qt5-doc qt5-doc-html qtbase5-examples qml-module-qtwebengine
    echo "Finished"
  else
    echo "WARNING: Could not install dependencies. You need root permissions. Skipping..."
  fi
}


# Automatic install + Creates desktop launcher in launcher and in desktop. 
install_musicmanager()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install Google music manager"
    if [[ -z "$(which google-musicmanager)" ]]; then
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

    else
      err "WARNING: Google Music Manager is already installed. Skipping"
    fi
    echo "Finished"
  else
    echo "WARNING: Could not install Google Music Manager. You need root permissions. Skipping..."
  fi
}


install_nemo()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install nemo"
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
    echo "WARNING: If Nemo has been installed,restart Ubuntu"
    echo "Finished"
  else
    echo "WARNING: Could not install nemo You should be root. Skipping..."
  fi
}


install_openoffice()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install openoffice"
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
    
    echo "Finished"
  else
    echo "WARNING: Could not install openoffice. You should be root. Skipping..."
  fi
  
}

install_obs-studio()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install obs-studio"
    # There's a dependency
    apt install -y ffmpeg
    apt install -y obs-studio
    echo -e "${obs_desktop_launcher}" > ${XDG_DESKTOP_DIR}/obs-studio.desktop
    chmod 775 ${XDG_DESKTOP_DIR}/obs-studio.desktop
    cp -p ${XDG_DESKTOP_DIR}/obs-studio.desktop /home/${SUDO_USER}/.local/share/applications
    echo "Finished"
  else
    echo "WARNING: Could not install obs-studio. You should be root. Skipping..."
  fi
}


# Install pdf grep
install_pdfgrep()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install pdfgrep"
    apt-get -y install pdfgrep
    echo "Finished"
  else
    echo "WARNING: Could not install pdfgrep. You should be root. Skipping..."
  fi
}


# Needs roots permission
install_pypy3_dependencies()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install pypy3 dependencies"
    # pypy3 module dependencies
    apt-get install -y -qq pkg-config
    apt-get install -y -qq libfreetype6-dev
    apt-get install -y -qq libpng-dev
    apt-get install -y -qq libffi-dev
    echo "Finished"
  else
    echo "WARNING: Could not install dependencies. You need root permissions. Skipping..."
  fi
}


# Install Python3
# Needs root permission
install_python3()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install python3"
    apt install -y python3-dev python-dev python3-pip
    echo "Finished"
  else
    echo "WARNING: Could not install python. You need root permissions. Skipping..."
  fi
}


# steam ubuntu client
install_steam()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install steam"
    # steam dependencies
    apt-get install curl

    if [[ -z $(which steam) ]]; then
      # Avoid collision from possible previous interrumped installations
      rm -f steam.deb*
      # Download steam
      wget -O steam.deb https://steamcdn-a.akamaihd.net/client/installer/steam.deb
      # Install
      dpkg -i steam.deb
      # Clean after
      rm -f steam.deb*
      copy_launcher "steam.desktop"
    else
      err "WARNING: steam is already installed. Skipping"
    fi
    echo "Finished"
  else
    echo "WARNING: Could not install steam. You should be root. Skipping..."
  fi
}


install_thunderbird()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attemptying to install thunderbird"
    apt-get install -y thunderbird 
    echo -e "${tmux_launcher}" > ${XDG_DESKTOP_DIR}/tmux.desktop
    echo "Finished"
  else
    echo "WARNING: Could not install thunderbird. You should be root user. Skipping..."
  fi
}


install_tmux()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install tmux"
    apt-get -y install tmux
    echo -e "${tmux_launcher}" > ${XDG_DESKTOP_DIR}/tmux.desktop
    chmod 775 ${XDG_DESKTOP_DIR}/tmux.desktop
    cp -p ${XDG_DESKTOP_DIR}/tmux.desktop /home/${SUDO_USER}/.local/share/applications
    echo "Finished"
  else
    echo "WARNING: Could not install tmux. You should be root. Skipping..."
  fi
}

install_transmission()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attemptying to install transmission"
    apt-get install -y transmission 
    copy_launcher "transmission-gtk.desktop"
    rm -f /home/${SUDO_USER}/.local/bin/transmission
    ln -s $(which transmission-gtk) /home/${SUDO_USER}/.local/bin/transmission
    chgrp ${SUDO_USER} /home/${SUDO_USER}/.local/bin/transmission
    chown ${SUDO_USER} /home/${SUDO_USER}/.local/bin/transmission
    echo "Finished"
  else
    echo "WARNING: Could not install transmission. You should be root user. Skipping..."
  fi
}


# install VLC
install_vlc()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install vlc"
    apt-get -y install vlc
    echo "Finished"
  else
    echo "WARNING: Could not install vlc. You should be root. Skipping..."
  fi
}


# VirtualBox
install_virtualbox()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "Attempting to install virtualbox"
    if [[ -z "$(which virtualbox)" ]]; then
      # Delete possible collisions with previous installation
      rm -f virtualbox*.deb*  
      # Download
      wget -O virtualbox.deb ${virtualbox_downloader}
      # Install
      dpkg -i virtualbox.deb
      # Clean
      rm -f virtualbox*.deb*
      # Create launcher and change its permissions (we are root)
      copy_launcher "virtualbox.desktop"
    else
      err "WARNING: Virtualbox is already installed. Skipping"
    fi
    echo "Finished"
  else
    echo "WARNING: Could not install virtualbox. You need root permissions. Skipping..."
  fi
}

#############################
###### SYSTEM FEATURES ######
#############################
# Most (all) of them just use user permissions

# Install templates (available files in the right click --> new --> ...)
# Python3, bash shell scripts, latex documents
install_templates()
{
  if [[ "$(whoami)" == "root" ]]; then
    echo "WARNING: Could not install templates. You should be normal user. Skipping..."
  else
    echo "Attemptying to install templates"
    echo "#!/usr/bin/env bash" > ${XDG_TEMPLATES_DIR}/shell_script.sh
    echo "#!/usr/bin/env python3" > ${XDG_TEMPLATES_DIR}/python3_script.py
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2345678901234567890123456789012345678901234567890123456789012345678901234567890
%        1         2         3         4         5         6         7         8
" > ${XDG_TEMPLATES_DIR}/latex_document.tex
    echo "CC = gcc
CFLAGS = -O3 -Wall

all : c_script

c_script : c_script.c
	\$(CC) \$(CFLAGS) c_script.c -o c_script -lm

run : c_script
	./c_script

.PHONY : clean
clean :
	rm -f c_script" > ${XDG_TEMPLATES_DIR}/makefile
    echo "#include \"c_script.h\"
  int main(int nargs, char* args[])
{
  printf(\"Hello World\");
}

" > ${XDG_TEMPLATES_DIR}/c_script.c
    echo "// Includes
#include <stdio.h>
#include <stdbool.h>  // To use booleans
#include <stdlib.h>
" > ${XDG_TEMPLATES_DIR}/c_script.h
    
  > ${XDG_TEMPLATES_DIR}/text_file.txt
    chmod 775 ${XDG_TEMPLATES_DIR}/*
    echo "Finished"
  fi
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

root_install()
{
  install_audacity
  install_cheat
  install_cmatrix
  install_clonezilla
  install_converters
  install_dropbox
  install_firefox
  install_f-irc
  #install_games
  install_gcc
  install_gimp
  install_git
  install_GNU_parallel
  install_gparted
  install_google_chrome
  install_gvim
  install_jdk11
  install_latex
  install_megasync
  install_mendeley_dependencies
  install_musicmanager
  install_nemo
  install_openoffice
  install_obs-studio
  install_pdfgrep
  install_python3
  install_pypy3_dependencies
  install_steam
  install_thunderbird
  install_tmux
  install_transmission
  install_vlc
  install_virtualbox
}

user_install()
{
  install_android_studio
  install_clion
  install_discord
  install_environment_aliases 
  install_extract_function 
  install_git_aliases
  install_intellij_community
  install_intellij_ultimate
  install_ls_alias
  install_mendeley
  install_pycharm_community
  install_pycharm_professional
  install_pypy3
  install_shell_history_optimization
  install_sublime_text
  install_telegram
  install_templates
  install_visualstudiocode
}

###### AUXILIAR FUNCTIONS ######

# Prints the given arguments to the stderr
err()
{
  echo "$*" >&2
}

##################
###### MAIN ######
##################
main()
{
  if [[ "$(whoami)" == "root" ]]; then
    # Update repositories and system before doing anything
    apt -y update
    apt -y upgrade

    # Do a safe copy
    cp -p ${BASHRC_PATH} ${BASHRC_PATH}.bak
  else
    # Create folder for user software
    mkdir -p ${HOME}/.bin

    # Make sure that ${HOME}/.local/bin is present
    mkdir -p ${HOME}/.local/bin

    # Make sure that folder for user launchers is present
    mkdir -p ${HOME}/.local/share/applications

    # Make sure that PATH is pointing to ${HOME}/.local/bin (where we will put our soft links to the software)
    if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "${HOME}/.local/bin" )" ]]; then
      echo "export PATH=$PATH:${HOME}/.local/bin" >> ${BASHRC_PATH}
    fi

  fi

  ###### ARGUMENT PROCESSING ######

  # If we don't receive arguments we try to install everything that we can given our permissions
  if [[ -z "$@" ]]; then
    if [[ "$(whoami)" == "root" ]]; then
      root_install
    else
      user_install
    fi
  else
    while [[ $# -gt 0 ]]; do
      key="$1"

      case ${key} in
      
        ### INDIVIDUAL ARGUMENTS ###
        # Sorted alphabetically by function name:
        -a|--android|--AndroidStudio|--androidstudio|--studio|--android-studio|--android_studio|--Androidstudio)
          install_android_studio
        ;;
        --audacity|--Audacity)
          install_audacity
        ;;
        --cheat|--cheat.sh|--Cheat.sh|--che)
          install_cheat
        ;;
        -n|--clion|--Clion|--CLion)
          install_clion
        ;;
        --cmatrix|--Cmatrix)
          install_cmatrix
        ;;
        --converters|--Converters)
          install_converters
        ;;
        -i|--discord|--Discord|--disc)
          install_discord
        ;;
        -b|--dropbox|--Dropbox|--DropBox|--Drop-box|--drop-box|--Drop-Box)
          install_dropbox
        ;;
        -c|--gcc)
          install_gcc
        ;;
        --clonezilla|--CloneZilla|--cloneZilla)
          install_clonezilla
        ;;
        -g|--git)
          install_git
        ;;
        --GIMP|--gimp|--Gimp)
          install_gimp
        ;;
        --GParted|--gparted|--GPARTED|--Gparted)
          install_gparted
        ;;
        --gvim|--vim-gtk3|--Gvim|--GVim)
          install_gvim
        ;;
        -l|--parallel|--gnu_parallel|--GNUparallel|--GNUParallel|--gnu-parallel)
          install_GNU_parallel
        ;;
        -o|--chrome|--Chrome|--google-chrome|--Google-Chrome)
          install_google_chrome
        ;;
        -j|--intellijcommunity|--intelliJCommunity|--intelliJ-Community|--intellij-community|--ideac)
          install_intellij_community
        ;;
        -u|--intellijultimate|--intelliJUltimate|--intelliJ-Ultimate|--intellij-ultimate|--ideau)
          install_intellij_ultimate
        ;;
        -k|--java|--javadevelopmentkit|--java-development-kit|--java-development-kit-11|--java-development-kit11|--jdk|--JDK|--jdk11|--JDK11)
          install_jdk11
        ;;
        -x|--latex|--LaTeX|--tex|--TeX)
          install_latex
        ;;
        --mega|--Mega|--MEGA|--MegaSync|--MEGAsync|--MEGA-sync|--megasync)
          install_megasync
        ;;
        --Mendeley|--mendeley|--mendeleyDesktop|--mendeley-desktop|--Mendeley-Desktop)
          install_mendeley
        ;;
        --MendeleyDependencies|--mendeleydependencies|--mendeleydesktopdependencies|--mendeley-desktop-dependencies|--Mendeley-Desktop-Dependencies)
          install_mendeley_dependencies
        ;;
        --nemo|--nemo-desktop|--Nemo-Desktop|--Nemodesktop|--nemodesktop|--Nemo|--Nemodesk|--NemoDesktop)
          install_nemo
        ;;
        --google-play-music|--musicmanager|--music-manager|--MusicManager|--playmusic|--GooglePlayMusic|--play-music|--google-playmusic|--playmusic|--google-music)
          install_musicmanager
        ;;
        -f|--pdfgrep|--findpdf|--pdf)
          install_pdfgrep
        ;;
        --f-irc|--firc|--Firc|--irc)
          install_f-irc
        ;;
        -m|--pycharmcommunity|--pycharmCommunity|--pycharm_community|--pycharm|--pycharm-community)
          install_pycharm_community
        ;;
        -h|--pycharmpro|--pycharmPro|--pycharm_pro|--pycharm-pro|--Pycharm-Pro|--PyCharm-pro)
          install_pycharm_professional
        ;;
        -p|--python|--python3|--Python3|--Python)
          install_python3
        ;;
        --office|--Openoffice|--OpenOffice|--openOfice|--open_office|--Office)
          install_openoffice
        ;;
        --OBS|--obs|--obs-studio|--obs_studio|--obs_Studio|--OBS_studio|--obs-Studio|--OBS_Studio|--OBS-Studio)
          install_obs-studio
        ;;
        -y|--pypy|--pypy3|--PyPy3|--PyPy)
          install_pypy3
        ;;
        -d|--dependencies|--pypy3_dependencies|--pypy3Dependencies|--PyPy3Dependencies|--pypy3dependencies|--pypy3-dependencies)
          install_pypy3_dependencies
        ;;
        -e|--shell|--shellCustomization|--shellOptimization|--environment|--environmentaliases|--environment_aliases|--environmentAliases|--alias|--Aliases)  # Considered "shell" in order
          install_shell_history_optimization
          install_ls_alias
          install_git_aliases
          install_environment_aliases
          install_extract_function
        ;;
        -s|--sublime|--sublimeText|--sublime_text|--Sublime|--sublime-Text|--sublime-text)
          install_sublime_text
        ;;
        -w|--steam|--Steam|--STEAM)
          install_steam
        ;;
        -r|--Telegram|--telegram)
          install_telegram
        ;;
        -t|--templates)
          install_templates
        ;;
        --tmux|--Tmux)
          install_tmux
        ;;
        --thunderbird|--mozillathunderbird|--mozilla-thunderbird|--Thunderbird|--thunder-bird)
          install_thunderbird
        ;;
        --transmission|--transmission-gtk|--Transmission)
          install_transmission
        ;;
        --virtualbox|--virtual-box|--VirtualBox|--virtualBox|--Virtual-Box|--Virtualbox)
          install_virtualbox
        ;;
        --visualstudiocode|--visual-studio-code|--code|--Code|--visualstudio|--visual-studio)
          install_visualstudiocode
        ;;
        -v|--vlc|--VLC|--Vlc)
          install_vlc
        ;;
        --firefox|--Firefox)
          install_firefox
        ;;
        --games|--Gaming|--Games)
          install_games
        ;;
        
        ### WRAPPER ARGUMENTS ###
        -U|--user|--regular|--normal)
          if [[ "$(whoami)" == "root" ]]; then
            echo "WARNING: Could not install user packages being root. You should be normal user."
          else
           user_install
          fi
        ;;
        -R|--root|--superuser|--su)
          if [[ "$(whoami)" == "root" ]]; then
            root_install
          else
            echo "WARNING: Could not install root packages being user. You should be root."
          fi
        ;;
        -A|-|--all)
          if [[ "$(whoami)" == "root" ]]; then
            root_install
          else
            user_install
          fi
        ;;
        *)    # unknown option
          err "$1 is not a recognized command"
        ;;
      esac
      shift
    done
  fi

  # Clean if we have permissions
  if [[ "$(whoami)" == "root" ]]; then
    apt -y autoremove
    apt -y autoclean
  fi

  return 0
}

# Script will exit if any command fails
set -e

# Import file of common variables
# WARNING: That makes that the script has to be executed from the directory containing it
source common_data.sh

# Call main function
main "$@"

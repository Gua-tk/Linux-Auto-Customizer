#!/usr/bin/env bash
# A simple portable shell script to initialize and customize a Linux working environment. Needs root permission for some features.
# Author: Aleix Mariné (aleix.marine@estudiants.urv.cat)
# Created on 28/5/19
# Last Update 19/4/2020register_file_associations

###### AUXILIAR FUNCTIONS ######

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
  cp /usr/share/applications/$1 ${XDG_DESKTOP_DIR}
  chmod 775 ${XDG_DESKTOP_DIR}/$1
  chgrp ${SUDO_USER} ${XDG_DESKTOP_DIR}/$1
  chown ${SUDO_USER} ${XDG_DESKTOP_DIR}/$1
}

###### SOFTWARE INSTALLATION FUNCTIONS ######

# Checks if Android studio is already installed and installs it if not
install_android_studio()
{
  echo "Attempting to install Android Studio"
  if [[ -z "$(which studio)" ]]; then
    # avoid collisions
    rm -f ${USR_BIN_FOLDER}/${android_studio_version}.tar.gz*
    # Download
    wget -P ${USR_BIN_FOLDER} https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.0.0.16/${android_studio_version}.tar.gz
    
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
}


install_clion()
{
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
    # Create links to the PATH
    rm -f ${HOME}/.local/bin/clion
    ln -s ${USR_BIN_FOLDER}/${clion_version_caps_down}/bin/clion.sh ${HOME}/.local/bin/clion
    # Create launcher for pycharm in the desktop and in the launcher menu
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
}


# discord desktop client
install_discord()
{
  echo "Attempting to install discord"
  if [[ -z $(which discord) ]]; then
    rm -f ${USR_BIN_FOLDER}/${discord_version}.tar.gz*
    (cd "${USR_BIN_FOLDER}"; wget -O ${discord_version}.tar.gz "https://discord.com/api/download?platform=linux&format=tar.gz")
    rm -Rf "${USR_BIN_FOLDER}/Discord"
    (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/${discord_version}.tar.gz
    rm -f ${USR_BIN_FOLDER}/discord*.tar.gz*
    rm -f ${HOME}/.local/bin/discord
    ln -s ${USR_BIN_FOLDER}/Discord/Discord ${HOME}/.local/bin/discord
    echo -e "${discord_launcher}" > ${XDG_DESKTOP_DIR}/discord.desktop
    chmod 755 ${XDG_DESKTOP_DIR}/discord.desktop
    cp -p ${XDG_DESKTOP_DIR}/discord.desktop ${HOME}/.local/share/applications
  else
    err "WARNING: discord is already installed. Skipping"
  fi
  echo "Finished"
}


# Installs pycharm, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharm_community()
{
  echo "Attempting to install $pycharm_version"

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
    # Create links to the PATH
    rm -f ${HOME}/.local/bin/pycharm
    ln -s ${USR_BIN_FOLDER}/${pycharm_version}/bin/pycharm.sh ${HOME}/.local/bin/pycharm

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
}


# Installs pycharm professional, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharm_professional()
{
  echo "Attempting to install $pycharm_professional_version"

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
    # Create links to the PATH
    rm -f ${HOME}/.local/bin/pycharm-pro
    ln -s ${USR_BIN_FOLDER}/pycharm-${pycharm_professional_ver}/bin/pycharm.sh ${HOME}/.local/bin/pycharm-pro
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
}


# Installs pypy3 dependencies, pypy3 and basic modules (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
# Links it to the path
install_pypy3()
{
  echo "Attempting to install $pypy3_version"

  if [[ -z $(which pypy3) ]]; then
    # Avoid error due to possible previous aborted installations
    rm -f ${USR_BIN_FOLDER}/${pypy3_version}.tar.gz*
    rm -Rf ${USR_BIN_FOLDER}/${pypy3_version}
  	# Download pypy
    wget -P ${USR_BIN_FOLDER} https://bitbucket.org/pypy/pypy/downloads/${pypy3_version}.tar.bz2
    # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
    (cd "${USR_BIN_FOLDER}"; tar -xjf -) < ${USR_BIN_FOLDER}/${pypy3_version}.tar.bz2
    # Clean
    rm -f ${USR_BIN_FOLDER}/${pypy3_version}.tar.bz2*

    # Install modules using pip
    ${USR_BIN_FOLDER}/${pypy3_version}/bin/pypy3 -m ensurepip  

    # Forces download of pip and of modules
    ${USR_BIN_FOLDER}/${pypy3_version}/bin/pip3.6 --no-cache-dir -q install --upgrade pip
    ${USR_BIN_FOLDER}/${pypy3_version}/bin/pip3.6 --no-cache-dir install cython numpy
    # Currently not supported
    # ${USR_BIN_FOLDER}/${pypy3_version}/bin/pip3.6 --no-cache-dir install matplotlib

    # Create links to the PATH
    rm -f ${HOME}/.local/bin/pypy3
    ln -s ${USR_BIN_FOLDER}/${pypy3_version}/bin/pypy3 ${HOME}/.local/bin/pypy3
    rm -f ${HOME}/.local/bin/pypy3-pip
    ln -s ${USR_BIN_FOLDER}/${pypy3_version}/bin/pip3.6 ${HOME}/.local/bin/pypy3-pip

  else
    err "WARNING: pypy3 is already installed. Skipping"
  fi
  echo "Finished"
}


# Install Sublime text 3
install_sublime_text()
{
  echo "Attempting to install $sublime_text_version"

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
    # Create link to the PATH
    rm -f ${HOME}/.local/bin/sublime
    ln -s ${USR_BIN_FOLDER}/sublime_text_3/sublime_text ${HOME}/.local/bin/sublime
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
}

# Install IntelliJ Ultimate
install_intellij_ultimate()
{
  echo "Attempting to install ${intellij_ultimate_version}"
  if [[ -z $(which ideau) ]]; then
    # Avoid error due to possible previous aborted installations
    rm -f ${USR_BIN_FOLDER}/${intellij_ultimate_version}.tar.gz*
    rm -Rf ${USR_BIN_FOLDER}/${intellij_ultimate_version}
    # Download sublime_text
    wget -P ${USR_BIN_FOLDER} https://download.jetbrains.com/idea/${intellij_ultimate_version}.tar.gz
    # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
    (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/${intellij_ultimate_version}.tar.gz
    # Clean
    rm -f ${USR_BIN_FOLDER}/${intellij_ultimate_version}.tar.gz*
    # Create link to the PATH
    rm -f ${HOME}/.local/bin/ideau
    ln -s ${USR_BIN_FOLDER}/${intellij_ultimate_ver}/bin/idea.sh ${HOME}/.local/bin/ideau
    # Create desktop launcher entry for sublime text
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
}



###### ROOT FUNCTIONS ######

# Checks if Google Chrome is already installed and installs it and its dependencies
# Needs root permission
install_google_chrome()
{
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
    cp /home/${SUDO_USER}/.local/share/applications/chrome* ${XDG_DESKTOP_DIR}
    chmod 775 ${XDG_DESKTOP_DIR}/chrome*
  else
    err "WARNING: Google Chrome is already installed. Skipping"
  fi
}

# steam ubuntu client
install_steam()
{
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
  else
    err "WARNING: steam is already installed. Skipping"
  fi
  echo "Steam Finished installing"
}

# MEGA desktop client
install_megasync()
{
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
}

# Needs roots permission
install_pypy3_dependencies()
{
  # pypy3 module dependencies
  echo "Attempting to install pypy3 dependencies"
  apt-get install -y -qq pkg-config
  apt-get install -y -qq libfreetype6-dev
  apt-get install -y -qq libpng-dev
  apt-get install -y -qq libffi-dev
  echo "Finished"
}

# Install GIT and all its related utilities (gitk e.g.)
# Needs root permission
install_git()
{
  echo "Attemptying to install git"
  apt install -y git-all
  apt-get install -y git-lfs
  echo "Finished"
}

# Install gcc (C compiler)
# Needs root permission
install_gcc()
{
  echo "Attemptying to install gcc"
  apt install -y gcc
  echo "Finished"
}

# Install Python3
# Needs root permission
install_python3()
{
  echo "Attemptying to install python3"
  apt install -y python3-dev python-dev
  echo "Finished"
}

# Install GNU parallel
install_GNU_parallel()
{
  echo "Attemptying to install parallel"
  apt-get -y install parallel
  echo "Finished"
}

# Install pdf grep
install_pdfgrep()
{
  echo "Attemptying to install pdfgrep"
  apt-get -y install pdfgrep
  echo "Finished"
}

# install VLC
install_vlc()
{
  echo "Attemptying to install vlc"
  apt-get -y install vlc
  echo "Finished"
}

# Install latex
# Needs root permission
install_latex()
{
  echo "Attemptying to install latex"
  apt-get install -y perl-tk
  apt -y install texlive-latex-extra
  copy_launcher "texmaker.desktop"
  copy_launcher "texdoctk.desktop"
  echo "Icon=/usr/share/icons/Yaru/256x256/mimetypes/text-x-tex.png" >> ${XDG_DESKTOP_DIR}/texdoctk.desktop
  echo "Finished"
}

install_transmission()
{
  echo "Attemptying to install transmission"
  apt-get install -y transmission 
  copy_launcher "transmission-gtk.desktop"
  echo "Finished"
}

install_thunderbird()
{
  echo "Attemptying to install thunderbird"
  apt-get install -y thunderbird 
  copy_launcher "thunderbird.desktop"
  echo "Finished"
}

###### SYSTEM FEATURES ######

# Install templates (available files in the right click --> new --> ...)
# Python3, bash shell scripts, latex documents
install_templates()
{
  echo "Attemptying to install templates"
  echo "#!/usr/bin/env bash" > ${XDG_TEMPLATES_DIR}/shell_script.sh
  echo "#!/usr/bin/env python3" > ${XDG_TEMPLATES_DIR}/python3_script.py
  echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2345678901234567890123456789012345678901234567890123456789012345678901234567890
%        1         2         3         4         5         6         7         8
" > ${XDG_TEMPLATES_DIR}/latex_document.tex
  echo "CC = gcc
CFLAGS = -O3 -Wall

all : Cscript

Cscript : Cscript.c
  $(CC) $(CFLAGS) Cscript.c -o Cscript.c -lm

run : Cscript
  ./Cscript

.PHONY : clean
clean :
  rm -f Cscript" > ${XDG_TEMPLATES_DIR}/makefile
  echo "#include \"Cscript.h\"
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
}

###### SHELL FEATURES ######

# Forces l as alias for ls -lAh
install_ls_alias()
{
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "alias l=" )" ]]; then
    echo "alias l=\"ls -lAh --color=auto\"" >> ${BASHRC_PATH}
  else
    sed -i 's/^alias l=.*/alias l=\"ls -lAh --color=auto\"/' ${BASHRC_PATH}
  fi
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
}

root_install()
{
  install_google_chrome
  install_gcc
  install_git
  install_latex
  install_python3
  install_GNU_parallel
  install_pdfgrep
  install_vlc
  install_steam
  install_pypy3_dependencies
  install_megasync
  install_thunderbird
  install_transmission
}

user_install()
{
  install_templates
  install_environment_aliases
  install_git_aliases
  install_ls_alias
  install_shell_history_optimization
  install_extract_function
  install_pycharm_professional
  install_pycharm_community
  install_clion
  install_sublime_text
  install_android_studio
  install_intellij_ultimate
  install_discord
  install_pypy3
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
    apt -y -qq update
    apt -y -qq upgrade

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
        -c|--gcc)
          if [[ "$(whoami)" == "root" ]]; then
            echo "Attempting to install gcc"
            install_gcc
            echo "Finished"
          else
            echo "WARNING: Could not install gcc. You need root permissions. Skipping..."
          fi
        ;;
        -o|--chrome|--Chrome|--google-chrome|--Google-Chrome)
          if [[ "$(whoami)" == "root" ]]; then
            echo "Attempting to install Google Chrome"
            install_google_chrome
            echo "Finished"
          else
            echo "WARNING: Could not install google chrome. You need root permissions. Skipping..."
          fi
        ;;
        -g|--git)
          if [[ "$(whoami)" == "root" ]]; then
            echo "Attempting to install GIT"
            install_git
            echo "Finished"
          else
            echo "WARNING: Could not install git. You need root permissions. Skipping..."
          fi
        ;;
        -x|--latex|--LaTeX|--tex|--TeX)
          if [[ "$(whoami)" == "root" ]]; then
            echo "Attempting to install latex"
            install_latex
            echo "Finished"
          else
            echo "WARNING: Could not install latex. You need root permissions. Skipping..."
          fi
        ;;
        -p|--python|--python3|--Python3|--Python)
          if [[ "$(whoami)" == "root" ]]; then
            echo "Attempting to install python3"
            install_python3
            echo "Finished"
          else
            echo "WARNING: Could not install python. You need root permissions. Skipping..."
          fi
        ;;
        -l|--parallel|--gnu_parallel|--GNUparallel|--GNUParallel|--gnu-parallel)
          if [[ "$(whoami)" == "root" ]]; then
            echo "Attempting to install GNU-parallel"
            install_GNU_parallel
            echo "Finished"
          else
            echo "WARNING: Could not install GNU parallel. You need root permissions. Skipping..."
          fi
        ;;
        -d|--dependencies|--pypy3_dependencies|--pypy3Dependencies|--PyPy3Dependencies|--pypy3dependencies|--pypy3-dependencies)
          if [[ "$(whoami)" == "root" ]]; then
            echo "Attempting to install pypy3 dependencies"
            install_pypy3_dependencies
            echo "Finished"
          else
            echo "WARNING: Could not install dependencies. You need root permissions. Skipping..."
          fi
        ;;
        -t|--templates)
          if [[ "$(whoami)" == "root" ]]; then
            echo "WARNING: Could not install templates. You should be normal user. Skipping..."
          else
            echo "Attempting to install templates"
            install_templates
            echo "Finished"
          fi
        ;;
        -e|--shell|--shellCustomization|--shellOptimization|--environment|--environmentaliases|--environment_aliases|--environmentAliases|--alias|--Aliases)
          echo "Attempting to install shell history optimization"
          install_shell_history_optimization
          echo "Finished"
          echo "Attempting to install ls alias"
          install_ls_alias
          echo "Finished"
          echo "Attempting to install git aliases"
          install_git_aliases
          echo "Finished"
          echo "Attempting to install environment aliases"
          install_environment_aliases
          echo "Finished"
          echo "Attempting to install extract function"
          install_extract_function
          echo "Finished"
        ;;
        -h|--pycharmpro|--pycharmPro|--pycharm_pro|--pycharm-pro|--Pycharm-Pro|--PyCharm-pro)
          if [[ "$(whoami)" == "root" ]]; then
            echo "WARNING: Could not install pycharm pro. You should be normal user. Skipping..."
          else
            echo "Attempting to install pycharm pro"
            install_pycharm_professional
            echo "Finished"
          fi
        ;;
        -m|--pycharmcommunity|--pycharmCommunity|--pycharm_community|--pycharm|--pycharm-community)
          if [[ "$(whoami)" == "root" ]]; then
            echo "WARNING: Could not install pycharm community. You should be normal user. Skipping..."
          else
            echo "Attempting to install pycharm community"
            install_pycharm_community
            echo "Finished"
          fi
        ;;
        -n|--clion|--Clion|--CLion)
          if [[ "$(whoami)" == "root" ]]; then
            echo "WARNING: Could not install clion. You should be normal user. Skipping..."
          else
            echo "Attempting to install clion"
            install_clion
            echo "Finished"
          fi
        ;;
        -s|--sublime|--sublimeText|--sublime_text|--Sublime|--sublime-Text|--sublime-text)
          if [[ "$(whoami)" == "root" ]]; then
            echo "WARNING: Could not install pycharm community. You should be normal user. Skipping..."
          else
            echo "Attempting to install sublime text"
            install_sublime_text
            echo "Finished"
          fi
        ;;
        -y|--pypy|--pypy3|--PyPy3|--PyPy)
          if [[ "$(whoami)" == "root" ]]; then
            echo "WARNING: Could not install pycharm community. You should be normal user. Skipping..."
          else
            echo "Attempting to install pypy3"
            install_pypy3
            echo "Finished"
          fi
        ;;
        -a|--android|--AndroidStudio|--androidstudio|--studio|--android-studio|--android_studio|--Androidstudio)
          if [[ "$(whoami)" == "root" ]]; then
            echo "WARNING: Could not install Android Studio. You should be normal user. Skipping..."
          else
            echo "Attempting to install Android Studio"
            install_android_studio
            echo "Finished"
          fi
        ;;
        -f|--pdfgrep|--findpdf|--pdf)
          if [[ "$(whoami)" == "root" ]]; then
            echo "Attempting to install pdfgrep"
            install_pdfgrep
            echo "Finished"
          else
            echo "WARNING: Could not install pdfgrep. You should be root. Skipping..."
          fi
        ;;
        -v|--vlc|--VLC|--Vlc)
          if [[ "$(whoami)" == "root" ]]; then
            echo "Attempting to install vlc"
            install_vlc
            echo "Finished"
          else
            echo "WARNING: Could not install vlc. You should be root. Skipping..."
          fi
        ;;
        -w|--steam|--Steam|--STEAM)
          if [[ "$(whoami)" == "root" ]]; then
            echo "Attempting to install steam"
            install_steam
            echo "Finished"
          else
            echo "WARNING: Could not install steam. You should be root. Skipping..."
          fi
        ;;
        -i|--discord|--Discord|--disc)
          if [[ "$(whoami)" != "root" ]]; then
            echo "Attempting to install discord"
            install_discord
            echo "Finished"
          else
            echo "WARNING: Could not install discord. You should be normal user. Skipping..."
          fi
        ;;
        --mega|--Mega|--MEGA|--MegaSync|--MEGAsync|--MEGA-sync|--megasync)
          if [[ "$(whoami)" == "root" ]]; then
            install_megasync
          else
            echo "WARNING: Could not install megasync. You should be root user. Skipping..."
          fi
        ;;
        --transmission|--transmission-gtk|--Transmission)
          if [[ "$(whoami)" == "root" ]]; then
            install_transmission
          else
            echo "WARNING: Could not install transmission. You should be root user. Skipping..."
          fi
        ;;
        --thunderbird|--mozillathunderbird|--mozilla-thunderbird|--Thunderbird|--thunder-bird)
          if [[ "$(whoami)" == "root" ]]; then
            install_thunderbird
          else
            echo "WARNING: Could not install thunderbird. You should be root user. Skipping..."
          fi
        ;;
        --j|--intellijultimate|--intelliJUltimate|--intelliJ-Ultimate|--intellij-ultimate)
          if [[ "$(whoami)" != "root" ]]; then
            install_intellij_ultimate
          else
            echo "WARNING: Could not install intelliJ. You should be normal user. Skipping..."
          fi
        ;;
        -u|--user|--regular|--normal)
          if [[ "$(whoami)" == "root" ]]; then
            echo "WARNING: Could not install user packages being root. You should be normal user."
          else
           user_install
          fi
        ;;
        -r|--root|--superuser|--su)
          if [[ "$(whoami)" == "root" ]]; then
            rootinstall
          else
            echo "WARNING: Could not install root packages being user. You should be root."
          fi
        ;;
        -|--all)
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
    apt -y -qq autoremove
    apt -y -qq autoclean
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

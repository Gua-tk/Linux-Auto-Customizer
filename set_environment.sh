#!/usr/bin/env bash
# A simple portable shell script to initialize and customize a Linux working environment. Needs root permission for some features.
# Author: Aleix Mariné (aleix.marine@estudiants.urv.cat)
# Created on 28/5/19
# Last Update 19/4/2020

###### SOFTWARE INSTALLATION FUNCTIONS ######

# Checks if Google Chrome is already installed and installs it and its dependencies
# Needs root permission
install_google_chrome()
{
  echo "Attempting to install Google Chrome"	

  # Chrome dependencies
  apt-get install -y -qq libxss1 libappindicator1 libindicator7

  if [[ -z "$(which google-chrome)" ]]; then
  	# Download
    wget -q -P ${USR_BIN_FOLDER} https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    # Install downloaded version
    apt install -y -qq ${USR_BIN_FOLDER}/google-chrome*.deb
    # Clean
    rm ${USR_BIN_FOLDER}/google-chrome*.deb
  else
    err "WARNING: Google Chrome is already installed. Skipping"
  fi

  echo "Finished"
}

# Installs pypy3 dependencies, pypy3 and basic modules (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
# Links it to the path
install_pypy3()
{
  # Targeted version of pypy3
  local -r pypy3_version=pypy3.5-v7.0.0-linux64

  echo "Attempting to install $pypy3_version"

  if [[ -z $(which pypy3) ]]; then
  	# Avoid error due to possible previous aborted installations
    rm -f ${USR_BIN_FOLDER}/${pypy3_version}.tar.gz*
    rm -Rf ${USR_BIN_FOLDER}/${pypy3_version}
  	# Download pypy
    wget -q -P ${USR_BIN_FOLDER} https://bitbucket.org/pypy/pypy/downloads/${pypy3_version}.tar.bz2
    # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
    (cd "${USR_BIN_FOLDER}"; tar -xjf -) <  ${USR_BIN_FOLDER}/${pypy3_version}.tar.bz2
    # Clean
    rm ${USR_BIN_FOLDER}/${pypy3_version}.tar.bz2*

    # Install modules using pip
    ${USR_BIN_FOLDER}/${pypy3_version}/bin/pypy3 -m ensurepip >/dev/null 2>&1  # redirection to hide output

    # Forces download of pip and of modules
    ${USR_BIN_FOLDER}/${pypy3_version}/bin/pip3.5 --no-cache-dir -q install --upgrade pip
    ${USR_BIN_FOLDER}/${pypy3_version}/bin/pip3.5 --no-cache-dir -q install cython numpy matplotlib biopython

    # Create links to the PATH
    rm -f ${HOME}/.local/bin/pypy3
    ln -s ${USR_BIN_FOLDER}/${pypy3_version}/bin/pypy3 ${HOME}/.local/bin/pypy3
    rm -f ${HOME}/.local/bin/pip-pypy3
    ln -s ${USR_BIN_FOLDER}/${pypy3_version}/bin/pip3.5 ${HOME}/.local/bin/pip-pypy3
  else
    err "WARNING: pypy3 is already installed. Skipping"
  fi

  echo "Finished"
}

# Needs roots permission
install_pypy3_dependencies()
{
  echo "Attempting to install pypy3 dependencies"
  # pypy3 module dependencies
  apt-get install -y -qq pkg-config
  apt-get install -y -qq libfreetype6-dev
  apt-get install -y -qq libpng-dev

  echo "Finished"
}

# Installs pycharm, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharm_community()
{
  local -r pycharm_version=pycharm-community-2019.1.1  # Targeted version of pycharm
  echo "Attempting to install $pycharm_version"

  if [[ -z $(which pycharm) ]]; then
    # Avoid error due to possible previous aborted installations
    rm -f ${USR_BIN_FOLDER}/${pycharm_version}.tar.gz*
    rm -Rf ${USR_BIN_FOLDER}/${pycharm_version}
    # Download pycharm
    wget -q -P ${USR_BIN_FOLDER} https://download.jetbrains.com/python/${pycharm_version}.tar.gz
    # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
    (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/${pycharm_version}.tar.gz
    # Clean
    rm -f ${USR_BIN_FOLDER}/${pycharm_version}.tar.gz*
    # Create links to the PATH
    rm -f ${HOME}/.local/bin/pycharm
    ln -s ${USR_BIN_FOLDER}/${pycharm_version}/bin/pycharm.sh ${HOME}/.local/bin/pycharm

    # Create launcher for pycharm in the desktop and in the launcher menu
    pycharm_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm
Icon=$HOME/.bin/$pycharm_version/bin/pycharm.png
Exec=pycharm
Comment=Python IDE for Professional Developers
Terminal=false
StartupWMClass=jetbrains-pycharm"
    echo -e "$pycharm_launcher" > ${HOME}/.local/share/applications/pycharm.desktop
    chmod 775 ${HOME}/.local/share/applications/pycharm.desktop
    cp -p ${HOME}/.local/share/applications/pycharm.desktop ${XDG_DESKTOP_DIR}
  else
  	err "WARNING: pycharm is already installed. Skipping"
  fi

  echo "Finished"
}

# Installs pycharm professional, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharm_professional()
{
  local -r pycharm_version=pycharm-professional-2020.1  # Targeted version of pycharm
  local -r pycharm_ver=$(echo $pycharm_version | cut -d '-' -f3)
  echo "Attempting to install $pycharm_version"

  if [[ -z $(which pycharm-pro) ]]; then
    # Avoid error due to possible previous aborted installations
    rm -f ${USR_BIN_FOLDER}/${pycharm_version}.tar.gz*
    rm -Rf ${USR_BIN_FOLDER}/${pycharm_version}
    # Download pycharm
    wget -q -P ${USR_BIN_FOLDER} https://download.jetbrains.com/python/${pycharm_version}.tar.gz
    # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
    (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/${pycharm_version}.tar.gz
    # Clean
    rm -f ${USR_BIN_FOLDER}/${pycharm_version}.tar.gz*
    # Create links to the PATH
    rm -f ${HOME}/.local/bin/pycharm-pro
    ln -s ${USR_BIN_FOLDER}/pycharm-${pycharm_ver}/bin/pycharm.sh ${HOME}/.local/bin/pycharm-pro
    # Create launcher for pycharm in the desktop and in the launcher menu
    pycharm_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm-pro
Icon=$HOME/.bin/$pycharm_version/bin/pycharm.png
Exec=pycharm-pro
Comment=Python IDE for Professional Developers
Terminal=false
StartupWMClass=jetbrains-pycharm"
    echo -e "$pycharm_launcher" > ${HOME}/.local/share/applications/pycharm-pro.desktop
    chmod 775 ${HOME}/.local/share/applications/pycharm-pro.desktop
    cp -p ${HOME}/.local/share/applications/pycharm-pro.desktop ${XDG_DESKTOP_DIR}
  else
  	err "WARNING: pycharm-pro is already installed. Skipping"
  fi

  echo "Finished"
}

install_clion()
{
  local -r clion_version=CLion-2020.1  # Targeted version of pycharm

  echo "Attempting to install $clion_version"

  if [[ -z $(which clion) ]]; then
    # Avoid error due to possible previous aborted installations
    rm -f ${USR_BIN_FOLDER}/${clion_version}.tar.gz*
    rm -Rf ${USR_BIN_FOLDER}/${clion_version}
    # Download CLion
    wget -q -P ${USR_BIN_FOLDER} https://download.jetbrains.com/cpp/${clion_version}.tar.gz
    # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
    (cd "${USR_BIN_FOLDER}"; tar -xzf -) < ${USR_BIN_FOLDER}/${clion_version}.tar.gz
    # Clean
    rm -f ${USR_BIN_FOLDER}/${clion_version}.tar.gz*
    # Create links to the PATH
    rm -f ${HOME}/.local/bin/clion
    ln -s ${USR_BIN_FOLDER}/${clion_version}/bin/clion.sh ${HOME}/.local/bin/clion
    # Create launcher for pycharm in the desktop and in the launcher menu
    clion_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=CLion
Icon=$HOME/.bin/$clion_version/bin/clion.png
Exec=clion
Comment=C and C++ IDE for Professional Developers
Terminal=false
StartupWMClass=jetbrains-clion"
    echo -e "$clion_launcher" > ${HOME}/.local/share/applications/clion.desktop
    chmod 775 ${HOME}/.local/share/applications/clion.desktop
    cp -p ${HOME}/.local/share/applications/clion.desktop ${XDG_DESKTOP_DIR}
  else
  	err "WARNING: CLion is already installed. Skipping"
  fi

  echo "Finished"
}

# Install GIT and all its related utilities (gitk e.g.)
# Needs root permission
install_git()
{
  echo "Attempting to install GIT"

  apt install -y -qq git-all

  echo "Finished"
}

# Install gcc (C compiler)
# Needs root permission
install_gcc()
{
  echo "Attempting to install gcc"

  apt install -y -qq gcc

  echo "Finished"
}

# Install Python3
# Needs root permission
install_python3()
{
  echo "Attempting to install python3"

  apt install -y -qq python3

  echo "Finished"
}

# Install GNU parallel
install_GNU_parallel()
{
  echo "Attempting to install GNU-parallel"	

  apt-get -y -qq install parallel

  echo "Finished"
}

# Install Sublime text 3
install_sublime_text()
{
  sublime_text_version=sublime_text_3_build_3211_x64  # Targeted version of sublime text

  echo "Attempting to install $sublime_text_version"

  if [[ -z $(which subl) ]]; then
  	# Avoid error due to possible previous aborted installations
    rm -f ${USR_BIN_FOLDER}/${sublime_text_version}.tar.bz2*
    rm -Rf ${USR_BIN_FOLDER}/${sublime_text_version}
  	# Download sublime_text
    wget -q -P ${USR_BIN_FOLDER} https://download.sublimetext.com/${sublime_text_version}.tar.bz2
    # Decompress to $USR_BIN_FOLDER directory in a subshell to avoid cd
    (cd "${USR_BIN_FOLDER}"; tar -xjf -) < ${USR_BIN_FOLDER}/${sublime_text_version}.tar.bz2
    # Clean
    rm -f ${USR_BIN_FOLDER}/${sublime_text_version}.tar.bz2*
    # Create link to the PATH
    rm -f ${HOME}/.local/bin/subl
    ln -s ${USR_BIN_FOLDER}/sublime_text_3/sublime_text ${HOME}/.local/bin/subl
    # Create desktop launcher entry for pycharm launcher
    sublime_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=Sublime Text
GenericName=Text Editor
Icon=$HOME/.bin/sublime_text_3/Icon/256x256/sublime-text.png
Comment=General Purpose Programming Text Editor
Terminal=false
Exec=subl"
    echo -e "$sublime_launcher" > ${HOME}/.local/share/applications/sublime_text.desktop
    chmod 775 ${HOME}/.local/share/applications/sublime_text.desktop
    # Copy launcher to the desktop
    cp -p ${HOME}/.local/share/applications/sublime_text.desktop ${XDG_DESKTOP_DIR}
  else
    err "WARNING: sublime text is already installed. Skipping"
  fi

  echo "Finished"
}

# Install latex
# Needs root permission
install_latex()
{
  echo "Attempting to install latex"

  apt -y -qq install texlive-latex-extra

  echo "Finished"
}

###### SYSTEM FEATURES ######

# Install templates (available files in the right click --> new --> ...)
# Python3, bash shell scripts, latex documents
install_templates()
{
  echo "Attempting to install templates"

  # Add templates
  if [[ -f ${HOME}/.config/user-dirs.dirs ]]; then
    echo "#!/usr/bin/env bash" > ${XDG_TEMPLATES_DIR}/New_Shell_Script.sh
    echo "#!/usr/bin/env python3" > ${XDG_TEMPLATES_DIR}/New_Python3_Script.py
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2345678901234567890123456789012345678901234567890123456789012345678901234567890
%        1         2         3         4         5         6         7         8
" > ${XDG_TEMPLATES_DIR}/New_LaTeX_Document.tex
    chmod 755 *
  fi

  echo "Finished"
}

###### SHELL FEATURES ######

# Forces l as alias for ls -lAh
install_ls_alias()
{
  echo "Attempting to install ls alias"

  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "alias l=" )" ]]; then
    echo "alias l=\"ls -lAh --color=auto\"" >> ${BASHRC_PATH}
  else
    sed -i 's/^alias l=.*/alias l=\"ls -lAh --color=auto\"/' ${BASHRC_PATH}
  fi

  echo "Finished"
}

# Defines a function to extract all types of compressed files
install_extract_function()
{
  echo "Attempting to install extract function"

  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "extract () {" )" ]]; then
      extract="

  # Function that allows to extract any type of compressed files
  extract () {
    if [ -f \$1 ] ; then
      case \$1 in
        *.tar.bz2)   tar xjf \$1        ;;
        *.tar.gz)    tar xzf \$1     ;;
        *.bz2)       bunzip2 \$1       ;;
        *.rar)       rar x \$1     ;;
        *.gz)        gunzip \$1     ;;
        *.tar)       tar xf \$1        ;;
        *.tbz2)      tar xjf \$1      ;;
        *.tgz)       tar xzf \$1       ;;
        *.zip)       unzip \$1     ;;
        *.Z)         uncompress \$1  ;;
        *.7z)        7z x \$1    ;;
        *)           echo \"'\$1' cannot be extracted via extract()\" ;;
      esac
    else
        echo \"'\$1' is not a valid file\"
    fi
  }"
    echo -e "$extract" >> ${BASHRC_PATH}
  else
  	err "WARNING: Extract function is already installed. Skipping"
  fi

  echo "Finished"
}

# Increases file history size, size of the history and forces to append to history, never overwrite
# Ignore repeated commands and simple commands
# Store multiline comments in just one command
install_shell_history_optimization()
{
  echo "Attempting to install shell history optimization"

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

  echo "Finished"
}

install_git_aliases()
{
  echo "Attempting to install git aliases"

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

  echo "Finished"
}

install_environment_aliases()
{
  echo "Attempting to install environment aliases"

  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "export DESK=" )" ]]; then
    echo "export DESK=${XDG_DESKTOP_DIR}" >> ${BASHRC_PATH}
  else
    err "WARNING: DESK environment alias is already installed. Skipping"
  fi

  echo "Finished"
}

root_install()
{
  install_google_chrome
  install_gcc
  install_git
  install_latex
  install_python3
  install_GNU_parallel
  install_pypy3_dependencies
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
  install_pypy3
}

###### AUXILIAR FUNCTIONS ######

# Prints the given arguments to the stderr
function err()
{
  echo "$*" >&2
}

##################
###### MAIN ######
##################
function main()
{
  # Update repositories and system before doing anything if we have permissions
  if [[ "$(whoami)" == "root" ]]; then
    apt -y -qq update
    apt -y -qq upgrade
  fi

  # Locate bash customizing files
  BASHRC_PATH=${HOME}/.bashrc

  # Do a safe copy
  cp -p ${BASHRC_PATH} ${HOME}/.bashrc.bak

  # Create folder for user software
  mkdir -m 0000 -p ${HOME}/.bin
  chmod 755 ${HOME}/.bin
  USR_BIN_FOLDER=${HOME}/.bin

  # Make sure that ${HOME}/.local/bin is present
  mkdir -m 0000 -p ${HOME}/.local/bin

  # Make sure that folder for user launchers is present
  mkdir -m 0000 -p ${HOME}/.local/share/applications

  # Make sure that PATH is pointing to ${HOME}/.local/bin (where we will put our soft links to the software)
  if [[ -z "$(echo $PATH | grep -Eo "${HOME}/.local/bin" )" ]]; then
    echo "export PATH=$PATH:${HOME}/.local/bin" >> ${BASHRC_PATH}
  fi

  ###### ARGUMENT PROCESSING ######

  # If we don't receive arguments we try to install everything that we can given our permissions
  if [[ -z "$@" ]]; then
    if [[ "$(whoami)" == "root" ]]; then
      root_install
      user_install
    else
      user_install
    fi
  else
    while [[ $# -gt 0 ]]; do
      key="$1"

      case $key in
        --chrome)
          
          ;;
        *)    # unknown option
          POSITIONAL+=("$1") # save it in an array for later
          shift # past argument
          ;;
      esac
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

# GLOBAL VARIABLES
# Contains variables XDG_DESKTOP_DIR, XDG_PICTURES_DIR, XDG_TEMPLATES_DIR
. ${HOME}/.config/user-dirs.dirs
# Other script-specific variables
DESK=
USR_BIN_FOLDER=
BASHRC_PATH=

# Call main function
main "$@"
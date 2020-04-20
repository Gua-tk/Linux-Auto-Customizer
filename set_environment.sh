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
  # Chrome dependencies
  apt-get install -y -qq libxss1 libappindicator1 libindicator7

  if [[ -z "$(which google-chrome)" ]]; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt install -y -qq ./google-chrome*.deb
    rm google-chrome*.deb
  else
    err "WARNING: Google Chrome is already installed. Skipping"
  fi
}

# Installs pypy3 dependencies, pypy3 and basic modules (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
# Links it to the path
install_pypy3()
{
  # Targeted version of pypy3
  local -r pypy3_version=pypy3.5-v7.0.0-linux64

  if [[ ! -d ${pypy3_version} ]]; then
    wget -q -P ${USR_BIN_FOLDER} https://bitbucket.org/pypy/pypy/downloads/${pypy3_version}.tar.bz2
    tar xjf ${USR_BIN_FOLDER}/${pypy3_version}.tar.bz2
    rm ${USR_BIN_FOLDER}/${pypy3_version}.tar.bz2*

    # Install modules using pip
    ${USR_BIN_FOLDER}/${pypy3_version}/bin/pypy3 -m ensurepip >/dev/null 2>&1  # redirection to hide output

    # Forces download
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
}

# Needs roots permission
install_pypy3_dependencies()
{
  # pypy3 module dependencies
  apt-get install -y -qq pkg-config
  apt-get install -y -qq libfreetype6-dev
  apt-get install -y -qq libpng-dev
}

# Installs pycharm, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharm()
{
  local -r pycharm_version=pycharm-community-2019.1.1  # Targeted version of pycharm

  # Download pycharm
  if [[ ! -d ${pycharm_version} ]]; then
    wget -q -P ${USR_BIN_FOLDER} https://download.jetbrains.com/python/${pycharm_version}.tar.gz
    tar xzf ${USR_BIN_FOLDER}/${pycharm_version}.tar.gz
    rm ${USR_BIN_FOLDER}/${pycharm_version}.tar.gz*

    # Create links to the PATH
    rm -f ${HOME}/.local/bin/pycharm
    ln -s ${USR_BIN_FOLDER}/${pycharm_version}/bin/pycharm.sh ${HOME}/.local/bin/pycharm
  else
    err "WARNING: pycharm is already installed. Skipping"
  fi

  # Create desktop entry for pycharm launcher
  if [[ -d ${pycharm_version} ]]; then
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
    cp ${HOME}/.local/share/applications/pycharm.desktop ${XDG_DESKTOP_DIR}
  fi
}

# Install GIT and all its related utilities (gitk e.g.)
# Needs root permission
install_git()
{
  apt install -y -qq git-all
}

# Install gcc (C compiler)
# Needs root permission
install_gcc()
{
  apt install -y -qq gcc
}

# Install Python3
# Needs root permission
install_python3()
{
  apt install -y -qq python3
}

# Install GNU parallel
install_GNU_parallel()
{
  apt-get install parallel
}

# Install Sublime text 3
install_sublime_text()
{
  sublime_text_version=sublime_text_3_build_3211_x64  # Targeted version of sublime text

  # Download sublime_text
  if [[ ! -d "sublime_text_3" ]]; then
    wget -q -P ${USR_BIN_FOLDER} https://download.sublimetext.com/${sublime_text_version}.tar.bz2
    tar xjf -P ${USR_BIN_FOLDER}/${sublime_text_version}.tar.bz2
    rm -P ${USR_BIN_FOLDER}/${sublime_text_version}.tar.bz2*

    # Create link to the PATH
    rm -f ${HOME}/.local/bin/subl
    ln -s ${USR_BIN_FOLDER}/sublime_text_3/sublime_text ${HOME}/.local/bin/subl
  fi

  # Create desktop launcher entry for pycharm launcher
  if [[ -d "sublime_text_3" ]]; then
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
    cp ${HOME}/.local/share/applications/sublime_text.desktop ${XDG_DESKTOP_DIR}
  fi
}

# Install latex
# Needs root permission
install_latex()
{
  apt -y -qq install texlive-latex-extra
}

###### SYSTEM FEATURES ######

# Install templates (available files in the right click --> new --> ...)
# Python3, bash shell scripts, latex documents
install_templates()
{
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
  fi
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
  cp ${BASHRC_PATH} ${HOME}/.bashrc.bak

  # Create folder for user software
  mkdir -p ${HOME}/.bin
  chmod 755 ${HOME}/.bin
  USR_BIN_FOLDER=${HOME}/.bin

  # Make sure that ${HOME}/.local/bin is present
  mkdir -p ${HOME}/.local/bin

  # Make sure that folder for user launchers is present
  mkdir -p ${HOME}/.local/share/applications

  # Make sure that PATH is pointing to ${HOME}/.local/bin (where we will put our links to the software)
  if [[ -z "$(echo $PATH | grep -Eo "${HOME}/.local/bin" )" ]]; then
    echo "export PATH=$PATH:${HOME}/.local/bin" >> ${BASHRC_PATH}
  fi

  ###### ARGUMENT PROCESSING ######
  install_pycharm

  # Clean if we have permissions
  if [[ "$(whoami)" == "root" ]]; then
    apt -y -qq autoremove
    apt -y -qq autoclean
  fi

  return 0
}

set -e
# Script will exit if any command fails

# GLOBAL VARIABLES
# Contains variables XDG_DESKTOP_DIR, XDG_PICTURES_DIR, XDG_TEMPLATES_DIR
. ${HOME}/.config/user-dirs.dirs
# Other script-specific variables
DESK=
USR_BIN_FOLDER=
BASHRC_PATH=

# Call main function
main "$@"
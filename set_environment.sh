#!/usr/bin/env bash
# A simple portable shell script to initialize and customize a Linux working environment. Needs root permission for some features.
# Author: Aleix Mariné (aleix.marine@estudiants.urv.cat)
# Created on 28/5/19
# Last Update 19/4/2020

###### SOFTWARE INSTALLATION FUNCTIONS ######

# Checks if Google Chrome is already installed and installs it and its dependencies
# Needs root permission
function install_google_chrome()
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
# Needs roots permission to install dependencies
function install_pypy3()
{
  # Targeted version of pypy3
  local -r pypy3_version=pypy3.5-v7.0.0-linux64

  # pypy3 module dependencies
  apt-get install -y -qq pkg-config
  apt-get install -y -qq libfreetype6-dev
  apt-get install -y -qq libpng-dev

  # Point to the user binaries folder
  cd ${USR_BIN_FOLDER}

  if [[ ! -d ${pypy3_version} ]]; then
    wget -q https://bitbucket.org/pypy/pypy/downloads/${pypy3_version}.tar.bz2
    tar xjf ${pypy3_version}.tar.bz2
    rm ${pypy3_version}.tar.bz2*
    cd ${pypy3_version}/bin

    # Install modules using pip
    ./pypy3 -m ensurepip >/dev/null 2>&1  # redirection to hide output

    # Forces download
    ./pip3.5 --no-cache-dir -q install --upgrade pip
    ./pip3.5 --no-cache-dir -q install cython numpy matplotlib biopython

    # Create links to the PATH
    rm -f ~/.local/bin/pypy3
    ln -s $(pwd)/pypy3 ~/.local/bin/pypy3
    rm -f ~/.local/bin/pip-pypy3
    ln -s $(pwd)/pip3.5 ~/.local/bin/pip-pypy3
  else
    err "WARNING: pypy3 is already installed. Skipping"
  fi

}

# Installs pycharm, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
function install_pycharm()
{
  local -r pycharm_version=pycharm-community-2019.1.1  # Targeted version of pycharm

  # Point to the user binaries folder
  cd ${USR_BIN_FOLDER}

  # Download pycharm
  if [[ ! -d ${pycharm_version} ]]; then
    wget -q https://download.jetbrains.com/python/${pycharm_version}.tar.gz
    tar xzf ${pycharm_version}.tar.gz
    rm ${pycharm_version}.tar.gz*

    # Create links to the PATH
    rm -f ~/.local/bin/pycharm
    ln -s $(pwd)/${pycharm_version}/bin/pycharm.sh ~/.local/bin/pycharm
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
    echo -e "$pycharm_launcher" > ~/.local/share/applications/pycharm.desktop
    chmod 775 ~/.local/share/applications/pycharm.desktop
    cp ~/.local/share/applications/pycharm.desktop ${XDG_DESKTOP_DIR}
  fi
}

# Install GIT and all its related utilities (gitk e.g.)
# Needs root permission
function install_git()
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

  apt install -y -qq git-all
}

# Install gcc (C compiler)
# Needs root permission
function install_gcc()
{
  apt install -y -qq gcc
}

# Install Python3
# Needs root permission
function install_python3()
{
  apt install -y -qq python3
}

# Install GNU parallel
function install_GNU_parallel()
{
  apt-get install parallel
}

# Install Sublime text 3
function install_sublime_text()
{
  sublime_text_version=sublime_text_3_build_3211_x64  # Targeted version of sublime text

  cd ${USR_BIN_FOLDER}  # Point to the user binaries folder

  # Download sublime_text
  if [[ ! -d "sublime_text_3" ]]; then
    wget -q https://download.sublimetext.com/${sublime_text_version}.tar.bz2
    tar xjf ${sublime_text_version}.tar.bz2
    rm ${sublime_text_version}.tar.bz2*

    # Create link to the PATH
    rm -f ~/.local/bin/subl
    ln -s $(pwd)/sublime_text_3/sublime_text ~/.local/bin/subl
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
    echo -e "$sublime_launcher" > ~/.local/share/applications/sublime_text.desktop
    chmod 775 ~/.local/share/applications/sublime_text.desktop

    # Copy launcher to the desktop
    cp ~/.local/share/applications/sublime_text.desktop ${XDG_DESKTOP_DIR}
  fi
}

# Install latex
# Needs root permission
function install_latex()
{
  apt -y -qq install texlive-latex-extra
}

###### SYSTEM FEATURES ######

# Install templates (available files in the right click --> new --> ...)
# Python3, bash shell scripts, latex documents
function install_templates()
{
  # Add templates
  cd ~
  if [[ -f ~/.config/user-dirs.dirs ]]; then
    cd ${XDG_TEMPLATES_DIR}
    echo "#!/usr/bin/env bash" > New_Shell_Script.sh
    echo "#!/usr/bin/env python3" > New_Python3_Script.py
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2345678901234567890123456789012345678901234567890123456789012345678901234567890
%        1         2         3         4         5         6         7         8
" > New_LaTeX_Document.tex
    chmod 755 *
  fi
}

###### SHELL FEATURES ######

# Forces l as alias for ls -lAh
function install_ls_alias()
{
  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "alias l=" )" ]]; then
    echo "alias l=\"ls -lAh --color=auto\"" >> ${BASHRC_PATH}
  else
    sed -i 's/^alias l=.*/alias l=\"ls -lAh --color=auto\"/' ${BASHRC_PATH}
  fi
}

# Defines a function to extract all types of compressed files
function install_extract_function()
{
  # TODO(aleix) assure bashrc_path variable
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
function install_shell_history_optimization()
{
  # TODO(aleix) assure bashrc_path variable

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
  # Update repositories and system before doing anything
  apt -y -qq update
  apt -y -qq upgrade

  # Locate bash customizing files
  BASHRC_PATH=~/.bashrc

  # Create folder for user software
  cd ~
  mkdir -p ~/.bin
  chmod 755 .bin
  USR_BIN_FOLDER=$(pwd)/.bin
  cd ~

  # Make sure that ~/.local/bin is present
  mkdir -p ~/.local/bin

  # Make sure that folder for user launchers is present
  mkdir -p ~/.local/share/applications

  if [[ -z "$(more ${BASHRC_PATH} | grep -Fo "export DESK=" )" ]]; then
    echo "export DESK=$DESK" >> ${BASHRC_PATH}
  fi

  # Make sure that PATH is pointing to ~/.local/bin (where we will put our links to the software)
  if [[ -z "$(echo $PATH | grep -Eo "~/.local/bin" )" ]]; then
    echo "export PATH=$PATH:~/.local/bin" >> ${BASHRC_PATH}
  fi

  install_python3
  install_gcc
  install_git
  install_google_chrome
  install_GNU_parallel
  install_latex

  # Clean
  apt -y -qq autoremove
  apt -y -qq autoclean
  return 0

}

# GLOBAL VARIABLES
# Contains variables XDG_DESKTOP_DIR, XDG_PICTURES_DIR, XDG_TEMPLATES_DIR
. ~/.config/user-dirs.dirs
# Other script-specific variables
DESK=
USR_BIN_FOLDER=
BASHRC_PATH=

# Call main function
main "$@"
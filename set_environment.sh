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
  apt-get install -y -qq libxss1 libappindicator1 libindicator7
  if [[ -z "$(which google-chrome)" ]]; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt install -y -qq ./google-chrome*.deb
    rm google-chrome*.deb
  else
    err "WARNING: Google Chrome is already installed. Skipping"
  fi
}

# Installs pypy3 dependencies, pypy3 and basic modules (cython, numpy, matplotlib) using pip3 from pypy3
# Needs roots permission to install dependencies
function install_pypy3()
{
  # pypy3 module dependencies
  apt-get install -y -qq pkg-config
  apt-get install -y -qq libfreetype6-dev
  apt-get install -y -qq libpng-dev

  # Downloads pypy3 and install modules
  readonly pypy3_version=pypy3.5-v7.0.0-linux64

  cd ${userBinariesFolder}  # TODO(aleix)  # TODO(aleix) make sure that pwd is pointing to ~/.bin

  if [[ ! -d ${pypy3_version} ]]; then
    wget -q https://bitbucket.org/pypy/pypy/downloads/${pypy3_version}.tar.bz2
    tar xjf pypy3.5-v7.0.0-linux64.tar.bz2
    rm pypy3.5-v7.0.0-linux64.tar.bz2*
    cd pypy3.5-v7.0.0-linux64/bin
    ./pypy3 -m ensurepip >/dev/null 2>&1  # redirection to hide output
    ./pip3.5 --no-cache-dir -q install --upgrade pip
    ./pip3.5 --no-cache-dir -q install cython numpy matplotlib biopython
    rm -f ~/.local/bin/pypy3
    ln -s $(pwd)/pypy3 ~/.local/bin/pypy3
    rm -f ~/.local/bin/pip-pypy3
    ln -s $(pwd)/pip3.5 ~/.local/bin/pip-pypy3
  else
    err "WARNING: pypy3 is already installed. Skipping"
  fi

}

# Installs pycharm, links it to the PATH and creates a launcher for it
function install_pycharm()
{
  pycharm_version=pycharm-community-2019.1.1  # Targeted version of pycharm
  cd ${userBinariesFolder}  # TODO(aleix)  # TODO(aleix) make sure that pwd is pointing to ~/.bin

  # Download pycharm
  if [[ ! -d ${pycharm_version} ]]; then
    wget -q https://download.jetbrains.com/python/${pycharm_version}.tar.gz
    tar xzf ${pycharm_version}.tar.gz
    rm ${pycharm_version}.tar.gz*
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

  fi
}

# Install GIT and all its related utilities (gitk e.g.)
# Needs root permission
function install_git()
{
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

  # Download sublime_text
  echo "Installing sublime-text"
  cd ${userBinariesFolder}  # TODO(aleix)  # TODO(aleix) make sure that pwd is pointing to ~/.bin
  if [[ ! -d "sublime_text_3" ]]; then
    wget -q https://download.sublimetext.com/${sublime_text_version}.tar.bz2
    tar xjf ${sublime_text_version}.tar.bz2
    rm ${sublime_text_version}.tar.bz2*
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
Exec=sublime"
    echo -e "$sublime_launcher" > ~/.local/share/applications/sublime_text.desktop
    chmod 775 ~/.local/share/applications/sublime_text.desktop
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
  echo "Adding user file templates"
  cd ~
  if [[ -f ~/.config/user-dirs.dirs ]]; then
    templates=$(more ~/.config/user-dirs.dirs | grep "XDG_TEMPLATES_DIR" | cut -d '"' -f2)  # obtain templates path (not affected by sys language)
    eval templates=${templates}  # Expand recursively all variables in $DESK (usually $HOME)
    cd ${templates}
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
  # TODO(aleix) assure bashrc_path variable
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
	if [[ -z "$(more $BASHRC_PATH | grep -Fo "extract () {" )" ]]; then
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
		echo -e "$extract" >> $BASHRC_PATH
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
  # TODO(aleix) prepare environment and variables for the installation
  return 0

}

if [ "$(whoami)" != "root" ]; then
	DESK=$(more ~/.config/user-dirs.dirs | grep "XDG_DESKTOP_DIR" | cut -d '"' -f2)  # obtain desktop path (not affected by sys language)
	eval DESK=$DESK  # Expand variables recursively

	# Locate bash customizing files
	BASHRC_PATH=~/.bashrc

	# Create folder for user software
	cd ~
	mkdir -p ~/.bin
	chmod 755 .bin
	userBinariesFolder=$(pwd)/.bin
	cd ~

	# Make sure that ~/.local/bin is present
	mkdir -p ~/.local/bin

	
	# Create folder for user launchers
	mkdir -p ~/.local/share/applications

	##### Console Features #####
	# Increase history size
	echo "Applying console features"
	if [ -z "$(more $BASHRC_PATH | grep -Fo "HISTSIZE=" )" ]; then 
		echo "export HISTSIZE=10000" >> $BASHRC_PATH
	else
		sed -i 's/HISTSIZE=.*/HISTSIZE=10000/' $BASHRC_PATH
	fi

	# Increase File history size
	if [ -z "$(more $BASHRC_PATH | grep -Fo "HISTFILESIZE=" )" ]; then 
		echo "export HISTFILESIZE=100000" >> $BASHRC_PATH
	else
		sed -i 's/HISTFILESIZE=.*/HISTFILESIZE=100000/' $BASHRC_PATH
	fi

	# Append and not overwrite history
	if [ -z "$(more $BASHRC_PATH | grep -Fo "shopt -s histappend" )" ]; then 
		echo "shopt -s histappend" >> $BASHRC_PATH
	fi

	# Ignore repeated commands
	if [ -z "$(more $BASHRC_PATH | grep -Fo "HISTCONTROL=" )" ]; then 
		echo "HISTCONTROL=ignoredups" >> $BASHRC_PATH
	else
		sed -i 's/HISTCONTROL=.*/HISTCONTROL=ignoredups/' $BASHRC_PATH
	fi

	# Ignore simple commands
	if [ -z "$(more $BASHRC_PATH | grep -Fo "HISTIGNORE=" )" ]; then 
		echo "HISTIGNORE=\"ls:ps:history:l:pwd:top:gitk\"" >> $BASHRC_PATH
	else
		sed -i 's/HISTIGNORE=.*/HISTIGNORE=\"ls:ps:history:l:pwd:top:gitk\"/' $BASHRC_PATH
	fi

	# store multiline commands in just one command
	if [ -z "$(more $BASHRC_PATH | grep -Fo "shopt -s cmdhist" )" ]; then 
		echo "shopt -s cmdhist" >> $BASHRC_PATH
	fi

	##### Add aliases and global variables #####



	# Force "gitk" as alias for gitk --all --date-order
	if [ -z "$(more $BASHRC_PATH | grep -Fo "alias gitk=" )" ]; then 
		echo "alias gitk=\"gitk --all --date-order \"" >> $BASHRC_PATH
	else
		sed -Ei 's/^alias gitk=.*/alias gitk=\"gitk --all --date-order \"/' $BASHRC_PATH
	fi

	# Desktop global variable pointer
	eval DESK=$DESK  # Expand recursively all variables in $DESK (usually $HOME)
	if [ -z "$(more $BASHRC_PATH | grep -Fo "export DESK=" )" ]; then 
		echo "export DESK=$DESK" >> $BASHRC_PATH
	fi


	if [ -z "$(echo $PATH | grep -Eo "~/.local/bin" )" ]; then 
		echo "export PATH=$PATH:~/.local/bin" >> $BASHRC_PATH
	fi




else
	##### Software #####
	# Update repositories and system
	apt -y -qq update
	apt -y -qq upgrade

	# GNU C compiler, git suite, python3, python2
	install_python3
    install_gcc
    install_git
    install_google_chrome

	# GNU-parallel

    # LaTeX
    apt -y -qq install texlive-latex-extra

	# Clean
	apt -y -qq autoremove
	apt -y -qq autoclean
fi

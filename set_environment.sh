#!/usr/bin/env bash
# A simple portable shell script to initialize and customize a Linux working environment. Needs root permission for some features.
# Author: Aleix Mariné (aleix.marine@estudiants.urv.cat)
# Created on 28/5/19

if [ "$(whoami)" != "root" ]; then
	pycharm_version=pycharm-community-2019.1.1
	sublime_text_version=sublime_text_3_build_3211_x64
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
	
	# Create folder for user launchers
	mkdir -p ~/.local/share/applications

    	# git credentials
    	if [ "$*" == 1 ]; then
	    git config --global user.email "aleixaretra@gmail.com"
	    git config --global user.name "AleixMT"
	fi

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

	# Block comment
	if [ -z "$(more $BASHRC_PATH | grep -Fo "alias BEGINCOMMENT" )" ]; then 
		echo "alias BEGINCOMMENT=\"if [ ]; then\"" >> $BASHRC_PATH
	fi
	if [ -z "$(more $BASHRC_PATH | grep -Fo "alias ENDCOMMENT" )" ]; then 
		echo "alias ENDCOMMENT=\"fi\"" >> $BASHRC_PATH
	fi

	# Force "l" as alias for ls -lAh
	if [ -z "$(more $BASHRC_PATH | grep -Fo "alias l=" )" ]; then 
		echo "alias l=\"ls -lAh --color=auto\"" >> $BASHRC_PATH
	else
		sed -i 's/^alias l=.*/alias l=\"ls -lAh --color=auto\"/' $BASHRC_PATH
	fi

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

	# Git folder global variable pointer
	if [ -z "$(more $BASHRC_PATH | grep -Fo "export GIT=" )" ]; then 
		cd $DESK
		if [ ! -d "GIT" ]; then
			mkdir GIT
		fi
		cd GIT
		echo "export GIT=$(pwd)" >> $BASHRC_PATH
	fi


	##### Add Global functions #####
	# Extract function, allows to extract from any type of compressed file
	if [ -z "$(more $BASHRC_PATH | grep -Fo "extract () {" )" ]; then 
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

	# Add templates
	echo "Adding user file templates"
	cd ~
	if [ -f ~/.config/user-dirs.dirs ]; then
		templates=$(more ~/.config/user-dirs.dirs | grep "XDG_TEMPLATES_DIR" | cut -d '"' -f2)  # obtain templates path (not affected by sys language)
		eval templates=$templates  # Expand recursively all variables in $DESK (usually $HOME)
		cd $templates
		echo "#!/usr/bin/env bash" > New_Shell_Script.sh
		echo "#!/usr/bin/env python3" > New_Python3_Script.py
		echo "#!/usr/bin/env python2" > New_Python2_Script.py
		chmod 755 *
		cd ..
	fi

	if [ -z "$(echo $PATH | grep -Eo "~/.local/bin" )" ]; then 
		echo "export PATH=$PATH:~/.local/bin" >> $BASHRC_PATH
	fi

	# pypy3
	# Create and add dependencies of pypy3 virtual environment
	# Downloads pypy3 and adds dependencies with cython, numpy and matplotlib
	echo "Installing pypy"
    cd $userBinariesFolder
	if [ ! -d "pypy3.5-v7.0.0-linux64" ]; then
		wget -q https://bitbucket.org/pypy/pypy/downloads/pypy3.5-v7.0.0-linux64.tar.bz2
		tar xjf pypy3.5-v7.0.0-linux64.tar.bz2
		rm pypy3.5-v7.0.0-linux64.tar.bz2*
		cd pypy3.5-v7.0.0-linux64/bin
		./pypy3 -m ensurepip >/dev/null 2>&1  # redirection to hide output
		./pip3 -q --no-cache-dir install --upgrade pip
		./pip3 -q --no-cache-dir install cython numpy matplotlib
		rm -f ~/.local/bin/pypy3
		ln -s $(pwd)/pypy3 ~/.local/bin/pypy3
		rm -f ~/.local/bin/pip-pypy3
		ln -s $(pwd)/pip ~/.local/bin/pip-pypy3
		rm -f ~/.local/bin/pip3-pypy
		ln -s $(pwd)/pip3 ~/.local/bin/pip3-pypy
	fi

	# pycharm
	echo "Installing pycharm"
	cd $userBinariesFolder
	if [ ! -d $pycharm_version ]; then
		wget -q https://download.jetbrains.com/python/$pycharm_version.tar.gz
		tar xzf $pycharm_version.tar.gz
		rm $pycharm_version.tar.gz*
		rm -f ~/.local/bin/pycharm
		ln -s $(pwd)/$pycharm_version/bin/pycharm.sh ~/.local/bin/pycharm
	fi
	# Create desktop entry for pycharm launcher
	if [ -d $pycharm_version ]; then
		pycharm_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm
Icon=~/.bin/$pycharm_version/bin/pycharm.png
Exec=pycharm
Comment=Python IDE for Professional Developers
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-pycharm"
		echo -e "$pycharm_launcher" > ~/.local/share/applications/pycharm.desktop
		chmod 775 ~/.local/share/applications/pycharm.desktop
	fi

    # sublime_text
	echo "Installing sublime-text"
	cd $userBinariesFolder
	if [ ! -d "sublime_text_3" ]; then
		wget -q https://download.sublimetext.com/$sublime_text_version.tar.bz2
		tar xjf $sublime_text_version.tar.bz2
		rm $sublime_text_version.tar.bz2*
		rm -f ~/.local/bin/sublime
		ln -s $(pwd)/sublime_text_3/sublime_text ~/.local/bin/sublime
	fi
		# Create desktop entry for pycharm launcher
	if [ -d "sublime_text_3" ]; then
		sublime_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=Sublime Text
GenericName=Text Editor
Icon=~/.bin/sublime_text_3/Icon/256x256/sublime-text.png
Comment=General Purpose Programming Text Editor
Categories=TextEditor;IDE;Development
Terminal=false
Exec=sublime"
#X-Ayatana-Desktop-Shortcuts=NewWindow
#[NewWindow Shortcut Group]
#Name=New Window
#Exec=sublime -n
#TargetEnvironment=Unity
		echo -e "$sublime_launcher" > ~/.local/share/applications/sublime.desktop
		chmod 775 ~/.local/share/applications/sublime.desktop
	fi
else
	##### Software #####
	# Update repositories and system
	apt -y -qq update
	apt -y -qq upgrade

	# GNU C compiler, git suite, python3, python2
	apt install -y -qq gcc git-all python3 python

	# pypy dependencies
	apt-get install -y -qq pkg-config
	apt-get install -y -qq libfreetype6-dev
	apt-get install -y -qq libpng-dev

	# Google Chrome
	apt-get install -y -qq libxss1 libappindicator1 libindicator7
	if [ -z "$(which google-chrome)" ]; then
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        apt install -y -qq ./google-chrome*.deb
        rm google-chrome*.deb
    fi

	# Clean
	apt -y -qq autoremove
	apt -y -qq autoclean 
fi

#!/usr/bin/env bash
# A simple portable shell script to initialize and customize a Linux working environment. Needs root permission for some features.
# Author: Aleix Mariné (aleix.marine@estudiants.urv.cat)
# Created on 28/5/19

pycharm_version=pycharm-community-2019.1.1
LAUNCHERS_PATH=/usr/share/applications
DESK=$(more ~/.config/user-dirs.dirs | grep "XDG_DESKTOP_DIR" | cut -d '"' -f2)  # obtain desktop path (not affected by sys language)
eval DESK=$DESK  # Expand variables recursively

if [ "$(whoami)" != "root" ]; then
	# Locate bash customizing files
	BASHRC_PATH=~/.bashrc

	##### Console Features #####
	# Increase history size
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

	# Force "gitk" as alias for gitk --all --date-order &
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
		git clone https://github.com/AleixMT/TrigenicInteractionPredictor
		git clone https://github.com/AleixMT/Linux-Auto-Customizer
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
	cd ~
	if [ -f ~/.config/user-dirs.dirs ]; then
		templates=$(more ~/.config/user-dirs.dirs | grep "XDG_TEMPLATES_DIR" | cut -d '"' -f2)  # obtain templates path (not affected by sys language)
		eval templates=$templates  # Expand recursively all variables in $DESK (usually $HOME)
		cd $templates
		echo "#!/usr/bin/env bash" > New_Shell_Script.sh
		echo "#!/usr/bin/env python3" > New_Python3_Script.py
		echo "#!/usr/bin/env python2" > New_Python2_Script.py
		chmod 777 *
		cd ..
	fi

	# pypy3
	# Create and add dependencies of pypy3 virtual environment
	# Downloads pypy3 and adds dependencies with cython, numpy and matplotlib
	cd $DESK
	if [ ! -d "pypy3.5-v7.0.0-linux64" ]; then
		wget https://bitbucket.org/pypy/pypy/downloads/pypy3.5-v7.0.0-linux64.tar.bz2
		tar xjf pypy3.5-v7.0.0-linux64.tar.bz2
		rm pypy3.5-v7.0.0-linux64.tar.bz2*
		cd pypy3.5-v7.0.0-linux64/bin
		./pypy3 -m ensurepip
		./pip3 --no-cache-dir install --upgrade pip
		./pip3 --no-cache-dir install cython numpy matplotlib
	fi

	# pycharm
	cd $DESK
	if [ ! -d $pycharm_version ]; then
		wget https://download.jetbrains.com/python/pycharm-community-2019.1.1.tar.gz
		tar xzf pycharm-community-2019.1.1.tar.gz
		rm pycharm-community-2019.1.1.tar.gz*
		# Add to PATH in order to be able to call pycharm from anywhere
	fi
	if [ -z "$(more $BASHRC_PATH | grep -Eo "export PATH=$PATH:$DESK/$pycharm_version/bin" )" ]; then 
		echo "enrtem"
		echo "export PATH=$PATH:$DESK/$pycharm_version/bin" >> $BASHRC_PATH
	fi
else
	##### Software #####
	# Update repositories and system

	apt -y update
	apt -y upgrade

	# GNU C compiler, git suite, python3, python2
	apt install -y gcc git-all python3 python

	# git credentials
	git config --global user.email "aleixaretra@gmail.com"
	git config --global user.name "AleixMT"

	# pypy dependencies
	apt-get install -y pkg-config
	apt-get install -y libfreetype6-dev
	apt-get install -y libpng-dev

	# sublime text
	cd $DESK
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
	apt-get -y install apt-transport-https
	if [ ! -e "/etc/apt/sources.list.d/sublime-text.list" ]; then
		echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
	fi
	apt-get -y update
	apt-get -y install sublime-text

	# Create desktop entry for pycharm launcher
	if [ -d $pycharm_version ]; then
		pycharm_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Community Edition
Icon=$DESK/$pycharm_version/bin/pycharm.svg
Exec=\"$DESK/$pycharm_version/bin/pycharm.sh\" %f
Comment=Python IDE for Professional Developers
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-pycharm-ce"
		echo -e "$pycharm_launcher" > $LAUNCHERS_PATH/pycharm.desktop
	fi

	# Google Chrome
	apt-get install -y libxss1 libappindicator1 libindicator7ç
	if [ -z "$(which google-chrome)" ]; then
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        apt install -y ./google-chrome*.deb
        rm google-chrome*.deb
    fi

	# Clean
	apt -y autoremove
	apt -y autoclean 
fi

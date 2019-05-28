#!/usr/bin/env bash
# A simple portable shell script to initialize and customize a Linux working environment. Needs root permission.
# Author: Aleix Mariné (aleix.marine@estudiants.urv.cat)
# Created on 28/5/19

# Update repositories and system
apt update
apt upgrade

# Add aliases

# Add templates
cd ~
mkdir Templates
cd Templates
echo "#!/usr/bin/env bash" > New_Shell_Script.sh
echo "#!/usr/bin/env python3" > New_Python3_Script.py
echo "#!/usr/bin/env python2" > New_Python2_Script.py
sed -i 's/XDG_TEMPLATES_DIR.*/XDG_TEMPLATES_DIR="$HOME\/Templates"/' ~/.config/user-dirs.dirs  # make sure that templates folder is pointing to ~/Templates
cd ..


##### Software #####

# GNU C compiler, git suite, python3, python2
apt install gcc git-all python3 python
# sublime text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
apt-get install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
apt-get update
apt-get install sublime-text

# pypy3
# Create and add dependencies of pypy3 virtual environment
# Downloads pypy3 and adds dependencies with cython, numpy and matplotlib
wget https://bitbucket.org/pypy/pypy/downloads/pypy3.5-v7.0.0-linux64.tar.bz2
tar xfv pypy3.5-v7.0.0-linux64.tar.bz2
rm pypy3.5-v7.0.0-linux64.tar.bz2
cd pypy3.5-v7.0.0-linux64/bin
./pypy3 -m ensurepip
./pip3 install cython numpy matplotlib

# pycharm
cd ~
wget https://download.jetbrains.com/python/pycharm-community-2019.1.1.tar.gz

apt-get install git-all
git clone https://github.com/AleixMT/TrigenicInteractionPredictor

# Clean
apt autoremove
apt autoclean

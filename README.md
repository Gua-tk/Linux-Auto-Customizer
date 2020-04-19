# Linux-Customizer

This software is intended to work as a time-saver when setting up a new virtual machine with Ubuntu. The script applies some custom features to the current user console and to the Ubuntu-Linux environment, such as local functions, file templates and global variables. Also, some software is installed too, including its dependencies.

This repository includes two scripts: one is to install the custom features and the other is to uninstall them. The installation script is also divided in two parts depending on what your user privileges are when running the script (regular user, root)

## Local user features
##### Console features
* Increased the size of history
* Deleted tracking history of some simple commands: ls, cd, gitk...
* Added a user global variable to $DESK (~/Desktop)
* Added a user global function that extracts from any type of compressed file

##### Software
* pycharm 2019.1 community.
* pypy3 (as a virtual environment, including pip)
* sublime-Text-3
The script also performs the addition of a symlink for each installed program into a user folder pointed by PATH variable in order to execute the software from anywhere in the system. A launcher is also generated for sublime-text and pycharm.
All user software is going to be installed under ~/.bin

## Root features
##### Software
* git-suite (git-all)
* Google Chrome


TODO add walpapers
add automount external unities
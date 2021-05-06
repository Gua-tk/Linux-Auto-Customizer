### Business rules

#### Environmental
* Both behaviors of the script use the file `~/.config/user-dirs.dirs` to set some language-independent environment variables (for example, to get an independent system-language path to the Desktop), so some functions of this script will fail if this file does not exist. The variables declared in this file that are used in the customizer are `XDG_DESKTOP_DIR=/home/username/Desktop`, `XDG_PICTURES_DIR=/home/username/Images`, `XDG_TEMPLATES_DIR=/home/username/Templates`.
* Customizer must not rely ever on the working directory, that is why relative paths are completely avoided. In the same vein, files must not be downloaded in the working directory, they should be deleted in a controlled location. In most cases, this location is `USR_BIN_FOLDER`.

#### Structural
* The software that is manually installed is put under `USR_BIN_FOLDER`, which by default points to `~/.bin`. `~/.bin` is always **present**.
* Shell features are not installed directly into `~/.bashrc`, instead, there is always present the file `~/.bash_functions`, which is a file imported by `~/.bashrc`. In `~/.bash_functions`, you can write imports to individual scripts that provide a feature to the shell environment. Usually those scripts are stored under `~/.bin/bash_functions/`, which is a location always present. So the generic way to include new content to `~/.bashrc` is writing a script to `~/.bin/bash_functions` and including it in `~/.bash_functions/`.
* Soft links to include a program in the path are created under `~/.local/bin` which is a directory that is assured to be in the PATH 

#### Behavioural
* Each feature is expected to be executed with certain permissions (root / normal user). So the script will skip a feature that needs to be installed with different permissions from the ones that currently has.
* Relative PATHs are forbidden. We must not use the given working directory  
* No unprotected `cd` commands. `cd` must be avoided and never change the working directory given from the outside, that is why they must be called from the inside of a subshell if present. 
* wget is always used with the `-O` flag, which is used to change the name of the file and / or select a destination for the download. 
* no `apt`, the default way to install package in script is `apt-get`

#### Syntactical
* All variables must be expanded by using `${VAR_NAME}` (include the brackets) except for the special ones, like `$#`, `$@`, `$!`, `$?`, etc.
* All variables must be protected by using "" to avoid resplitting because of spaces, despite, customizer is not emphasized to work with spaces in its variables. Spaces are *evil* and are not considered.
* There is one blankline between functions in the same block. There is two blanklines between blocks.
* Indent is always 2 spaces and never TAB.
* The used package manager by default is apt-get, which is actually the recommended way to use `apt` through scripts.

## Developed features
#### Aleix
- [x] Create argument (! or --not) for deselecting installed or uninstalled features.
- [x] -v --verbose Verbose mode (make the software not verbose by default)
- [x] Solve a bug of `PATH` addition in shell features. (it works, but it appends the export many times)
- [x] To add more useful directory path variables in common_data.sh
- [x] Make sure USR_BIN_FOLDER is present in any user roll
- [x] Create a file and directory structure to add features to `.bashrc` without actually writing anything on it by using the wrapper in `.bash_functions`
- [x] Name refactor of functions to make it coincide with what command is being thrown in order to determine if it is installed using which
- [x] try refactoring the point above by using type, which recognizes alias and functions too
- [x] Add aliases to pycharm, clion, etc
- [x] Add argument to dummy commit
- [x] refactor installation bit to be installation order, which contains an integer that if it is greater than 0 means selected for install, and the integer determines the installation order
- [x] Installations must be done by argument order apparition (add another column to installation_data to sort an integer that determines the order)
- [x] declare variables like DESK, GIT, etc
- [x] Split multifeatures in one function into different functions
- [x] Create source in bashrc with file bash_functions.sh with all sources calls
- [x] Desktop wallpapers
- [x] Refactor old stuff from the README.md
- [x] Add a new column for testing and permissions
- [x] Repair broken desktop icons (VLC, VScode, Telegram)
- [x] Create generic version for the function output_proxy_exec, to integrate with a bash feature to be installed. this command is `s "command"`
- [x] On nemo desktop delete automatically nautilus
- [x] Wireshark
- [ ] Replicate most of the necessary structures and data to adapt `uninstall.sh` to the new specs
- [x] Red prompt for warning and error messages
- [x] Optimize history to be updated in real-time and share the same hsitory between folders (export PROMPT_COMMAND='history -a; history -r') Also change filesize
- [x] Anydesk
- [x] Put Path declaration in common data, as a bash function  
- [x] Add final & to alias of gitk  (git_aliases), pluma, VS code,  so is always launched in background
- [x] Apply rule: no apt, the default way to install package in script is apt-get


#### Axel
- [x] Delete / rearrange arguments of one letter 
- [x] Refactor of data table in README.md
- [x] Youtube-dl
- [x] Create escape function, which returns an escaped sequence of characters
- [ ] nettools*
- [ ] docker 
- [ ] rar
  
- [ ] GnuCash, Rosegarden, Remmina, Freeciv, Shotwell, Handbrake, fslint, CMake, unrar, rar, evolution, guake, Brasero, Remastersys, UNetbootin, Blender3D, Skype, Ardour, Spotify, TeamViewer, Remmina, WireShark, PacketTracer, LMMS...
- [ ] LAMP stack web server, Wordpress
- [ ] Rsync, Axel, GNOME Tweak, Wine 5.0, Picasa, Synaptic, Bacula, Docker, kubernetes, Agave, apache2, Moodle, Oracle SQL Developer, Mdadm, PuTTY, MySQL Server instance, glpi*, FOG Server*, Proxmox*, Nessus*, PLEX Media Server
- [ ] nmap, gobuster, metasploit, Firewalld, sysmontask, sherlock, Hydra, Ghidra, THC Hydra, Zenmap, Snort, Hashcat, Pixiewps, Fern Wifi Cracker, gufw, WinFF, chkrootkit, rkhunter, Yersinia, Maltego, GNU MAC Changer, Burp Suite, BackTrack, John the Ripper, aircrack-ng
- [ ] SublimeText-Markdown, & other plugins for programs...
- [ ] Fonts



## Currently developing/refactoring features

## TO-DO
- [ ] Update and construct readme and help message
- [ ] Add examples (images) of a working environement after applying the customizer in Linux 
- [ ] Change the default storing place for wallpapers. change from ~/Images to ~/Images/wallpapers or in a folder in $USR_BIN_FOLDER
- [ ] Refine extract function: extract dependencies in another extract function
- [ ] Use the same fields in the same order in launchers: Name, GenericName, Type, Comment, Categories=IDE;Programming;, Version, StartupWMClass, Icon, Exec, Terminal, StartupNotify, MimeType=x-scheme-handler/tg;, Encoding=UTF-8
- [ ] Add special func in `uninstall` that uninstalls the file structures that the customizer creates (~/.bash_functions, ~/.bin, etc.) That cannot be removed directly using uninstall
- [ ] Move all argument processing to the same data structure that we are using for storing info abaout the programs. This is in order to reduce the steps needed to implement a program an autogenerate a README table
- [ ] Apply rule: all variables should be declared with the needed scope and its write/read permissions (local -r)
- [ ] Autofirma
- [ ] Eclipse
- [ ] Geogebra
- [ ] Zoom
- [ ] Teams (?)  
- [ ] Write date in all the messages that the customizer outputs (warning, info etc)
- [ ] May be possible to achieve a post configuration install to nemo-desktop ? to add some customization such as the rendering thumbnails of images depending on the size

## Coming features
- [ ] L Function  
- [ ] Why some programs such as pycharm can not be added to favourites from the task bar? (related to launchers and how executables are related to launchers)  
- [ ] create a unique endpoint for all the code in customizer customizer.sh which accepts the arguments install uninstall for the recognized features and make the corresponding calls to sudo uninstall.sh ..., sudo install.sh ... And Install.sh ...
- [ ] When having this unique endopint, if an argument is provided but not recognized, customizer will try luck by using apt-get to install it
- [ ] Split git aliases in many functions (alias_gitk, function_dummycommit, gitprompt added in prompt...)
- [ ] Create high-level wrappers for a set of features, such as "minimal", "custom", "git_customization" etc. in this new endpoint
- [ ] Create or integrate loc function bash feature which displays the lines of code of a script  
- [ ] Program function to unregister default opening applications on `uninstall.sh`
- [ ] Codium does not work because of the folder . in the root
- [ ] Create cloud-init file to run customizer with a certain wrapper for a VM automatic customization (thanks to José Ángel Morena for the idea)
- [ ] Automount available drives.*
- [ ] refactor extract function: more robustness and error handling. decompress in a folder
- [ ] Flatten function, which narrows branches of the file system by deleting a folder that contains only another folder.

```
# wget not used with -O and in subshell to avoid cd
# tar not used in a subshell to avoid cd
# echo or err directly used instead of using output_proxy_executioner
# desktop launchers created manually as user created ONLY in the desktop and not also in the user launchers folder
# desktop launchers created manually as root created ONLY in the desktop and not in the all users launchers folder
# Files or folders created as root that only change their permissions, and not also its group and owner, using chgrp and chown
# using ~ or $HOME instead of HOME_FOLDER
# console feature installed directly in bashrc instead of using the structure provided by the customizer using .bash_functions

## asjko
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

  #alias a="echo '---------------Alias----------------';alias"
  #alias c="clear"
  #alias h="history | grep $1"
  #du -shxc .[!.]* * | sort -h


# Increases file history size, size of the history and forces to append to history, never overwrite
# Ignore repeated commands and simple commands
# Store multiline comments in just one command
``
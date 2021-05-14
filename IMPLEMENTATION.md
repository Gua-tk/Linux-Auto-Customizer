### Business rules

#### Environmental
* Both behaviors of the script use the file `~/.config/user-dirs.dirs` to set some language-independent environment variables (for example, to get an independent system-language path to the Desktop), so some functions of this script will fail if this file does not exist. The variables declared in this file that are used in the customizer are `XDG_DESKTOP_DIR=/home/username/Desktop`, `XDG_PICTURES_DIR=/home/username/Images`, `XDG_TEMPLATES_DIR=/home/username/Templates`.
* Customizer must not rely ever on the working directory, that is why relative paths are completely avoided. In the same vein, files must not be downloaded in the working directory, they should be deleted in a controlled location. In most cases, this location is `USR_BIN_FOLDER`.

#### Structural
* The software that is manually installed is put under `USR_BIN_FOLDER`, which by default points to `~/.bin`. `~/.bin` is always **present**.
* Shell features are not installed directly into `~/.bashrc`, instead, there is always present the file `~/.bash_functions`, which is a file imported by `~/.bashrc`. In `~/.bash_functions`, you can write imports to individual scripts that provide a feature to the shell environment. Usually those scripts are stored under `~/.bin/bash_functions/`, which is a location always present. So the generic way to include new content to `~/.bashrc` is writing a script to `~/.bin/bash_functions` and including it in `~/.bash_functions/`.
* Soft links to include a program in the path are created under `~/.local/bin` which is a directory that is assured to be in the PATH 
* Files or folders created as root need to change their permissions and also its group and owner to the `${SUDO_USER}` using chgrp and chown
* console features are not installed directly in bashrc; instead use the structure provided by the customizer using .bash_functions
* Code lines length is 120 maximum. Lines with more characters need to be split in many. Some exceptions may apply, for example when defining vars that contain links.

#### Behavioural
* Each feature is expected to be executed with certain permissions (root / normal user). So the script will skip a feature that needs to be installed with different permissions from the ones that currently has.
* Relative PATHs are forbidden. We must not use the given working directory  
* No unprotected `cd` commands. `cd` must be avoided and never change the working directory given from the outside, that is why they must be called from the inside of a subshell if present. 
* wget is always used with the `-O` flag, which is used to change the name of the file and / or select a destination for the download.
* tar is always used in a subshell, cd'ing into an empty directory before the tar, so the pwd givento the script is not changed
* no `apt`, the default way to install package in script is `apt-get`
* Only in special cases use echo directly to print to stdout. In most cases you need to use `output_proxy_executioner`
* desktop launchers created manually have to be created in the desktop and also in the user launchers folder
* desktop launchers created manually as root have to be in the desktop and also in the all users launchers folder
* All `ln`s are created with the option -f, to avoid collision problems.
#### Syntactical
* All variables must be expanded by using `${VAR_NAME}` (include the brackets) except for the special ones, like `$#`, `$@`, `$!`, `$?`, etc.
* All variables must be protected by using "" to avoid resplitting because of spaces, despite, customizer is not emphasized to work with spaces in its variables. Spaces are *evil* and are not considered.
* There is one blankline between functions in the same block. There is two blanklines between blocks.
* Indent is always 2 spaces and never TAB.
* The used package manager by default is apt-get, which is actually the recommended way to use `apt` through scripts.
* using ~ or $HOME instead of HOME_FOLDER


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
- [X] rar / unrar - zip / unzip (also integrate in extract func)
- [x] Red prompt for warning and error messages
- [x] Optimize history to be updated in real-time and share the same hsitory between folders (export PROMPT_COMMAND='history -a; history -r') Also change filesize
- [x] Anydesk
- [x] Put Path declaration in common data, as a bash function  
- [x] Add final & to alias of gitk  (git_aliases), pluma, VS code,  so is always launched in background
- [x] Apply rule: no apt, the default way to install package in script is apt-get
- [x] Change the default storing place for wallpapers. change from ~/Images to ~/Images/wallpapers or in a folder in $USR_BIN_FOLDER
- [x] Write date in all the messages that the customizer outputs (warning, info etc)
- [x] Fusion create links in path with download and decompress
- [x] Autofirma
- [x] AutoUpdate and construct README
- [x] L Function
- [x] Add folder to store icons for .desktop files --> `created add_internet_shortcut`
- [x] Internet shortcut icons are broken because are downloaded into google-chrome folder --> Parametrized using indirect variable expansion, and adding parametrized line of Icon and exec in the launcher
- [x] Change `google-chrome` for `xdg-open`  on internet shortcut. Delete `${program_name}_url` and put it hardcoded inside of each desktop launcher
- [ ] Replicate most of the necessary structures and data to adapt `uninstall.sh` to the new specs
- [ ] Program function in `uninstall.sh` to remove bash functions
- [ ] Program function to remove desktop icons from the bar's favorite in `uninstall.sh`
- [ ] Move all argument processing to the same data structure that we are using for storing info about the programs. This is in order to reduce the steps needed to implement a program an autogenerate a README.md table
- [ ] Add special func in `uninstall` that uninstalls the file structures that the customizer creates (~/.bash_functions, ~/.bin, etc.) That cannot be removed directly using uninstall
- [ ] Program function to unregister default opening applications on `uninstall.sh`
- [ ] Call add_program matching against table in `common_data.sh` --> move all arguments to `common_data.sh` table and ensure there's no collision with separators.

#### Axel
- [x] Delete / rearrange arguments of one letter
- [x] Use the same fields in the same order in launchers: Name, GenericName, Type, Comment, Categories=IDE;Programming;, Version, StartupWMClass, Icon, Exec, Terminal, StartupNotify, MimeType=x-scheme-handler/tg;, Encoding=UTF-8
- [x] Refactor of data table in README.md
- [x] Youtube-dl
- [x] Create escape function, which returns an escaped sequence of characters
- [x] net-tools
- [x] Eclipse
- [x] Zoom
- [x] Geogebra
- [x] docker 
- [x] Spotify
- [x] Teams
- [x] Create variable in shortcut functions that tells out public IP
- [x] communication: skype (wget https://go.skype.com/skypeforlinux-64.deb)
- [x] Change default Screenshots folder to /home/user/Images/screenshots/
- [x] Internet shortcut launchers: Gapps, Netflix, OneDrive, Outlook, GitHub, Overleaf...
- [x] INTERNET SHORTCUT BUG: delete lines of Exec and Icon in all launchers of internet desktop launchers  
- [ ] Add aliases in `install_git-aliases` of `fetch` as `git fetch`, `status` as `git status`, `commit` as a function that controlls the message etc...
- [ ] Add desktop internet shortcuts for https://twitch.tv/, https://facebook.com/, https://twitter.com/, https://instagram.com/, https://discord.com/channels/, Telegram Web (https://web.telegram.org/, version X, version Z), https://open.spotify.com/ ...
- [ ] Split git aliases in many functions (alias_gitk, function_dummycommit, gitprompt added in prompt...)
- [ ] sysmontask
- [ ] Screenshots Keyboard combination set to the same as for windows or similar (Windows+Shift+s)
- [ ] fslint (duplicate finder graphical)
- [ ] fdups  (duplicate finder CLI)
- [ ] PacketTracer  
- [ ] CMake
- [ ] evolution (sudo apt-get install aspell-es aspell-ca # for different spellings in evolution)  
- [ ] Rsync and grsync (graphical)
- [ ] GNOME Tweak tools
- [ ] Synaptics
- [ ] sherlock
- [ ] SublimeText-Markdown, & other plugins for programs...
- [ ] Fonts


## Currently developing/refactoring features

#### TO-DO
- [ ] Autoinstall nvidia drivers
- [ ] Apply rule: all variables should be declared with the needed scope and its write/read permissions (local -r)
- [ ] Add examples (images) of a working environement after applying the customizer in Linux
- [ ] help message: arguments refactor with format
- [ ] customizer.sh help, customizer install, customizer uninstall, customizer parallell [install| uninstall]


#### Coming features
- [ ] Why some programs such as pycharm can not be added to favourites from the task bar? (related to launchers and how executables are related to launchers)
- [ ] create a unique endpoint for all the code in customizer customizer.sh which accepts the arguments install uninstall for the recognized features and make the corresponding calls to sudo uninstall.sh ..., sudo install.sh ... And Install.sh ...
- [ ] When having this unique endopint, if an argument is provided but not recognized, customizer will try luck by using apt-get to install it
- [ ] Create high-level wrappers for a set of features, such as "minimal", "custom", "git_customization" etc. in this new endpoint
- [ ] Create or integrate loc function bash feature which displays the lines of code of a script  
- [ ] Create cloud-init file to run customizer with a certain wrapper for a VM automatic customization (thanks to José Ángel Morena for the idea)
- [ ] refactor extract function: more robustness and error handling. decompress in a folder
- [ ] Flatten function, which narrows branches of the file system by deleting a folder that contains only another folder.
- [ ] Python Script to store and auto-generate all user's static data
- [ ] May be possible to achieve a post configuration install to nemo-desktop ? to add some customization such as the rendering thumbnails of images depending on the size

#### Discarded for now
- [ ] Automount available drives.
- [ ] Automatic Backup Recovery
- [ ] Accounting program: GNUCash
- [ ] music edition: rosegarden, Ardour, LMMS
- [ ] desktop access: Remmina, TeamViewer
- [ ] Games: Freeciv
- [ ] Photo organizer: Shotwell  
- [ ] handbreak: format editing tool  
- [ ] terminal: guake
- [ ] cd/dvd burning: brasero
- [ ] iso customization: Remastersys, UNetbootin
- [ ] image edition: Blender3D, Agave (sudo apt-get instal agave)
- [ ] download manager: Axel
- [ ] virtualization: Wine 5.0, kubernetes
- [ ] Oracle SQL Developer: link not downloadable via wget thanks to Oracle (https://www.oracle.com/webapps/redirect/signon?nexturl=https://download.oracle.com/otn/java/sqldeveloper/sqldeveloper-20.4.1.407.0006-no-jre.zip)
- [ ] System administration: 
  * bacula (system network administrator), 
  * Mdadm (raid manager)
  * PuTTY (ssh client), 
  * glpi (info organization) uses LAMP
  * samba (windows-linux file sharing)
  * Dbeaver (database manager)
  * HardInfo (Benchmark tool)
  * Hidra /Ghidra /THCHydra (logon cracker)
  * Snort
  * Hashcat
  * Pixiewps
  * Fern Wifi Cracker
  * gufw
  * WinFF
  * chkrootkit
  * rkhunter
  * Yersinia
  * Maltego
  * GNU MAC Changer
  * Burp Suite
  * BackTrack
  * John the Ripper
  * aircrack-ng
  * nmap   zenmap (nmap gui)
  * gobuster
  * metasploit (https://apt.metasploit.com/)
  * aircrack-ng
The security apps must be the last to install because they are the less necessary ones, usually they have problems because it is software from the community and also this type of software is all included in Linux distros such as Kali Linux 

# This is a docker run, not a customizer function
Moodle
Wordpress
LAMP stack web server
LDAP, LDAP Account Manager, PHPLDAPADMIN (sudo apt-get -y install phpldapadmin)
Apache Directory Studio
MySQL Server instance
FOG Server
ProxMox
Nessus
PLEX Media Server
OCSInventory
OnCloud
Odoo
VNCServer


```

## Original L function. Needs refactor
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

```

#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer data of features.                                                                      #
# - Description: A set of programs, functions, aliases, templates, environment variables, wallpapers, desktop          #
# features... collected in a simple portable shell script to customize a Linux working environment.                    #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 16/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernández Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when   #
# logged as root) to install some of the features.                                                                     #
# - Arguments: Accepts behavioural arguments with one hyphen (-f, -o, etc.) and feature selection with two hyphens     #
# (--pycharm, --gcc).                                                                                                  #
# - Usage: Installs the features given by argument.                                                                    #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


############################
##### COMMON VARIABLES #####
############################

### EXPECTED VARIABLE CONTENT (BY-DEFAULT) ###

# PERSONAL_LAUNCHERS_DIR: /home/username/.local/share/applications
# ALL_USERS_LAUNCHERS_DIR: /usr/share/applications
# HOME_FOLDER: /home/username
# USR_BIN_FOLDER: /home/username/.bin
# BASHRC_PATH: /home/username/.bashrc
# DIR_IN_PATH: /home/username/.local/bin
# HOME_FOLDER: /home/username
# BASH_FUNCTIONS_FOLDER: /home/username/.bin/bash-functions
# BASH_FUNCTIONS_PATH: /home/username/.bin/bash_functions/.bash_functions

# Imported from ${HOME}/.config/user-dirs.dirs
# XDG_DESKTOP_DIR: /home/username/Desktop
# XDG_PICTURES_DIR: /home/username/Images
# XDG_TEMPLATES_DIR: /home/username/Templates

### VARIABLE DECLARATION ###

if [[ "$(whoami)" != "root" ]]; then
  # Path pointing to $HOME
  HOME_FOLDER=${HOME}

  # Declare lenguage specific user environment variables (XDG_DESKTOP_DIR, XDG_PICTURES_DIR, XDG_TEMPLATES_DIR...)
  source ${HOME_FOLDER}/.config/user-dirs.dirs
else
  # Path pointing to $HOME
  HOME_FOLDER=/home/${SUDO_USER}

  # Declare lenguage specific user environment variables (XDG_DESKTOP_DIR, XDG_PICTURES_DIR, XDG_TEMPLATES_DIR...)
  # This declaration is different from the analogous one in the previous block because $HOME needs to be substituted
  # for /home/$SUDO_USER to be interpreted correctly as a root user.
  declare $(cat ${HOME_FOLDER}/.config/user-dirs.dirs | sed 's/#.*//g' | sed "s|\$HOME|/home/$SUDO_USER|g" | sed "s|\"||g")
fi

# Path pointing to a directory that is included in the PATH variable
DIR_IN_PATH=${HOME_FOLDER}/.local/bin
# Path pointing to a folder that contains the desktop launchers for the unity application launcher of the current user
PERSONAL_LAUNCHERS_DIR=${HOME_FOLDER}/.local/share/applications
# Path pointing to .bashrc file of the user
BASHRC_PATH=${HOME_FOLDER}/.bashrc
# Folder where all the software will be installed
USR_BIN_FOLDER=${HOME_FOLDER}/.bin
# Path pointing to .bash_functions, which is the file used to control the installed features of the customizer
BASH_FUNCTIONS_PATH=${USR_BIN_FOLDER}/bash-functions/.bash_functions
# Path pointing to the folder containing all the scripts of the bash functions
BASH_FUNCTIONS_FOLDER=${USR_BIN_FOLDER}/bash-functions
# Path pointing to a folder that contains the desktop launchers of all users
ALL_USERS_LAUNCHERS_DIR=/usr/share/applications
# File that contains the association of mime types with .desktop files
MIME_ASSOCIATION_PATH=${HOME_FOLDER}/.config/mimeapps.list
# Default favorites list, data to set favorites
PROGRAM_FAVORITES_PATH="${BASH_FUNCTIONS_FOLDER}/favorites.txt"
# Default user's fonts folder
FONTS_FOLDER=${HOME_FOLDER}/.fonts
# Here we store the .desktop launchers of the programs we want to autostart
AUTOSTART_FOLDER=${HOME_FOLDER}/.config/autostart


# The variables that begin with FLAG_ can change the installation of a feature individually. They will continue holding
# the same value until the end of the execution until another argument
FLAG_OVERWRITE=0     # 0 --> Skips a feature if it is already installed, 1 --> Install a feature even if it is already installed
FLAG_INSTALL=1       # 1 or more --> Install the feature provided to add_program. 0 --> DO NOT install the feature provided to add_program
# Also, flag_install is the number used to determine the installation order
FLAG_QUIETNESS=1     # 0 --> verbose mode, 1 --> only shows echoes from main script, 2 --> no output is shown
FLAG_IGNORE_ERRORS=0 # 1 --> the script will continue its execution even if an error is found. 0 --> Abort execution on error
NUM_INSTALLATION=1  # Used to perform the (un)installation in the same order that we are receiving arguments. Also, keeps the order even if we use --no, because we need a temporal
FLAG_UPGRADE=1  # 0 --> no update, no upgrade; 1 --> update, no upgrade; 2 --> update and upgrade
FLAG_AUTOCLEAN=2  # Clean caches after installation. 0 --> no clean; 1 --> perform autoremove; 2 --> perform autoremove and autoclean
FLAG_FAVORITES=0  # 0 --> does nothing; 1 --> sets the program to favourites if there is a desktop launcher
FLAG_MODE=  # Tells if code is running under install.sh or under uninstall.sh, 1 or 0, respectively


### FEATURE_DATA ###

# This pseudo-matrix contains different information for every feature available in this project.
# * The first values of the two cells delimited with ; in each row are used to store dynamically the arguments desired
#   for that function.
#   - The first field contains all the arguments to call the program delimited with "|". It is very important to know
#     that the first argument without the -- is a string that is also matched against a installing function in install
#     or the corresponding variables in data_features.sh. Also, The name of the first argument without the -- is
#     expected to be the binary used to detect if there is an installation present.
#   - The second argument that now is a bit (0 or 1) between semicolons is the permissions needed to install each
#     program. It is going to be changed to the installation type soon.
#     Its format: 0 for user permissions, 1 for root permissions, 2 for indiferent. Soon will be the installationtype,
#     such as "packagemanager"
#   - In this each of the field of installation_data we would find other data during the runtime, since the rest of
#     the data is removed.
#   - Also other numeric data is added to store the desired behavioural flags for each program, such as:
#     1.- If we are actually going to install the program.
#     2.- If we should (or not) abort when finding errors.
#     3.- What level of standard output is desired for that feature: 0 verbose, 1 quiet (only informative prints), 2 totally quiet
#     4.- If we should reinstall the feature or not when we find that the desired feature already installed.
#     install_yes/no; forceness; quietness; overwrite; permissions; function_name
#   - The rest
installation_data=(
  "--a;0;| alias | Prints a list of aliases using \`compgen -a\` | Command \`a\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--add;0;| add | alias for \`git add\` | Command \`add\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--aisleriot|--solitaire|--Solitaire|--gnome-solitaire;1;| Solitaire aisleriot | Implementation of the classical game solitaire | Command \`aisleriot\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--alert|--alert-alias|--alias-alert;0;| Function \`alert\` | Alias to show a notification at the end of a command | Alias \`alert\`. Use it at the end of long running commands like so: \`sleep 10; alert\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--ant|--apache_ant|--apache-ant;0;| Apache Ant | Software tool for automating software build processes | Command \`ant\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |"
  "--ansible;1;| Ansible | Automation of software | Command \`ansible\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--anydesk;0;| Anydesk | Software to remote control other computers | Command \`anydesk\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--aspell;1;| Aspell | Spell checker | Command \`aspell\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--atom|--Atom;1;| Atom | Text and source code editor | Command \`atom\`, desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--audacity|--Audacity;1;| Audacity | Digital audio editor and recording | Command \`audacity\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--AutoFirma|--autofirma;1;| AutoFirma | Electronic signature recognition | Command \`AutoFirma\` and desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--axel|--Axel;1;| Axel | Download manager | Command \`axel\` and desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--b|--b-alias;0;| Function \`b\` | Alias for \`bash\` | Alias \`b\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--bashcolors;0;| bashcolors | bring color to terminal | Command \`bashcolors\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--bi;0;| Function Fix broken install | alias for \`(sudo apt --fix-broken install)\` | Command \`bi\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--branch;0;| Function \`branch\` | alias for \`git branch -vv\` | Command \`branch\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--brasero;1;| Brasero | Software for image burning | Command \`brasero\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--c;0;| Function \`c\` | Function \`c\` that changes the directory or clears the screen | Function \`c \` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--caffeine|--Caffeine|--cafe|--coffee;1;| Caffeine | Simple indicator applet on Ubuntu panel that allows to temporarily prevent the activation of the screensaver, screen lock, and the “sleep” power saving mode. | Commands \`caffeine\`, \`caffeinate\` and \`caffeine-indicator\`, desktop launcher for \`caffeine\`, dashboard launcher for \`caffeine\` and \`caffeine-indicator\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--calibre|--Calibre|--cali;1;| Calibre | e-book reader| Commmand \`calibre\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--change-bg|--wallpapers|--Wallpapers;0;| Function \`change-bg\` | Function that changes the wallpaper using one random image from user images folder. It also downloads wallpapers and installs a cronjob to change the wallpaper every 5 minutes | Function \`change-bg\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--cheat|--cheat.sh|--Cheat.sh|--che;0;| cheat.sh | Provides access to community-driven cheat sheets and snippets for Linux/UNIX commands and many programming languages | Command \`cheat\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--checkout;0;| Function \`checkout\` | alias for \`git checkout\` | Command \`checkout\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--cheese|--Cheese;1;| Cheese | GNOME webcam application | Command \`cheese\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--clementine|--Clementine;1;| Clementine | Modern music player and library organizer | Command \`clementine\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--clion|--Clion|--CLion;0;| Clion | Cross-platform C/C++ IDE | Command \`clion\`, silent alias \`clion\`, desktop launcher, dashboard launcher, associated with mimetypes \`.c\`, \`.h\` and \`.cpp\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--clonezilla|--CloneZilla|--cloneZilla;1;| CloneZilla | Disk cloning, disk imaging, data recovery, and deployment | Command \`clonezilla\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--cmatrix|--Cmatrix;1;| Cmatrix | Terminal screensaver from The Matrix | Command \`cmatrix\`, function \`matrix\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--code|--visualstudiocode|--visual-studio-code|--Code|--visualstudio|--visual-studio;0;| Visual Studio Code | Source-code editor | Command \`code\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--codeblocks;1;| Code::Blocks | IDE for programming  | Command \`codeblocks\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--converters|--Converters;0;| Converters | Set of converter Python scripts that integrate in your environment as \`bash\` commands | Commands \`bintodec\`, \`dectobin\`, \`dectohex\`, \`dectoutf\`, \`escaper\`, \`hextodec\`, \`to\` and \`utftodec\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--commit;0;| Function \`commit\` | Function \`commit\` that makes \`git commit -am \"\$1\"\` | Function \`commit\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--copyq|--copy-q|--copy_q|--copqQ|--Copyq|--copy-Q;1;| copyq | A clipboard manager application that comes with extra features such as editing and scripting | Command \`copyq\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--curl|--Curl;1;| Curl | Curl is a CLI command for retrieving or sending data to a server | Command \`curl\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--dbeaver;1;| DBeaver | SQL Client IDE | Command \`dbeaver\` desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--dconf-editor;1;| dconf-editor | Editor settings | Command \`dconf-editor\` and desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--default-jdk|--jshell;1;| jshell | Default Java Environment   | Command \`jshell\` for developers || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--dia|--Dia;1;| Dia | Graph and relational  | Command \`dia\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--discord|--Discord|--disc;0;| Discord | VoIP, instant messaging and digital distribution | Command \`discord\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--docker|--Docker;0;| Docker | Containerization service | Command \`docker\`, \`containerd\`, \`containerd-shim\`, \`containerd-shim-runc-v2\`, \`ctr\`, \`dockerd\`, \`docker-init\`, \`docker-proxy\`, \`runc\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--document|--google-document;0;| Document | Google Document opening in Chrome | Command \`document\` and desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--dummycommit;0;| Function dummycommit | Do the following commands \`git add -a\` \`git commit -am \$1\` \`git push\` | Command \`dummycommit\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--drive|--GoogleDrive|--Drive|--google-drive|--Google-Drive;0;| Google Drive | Google Drive opening in Chrome | Command \`drive\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--dropbox|--Dropbox|--DropBox|--Drop-box|--drop-box|--Drop-Box;1;| Dropbox | File hosting service | Command \`dropbox\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--duckduckgo|--DuckDuckGo;0|| DuckDuckGo | Opens DuckDuckGo in Chrome | Command \`duckduckgo\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--e;0;| Function \`e\` | Multi Function \`e\` to edit a file or project in folder | Function \`e\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--eclipse|--Eclipse;0;| Eclipse | IDE for general purpose programming | Command \`eclipse\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--extract|--extract-function|--extract_function;0;| Function \`extract\` | Function to extract from a compressed file, no matter its format | Function \`extract \"filename\"\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--evolution|--Evolution;1;| evolution | User calendar agend, planning | Command \`evolution\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--f-irc|--firc|--Firc|--irc;1;| f-irc | CLI IRC client | Command \`f-irc\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--facebook|--Facebook;0;| Facebook| Opens Facebook in Chrome | Command \`facebook\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--fdupes;1;| Fdupes| Searches for duplicated files within given directories | Command \`fdupes\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--fetch;0;| fetch| \`git fetch\`| Command \`fetch\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--ffmpeg|--youtube-dl-dependencies;1;| ffmpeg | Super fast video / audio encoder | Command \`ffmpeg\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--firefox|--Firefox;1;| Firefox | Free web browser | Command \`firefox\`, desktop launcher, dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--fonts-firacode|--fonts-firacode;1;| fonts-firacode | Installs font | Install firacode font ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--fonts-hack|--fonts-hack;1;| fonts-hack | Installs font | Install hack font ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--fonts-hermit|--fonts-hermit;1;| fonts-hermit | Installs font | Install hermit font ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--fonts-roboto|--fonts-roboto;1;| fonts-roboto | Installs font| Install roboto font ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--fonts-alegreya-sans|--alegreya_sans;0;| fonts-alegreya_sans | Installs font | Install alegreya font || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--fonts-lato;0;| fonts-lato | Installs font | Install lato font || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--fonts-oswald;0;| fonts-oswald | Installs font| Install oswald font || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--fonts-oxygen;0;| fonts-oxygen | Installs font | Install oxygen font || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--fonts-noto-sans|--noto_sans;0;| fonts-noto_sans | Installs font| Install noto_sans font || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--forms|--google-forms;0;| Forms | Google Forms opening in Chrome | Command \`forms\`, desktop launcher, dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--freecad|--FreeCAD|--freeCAD;1;| FreeCAD | General-purpose parametric 3D computer-aided design modeler and a building information modeling | Command \`freecad\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--g|--gitk-alias;0;| Function g | \`g\` is an alias for gitk | Function \`g\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gcc|--GCC;1;| GNU C Compiler | C compiler for GNU systems | Command \`gcc\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--geany|--Geany;1;| Geany | Lightweight GUI text editor using Scintilla and GTK, including basic IDE features | Command \`geany\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--geogebra|--geogebra-classic-6|--Geogebra-6|--geogebra-6|--Geogebra-Classic-6|--geogebra-classic;0;| GeoGebra | Geometry calculator GUI | Command \`geogebra\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--ghostwriter|--Ghostwriter|--GhostWriter;1;| GhostWriter | Text editor without distractions. | Command \`ghostwriter, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gimp|--GIMP|--Gimp;1;| Gimp | Raster graphics editor used for image manipulation and image editing, free-form drawing, transcoding between different image file formats. | Command \`gimp\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--git;1;| git | Software for tracking changes in any set of files, usually used for coordinating work among programmers collaboratively developing source code during software development | Command \`git\` and \`gitk\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--github|--Github|--GitHub;1;| GitHub | GitHub opening in Chrome | Command || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gitk|--Gitk|--Git-k;1;| Gitk | GUI for git | Command \`gitk\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gitlab|--GitLab|--git-lab;0;| GitLab | Gitlab opening in Chrome | Command || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gitprompt|--git-prompt;1;| gitprompt | Special prompt in git repositories | Command \`gitprompt\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gmail|--Gmail;0;| Gmail | Gmail opening in Chrome | Command \`gmail\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gnat-gps|--gnat-programming-studio|--gnat-ps|--gnatps|--gnatgps;1;| GNAT | Programming Studio for Ada and C | Command \`gnat-gps\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gnome-calculator|--GNOME_Calculator|--gnomecalculator|--calculator;1;| Calculator | GUI calculator| Commmand \`calculator\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gnome-chess|--GNOME_Chess|--gnomechess|--chess;1;| Chess | Plays a full game of chess against a human being or other computer program | Command \`gnome-chess\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gnome-mahjongg|--mahjongg|--Mahjongg;1;| Mahjongg | Implementation for GNU systems of the famous popular chinese game Mahjongg | Command \`gnome-mahjongg\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gnome-mines|--mines|--Mines|--GNU-mines|--gnomemines;1;| Mines | Implementation for GNU systems of the famous game mines | Command \`gnome-mines\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gnome-sudoku|--sudoku|--Sudoku;1;| sudoku | Implementation for GNU systems of the famous popular mathematical game sudoku | Command \`gnome-sudoku\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gnome-terminal|--terminal|--Terminal;1;| GNOME terminal | Terminal of the system | Command \`gnome-terminal\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gnome-tweak-tool|--gnome-tweaks|--gnome-tweak|--gnome-tweak-tools|--tweaks;1;| GNOME Tweaks | GUI for system customization | command and desktop launcher... ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--googlecalendar|--Google-Calendar|--googlecalendar;0;| Google Calendar | Google Calendar opening in Chrome | Command \`googlecalendar\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--google-chrome|--chrome|--Chrome|--Google-Chrome;1;| Google Chrome | Cross-platform web browser | Command \`google-chrome\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gpaint|--paint|--Gpaint;1;| Gpaint | Raster graphics editor similar to Microsoft Paint | Command \`gpaint\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gparted|--GParted|--GPARTED|--Gparted;1;| GParted | Creating, deleting, resizing, moving, checking, and copying disk partitions and their file systems | Command \`gparted\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--h;0;| Function \`h\` | Search in your history for previous commands entered, stands by \`history | grep \"\$@\"\` | Command \`h\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--gvim|--vim-gtk3|--Gvim|--GVim;1;| Gvim | Vim with a built-in GUI | Command \`gvim\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--handbrake;1;| Handbrake | Video Transcoder | Command \`handbrake\`, Desktop and dashboard launchers || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--hard;0;| Function hard | alias for \`git reset HEAD --hard\` | <-- || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--hardinfo;1;| Hardinfo | Check pc hardware info | Command \`hardinfo\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--history-optimization;0;| history optimization | Increased the size of bash history, store multiline commands in just one line, force append and not overwrite to history, ignore repeated commands when appending to history, deleted tracking history of some simple commands: \`ls\`, \`cd\`, \`gitk\`... | <-- || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--ideac|--intellijcommunity|--intelliJCommunity|--intelliJ-Community|--intellij-community;0;| intelliJ Community | Integrated development environment written in Java for developing computer software | Command \`ideac\`, silent alias for \`ideac\`, desktop launcher, dashboard launcher and association to \`.java\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |"
  "--ideau|--intellijultimate|--intelliJUltimate|--intelliJ-Ultimate|--intellij-ultimate;0;| intelliJ Ultimate | Integrated development environment written in Java for developing computer software | Command \`ideau\`, silent alias for \`ideau\`, desktop launcher, dashboard launcher and association to \`.java\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |"
  "--ijs;0;| iJavaScript | JavaScript kernel for jupyter ecosystem | Command \`ijs\`files || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--inkscape|--ink-scape|--Inkscape|--InkScape;1;| Inkscape | Vector graphics editor used to create vector images, primarily in Scalable Vector Graphics format | Command \`inkscape\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--instagram|--Instagram;0;| Instagram | Opens Instagram in Chrome | Command \`instagram\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--ipe|--ipe-function;0;| ipe function | Returns the public IP | Command \`ipe\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--ipi|--ipi-function;0;| ipi function | Returns the private IP | Command \`ipi\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--iqmol|--IQmol;1;| IQmol | Program to visualize molecular data | Command \`iqmol\`, silent alias, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--j;0;| Function jobs | alias for jobs -l | Commands \`j\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--java|--javadevelopmentkit|--java-development-kit|--java-development-kit-11|--java-development-kit11|--jdk|--JDK|--jdk11|--JDK11|--javadevelopmentkit-11;0;| Java Development Kit 8 | Implementation of version 8 of the Java (programming language) SE Platform | Commands \`java\`, \`javac\` and \`jar\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--julia|--Julia;0;| Julia and IJulia| Programming language | Commands \`julia\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--jupyter-lab|--jupyter-notebook|--jupyter;0;| Jupyter Lab | IDE with a lot of possible customization and usable for different programming languages.| alias \`lab\`, commands \`jupyter-lab\`, \`jupyter-lab\`, \`ipython\`, \`ipython3\`, desktop launcher and dashboard launcher. Recognized programming languages: Python, Ansible, Bash, IArm, Kotlin, PowerShell, Vim. || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--k;0;| Function k | \`Function for killing processes kill -9\` | Command \`k\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--keep|--google-keep|--Keep|--Google-Keep|--googlekeep;0;| Google Keep | Google Keep opening in Chrome | Command \`keep\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--latex|--LaTeX|--tex|--TeX;1;| LaTeX | Software system for document preparation | Command \`tex\` (LaTeX compiler) and \`texmaker\` (LaTeX IDE), desktop launchers for \`texmaker\` and LaTeX documentation ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--libgtkglext1|--anydesk-dependencies;1;| libgtkglext1 | Anydesk dependency | Used when Anydesk is run ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--libkrb5-dev|--kerberos-dependencies;1;| libkrb5-dev | Kerberos dependency | Used when Jupiter Lab is run ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--libxcb-xtest0;1;| libxcb-xtest0 | Zoom dependency | Used when Zoom is run ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--lolcat;1;| lolcat | Same as the command \`cat\` but outputting the text in rainbow color and concatenate string | command \`lolcat\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--lol;0;| Function lol | alias to \`lolcat\`  | command \`lol\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--L|--L-function;0;| Function \`L\` | Function that lists files in a directory, but listing the directory sizes | Function \`L\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--l|--alias-l|--alias-ls|--l-alias|--ls-alias;0;| Function \`l\` | alias for \`ls\` | command \`l\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--lab;0;| \`lab\` | alias for \`jupyter-lab\` | command \`lab\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--mdadm;1;| mdadm | Manage RAID systems | Command \`mdadm\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--megasync|--Mega|--MEGA|--MegaSync|--MEGAsync|--MEGA-sync|--mega;1;| MegaSync | Synchronises folders between your computer and your MEGA Cloud Drive | Command \`megasync\`, desktop launcher, dashboard launcher and integration with \`nemo\` file explorer ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--mendeley-dependencies|--MendeleyDependencies|--mendeleydependencies|--mendeleydesktopdependencies|--mendeley-desktop-dependencies|--Mendeley-Desktop-Dependencies;1;| MendeleyDependencies | Installs Mendeley Desktop dependencies \`gconf2\`, \`qt5-default\`, \`qt5-doc\`, \`qt5-doc-html\`, \`qtbase5-examples\` and \`qml-module-qtwebengine\` | Used when installing Mendeley and other dependent software || <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |   "
  "--mendeley|--Mendeley|--mendeleyDesktop|--mendeley-desktop|--Mendeley-Desktop;0;| Mendeley | It is most known for its reference manager which is used to manage and share research papers and generate bibliographies for scholarly articles | Command \`mendeley\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--mvn|--maven;0;| Maven | Build automation tool used primarily for Java projects | Command \`mvn\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |"
  "--nautilus;1;| Nautilus | Standard file and desktop manager | Command \`nautilus\` Desktop launcher and dashboard launcher for the file manager ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--nedit|--NEdit|--Nirvana-Editor|--nirvanaeditor|--nirvana|--Nirvana|--nirvana-editor;1;| NEdit | Multi-purpose text editor and source code editor | Command \`nedit\` desktop launcher, dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--nemo|--nemo-desktop|--Nemo-Desktop|--Nemodesktop|--nemodesktop|--Nemo|--Nemodesk|--NemoDesktop;1;| Nemo Desktop | File and desktop manager, usually with better options and less bugs than nautilus. *We recommend this explorer to view correctly the launchers* | Command \`nemo\` for the file manager, and \`nemo-desktop\` for the desktop manager service. Desktop launcher and dashboard launcher for the file manager ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--net-tools|--nettools;1;| net-tools | GUI network interfaces. *We recommend this explorer to view correctly the launchers* | Command \`net-tools\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--netflix|--Netflix;0;| Netflix | Netflix opening in Chrome | Command \`netflix\`. Desktop launcher and dashboard launcher for the file manager ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |;| Netflix | Netflix opening in Chrome | Command \`netflix\`. Desktop launcher and dashboard launcher for the file manager | --netflix --Netflix |  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--nvidia-drivers|--ubuntu-drivers|--autoinstall;1;| nvidia-drivers | Auto-install nvidia drivers in ubuntu | Drivers || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--node;0;| NodeJS npm and npx | JavaScript for the developers. | Command \`node\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--notebook;0;| Jupyter Notebook alias | alias for opening \`jupyter notebook\` | Alias \`notebook\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--notepadqq|--Notepadqq|--notepadQQ|--NotepadQQ|--notepadQq|--notepadQq|--NotepadQq|--NotepadqQ;1;| Notepadqq | Text editor that is designed by developers for the developers. It supports more than 100 programming languages | Command \`notepadqq\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--obs-studio|--OBS|--obs|--obs_studio|--obs_Studio|--OBS_studio|--obs-Studio|--OBS_Studio|--OBS-Studio;1;| OBS | Streaming and recording program | Command \`obs\`, desktop launcher and dashboard launcher. ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--o|--o-function|--function-o;0;| Function \`o\` | Alias for \`nemo-desktop\` | Alias \`o\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--okular|--Okular|--okularpdf;1;| Okular | PDF viewer | Command \`okular\`, desktop launcher and dashboard launcher ||   <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--onedrive|--OneDrive|--one-drive|--One-Drive;0;| OneDrive | Microsoft OneDrive opening in Chrome | Command \`onedrive\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--openoffice|--office|--Openoffice|--OpenOffice|--openOfice|--open_office|--Office;1;| OpenOffice | Office suite for open-source systems | Command \`openoffice4\` in PATH, desktop launchers for \`base\`, \`calc\`, \`draw\`, \`math\` and \`writer\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--openssl102|--rstudio-dependencies;1;| openssl1.0 | RStudio dependency | Used for running rstudio ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--outlook|--Outlook;0;| Outlook | Microsoft Outlook e-mail opening in Chrome | Command \`outlook\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--overleaf|--Overleaf;0;| Overleaf | Online LaTeX editor opening in Chrome | Command \`overleaf\`, desktop launcher and dashboard launcher ||   <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--pacman|--pac-man;1;| Pac-man | Implementation of the classical arcade game | Command \`pacman\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--parallel|--gnu_parallel|--GNUparallel|--GNUParallel|--gnu-parallel;1;| GNUparallel | Command-line driven utility for Linux and other Unix-like operating systems which allows the user to execute shell scripts or commands in parallel | Command \`parallel\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--pdfgrep|--findpdf;1;| pdfgrep | CLI utility that makes it possible to search for text in a PDF file without opening the file | Command \`pdfgrep\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--pgadmin|--pgadmin4;0;| pgAdmin | PostgreSQL Tools | Command \`pgadmin4\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--php;1;| php | Programming language | Command \`php\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--pluma;1;| pluma | Fork of gedit 2.0 that supports many plugins and new features | Command \`pluma\`, desktop launcjer and dashboard launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--postman|--Postman;0;| Postman | Application to maintain and organize collections of REST API calls | Command \`postman\`, desktop launcher and dashboard launcher  ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--presentation|--google-presentation;0;| Presentation | Google Presentation opening in Chrome | Command \`presentation\`, desktop launcher and dashboard launcher||  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--prompt;0;| prompt | Installs a new colourful prompt on terminal window including and upgrading the default ones in Ubuntu | Adds a personalized prompt that shows the date, return code of last executed program, user, group and working directory. It also changes the prompt colour of introduced text to green. It changes the terminal windows title, adds colourful aliases and ensures completion || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--psql|--postgreSQL|--PostGreSQL|--postgresql|--postgre-sql|--postgre-SQL|--pSQL|--p-SQL|--p-sql;1;| PostGreSQL | Installs \`psql\`|  Command \`psql\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--pull;0;| \`pull\` | Alias for \`git pull\`|  Command \`pull\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--push;0;| \`push\` | Alias for \`git push\`|  Command \`push\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--pycharmpro|--pycharmPro|--pycharm_pro|--pycharm-pro|--Pycharm-Pro|--PyCharm-pro;0;| Pycharm Pro | Integrated development environment used in computer programming | Command \`pycharm-pro\`, silent alias for \`pycharm-pro\`, desktop launcher, dashboard launcher, associated to the mime type of \`.py\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--pycharm|--pycharmcommunity|--pycharmCommunity|--pycharm_community|--pycharm-community;0;| Pycharm Community | Integrated development environment used in computer programming | Command \`pycharm\`, silent alias for \`pycharm-pro\`, desktop launcher, dashboard launcher, associated to the mime type of \`.py\` files  || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--pypy3-dependencies|--dependencies|--pypy3Dependencies|--PyPy3Dependencies|--pypy3dependencies|--pypy3-dependencies;1;| pypy3_dependencies | Dependencies to run pypy3 | Libraries \`pkg-config\`, \`libfreetype6-dev\`, \`libpng-dev\` and \`libffi-dev\` used when deploying \`pypy\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--pypy3|--pypy|--PyPy3|--PyPy;0;| pypy3 | Faster interpreter for the Python3 programming language | Commands \`pypy3\` and \`pypy3-pip\` in the PATH || <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--python3|--python|--Python3|--Python;1;| Python3 | Interpreted, high-level and general-purpose programming language | Commands \`python\`, \`python3\`, \`pip3\` and Function \`v\` is for activate/deactivate python3 virtual environments (venv) can be used as default \`v\` as a command creates the /venv/ environment we can activate/deactivate new or existing virtual environments, command \`v namevenv\` creates /namevenv/ we can activate the virtual environment again using \`v namenv\` or deactivate same again, using \`v namenv\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--reddit|--Reddit;0;| Reddit | Opens Reddit in Chrome | Commands \`reddit\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--R|--r-base;1;| R | Programming language | Commands \`R\`, Dashboard Launcher, Desktop Launcher|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--remmina;1;| Remmina | Remote Desktop Contol | Commands \`remmina\`, Desktop launcher and Icon || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--rustc;1;| Rust | Programming Language | Installs \`rustc\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--rstudio;0;| RStudio | Installs \`rstudio\`, desktop launcher, dashboard launcher, default application for .R files | Commands \`rstudio\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--rsync|--Rsync|--grsync;1;| Grsync | Installs \`grsync\`, desktop launcher... | Commands \`grsync\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--s|--s-function;0;| Function \`s\` | Function to execute any program silently and in the background | Function \`s \"command\"\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--scala|--Scala;1;| Scala | Programming language | Command \`scala\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--screenshots|--Screenshots;0;| Screenshots | Takes a screenshot and saves it to custom ~/Images/screenshots folder | Commands \`screenshot-full\` \`screenshot-window\` \`screenshot-area\`||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--system-fonts;0;| Customize fonts | Changes system fonts to predefined ones downloadable with Customizer | Set custom fonts predefinedly || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--shortcuts;0;| shortcuts | Installs custom key commands | variables... (\$DESK...) || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--shotcut|--ShotCut|--Shotcut|--shot-cut|--shot_cut;1;| ShotCut | Cross-platform video editing | Command \`shotcut\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--shotwell|--ShotWell|--Shotwell |--shot-well|--shot_well;1;| Shotwell | Cross-platform video editing | Command \`shotwell\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--skype|--Skype;1;| Skype | Call & conversation tool service | Icon Launcher... ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--slack|--Slack;1;| Slack | Platform to coordinate your work with a team | Icon Launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--sonic-pi|--sonicpi|--sonic-Pi;1;| Sonic Pi | programming language that ouputs sounds as compilation product | Command \`sonic-pi\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--spotify|--Spotify;1;| Spotify | Music streaming service | Command \`spotify\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--spreadsheets|--google-spreadsheets;0;| Spreadsheets | Google Spreadsheets opening in Chrome | Command \`spreadsheets\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--status;0;| status | \`git status\` | Command \`status\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--steam|--Steam|--STEAM;1;| Steam | Video game digital distribution service | Command \`steam\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--studio|--android|--AndroidStudio|--androidstudio|--android-studio|--android_studio|--Androidstudio;0;| Android Studio | Development environment for Google's Android operating system | Command \`studio\`, alias \`studio\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--sublime|--sublimeText|--sublime_text|--Sublime|--sublime-Text|--sublime-text;0;| Sublime | Source code editor with an emphasis on source code editing | Command \`sublime\`, silent alias for \`sublime\`, desktop launcher, dashboard launcher, associated with the mime type of \`.c\`, \`.h\`, \`.cpp\`, \`.hpp\`, \`.sh\` and \`.py\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--synaptic|--Synaptic;1;| Synaptic | Package installation manager | Command \`synaptic\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--sysmontask|--SysMonTask;1;| Sysmontask | Control panel for linux | Command \`sysmontask\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--teamviewer|--TeamViewer|--viewer;1;| Team Viewer | Video remote pc control | Command \`teamviewer\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--teams|--Teams|--MicrosoftTeams;1;| Microsoft Teams | Video Conference, calls and meetings | Command \`teams\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--telegram|--Telegram;0;| Telegram | Cloud-based instant messaging software and application service | Command \`telegram\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--templates;0;| Templates | Different collection of templates for starting code projects: Python3 script (\`.py\`), Bash script (\`.sh\`), LaTeX document (\`.tex\`), C script (\`.c\`), C header script (\`.h\`), makefile example (\`makefile\`) and empty text file (\`.txt\`) | In the file explorer, right click on any folder to see the contextual menu of \"create document\", where all the templates are located || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--terminal-background|--terminal_background;0;| Terminal background | Change background of the terminal to black | Every time you open a terminal || <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--terminator|--Terminator;1;| Terminator | Terminal emulator for Linux programmed in Python | Command \`terminator\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--thunderbird|--mozillathunderbird|--mozilla-thunderbird|--Thunderbird|--thunder-bird;1;| Thunderbird | Email, personal information manager, news, RSS and chat client | Command \`thunderbird\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--tilix|--Tilix;1;| Tilix | Advanced GTK3 tiling terminal emulator | Command \`tilix\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--tmux|--Tmux;1;| Tmux | Terminal multiplexer for Unix-like operating systems | Command \`tmux\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--tomcat|--tomcat-server|--apache-tomcat;0;| Apache Tomcat 9.0.43 | Open-source server to run web apps written in Jakarta Server Pages | Tomcat available in \${USER_BIN_FOLDER} to deploy web apps || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li>|" 
  "--tor|--torbrowser|--tor_browser|--TOR|--TOR-browser|--TOR-BROSWER|--TORBROWSER|--TOR_BROWSER|--TOR_browser;1;| Tor browser | Software for enabling anonymous communication by directing Internet traffic. | Command \`tor\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--msttcorefonts|--microsoftfonts|--microsoft-fonts|--mscorefonts|--ttf-mscorefonts;1;| font Msttcorefonts | Windows classic fonts | Install mscore fonts ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--transmission-gtk|--transmission|--Transmission;1;| Transmission | A set of lightweight Torrent client (in GUI, CLI and daemon form) | Executable \`transmission\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--trello|--Trello;0;| Trello | Trello web opens in Chrome | Command \`trello\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--tumblr|--Tumblr;0;| Tumblr | Tumblr web opens in Chrome | Command \`tumblr\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--twitch|--Twitch|--twitchtv;0;| Twitch | Twitch web opens in Chrome | Command \`twitch\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--twitter|--Twitter;0;| Twitter | Twitter web opens in Chrome | Command \`twitter\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--u;0;| Function \`u\` | Opens given link in default web browser | Command \`u\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--uget;1;| uget | GUI utility to manage downloads | Command \`uget\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--virtualbox|--virtual-box|--VirtualBox|--virtualBox|--Virtual-Box|--Virtualbox;1;| VirtualBox | Hosted hypervisor for x86 virtualization | Command \`virtualbox\`, desktop launcher and dashboard launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--vlc|--VLC|--Vlc;1;| VLC | Media player software, and streaming media server | Command \`vlc\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--whatsapp|--Whatsapp;0;| Whatsapp Web | Whatsapp web opens in Chrome | Command \`whatsapp\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--wikipedia|--Wikipedia;0;| Wikipedia | Wikipedia web opens in Chrome | Command \`wikipedia\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--wireshark|--Wireshark;1;| Wireshark | Net sniffer | Command \`wireshark\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--youtube-dl;0;| youtube-dl | Download manager for video and audio from YouTube and over 1000 other video hosting websites. | Command \`youtube-dl\` in the PATH and alias \`youtube-wav\` to scratch a mp3 from youtube || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--youtubemusic|--youtube-music|--YouTubeMusic|--YouTube-Music|--Youtube-Music|--youtube-music;0;| Youtube Music | YouTube music opens in Chrome. | Command \`youtubemusic\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--youtube|--Youtube|--YouTube;0;| Youtube| YouTube opens in Chrome | Command \`youtube\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--zoom|--Zoom;0;| Zoom | Video Stram Calls | Command \`zoom\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
)

####################
##### WRAPPERS #####
####################

# Associates lists representing a wrapper containing a set of related features

programming_core=("python3" "gcc" "jdk11" "git" "GNU_parallel" "pypy3_dependencies")
programming_ide=("android_studio" "sublime_text" "pycharm" "intellij_community" "visualstudiocode" "pypy3" "clion")
programming_pro=("intellij_ultimate" "pycharm_professional" "clion")
text_editor_core=("atom" "openoffice" "latex" "geany" "notepadqq" "gvim")
media_core=("vlc" "gpaint" "okular" "clementine")
system_core=("virtualbox" "gparted" "clonezilla")
internet_core=("transmission" "thunderbird" "f-irc" "telegram" "dropbox" "discord" "megasync" "google_chrome" "firefox" "cheat")
art_core=("audacity" "shotcut" "gimp" "obs" "inkscape")
games_install=("games" "steam" "cmatrix")
standard_install=("templates" "virtualbox" "converters" "thunderbird" "clonezilla" "gparted" "gpaint" "transmission" "vlc" "python3" "gcc" "jdk11" "pdfgrep" "nemo" "git" "openoffice" "mendeley_dependencies" "mendeley" "GNU_parallel" "pypy3_dependencies" "android_studio" "sublime_text" "pycharm" "intellij_community" "pypy3" "clion" "latex" "telegram" "dropbox" "discord" "megasync" "google_chrome" "firefox")

# custom
#custom1_system=("templates" "converters" "s" "l" "extract" "extract" "cheat" "history_optimization" "git_aliases" "shortcut" "prompt" "chwlppr")
#custom1_user=("sublime" "pycharm" "ideac" "clion" "discord" "telegram" "mendeley")
#custom1_root=("megasync" "google-chrome" "transmission" "pdfgrep" "vlc" "okular" "thunderbird" "latex" "gparted" "gpaint" "pdfgrep" "nemo" "openoffice" "parallel" "copyq" "caffeine" "gnome-chess" "openoffice")
#dependencies=("gcc" "pypy3_dependencies" "curl" "git" "ffmpeg" "mendeley_dependencies" "java" "python3")
custom1=("templates" "converters" "s" "l" "extract" "extract" "cheat" "history_optimization" "git_aliases" "shortcut" "prompt" "change-bg" "sublime" "pycharm" "ideac" "clion" "discord" "telegram" "mendeley" "google-chrome" "transmission" "pdfgrep" "vlc" "okular" "thunderbird" "latex" "gparted" "gpaint" "pdfgrep" "nemo" "openoffice" "parallel" "copyq" "caffeine" "gnome-chess" "openoffice" "gcc" "pypy3_dependencies" "curl" "git" "ffmpeg" "mendeley_dependencies" "java" "python3")
iochem=("psql" "gcc" "java" "ant" "mvn")



help_common="

12345678901234567890123456789012345678901234567890123456789012345678901234567890
        10        20        30        40        50        60        70        80
#### install.sh manual usage:
[sudo] bash install.sh [[-f|--force]|[-i|--ignore|--ignore-errors]|
                       [-e|--exit-on-error]]

                       [[-f|--force]|[-o|--overwrite|--overwrite-if-present]|
                       [-s|--skip|--skip-if-installed]]

                       [[-v|--verbose]|[-Q|--Quiet]|[-q|--quiet]]

                       [[-d|--dirty|--no-autoclean]|[-c|--clean]|[-C|-Clean]]

                       [[-U|--Upgrade]|[-u|--upgrade]|
                       [-k|-K|--keep-system-outdated]]

                       [[-n|--not|-!]|[-y|--yes]]

                       SELECTED_FEATURES_TO_INSTALL


#### install.sh description:

  - install.sh performs the automatic configuration of a Linux
    environment by installing applications, adding bash functions, customizing
    terminal variables, declaring new useful global variables and aliases...

  - Each feature have specific privilege requirements: Some will need sudo when
    running install.sh and others won't


#### uninstall.sh description:

  - uninstall.sh, on the opposite, have the same feature arguments to select
    the features to be uninstalled.

  - It always need root permissions by using sudo.


#### Examples of usage:

    # Installs Sublime Text
    bash install.sh --sublime

    # Installs megasync and dropbox
    sudo bash install.sh --dropbox --megasync

    # Installs Pycharm verbosely
    bash install.sh -v --pycharm

    # Install Clion verbosely but install sublime_text silently
    bash install.sh -v --clion -Q --sublime

    # Installs Nemo overwriting previous installs and ignoring errors
    sudo bash install.sh -o -i --nemo

    # Installs AnyDesk overwriting previous installs and ignoring errors
    sudo bash install.sh -f --anydesk

    # Installs python3 but only updating packages, not upgrading
    sudo bash install.sh -u --python

    # Installs GParted without updating and upgrading
    sudo bash install.sh -k --gparted

    # Installs gcc, git and chess without cleaning packages afterwards
    sudo bash install.sh -d  --gcc --git --chess

    # Install verbosely all the programs in wrapper custom1, which
    contains the most stable and interesting features.
    sudo bash install -v --custom1 && bash install -v --custom1

    # Installs all features, both root and user features
    sudo bash install.sh --all && bash install --all
"

help_simple="
Some install.sh arguments change the way in which each feature succeeding that
argument is installed. This behaviour is maintained until the end of the
program, unless another argument changes this behaviour again.

Use:

    bash install.sh -H

to refer to the complete help, where all behavioural arguments and feature
arguments are listed and explained in detail.
"

help_auxiliar_arguments="
#### Arguments:

 -c, --clean          Perform an apt-get autoremove at the end of installation
                      if we are root
 -C, --Clean          (default) Perform an apt-get autoremove and autoclean at
                      the end of installation if we are root
 -d, --dirty          Do not clean at the end of installation


 -i, --ignore-errors  Default behaviour of bash, set +e. Keep executing after
                      error
 -e, --exit-on-error  (default) Exit the program if any command throws an error*
                      using set -e


 -o, --overwrite      Overwrite if there are previous installation
 -s, --skip           (default) Skip if the feature is detected in the system by
                      using which


 -v, --verbose        Displays all the possible output
 -q, --quiet          (default) Shows only install.sh basic informative output
 -Q, --Quiet          No output


 -u, --update         Performs an apt-get update before installation if we are
                      root
 -U, --upgrade        (default) Performs an apt-get update and upgrade before
                      installation if we are root
 -k, --keep-outdated  Do nothing before the installation


 -n, --not            Do NOT install the selected features. Used to trim from
                      wrappers
 -y, --yes            (default) Install the selected feature

Some install.sh arguments change the way in which each feature succeeding that
argument is installed. This behaviour is maintained until the end of the
program, unless another argument changes this behaviour again.

For example, consider the following execution:

    bash install -v -i -o --mendeley -Q -s --discord

That will execute the script to install mendeley verbosely, ignoring errors and
overwriting previous installations; after that we install discord without
output and skipping if it is present, but notice also we ignore errors too when
installing discord, because we activated the ignore errors behaviour before and
it will be still on for the remaining features.

By default, install.sh runs with the following implicit arguments:
--exit-on-error, --skip-if-installed, --quiet, -Clean, --Upgrade, --yes
"

help_individual_arguments_header="
#### Feature arguments:

This arguments are used to select which features we want to install or uninstall
using install.sh or uninstall.sh respectively.
There are two types of selectable features: feature wrappers and individual
features.
  - Individual features are a certain installation, configuration or
  customization of a program or system module.
  - Feature wrappers group many individual features with the same permissions
  related to the same topic: programming, image edition, system cutomization...
"

help_wrappers="
## Wrapper arguments
  --user|--regular|--normal)
  --root|--superuser|--su)
  --ALL|--all|--All)
  --custom1
"

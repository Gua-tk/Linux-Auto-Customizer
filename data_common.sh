#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer data of features.                                                                      #
# - Description: A set of programs, functions, aliases, templates, environment variables, wallpapers, desktop          #
# features... collected in a simple portable shell script to customize a Linux working environment.                    #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 16/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernandez Curros                                                                                      #
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
# To avoid to be queried by apt-get or dpkg when installing such features such wireshark and sonic-pi.
export DEBIAN_FRONTEND=noninteractive

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
# Default keybind list< data to set custom keybindings
PROGRAM_KEYBIND_PATH="${BASH_FUNCTIONS_FOLDER}/keybinds.txt"
# Default user's fonts folder
FONTS_FOLDER=${HOME_FOLDER}/.fonts
# Here we store the .desktop launchers of the programs we want to autostart
AUTOSTART_FOLDER=${HOME_FOLDER}/.config/autostart

# The variables that begin with FLAG_ can change the installation of a feature individually. They will continue holding
# the same value until the end of the execution until another argument
FLAG_OVERWRITE=0     # 0 --> Skips a feature if it is already installed, 1 --> Install a feature even if it is already installed
FLAG_INSTALL=1       # 1 or more --> Install the feature provided to add_program. 0 --> DO NOT install the feature provided to add_program
# Also, flag_install is the number used to determine the installation order
FLAG_QUIETNESS=2     # 0 --> verbose mode, 1 --> only shows echoes from main script, 2 --> no output is shown
FLAG_IGNORE_ERRORS=0 # 1 --> the script will continue its execution even if an error is found. 0 --> Abort execution on error
NUM_INSTALLATION=1  # Used to perform the (un)installation in the same order that we are receiving arguments. Also, keeps the order even if we use --no, because we need a temporal
FLAG_UPGRADE=1  # 0 --> no update, no upgrade; 1 --> update, no upgrade; 2 --> update and upgrade
FLAG_AUTOCLEAN=2  # Clean caches after installation. 0 --> no clean; 1 --> perform autoremove; 2 --> perform autoremove and autoclean
FLAG_FAVORITES=0  # 0 --> does nothing; 1 --> sets the program to favourites if there is a desktop launcher
FLAG_MODE=  # Tells if code is running under install.sh or under uninstall.sh, 1 or 0, respectively
FLAG_AUTOSTART=0  # 0 --> does nothing; 1 --> autostart program if possible

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
  "--a;0;"
  "--add;0;"
  "--aisleriot|--solitaire|--Solitaire|--gnome-solitaire;1;"
  "--alert|--alert-alias|--alias-alert;0;"
  "--ansible;1;"
  "--ant|--apache_ant|--apache-ant;0;"
  "--anydesk;0;"
  "--aspell;1;"
  "--atom|--Atom;1;"
  "--audacity|--Audacity;1;"
  "--AutoFirma|--autofirma;1;"
  "--axel|--Axel;1;"
  "--b|--b-alias;0;"
  "--bashcolors;0;"
  "--branch;0;"
  "--brasero;1;"
  "--c;0;"
  "--caffeine|--Caffeine|--cafe|--coffee;1;"
  "--calibre|--Calibre|--cali;1;"
  "--changebg|--wallpapers|--Wallpapers|--change-bg;0;"
  "--cheat|--cheat.sh|--Cheat.sh|--che;0;"
  "--checkout;0;"
  "--cheese|--Cheese;1;"
  "--clean|--function-clean|--clean-function;0;"
  "--clementine|--Clementine;1;"
  "--clion|--Clion|--CLion;0;"
  "--clonezilla|--CloneZilla|--cloneZilla;1;"
  "--cmatrix|--Cmatrix;1;"
  "--code|--visualstudiocode|--visual-studio-code|--Code|--visualstudio|--visual-studio;0;"
  "--codeblocks;1;"
  "--commit;0;|"
  "--converters|--Converters;0;"
  "--copyq|--copy-q|--copy_q|--copqQ|--Copyq|--copy-Q;1;"
  "--curl|--Curl;1;"
  "--dbeaver;1;"
  "--dconf-editor|--dconf|;1;"
  "--dia|--Dia;1;"
  "--discord|--Discord|--disc;0;"
  "--docker|--Docker;0;"
  "--documents|--google-document;0;"
  "--drive|--GoogleDrive|--Drive|--google-drive|--Google-Drive;0;"
  "--dropbox|--Dropbox|--DropBox|--Drop-box|--drop-box|--Drop-Box;1;"
  "--duckduckgo|--DuckDuckGo;0;"
  "--dummycommit;0;"
  "--e;0;"
  "--eclipse|--Eclipse;0;"
  "--evolution|--Evolution;1;"
  "--f-irc|--firc|--Firc|--irc;1;"
  "--facebook|--Facebook;0;"
  "--fdupes;1;"
  "--fetch;0;"
  "--ffmpeg|--youtube-dl-dependencies;1;"
  "--firefox|--Firefox;1;"
  "--fonts-alegreya-sans|--alegreya_sans;0;"
  "--fonts-firacode|--fonts-firacode;1;"
  "--fonts-hack|--fonts-hack;1;"
  "--fonts-hermit|--fonts-hermit;1;"
  "--fonts-lato;0;"
  "--fonts-noto-sans|--noto_sans;0;"
  "--fonts-oswald;0;"
  "--fonts-oxygen;0;"
  "--fonts-roboto|--fonts-roboto;1;"
  "--forms|--google-forms;0;"
  "--freecad|--FreeCAD|--freeCAD;1;"
  "--gcc|--GCC;1;"
  "--geany|--Geany;1;"
  "--geogebra|--geogebra-classic-6|--Geogebra-6|--geogebra-6|--Geogebra-Classic-6|--geogebra-classic;0;"
  "--ghostwriter|--Ghostwriter|--GhostWriter;1;"
  "--gimp|--GIMP|--Gimp;1;"
  "--git;1;"
  "--github|--Github|--GitHub;0;"
  "--github-desktop|--Github-Desktop|--GitHub-Desktop;1;"
  "--gitk|--Gitk|--Git-k;1;"
  "--gitlab|--GitLab|--git-lab;0;"
  "--gitprompt|--git-prompt;0;"
  "--gmail|--Gmail;0;"
  "--gnat-gps|--gnat-programming-studio|--gnat-ps|--gnatps|--gnatgps|--gnat;1;"
  "--gnome-calculator|--GNOME_Calculator|--gnomecalculator|--calculator;1;"
  "--gnome-chess|--GNOME_Chess|--gnomechess|--chess;1;"
  "--gnome-mahjongg|--mahjongg|--Mahjongg;1;"
  "--gnome-mines|--mines|--Mines|--GNU-mines|--gnomemines;1;"
  "--gnome-sudoku|--sudoku|--Sudoku;1;"
  "--gnome-terminal|--terminal|--Terminal;1;"
  "--gnome-tweak-tool|--gnome-tweaks|--gnome-tweak|--gnome-tweak-tools|--tweaks;1;"
  "--googlecalendar|--Google-Calendar|--googlecalendar;0;"
  "--google-chrome|--chrome|--Chrome|--Google-Chrome;1;"
  "--gpaint|--paint|--Gpaint;1;"
  "--gparted|--GParted|--GPARTED|--Gparted;1;"
  "--gvim|--vim-gtk3|--Gvim|--GVim;1;"
  "--h;0;"
  "--handbrake;1;"
  "--hard;0;"
  "--hardinfo;1;"
  "--history-optimization;0;"
  "--ideac|--intellijcommunity|--intelliJCommunity|--intelliJ-Community|--intellij-community;0;"
  "--ideau|--intellijultimate|--intelliJUltimate|--intelliJ-Ultimate|--intellij-ultimate;0;"
  "--inkscape|--ink-scape|--Inkscape|--InkScape;1;"
  "--instagram|--Instagram;0;"
  "--ipe|--ipe-function;0;"
  "--ipi|--ipi-function;0;"
  "--iqmol|--IQmol;1;"
  "--j;0;"
  "--java|--javadevelopmentkit|--java-development-kit|--java-development-kit-11|--java-development-kit11|--jdk|--JDK|--jdk11|--JDK11|--javadevelopmentkit-11;0;"
  "--julia|--Julia;0;"
  "--jupyter-lab|--jupyter-notebook|--jupyter|--jupyterlab;0;"
  "--keep|--google-keep|--Keep|--Google-Keep|--googlekeep;0;"
  "--L|--L-function;0;"
  "--l|--alias-l|--alias-ls|--l-alias|--ls-alias;0;"
  "--latex|--LaTeX|--tex|--TeX;1;"
  "--libgtkglext1|--anydesk-dependencies;1;"
  "--libkrb5-dev|--kerberos-dependencies;1;"
  "--libxcb-xtest0;1;"
  "--lolcat;1;"
  "--mdadm;1;"
  "--megasync|--Mega|--MEGA|--MegaSync|--MEGAsync|--MEGA-sync|--mega;1;"
  "--mendeley-dependencies|--MendeleyDependencies|--mendeleydependencies|--mendeleydesktopdependencies|--mendeley-desktop-dependencies|--Mendeley-Desktop-Dependencies;1;"
  "--mendeley|--Mendeley|--mendeleyDesktop|--mendeley-desktop|--Mendeley-Desktop;0;"
  "--msttcorefonts|--microsoftfonts|--microsoft-fonts|--mscorefonts|--ttf-mscorefonts;1;"
  "--mvn|--maven;0;"
  "--nautilus;1;"
  "--nedit|--NEdit|--Nirvana-Editor|--nirvanaeditor|--nirvana|--Nirvana|--nirvana-editor;1;"
  "--nemo|--nemo-desktop|--Nemo-Desktop|--Nemodesktop|--nemodesktop|--Nemo|--Nemodesk|--NemoDesktop;1;"
  "--netflix|--Netflix;0;"
  "--net-tools|--nettools;1;"
  "--npm;0;"
  "--notepadqq|--Notepadqq|--notepadQQ|--NotepadQQ|--notepadQq|--notepadQq|--NotepadQq|--NotepadqQ;1;"
  "--o|--o-function|--function-o;0;"
  "--obs-studio|--OBS|--obs|--obs_studio|--obs_Studio|--OBS_studio|--obs-Studio|--OBS_Studio|--OBS-Studio;1;"
  "--okular|--Okular|--okularpdf;1;"
  "--onedrive|--OneDrive|--one-drive|--One-Drive;0;"
  "--openoffice|--office|--Openoffice|--OpenOffice|--openOfice|--open_office|--Office;1;"
  "--openssl102|--rstudio-dependencies;1;"
  "--outlook|--Outlook;0;"
  "--overleaf|--Overleaf;0;"
  "--pacman|--pac-man;1;"
  "--parallel|--gnu_parallel|--GNUparallel|--GNUParallel|--gnu-parallel;1;"
  "--pdfgrep|--findpdf;1;"
  "--pgadmin|--pgadmin4;0;"
  "--php;1;"
  "--pluma;1;"
  "--postman|--Postman;0;"
  "--presentation|--google-presentation;0;"
  "--prompt;0;"
  "--psql|--postgreSQL|--PostGreSQL|--postgresql|--postgre-sql|--postgre-SQL|--pSQL|--p-SQL|--p-sql;1;"
  "--pull;0;"
  "--push;0;"
  "--pycharm|--pycharmcommunity|--pycharmCommunity|--pycharm_community|--pycharm-community;0;| Pycharm Community | Integrated development environment used in computer programming | Command \`pycharm\`, silent alias for \`pycharm-pro\`, desktop launcher, dashboard launcher, associated to the mime type of \`.py\` files  || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--pycharmpro|--pycharmPro|--pycharm_pro|--pycharm-pro|--Pycharm-Pro|--PyCharm-pro;0;| Pycharm Pro | Integrated development environment used in computer programming | Command \`pycharm-pro\`, silent alias for \`pycharm-pro\`, desktop launcher, dashboard launcher, associated to the mime type of \`.py\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--pypy3|--pypy|--PyPy3|--PyPy;0;| pypy3 | Faster interpreter for the Python3 programming language | Commands \`pypy3\` and \`pypy3-pip\` in the PATH || <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--pypy3-dependencies|--dependencies|--pypy3Dependencies|--PyPy3Dependencies|--pypy3dependencies|--pypy3-dependencies;1;| pypy3_dependencies | Dependencies to run pypy3 | Libraries \`pkg-config\`, \`libfreetype6-dev\`, \`libpng-dev\` and \`libffi-dev\` used when deploying \`pypy\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--python3|--python|--Python3|--Python;1;| Python3 | Interpreted, high-level and general-purpose programming language | Commands \`python\`, \`python3\`, \`pip3\` and Function \`v\` is for activate/deactivate python3 virtual environments (venv) can be used as default \`v\` as a command creates the /venv/ environment we can activate/deactivate new or existing virtual environments, command \`v namevenv\` creates /namevenv/ we can activate the virtual environment again using \`v namenv\` or deactivate same again, using \`v namenv\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
  "--R|--r-base;1;| R | Programming language | Commands \`R\`, Dashboard Launcher, Desktop Launcher|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--reddit|--Reddit;0;| Reddit | Opens Reddit in Chrome | Commands \`reddit\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--remmina;1;| Remmina | Remote Desktop Contol | Commands \`remmina\`, Desktop launcher and Icon || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--rstudio;0;| RStudio | Installs \`rstudio\`, desktop launcher, dashboard launcher, default application for .R files | Commands \`rstudio\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--rsync|--Rsync|--grsync;1;| Grsync | Installs \`grsync\`, desktop launcher... | Commands \`grsync\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
  "--rustc;1;| Rust | Programming Language | Installs \`rustc\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
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
  "--system-fonts|--systemfonts;1;| Change default fonts | Sets pre-defined fonts to desktop environment. | A new set of fonts is updated in the system's screen. || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
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
  "--x|--x-function|--extract;0;| Function \`x\` | Function to extract from a compressed file, no matter its format | Function \`x \"filename\"\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
  "--xclip;1;| \`xclip\` | Utility for pasting. | Command \`xclip\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
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
\e[0m
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

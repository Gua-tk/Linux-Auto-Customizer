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


########################################################################################################################
################################################## CONSTANT PATHS ######################################################
########################################################################################################################
# Define constant paths that are privileged-independent to allow customizer to locate and use its resources and system #
# resources to fulfill each installation requirements.                                                                 #
# Default expected content of each constant:                                                                           #
#                                                                                                                      #
# * XDG constants (imported from ${HOME}/.config/user-dirs.dirs)                                                       #
#   - XDG_DESKTOP_DIR: /home/username/Desktop                                                                          #
#   - XDG_PICTURES_DIR: /home/username/Images                                                                          #
#   - XDG_TEMPLATES_DIR: /home/username/Templates                                                                      #
#                                                                                                                      #
# * Customizer routes:                                                                                                 #
#   - CUSTOMIZER_FOLDER: /home/username/.customizer                                                                    #
#     Folder where we will put the different files installed by customizer.                                            #
#   - BIN_FOLDER: /home/username/.bin                                                                                  #
#     Folder where all the software will be installed.                                                                 #
#   - FUNCTIONS_FOLDER: /home/username/.bin/bash-functions                                                             #
#     Path pointing to the folder containing all the scripts of the bash functions                                     #
#   - FUNCTIONS_PATH: /home/username/.bin/bash_functions/.bash_functions                                               #
#     Path pointing to .bash_functions, which is the file used to control the installed features of the customizer.    #
#   - INITIALIZATIONS_PATH: /home/username/.bin/bash-functions/.bash_profile                                           #
#     Path pointing to the ${HOME_FOLDER}/.profile of bash which is run at system start.                               #
#   - INITIALIZATIONS_FOLDER: /home/username/.bin/bash_functions/.bash_functions                                       #
#     Path pointing to the folder which contains the initialization bash scripts.                                      #
#   - PROGRAM_FAVORITES_PATH: {INITIALIZATIONS_FOLDER}/favorites.txt                                                   #
#     Default favorites list, data to set favorites.                                                                   #
#   - PROGRAM_KEYBIND_PATH: ${INITIALIZATIONS_FOLDER}/keybindings.txt                                                  #
#     Default keybinding list data to set custom keybindings.                                                          #
#                                                                                                                      #
# * System routes:                                                                                                     #
#   - HOME_FOLDER: /home/username                                                                                      #
#     Path pointing to the $HOME of the normal user who runs the installation or that is running sudo to run the       #
#     installation.                                                                                                    #
#   - PERSONAL_LAUNCHERS_DIR: /home/username/.local/share/applications                                                 #
#     Path pointing to a folder that contains the desktop launchers for the unity application launcher of the current  #
#     user.                                                                                                            #
#   - ALL_USERS_LAUNCHERS_DIR: /usr/share/applications                                                                 #
#     Path pointing to a folder that contains the desktop launchers of all users.                                      #
#   - BASHRC_PATH: /home/username/.bashrc                                                                              #
#     Path pointing to .bashrc file of the user.                                                                       #
#   - BASHRC_ALL_USERS_PATH: /etc/bash.bashrc                                                                          #
#     Bashrc for all users path variable system-wide.                                                                  #
#   - PROFILE_PATH: ${HOME_FOLDER}/.profile                                                                            #
#     Path pointing to our internal file for initializations.                                                          #
#   - PATH_POINTED_FOLDER: /home/username/.local/bin                                                                   #
#     Path pointing to a directory that is included in the PATH variable of the current user.                          #
#   - ALL_USERS_PATH_POINTED_FOLDER: /usr/bin                                                                          #
#     Path pointing to a directory that it is in the PATH of all users.                                                #
#   - MIME_ASSOCIATION_PATH: ${HOME_FOLDER}/.config/mimeapps.list                                                      #
#     File that contains the association of mime types with .desktop files.                                            #
#   - FONTS_FOLDER: ${HOME_FOLDER}/.fonts                                                                              #
#     Default user's fonts folder.                                                                                     #
#   - AUTOSTART_FOLDER: ${HOME_FOLDER}/.config/autostart                                                               #
#     Here we store the .desktop launchers of the programs we want to autostart.                                       #
########################################################################################################################

initialize_package_manager_apt() {
  DEFAULT_PACKAGE_MANAGER="apt-get"
  PACKAGE_MANAGER_INSTALL="apt-get -y install"
  PACKAGE_MANAGER_FIXBROKEN="apt-get install -y --fix-broken"
  PACKAGE_MANAGER_UNINSTALL="apt-get -y purge"
  PACKAGE_MANAGER_UPDATE="apt-get -y update"
  PACKAGE_MANAGER_UPGRADE="apt-get -y upgrade"
  PACKAGE_MANAGER_INSTALLPACKAGE="dpkg -i"
  PACKAGE_MANAGER_INSTALLPACKAGES="dpkg -Ri"
  PACKAGE_MANAGER_UNINSTALLPACKAGE="apt-get -y purge"
  PACKAGE_MANAGER_AUTOREMOVE="apt-get -y autoremove"
  PACKAGE_MANAGER_AUTOCLEAN="apt-get -y autoclean"
  PACKAGE_MANAGER_ENSUREDEPENDENCIES="apt-get -y install -f"
}


if [ "${EUID}" != 0 ]; then
  declare -r HOME_FOLDER="${HOME}"

  declare -r USER_DIRS_PATH="${HOME_FOLDER}/.config/user-dirs.dirs"

  # Declare language specific user environment variables (XDG_DESKTOP_DIR, XDG_PICTURES_DIR, XDG_TEMPLATES_DIR...)
  if [ -f "${USER_DIRS_PATH}" ]; then
    source "${USER_DIRS_PATH}"
  fi 
else
  declare -r HOME_FOLDER="/home/${SUDO_USER}"

  declare -r USER_DIRS_PATH="${HOME_FOLDER}/.config/user-dirs.dirs"

  # Declare language specific user environment variables (XDG_DESKTOP_DIR, XDG_PICTURES_DIR, XDG_TEMPLATES_DIR...)
  # This declaration is different from the analogous one in the previous block because $HOME needs to be substituted
  # for /home/$SUDO_USER to be interpreted correctly as a root user. Also with declare we can declare all variables in
  # the file in one line.
  if [ -f "${USER_DIRS_PATH}" ]; then
    while IFS= read -r line; do
      if ! echo "${line}" | grep -Eoq "^#"; then
        declare -r "$(echo "${line/\$HOME//home/${SUDO_USER}}" | tr -d "\"")"
      fi
    done < "${HOME_FOLDER}/.config/user-dirs.dirs"
  fi
fi

# Define fallbacks if user-dirs.dirs is not present
if [ -z "${XDG_DESKTOP_DIR}" ]; then
  declare -r XDG_DESKTOP_DIR="${HOME_FOLDER}/Desktop"
fi
if [ -z "${XDG_PICTURES_DIR}" ]; then
  declare -r XDG_PICTURES_DIR="${HOME_FOLDER}/Pictures"
fi
if [ -z "${XDG_TEMPLATES_DIR}" ]; then
  declare -r XDG_TEMPLATES_DIR="${HOME_FOLDER}/Templates"
fi

# Search the current OS in order to determine the default package manager and its main
if [ -f "/etc/os-release" ]; then
  declare OS_NAME
  OS_NAME=$( (grep -Eo "^NAME=.*\$" | cut -d "=" -f2 | tr -d '"' ) < "/etc/os-release" )
else
  declare -r OS_NAME="Ubuntu"
fi

case ${OS_NAME} in
  # Using default package manager such as $DEFAULT_PACKAGE_MANAGER
  Ubuntu)
    initialize_package_manager_apt
  ;;
  Debian)
    initialize_package_manager_apt
  ;;
  ElementaryOS)
    initialize_package_manager_apt
  ;;
  Fedora)
    DEFAULT_PACKAGE_MANAGER="yum"
    PACKAGE_MANAGER_INSTALL="yum -y install"
    PACKAGE_MANAGER_UNINSTALL="yum -y purge"
    PACKAGE_MANAGER_UPDATE="yum -y update"
    PACKAGE_MANAGER_UPGRADE="apt-get -y upgrade"
    PACKAGE_MANAGER_INSTALLPACKAGE="yum -y install"
    PACKAGE_MANAGER_INSTALLPACKAGES="yum -y install"
    PACKAGE_MANAGER_UNINSTALLPACKAGE="yum -y purge"
    PACKAGE_MANAGER_CLEAN="yum -y autoremove && apt-get -y autoclean"
    PACKAGE_MANAGER_ENSUREDEPENDENCIES="yum -y install -f"
  ;;
  *)
    output_proxy_executioner "ERROR: ${OS_NAME} is not a recognised OS. Aborting"
    exit 1
  ;;
esac


declare -r CUSTOMIZER_FOLDER="${HOME_FOLDER}/.customizer"
declare -r BIN_FOLDER="${CUSTOMIZER_FOLDER}/bin"
declare -r CACHE_FOLDER="${CUSTOMIZER_FOLDER}/cache"
declare -r TEMP_FOLDER="${CUSTOMIZER_FOLDER}/temp"
declare -r FUNCTIONS_FOLDER="${CUSTOMIZER_FOLDER}/functions"
declare -r INITIALIZATIONS_FOLDER="${CUSTOMIZER_FOLDER}/initializations"
declare -r DATA_FOLDER="${CUSTOMIZER_FOLDER}/data"

declare -r FUNCTIONS_PATH="${DATA_FOLDER}/functions.sh"
declare -r INITIALIZATIONS_PATH="${DATA_FOLDER}/initializations.sh"
declare -r PROGRAM_FAVORITES_PATH="${DATA_FOLDER}/favorites.txt"
declare -r PROGRAM_KEYBINDINGS_PATH="${DATA_FOLDER}/keybindings.txt"
declare -r INSTALLED_FEATURES="${DATA_FOLDER}/installed_features.txt"

declare -r PATH_POINTED_FOLDER="${HOME_FOLDER}/.local/bin"
declare -r ALL_USERS_PATH_POINTED_FOLDER="/usr/bin"
declare -r PERSONAL_LAUNCHERS_DIR="${HOME_FOLDER}/.local/share/applications"
declare -r ALL_USERS_LAUNCHERS_DIR="/usr/share/applications"
declare -r BASHRC_PATH="${HOME_FOLDER}/.bashrc"
declare -r BASHRC_ALL_USERS_PATH="/etc/bash.bashrc"
declare -r PROFILE_PATH="${HOME_FOLDER}/.profile"
declare -r MIME_ASSOCIATION_PATH="${HOME_FOLDER}/.config/mimeapps.list"
declare -r FONTS_FOLDER="${HOME_FOLDER}/.fonts"
declare -r AUTOSTART_FOLDER="${HOME_FOLDER}/.config/autostart"

########################################################################################################################
################################################## RUNTIME FLAGS #######################################################
########################################################################################################################
# Global variables used for the program to communicate different functions and modules with themselves. They also      #
# record the internal state of the software, which in many cases change the way in which an installation is performed  #
# or the general behaviour of the program. Some of the flags are saved for every installation in add_program() to be   #
# interpreted later in execute_installation(). During the installation each flag will hold its default value until a   #
# behavioural argument is supplied to change it.                                                                       #
#                                                                                                                      #
# * Static flags: Do not change during runtime and are used to obtain information:                                     #
#   - FLAG_MODE: Can be set to "install" or "uninstall" to indicate in which state we are in.                          #
#                                                                                                                      #
# * Installation behaviour flags: Are used to determine which modifiers will be applied to the installation of each    #
#   feature. Can be modified using behavioural arguments:                                                              #
#   - FLAG_OVERWRITE: By default "0". Can be set to "0" or "1" with -s or -o, which will cause to skip a feature if it #
#     is installed or install it anyway if it is already installed, respectively.                                      #
#   - FLAG_INSTALL: By default "1". Can be set to "0" or "1" with -n or -y, which will remove or add the supplied      #
#     features from the pull of features to install or uninstall, depending on the mode we are.                        #
#   - FLAG_QUIETNESS: By default "0". Can be set to "0", "1" or "2" with -v, -q or -Q, which will cause the            #
#     installation and general program to be fully verbose, show only echoes or by completely silent, respectively.    #
#   - FLAG_IGNORE_ERRORS: By default "0". Can be set to "0" or "1" with -e or -i, which will cause to exit when        #
#     finding an error during an installation or continue installation ignoring errors, respectively.                  #
#   - FLAG_FAVORITES: By default "0". Can be set to "0" or "1" with -z or -f, which will cause to do nothing or add    #
#     the installed programs to the favorite apps of the taskbar by using the desktop launchers of each feature.       #
#   - FLAG_AUTOSTART: By default "0". Can be set to "0" or "1" with -a or -r, which will cause to do nothing or        #
#     autostart the installed feature at system boot.                                                                  #
#   - FLAG_SKIP_PRIVILEGES_CHECK: By default "0". Can be set to "0" or "1" with -p or -P to force the match of         #
#     permissions when installing a feature or ignore this match checking.                                             #
#                                                                                                                      #
# * Common behaviour flags: Are used in the program to modify common behaviour. These flags are not saved and used for #
#   every feature but can be also modified with a behavioural argument.                                                #
#   - FLAG_UPGRADE: By default "1". Can be set to "0", "1" or "2" with -k, -u or -U, which will do nothing, update or  #
#     update and upgrade, respectively.                                                                                #
#   - FLAG_AUTOCLEAN: By default "1". Can be set to "0", "1" or "2" with -d, -c or -C, which will do nothing, do a     #
#     cache auto-remove or do a cache auto-remove and auto-clean.                                                      #
#   - FLAG_CACHE: By default "1". Can be set to "0" or "1" with
########################################################################################################################

# Static flags
FLAG_MODE=

# Installation behaviour flags
FLAG_OVERWRITE=0
FLAG_INSTALL=1
FLAG_QUIETNESS=2
FLAG_IGNORE_ERRORS=0
FLAG_FAVORITES=0
FLAG_AUTOSTART=0
FLAG_SKIP_PRIVILEGES_CHECK=0

# Common behaviour flags
FLAG_UPGRADE=1
FLAG_AUTOCLEAN=2
FLAG_CACHE=1

########################################################################################################################
################################################ FEATURE KEYNAMES ######################################################
########################################################################################################################
# Array of keynames that match all available features in data_features.sh. The keynames are always in lower case and   #
# have _ in the keyname position where a space or - could be written. This is used to match different argument formats #
# like mixed cases or using - or _ against each keyname, allowing a greater number of arguments that the ones here     #
# defined plus the ones defined in FEATUREKEYNAME_arguments, in data_features.sh. These keynames are used to expand    #
# indirectly the different properties for each feature, which are used to know which properties have to be installed   #
# for each installation.                                                                                               #
########################################################################################################################

declare -r feature_keynames=(
  "a"
  "add"
  "aircrack_ng"
  "aisleriot"
  "alert"
  "ansible"
  "ant"
  "anydesk"
  "ardour"
  "aspell"
  "atom"
  "audacity"
  "AutoFirma"
  "axel"
  "B"
  "b"
  "bashcolors"
  "blender"
  "branch"
  "brasero"
  "c"
  "caffeine"
  "calibre"
  "changebg"
  "cheat"
  "checkout"
  "cheese"
  "clean"
  "clementine"
  "clion"
  "clone"
  "clonezilla"
  "cmake"
  "cmatrix"
  "code"
  "codeblocks"
  "codium"
  "commit"
  "converters"
  "copyq"
  "curl"
  "customizer"
  "d"
  "dbeaver"
  "dconf_editor"
  "dia"
  "discord"
  "docker"
  "documents"
  "drive"
  "dropbox"
  "duckduckgo"
  "dummycommit"
  "E"
  "e"
  "eclipse"
  "emojis"
  "evolution"
  "F"
  "f"
  "f_irc"
  "facebook"
  "fastcommands"
  "fdupes"
  "fetch"
  "ffmpeg"
  "firefox"
  "fonts_alegreya_sans"
  "fonts_firacode"
  "fonts_hack"
  "fonts_hermit"
  "fonts_lato"
  "fonts_noto_sans"
  "fonts_oswald"
  "fonts_oxygen"
  "fonts_roboto"
  "forms"
  "freecad"
  "gcc"
  "geany"
  "geogebra"
  "ghostwriter"
  "gimp"
  "git"
  "gitcm"
  "github"
  "github_desktop"
  "gitk"
  "gitlab"
  "gitprompt"
  "gmail"
  "gnat_gps"
  "gnome_calculator"
  "gnome_chess"
  "gnome_mahjongg"
  "gnome_mines"
  "gnome_sudoku"
  "gnome_terminal"
  "gnome_tweak_tool"
  "go"
  "google"
  "googlecalendar"
  "google_chrome"
  "gpaint"
  "gparted"
  "guake"
  "gvim"
  "h"
  "handbrake"
  "hard"
  "hardinfo"
  "history_optimization"
  "i"
  "ideac"
  "ideau"
  "inkscape"
  "instagram"
  "ipe"
  "ipi"
  "iqmol"
  "j"
  "java"
  "julia"
  "jupyter_lab"
  "k"
  "keep"
  "L"
  "l"
  "latex"
  "libgtkglext1"
  "libkrb5_dev"
  "libxcb_xtest0"
  "lmms"
  "loc"
  "lolcat"
  "mdadm"
  "megasync"
  "meld"
  "mendeley"
  "merge"
  "msttcorefonts"
  "mvn"
  "nautilus"
  "ncat"
  "nedit"
  "nemo"
  "netflix"
  "net_tools"
  "nmap"
  "npm"
  "notepadqq"
  "o"
  "obs_studio"
  "octave"
  "okular"
  "onedrive"
  "openoffice"
  "openssl102"
  "openssh_server"
  "outlook"
  "overleaf"
  "p"
  "pacman"
  "parallel"
  "pdfgrep"
  "pgadmin"
  "php"
  "pluma"
  "postman"
  "presentation"
  "prompt"
  "psql"
  "pull"
  "push"
  "pycharm"
  "pycharmpro"
  "pypy3"
  "python3"
  "q"
  "R"
  "reddit"
  "remmina"
  "rosegarden"
  "rstudio"
  "rsync"
  "rustc"
  "s"
  "scala"
  "scilab"
  "screenshots"
  "sherlock"
  "shortcuts"
  "shotcut"
  "shotwell"
  "skype"
  "slack"
  "sonic_pi"
  "soundcloud"
  "spotify"
  "spreadsheets"
  "ssh"
  "status"
  "steam"
  "studio"
  "sublime"
  "synaptic"
  "sysmontask"
  "system_fonts"
  "teamviewer"
  "teams"
  "telegram"
  "templates"
  "terminal_background"
  "terminator"
  "thunderbird"
  "tilix"
  "tmux"
  "tomcat"
  "tor"
  "translator"
  "transmission_gtk"
  "trello"
  "tumblr"
  "twitch"
  "twitter"
  "u"
  "uget"
  "virtualbox"
  "vlc"
  "whatsapp"
  "wikipedia"
  "wikit"
  "wireshark"
  "x"
  "xclip"
  "youtube"
  "youtube_dl"
  "youtubemusic"
  "z"
  "zoom"
)

# Array to store the keynames of the features that have been added for installation
added_feature_keynames=()

########################################################################################################################
############################################ BEHAVIOURAL ARGUMENTS #####################################################
########################################################################################################################
# Array containing all the possible auxiliary arguments that can be used to modify the behaviour of each installation  #
# and the general behaviour of the program. This is used for the autocompletion of this script.                        #
########################################################################################################################

declare -r auxiliary_arguments=("-v" "-q" "-Q" "-s" "-o" "-e" "-i" "-d" "-c" "-C" "-k" "-u" "-U" "-f" "-z" "-a" "-r" "-n" "-y" "-p" "-P" "-h" "-H" "--debug" "--commands" "--custom1" "--iochem" "--user" "--root" "--ALL")


########################################################################################################################
################################################ WRAPPER KEYNAMES ######################################################
########################################################################################################################
# Variables that contain sets of installation keynames that can be used as a multi-feature installation. These         #
# variables are expanded and its content is supplied to add_program function in order to install all the features      #
# contained in the wrapper. The text after the "wrapper_" prefix can be used as the argument to install the            #
# multi-feature wrapper.                                                                                               #
# Is preferable that the wrapper has the same installation privileges in all of its features.                          #
########################################################################################################################

# Thematic wrappers
declare -r wrapper_programmingcore=("python3" "gcc" "jdk11" "git" "GNU_parallel")
declare -r wrapper_programmingide=("android_studio" "sublime_text" "pycharm" "intellij_community" "visualstudiocode" "pypy3" "clion")
declare -r wrapper_programmingpro=("intellij_ultimate" "pycharm_professional" "clion")
declare -r wrapper_texteditorcore=("atom" "openoffice" "latex" "geany" "notepadqq" "gvim")
declare -r wrapper_mediacore=("vlc" "gpaint" "okular" "clementine")
declare -r wrapper_systemcore=("virtualbox" "gparted" "clonezilla")
declare -r wrapper_internetcore=("transmission" "thunderbird" "f-irc" "telegram" "dropbox" "discord" "megasync" "google_chrome" "firefox" "cheat")
declare -r wrapper_artcore=("audacity" "shotcut" "gimp" "obs" "inkscape")
declare -r wrapper_gamesinstall=("steam" "cmatrix")
declare -r wrapper_standardinstall=("templates" "virtualbox" "converters" "thunderbird" "clonezilla" "gparted" "gpaint" "transmission" "vlc" "python3" "gcc" "jdk11" "pdfgrep" "nemo" "git" "openoffice" "mendeley" "GNU_parallel" "android_studio" "sublime_text" "pycharm" "intellij_community" "pypy3" "clion" "latex" "telegram" "dropbox" "discord" "megasync" "google_chrome" "firefox")
declare -r wrapper_bashfunctions=("a" "b" "c" "e" "f" "h" "j" "k" "L" "l" "o" "q" "s" "u" "x")
declare -r wrapper_desktopfunctions=("changebg" "screenshots" "system_fonts" "templates")
declare -r wrapper_terminalfunctions=("prompt" "gitprompt" "terminal_background" "history_optimization" "shortcuts" "converters" "bashcolors")

# Custom wrappers
declare -r wrapper_custom1=("templates" "converters" "s" "l" "cheat" "history_optimization" "shortcut" "port" "prompt" "changebg" "sublime" "pycharm" "ideac" "clion" "discord" "telegram" "mendeley" "google-chrome" "transmission" "pdfgrep" "vlc" "okular" "thunderbird" "latex" "gparted" "gpaint" "pdfgrep" "nemo" "openoffice" "parallel" "copyq" "caffeine" "gnome-chess" "openoffice" "gcc" "curl" "git" "ffmpeg" "java" "python3")
declare -r wrapper_iochem=("psql" "gcc" "java" "ant" "mvn")
declare -r wrapper_gitbashfunctions=("pull" "push" "dummycommit" "commit" "checkout" "clone" "branch" "status" "add" "hard" "fetch")

########################################################################################################################
############################################ COMMON DATA VARIABLES #####################################################
########################################################################################################################
# Variables that contain static data for both parts of the program (install.sh / uninstall.sh) but are not strictly    #
# related to an installation feature. This include data templates, output messages, etc.                               #
########################################################################################################################

declare -r bash_functions_import="source \"${FUNCTIONS_PATH}\""
declare -r bash_initializations_import="source \"${INITIALIZATIONS_PATH}\""
declare -r flagsoverride_template=";;;;;"

declare -r bash_functions_init="
# If not running interactively, don't do anything
case \$- in
    *i*) ;;
      *) return;;
esac

# Make sure that PATH is pointing to ${PATH_POINTED_FOLDER} (where we will put our soft links to the software)
if [ -z \"\$(echo \$PATH | grep -Eo \"${PATH_POINTED_FOLDER}\")\" ]; then
  export PATH=\$PATH:${PATH_POINTED_FOLDER}
fi
"

declare -r help_common="\e[0m
12345678901234567890123456789012345678901234567890123456789012345678901234567890
        10        20        30        40        50        60        70        80
#### install.sh manual usage:
[sudo] bash install.sh [[-f|--force]|[-i|--ignore|--ignore-errors]|
                       [-e|--exit-on-error]]

                       [[-f|--favorites|--set-favorites]|[-o|--overwrite|--overwrite-if-present]|
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

declare -r help_simple="
Some install.sh arguments change the way in which each feature succeeding that
argument is installed. This behaviour is maintained until the end of the
program, unless another argument changes this behaviour again.

Use:

    bash install.sh -H

to refer to the complete help, where all behavioural arguments and feature
arguments are listed and explained in detail.
"

declare -r help_auxiliar_arguments="
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

declare -r help_individual_arguments_header="
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

declare -r help_wrappers="
## Wrapper arguments
  --user|--regular|--normal)
  --root|--superuser|--su)
  --ALL|--all|--All)
  --custom1
"


########################################################################################################################
############################################ BEHAVIOURAL VARIABLES #####################################################
########################################################################################################################
# Variable that are not directly used. Instead, they are unset or set with special values to obtain a certain special  #
# behaviour.                                                                                                           #
########################################################################################################################

# Behavioural variable, used to avoid to be queried by apt-get or dpkg when installing such features such wireshark and
# sonic-pi.
export DEBIAN_FRONTEND=noninteractive
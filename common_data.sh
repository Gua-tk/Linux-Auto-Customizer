#!/usr/bin/env bash
######################################
##### COMMON AUXILIARY FUNCTIONS #####
######################################

# Execute the command received in the first argument and redirect the output depending on the quietness level
# Argument 1: Bash command to execute.
# Argument 2: Quietness level [0, 1, 2].
output_proxy_executioner() {
  comm=$(echo "$1" | head -1 | cut -d " " -f1)
  if [[ "${comm}" == "echo" ]]; then
    rest=$(echo "$1" | sed '1 s@^echo @@')
    message_type="$(echo "${rest}" | cut -d ":" -f1)"
    if [[ ${message_type} == "WARNING" ]]; then
      echo -en "\e[33m" # Activate yellow colour
    elif [[ ${message_type} == "INFO" ]]; then
      echo -en "\e[36m" # Activate cyan colour
    elif [[ ${message_type} == "ERROR" ]]; then
      echo -en "\e[91m" # Activate red colour
    fi
    echo -n "$(date +%Y-%m-%d_%T) -- "
  fi

  if [[ $2 == 0 ]]; then
    $1
  elif [[ $2 == 1 ]]; then
    if [[ "${comm}" == "echo" ]]; then
      # If it is a echo command, delete trailing echo and echo formatting
      rest=$(echo "$1" | sed '1 s@^echo @@') # Delete echo at the beggining of the line
      echo "${rest}"
    else
      $1 &>/dev/null
    fi
  else
    $1 &>/dev/null
  fi

  if [[ "${comm}" == "echo" ]]; then
    echo -en "\e[0m" # DeActivate colour
  fi
}


# Receives a list of feature function name (install_pycharm, install_vlc...) and applies the current flags to it,
# modifying the corresponding line of installation_data
add_program()
{
  while [[ $# -gt 0 ]]; do
    total=${#installation_data[*]}
    for (( i=0; i<$(( ${total} )); i++ )); do
      program_name=$(echo "${installation_data[$i]}" | rev | cut -d ";" -f1 | rev)

      if [[ "$1" == "${program_name}" ]]; then
        # Cut static bits
        rest=$(echo "${installation_data[$i]}" | rev | cut -d ";" -f1,2 | rev)
        # Append static bits to the state of the flags
        new="${FLAG_INSTALL};${FLAG_IGNORE_ERRORS};${FLAG_QUIETNESS};${FLAG_OVERWRITE};${rest}"
        installation_data[$i]=${new}
        # Update flags and program counter
        if [[ ${FLAG_INSTALL} -gt 0 ]]; then
          NUM_INSTALLATION=$(( ${NUM_INSTALLATION} + 1 ))
          FLAG_INSTALL=${NUM_INSTALLATION}
        fi
      fi
    done
    shift
  done
}

add_programs()
{
  while [[ $# -gt 0 ]]; do
    add_program "install_$1"
    shift
  done
}


############################
##### COMMON VARIABLES #####
############################

### DECLARATION ###

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

  # Force inclusions of DIR_IN_PATH to the PATH of the root user in order to let bash find installed binaries in
  # DIR_IN_PATH when logged as root using which or type calls.
  #export PATH=${PATH}:${DIR_IN_PATH}
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
BASH_FUNCTIONS_PATH=${HOME_FOLDER}/.bash_functions

# Path pointing to the folder containing all the scripts of the bash functions
BASH_FUNCTIONS_FOLDER=${USR_BIN_FOLDER}/bash-functions

# Path pointing to a folder that contains the desktop launchers of all users
ALL_USERS_LAUNCHERS_DIR=/usr/share/applications

# The variables that begin with FLAG_ can change the installation of a feature individually. They will continue holding
# the same value until the end of the execution until another argument
FLAG_OVERWRITE=0     # 0 --> Skips a feature if it is already installed, 1 --> Install a feature even if it is already installed
FLAG_INSTALL=1       # 1 or more --> Install the feature provided to add_program. 0 --> DO NOT install the feature provided to add_program
# Also, flag_install is the number used to determine the installation order
FLAG_QUIETNESS=1     # 0 --> verbose mode, 1 --> only shows echoes from main script, 2 --> no output is shown
FLAG_IGNORE_ERRORS=0 # 1 --> the script will continue its execution even if an error is found. 0 --> Abort execution on error
NUM_INSTALLATION=1  # Used to perform the (un)installation in the same order that we are receiving arguments
FLAG_UPGRADE=1  # 0 --> no update, no upgrade; 1 --> update, no upgrade; 2 --> update and upgrade
FLAG_AUTOCLEAN=2  # Clean caches after installation. 0 --> no clean; 1 --> perform autoremove; 2 --> perform autoremove and autoclean

### EXPECTED VARIABLE CONTENT (BY-DEFAULT) ###

# PERSONAL_LAUNCHERS_DIR: /home/username/.local/share/applications
# ALL_USERS_LAUNCHERS_DIR: /usr/share/applications
# HOME_FOLDER: /home/username
# USR_BIN_FOLDER: /home/username/.bin
# BASHRC_PATH: /home/username/.bashrc
# DIR_IN_PATH: /home/username/.local/bin
# HOME_FOLDER: /home/username
# BASH_FUNCTIONS_FOLDER: /home/username/.bin/bash-functions
# BASH_FUNCTIONS_PATH: /home/username/.bash_functions

# Imported from ${HOME}/.config/user-dirs.dirs
# XDG_DESKTOP_DIR: /home/username/Desktop
# XDG_PICTURES_DIR: /home/username/Images
# XDG_TEMPLATES_DIR: /home/username/Templates

### FEATURE_DATA ###

# This pseudo-matrix contains different information for every feature available in this project.
# The first values are used to store dynamically the arguments desired for that function:
# 1.- If we are actually going to install the program.
# 2.- If we should (or not) abort when finding errors.
# 3.- What level of standard output is desired for that feature: 0 verbose, 1 quiet (only informative prints), 2 totally quiet
# 4.- If we should reinstall the feature or not when we find that the desired feature already installed.
# The last two values are static and are used only to read:
# 5.- Permissions: 0 for user permissions, 1 for root permissions, 2 for indiferent
# 6.- Function name
# install_yes/no; forceness; quietness; overwrite; permissions; function_name
installation_data=(
  "--ant|--apache_ant|--apache-ant;0;install_ant"
  "--anydesk;0;install_anydesk"
  "--audacity|--Audacity;1;install_audacity"
  "--autofirma;1;install_AutoFirma"
  "--alert|--alert-alias|--alias-alert;0;install_alert"
  "--atom|--Atom;1;install_atom"
  "--caffeine|--Caffeine|--cafe|--coffee;1;install_caffeine"
  "--calibre|--Calibre|--cali;1;install_calibre"
  "--clementine|--Clementine;1;install_clementine"
  "--clion|--Clion|--CLion;0;install_clion"
  "--cheat|--cheat.sh|--Cheat.sh|--che;0;install_cheat"
  "--cheese|--Cheese;1;install_cheese"
  "--cmatrix|--Cmatrix;1;install_cmatrix"
  "--codium|--vscodium;0;install_codium"
  "--converters|--Converters;0;install_converters"
  "--clonezilla|--CloneZilla|--cloneZilla;1;install_clonezilla"
  "--copyq|--copy-q|--copy_q|--copqQ|--Copyq|--copy-Q;1;install_copyq"
  "--curl|--Curl;1;install_curl"
  "--discord|--Discord|--disc;0;install_discord"
  "--docker|--Docker;1;install_docker"
  "--dropbox|--Dropbox|--DropBox|--Drop-box|--drop-box|--Drop-Box;1;install_dropbox"
  "--drive|--GoogleDrive|--Drive|--google-drive|--Google-Drive;0;install_drive"
  "--document|--google-document;0;install_document"
  "--eclipse|--Eclipse;0;install_eclipse"
  "--extract-function|-extract_function;0;install_extract"
  "--ffmpeg|--youtube-dl-dependencies;1;install_ffmpeg"
  "--f-irc|--firc|--Firc|--irc;1;install_f-irc"
  "--firefox|--Firefox;1;install_firefox"
  "--forms|--google-forms;0;install_forms"
  "--freecad|--FreeCAD|--freeCAD;1;install_freecad"
  "--gcc|--GCC;1;install_gcc"
  "--github|--Github|--GitHub;0;install_github"
  "--gpaint|--paint|--Gpaint;1;install_gpaint"
  "--geany|--Geany;1;install_geany"
  "--geogebra|--geogebra-classic-6|--Geogebra-6|--geogebra-6|--Geogebra-Classic-6|--geogebra-classic;0;install_geogebra"
  "--git;1;install_git"
  "--git-aliases|--git_aliases|--git-prompt;0;install_git_aliases"
  "--GIMP|--gimp|--Gimp;1;install_gimp"
  "--gmail|--Gmail;0;install_gmail"
  "--GParted|--gparted|--GPARTED|--Gparted;1;install_gparted"
  "--gvim|--vim-gtk3|--Gvim|--GVim;1;install_gvim"
  "--chrome|--Chrome|--google-chrome|--Google-Chrome;1;install_google-chrome"
  "--google-calendar|--Google-Calendar|--googlecalendar;0;install_google-calendar"
  "--GNOME_Chess|--gnome_Chess|--gnomechess|--chess;1;install_gnome-chess"
  "--history-optimization;0;install_history_optimization"
  "--ipe-function|--ipe;0;install_ipe"
  "--iqmol|--IQmol;1;install_iqmol"
  "--inkscape|--ink-scape|--Inkscape|--InkScape;1;install_inkscape"
  "--intellijcommunity|--intelliJCommunity|--intelliJ-Community|--intellij-community|--ideac;0;install_ideac"
  "--intellijultimate|--intelliJUltimate|--intelliJ-Ultimate|--intellij-ultimate|--ideau;0;install_ideau"
  "--java|--javadevelopmentkit|--java-development-kit|--java-development-kit-11|--java-development-kit11|--jdk|--JDK|--jdk11|--JDK11|--javadevelopmentkit-11;0;install_java"
  "--keep|--google-keep|--Keep|--Google-Keep|--googlekeep;0;install_keep"
  "--latex|--LaTeX|--tex|--TeX;1;install_latex"
  "--alias-l|--alias-ls|--l-alias|--ls-alias|--l;0;install_l"
  "--L|--L-function;0;install_L"
  "--libgtkglext1;1;install_libgtkglext1"
  "--libxcb-xtest0;1;install_libxcb-xtest0"
  "--mahjongg|--Mahjongg|--gnome-mahjongg;1;install_gnome-mahjongg"
  "--maven|--mvn;0;install_mvn"
  "--mega|--Mega|--MEGA|--MegaSync|--MEGAsync|--MEGA-sync|--megasync;1;install_megasync"
  "--Mendeley|--mendeley|--mendeleyDesktop|--mendeley-desktop|--Mendeley-Desktop;0;install_mendeley"
  "--MendeleyDependencies|--mendeleydependencies|--mendeleydesktopdependencies|--mendeley-desktop-dependencies|--Mendeley-Desktop-Dependencies;1;install_mendeley_dependencies"
  "--mines|--Mines|--GNU-mines|--gnome-mines|--gnomemines;1;install_gnome-mines"
  "--nemo|--nemo-desktop|--Nemo-Desktop|--Nemodesktop|--nemodesktop|--Nemo|--Nemodesk|--NemoDesktop;1;install_nemo"
  "--netflix|--Netflix;0;install_netflix"
  "--net-tools|--nettools;1;install_net-tools"
  "--notepadqq|--Notepadqq|--notepadQQ|--NotepadQQ|--notepadQq|--notepadQq|--NotepadQq|--NotepadqQ;1;install_notepadqq"
  "--onedrive|--OneDrive|--one-drive|--One-Drive;0;install_onedrive"
  "--outlook|--Outlook;0;install_outlook"
  "--openoffice|--office|--Openoffice|--OpenOffice|--openOfice|--open_office|--Office;1;install_openoffice"
  "--OBS|--obs|--obs-studio|--obs_studio|--obs_Studio|--OBS_studio|--obs-Studio|--OBS_Studio|--OBS-Studio;1;install_obs-studio"
  "--okular|--Okular|--okularpdf;1;install_okular"
  "--overleaf|--Overleaf;0;install_overleaf"
  "--pacman|--pac-man;1;install_pacman"
  "--parallel|--gnu_parallel|--GNUparallel|--GNUParallel|--gnu-parallel;1;install_parallel"
  "--pdfgrep|--findpdf;1;install_pdfgrep"
  "--pluma;1;install_pluma"
  "--presentation|--google-presentation;0;install_presentation"
  "--prompt;0;install_prompt"
  "--postgreSQL|--PostGreSQL|--postgresql|--postgre-sql|--postgre-SQL|--psql|--pSQL|--p-SQL|--p-sql;1;install_psql"
  "--pycharmcommunity|--pycharmCommunity|--pycharm_community|--pycharm|--pycharm-community;0;install_pycharm"
  "--pycharmpro|--pycharmPro|--pycharm_pro|--pycharm-pro|--Pycharm-Pro|--PyCharm-pro;0;install_pycharmpro"
  "--python|--python3|--Python3|--Python;1;install_python3"
  "--pypy|--pypy3|--PyPy3|--PyPy;0;install_pypy3"
  "--dependencies|--pypy3_dependencies|--pypy3Dependencies|--PyPy3Dependencies|--pypy3dependencies|--pypy3-dependencies;1;install_pypy3_dependencies"
  "--steam|--Steam|--STEAM;1;install_steam"
  "--screenshots|--Screenshots;0;install_screenshots"
  "--shotcut|--ShotCut|--Shotcut|--shot-cut|--shot_cut;1;install_shotcut"
  "--shortcuts;0;install_shortcuts"
  "--solitaire|--Solitaire|--gnome-solitaire|--aisleriot;1;install_aisleriot"
  "--s|--s-function;0;install_s"
  "--skype|--Skype;1;install_skype"
  "--slack|--Slack;1;install_slack"
  "--studio|--android|--AndroidStudio|--androidstudio|--android-studio|--android_studio|--Androidstudio;0;install_studio"
  "--sublime|--sublimeText|--sublime_text|--Sublime|--sublime-Text|--sublime-text;0;install_sublime"
  "--spotify|--Spotify;1;install_spotify"
  "--spreadsheets|--google-spreadsheets;0;install_spreadsheets"
  "--sudoku|--Sudoku|--gnome-sudoku;1;install_gnome-sudoku"
  "--Telegram|--telegram;0;install_telegram"
  "--templates;0;install_templates"
  "--terminal-background|--terminal_background;0;install_terminal_background"
  "--Terminator|--terminator;1;install_terminator"
  "--Tilix|--tilix;1;install_tilix"
  "--tmux|--Tmux;1;install_tmux"
  "--teams|--Teams|--MicrosoftTeams;1;install_teams"
  "--uget;1;install_uget"
  "--thunderbird|--mozillathunderbird|--mozilla-thunderbird|--Thunderbird|--thunder-bird;1;install_thunderbird"
  "--tor|--torbrowser|--tor_browser|--TOR|--TOR-browser|--TOR-BROSWER|--TORBROWSER|--TOR_BROWSER|--TOR_browser;1;install_tor"
  "--transmission|--transmission-gtk|--Transmission;1;install_transmission"
  "--virtualbox|--virtual-box|--VirtualBox|--virtualBox|--Virtual-Box|--Virtualbox;1;install_virtualbox"
  "--code|--visualstudiocode|--visual-studio-code|--Code|--visualstudio|--visual-studio;0;install_code"
  "--vlc|--VLC|--Vlc;1;install_vlc"
  "--Wallpapers|--wallpapers|--chwlppr;0;install_chwlppr"
  "--youtube-dl;0;install_youtube-dl"
  "--whatsapp|--Whatsapp;0;install_whatsapp"
  "--wireshark|--Wireshark;1;install_wireshark"
  "--youtube|--Youtube|--YouTube;0;install_youtube"
  "--youtubemusic|--YouTubeMusic|--YouTube-Music|--Youtube-Music|--youtube-music;0;install_youtubemusic"
  "--Zoom| --zoom;0;install_zoom"
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
custom1=("templates" "converters" "s" "l" "extract" "extract" "cheat" "history_optimization" "git_aliases" "shortcut" "prompt" "chwlppr" "sublime" "pycharm" "ideac" "clion" "discord" "telegram" "mendeley" "google-chrome" "transmission" "pdfgrep" "vlc" "okular" "thunderbird" "latex" "gparted" "gpaint" "pdfgrep" "nemo" "openoffice" "parallel" "copyq" "caffeine" "gnome-chess" "openoffice" "gcc" "pypy3_dependencies" "curl" "git" "ffmpeg" "mendeley_dependencies" "java" "python3")
iochem=("psql" "gcc" "java" "ant" "mvn")

add_root_programs()
{
  for program in ${installation_data[@]}; do
    permissions=$(echo ${program} | cut -d ";" -f5)
    if [[ ${permissions} != 0 ]]; then
      name=$(echo ${program} | cut -d ";" -f6)
      add_program ${name}
    fi
  done
}

add_user_programs()
{
  for program in ${installation_data[@]}; do
    permissions=$(echo ${program} | cut -d ";" -f5)
    if [[ ${permissions} != 1 ]]; then
      name=$(echo ${program} | cut -d ";" -f6)
      add_program ${name}
    fi
  done
}

add_all_programs()
{
  for program in ${installation_data[@]}; do
    name=$(echo ${program} | cut -d ";" -f6)
    add_program $name
  done
}

#######################################
##### SOFTWARE SPECIFIC VARIABLES #####
#######################################

alert_alias="
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i \"\$([ \$? = 0 ] && echo terminal || echo error)\" \"\$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\\'')\"'
"
# Variables used exclusively in the corresponding installation function. Alphabetically sorted.
#Name, GenericName, Type, Comment, Version, StartupWMClass, Icon, Exec, Terminal, Categories=IDE;Programming;, StartupNotify, MimeType=x-scheme-handler/tg;, Encoding=UTF-8
android_studio_downloader=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.1.2.0/android-studio-ide-201.7042882-linux.tar.gz
android_studio_alias="alias studio=\"studio . &>/dev/null &\""
android_studio_launcher="[Desktop Entry]
Categories=Development;IDE;
Comment=IDE for developing android applications
Encoding=UTF-8
Exec=studio %F
GenericName=studio
Icon=${USR_BIN_FOLDER}/android-studio/bin/studio.svg
Keywords=IDE;programming;android;studio;dev;
MimeType=
Name=Android Studio
StartupNotify=true
StartupWMClass=jetbrains-android-studio
Terminal=false
TryExec=studio
Type=Application
Version=1.0
"

ant_downloader="https://ftp.cixug.es/apache//ant/binaries/apache-ant-1.10.9-bin.tar.gz"

anydesk_downloader="https://download.anydesk.com/linux/anydesk-6.1.1-amd64.tar.gz"
anydesk_launcher="[Desktop Entry]
Categories=Remote;control;other;
Comment=Remote control other PCs
Encoding=UTF-8
Exec=anydesk
GenericName=Remote computer control
Icon=${USR_BIN_FOLDER}/anydesk/icons/hicolor/scalable/apps/anydesk.svg
Keywords=IDE;programming;android;studio;dev;
MimeType=
Name=AnyDesk
StartupNotify=true
StartupWMClass=anydesk
Terminal=false
TryExec=anydesk
Type=Application
Version=1.0"

atom_downloader=https://atom.io/download/deb

autofirma_downloader=https://estaticos.redsara.es/comunes/autofirma/currentversion/AutoFirma_Linux.zip

bash_functions_import="
source ${BASH_FUNCTIONS_PATH}
"
bash_functions_init="
# If not running interactively, don't do anything
case \$- in
    *i*) ;;
      *) return;;
esac
"

cheat_downloader=https://cht.sh/:cht.sh

clion_downloader=https://download.jetbrains.com/cpp/CLion-2020.1.tar.gz
clion_launcher="[Desktop Entry]
Categories=Development;IDE;
Comment=C and C++ IDE for Professional Developers
Encoding=UTF-8
Exec=clion %F
GenericName=C Programing IDE
Icon=${USR_BIN_FOLDER}/clion/bin/clion.png
Keywords=IDE;programming;android;studio;dev;
MimeType=
Name=CLion
StartupNotify=true
StartupWMClass=jetbrains-clion
Terminal=false
TryExec=clion
Type=Application
Version=1.0"
clion_alias="alias clion=\"clion . &>/dev/null &\""

clonezilla_launcher="[Desktop Entry]
Categories=backup;images;restoration;boot;
Comment=Create bootable clonezilla images
Encoding=UTF-8
Exec=sudo clonezilla
GenericName=Disk image utility
Icon=/usr/share/gdm/themes/drbl-gdm/clonezilla/ocslogo-1.png
Keywords=clonezilla;CloneZilla;iso
MimeType=
Name=CloneZilla
StartupNotify=true
StartupWMClass=CloneZilla
Terminal=true
TryExec=clonezilla
Type=Application
Version=1.0"

cmatrix_launcher="[Desktop Entry]
Categories=matrix;
Comment=Matrix
Encoding=UTF-8
Exec=cmatrix
GenericName=cmatrix
Icon=/var/lib/app-info/icons/ubuntu-focal-universe/64x64/bless_bless-48x48.png
Keywords=cmatrix;matrix;
MimeType=
Name=CMatrix
StartupNotify=true
StartupWMClass=cmatrix
Terminal=true
TryExec=cmatrix
Type=Application
Version=1.0"

codium_downloader=https://github.com/VSCodium/vscodium/releases/download/1.54.3/VSCodium-linux-x64-1.54.3.tar.gz
codium_launcher="[Desktop Entry]
Categories=IDE;programming;
Comment=Community-driven distribution of Microsoft’s editor VSCode.
Encoding=UTF-8
Exec=codium
GenericName=IDE for programming
Icon=${USR_BIN_FOLDER}/codium/resources/app/resources/linux/code.png
Keywords=programming;dev;
MimeType=
Name=VSCodium
StartupNotify=true
StartupWMClass=
Terminal=false
TryExec=codium
Type=Application
Version=1.0"

dropbox_downloader=https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb

discord_downloader="https://discord.com/api/download?platform=linux&format=tar.gz"
discord_launcher="[Desktop Entry]
Categories=Network;InstantMessaging;
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
Encoding=UTF-8
Exec=discord
GenericName=Internet Messenger
Icon=${USR_BIN_FOLDER}/discord/discord.png
Keywords=VoiceChat;Messaging;Social;
MimeType=
Name=Discord
StartupNotify=true
StartupWMClass=discord
Terminal=false
TryExec=discord
Type=Application
Version=1.0"

docker_downloader=https://download.docker.com/linux/static/stable/x86_64/docker-20.10.6.tgz

eclipse_downloader=http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.2.2-201302041200/eclipse-SDK-4.2.2-linux-gtk-x86_64.tar.gz
eclipse_launcher="[Desktop Entry]
Categories=Development;IDE;
Comment=Capable Multi-purpose IDE
Encoding=UTF-8
Exec=eclipse
GenericName=IDE
Icon=${USR_BIN_FOLDER}/eclipse/icon.xpm
Keywords=IDE;programming;
MimeType=
Name=Eclipse IDE
StartupNotify=true
StartupWMClass=Eclipse
Terminal=false
TryExec=eclipse
Type=Application
Version=4.2.2"

firc_launcher="[Desktop Entry]
Categories=InstantMessaging;Communication;
Comment=irc relay chat for terminal (easy to use)
Encoding=UTF-8
Exec=f-irc
GenericName=IRC client
Icon=/var/lib/app-info/icons/ubuntu-focal-universe/64x64/flightgear_flightgear.png
Keywords=InstantMessaging;irc;
MimeType=
Name=F-irc
StartupNotify=true
StartupWMClass=f-irc
Terminal=true
TryExec=f-irc
Type=Application
Version=1.0"

gcc_function="# colored GCC warnings and errors
export GCC_COLORS=\"error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01\"
"

geogebra_downloader=https://download.geogebra.org/package/linux-port6
geogebra_icon=https://upload.wikimedia.org/wikipedia/commons/5/57/Geogebra.svg

geogebra_desktop="[Desktop Entry]
Categories=geometry;
Comment=GeoGebra
Encoding=UTF-8
Exec=geogebra
GenericName=Geometry visualization plotter
Icon=${USR_BIN_FOLDER}/geogebra/GeoGebra.svg
Keywords=GeoGebra;geogebra;
MimeType=
Name=GeoGebra
StartupNotify=true
StartupWMClass=geogebra
Terminal=false
TryExec=geogebra
Type=Application
Version=4.2.2"

git_aliases_function="
commit()
{
    message=\$*
    if [ -z \"\$message\" ]; then
      echo \"Add a message\"
      read message
    fi
    git commit -am \"\$message\"
}
dummycommit()
{
  git add -A
  git commit -am \"\$1\"
  git push
}

alias gitk=\"gitk --all --date-order &\"
if [ -f ${USR_BIN_FOLDER}/.bash-git-prompt/gitprompt.sh ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source ${USR_BIN_FOLDER}/.bash-git-prompt/gitprompt.sh
fi
"

forms_url=https://docs.google.com/forms/
forms_icon="https://upload.wikimedia.org/wikipedia/commons/5/5b/Google_Forms_2020_Logo.svg"
forms_alias="alias forms=\"xdg-open ${forms_url} &>/dev/null &\""
forms_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Google Forms from Chrome
Encoding=UTF-8
Exec=xdg-open ${forms_url}
GenericName=Document
Icon=${USR_BIN_FOLDER}/google-chrome/forms_icon.svg
Keywords=forms;
MimeType=x-scheme-handler/tg;
Name=Google Forms
StartupNotify=true
StartupWMClass=Google Forms
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

presentation_url=https://docs.google.com/presentation/
presentation_icon="https://upload.wikimedia.org/wikipedia/commons/1/16/Google_Slides_2020_Logo.svg"
presentation_alias="alias presentation=\"google-chrome ${presentation_url} &>/dev/null &\""
presentation_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Google Presentation from Chrome
Encoding=UTF-8
GenericName=Document
Keywords=presentations;
MimeType=x-scheme-handler/tg;
Name=Google Presentation
StartupNotify=true
StartupWMClass=Google Presentation
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

document_url=https://docs.google.com/document/
document_icon="https://upload.wikimedia.org/wikipedia/commons/6/66/Google_Docs_2020_Logo.svg"
document_alias="alias document=\"google-chrome ${document_url} &>/dev/null &\""
document_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Google Documents from Chrome
Encoding=UTF-8
Exec=google-chrome ${document_url}
GenericName=Document
Icon=${USR_BIN_FOLDER}/google-chrome/document_icon.svg
Keywords=documents;
MimeType=x-scheme-handler/tg;
Name=Google Document
StartupNotify=true
StartupWMClass=Google Document
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

spreadsheets_url=https://docs.google.com/spreadsheets/
spreadsheets_icon="https://upload.wikimedia.org/wikipedia/commons/a/ae/Google_Sheets_2020_Logo.svg"
spreadsheets_alias="alias spreadsheets=\"google-chrome ${spreadsheets_url} &>/dev/null &\""
spreadsheets_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Google Spreadsheets from Chrome
Encoding=UTF-8
Exec=google-chrome ${spreadsheets_url}
GenericName=Spreadsheets
Icon=${USR_BIN_FOLDER}/google-chrome/spreadsheets_icon.svg
Keywords=spreadsheets;
MimeType=x-scheme-handler/tg;
Name=Google Spreadsheets
StartupNotify=true
StartupWMClass=Google Spreadsheets
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

google_chrome_downloader=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
gmail_url=https://mail.google.com/
gmail_icon=https://upload.wikimedia.org/wikipedia/commons/7/7e/Gmail_icon_%282020%29.svg
gmail_alias="alias gmail=\"google-chrome ${gmail_url} &>/dev/null &\""
gmail_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to instant e-mail messaging from Chrome
Encoding=UTF-8
Exec=google-chrome ${gmail_url}
GenericName=Gmail
Icon=${USR_BIN_FOLDER}/google-chrome/gmail_icon.svg
Keywords=gmail;
MimeType=x-scheme-handler/tg;
Name=Gmail
StartupNotify=true
StartupWMClass=Gmail
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

drive_url=https://drive.google.com/
drive_icon=https://upload.wikimedia.org/wikipedia/commons/1/12/Google_Drive_icon_%282020%29.svg
drive_alias="alias drive=\"google-chrome ${drive_url} &>/dev/null &\""
drive_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to instant e-mail messaging from Chrome
Encoding=UTF-8
Exec=google-chrome ${drive_url}
GenericName=Gmail
Icon=${USR_BIN_FOLDER}/google-chrome/drive_icon.svg
Keywords=drive;
MimeType=x-scheme-handler/tg;
Name=Google Drive
StartupNotify=true
StartupWMClass=Google Drive
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

drive_url=https://drive.google.com/
drive_icon=https://upload.wikimedia.org/wikipedia/commons/1/12/Google_Drive_icon_%282020%29.svg
drive_alias="alias drive=\"google-chrome ${drive_url} &>/dev/null &\""
drive_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to instant e-mail messaging from Chrome
Encoding=UTF-8
Exec=google-chrome ${drive_url}
GenericName=Gmail
Icon=${USR_BIN_FOLDER}/google-chrome/drive_icon.svg
Keywords=drive;
MimeType=x-scheme-handler/tg;
Name=Google Drive
StartupNotify=true
StartupWMClass=Google Drive
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

overleaf_icon="https://images.ctfassets.net/nrgyaltdicpt/h9dpHuVys19B1sOAWvbP6/5f8d4c6d051f63e4ba450befd56f9189/ologo_square_colour_light_bg.svg"
overleaf_url=https://www.overleaf.com/
overleaf_alias="alias overleaf=\"google-chrome ${overleaf_url} &>/dev/null &\""
overleaf_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Overleaf online LaTeX editor from Chrome
Encoding=UTF-8
Exec=google-chrome ${overleaf_url}
GenericName=Overleaf
Icon=${USR_BIN_FOLDER}/google-chrome/overleaf_icon.svg
Keywords=overleaf;
MimeType=x-scheme-handler/tg;
Name=Overleaf
StartupNotify=true
StartupWMClass=Overleaf
#Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

github_icon="https://upload.wikimedia.org/wikipedia/commons/9/91/Octicons-mark-github.svg"
github_url=https://github.com/
github_alias="alias github=\"google-chrome ${github_url} &>/dev/null &\""
github_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Github from Chrome
Encoding=UTF-8
Exec=google-chrome ${github_url}
GenericName=GitHub
Icon=${USR_BIN_FOLDER}/google-chrome/github_icon.svg
Keywords=github;
MimeType=x-scheme-handler/tg;
Name=GitHub
StartupNotify=true
StartupWMClass=GitHub
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

outlook_icon="https://upload.wikimedia.org/wikipedia/commons/d/df/Microsoft_Office_Outlook_%282018%E2%80%93present%29.svg"
outlook_url=https://outlook.live.com
outlook_alias="alias outlook=\"google-chrome ${outlook_url} &>/dev/null &\""
outlook_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to Microsoft Outlook from Chrome
Encoding=UTF-8
Exec=google-chrome ${outlook_url}
GenericName=Outlook
Icon=${USR_BIN_FOLDER}/google-chrome/outlook_icon.svg
Keywords=outlook;
MimeType=x-scheme-handler/tg;
Name=Outlook
StartupNotify=true
StartupWMClass=Outlook
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"


onedrive_icon="https://upload.wikimedia.org/wikipedia/commons/3/3c/Microsoft_Office_OneDrive_%282019%E2%80%93present%29.svg"
onedrive_url=https://onedrive.live.com/
onedrive_alias="alias onedrive=\"google-chrome ${onedrive_url} &>/dev/null &\""
onedrive_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to Microsoft OneDrive from Chrome
Encoding=UTF-8
Exec=google-chrome ${onedrive_url}
GenericName=OneDrive
Icon=${USR_BIN_FOLDER}/google-chrome/onedrive_icon.svg
Keywords=onedrive;
MimeType=x-scheme-handler/tg;
Name=OneDrive
StartupNotify=true
StartupWMClass=OneDrive
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

googlecalendar_url="https://calendar.google.com/"
googlecalendar_icon="https://upload.wikimedia.org/wikipedia/commons/a/a5/Google_Calendar_icon_%282020%29.svg"
googlecalendar_alias="alias google-calendar=\"google-chrome ${googlecalendar_url} &>/dev/null &\""
googlecalendar_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to Google Calendar from Chrome
Encoding=UTF-8
Exec=google-chrome ${googlecalendar_url}
GenericName=Google Calendar
Icon=${USR_BIN_FOLDER}/google-chrome/googlecalendar_icon.svg
Keywords=google-calendar;
MimeType=x-scheme-handler/tg;
Name=Google Calendar
StartupNotify=true
StartupWMClass=Google Calendar
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

keep_url="https://keep.google.com/"
keep_icon="https://upload.wikimedia.org/wikipedia/commons/b/bd/Google_Keep_icon_%282015-2020%29.svg"
keep_alias="alias keep=\"google-chrome ${keep_url} &>/dev/null &\""
keep_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to Google Keep from Chrome
Encoding=UTF-8
Exec=google-chrome ${keep_url}
GenericName=Google Calendar
Icon=${USR_BIN_FOLDER}/google-chrome/keep_icon.svg
Keywords=google-keep;keep;
MimeType=x-scheme-handler/tg;
Name=Google Keep
StartupNotify=true
StartupWMClass=Google Keep
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

gpaint_icon_path=/usr/share/icons/hicolor/scalable/apps/gpaint.svg

intellij_ultimate_downloader="https://download.jetbrains.com/idea/ideaIU-2020.3.1.tar.gz"
intellij_ultimate_launcher="[Desktop Entry]
Categories=Development;IDE;
Comment=Capable and Ergonomic IDE for JVM
Encoding=UTF-8
Exec=ideau %f
GenericName=Java programing IDE
Icon=${HOME_FOLDER}/.bin/idea-iu/bin/idea.png
Keywords=IDE;programming;java;dev;
MimeType=
Name=IntelliJ IDEA Ultimate Edition
StartupNotify=true
StartupWMClass=jetbrains-idea
Terminal=false
TryExec=ideau
Type=Application
Version=1.0"
ideau_alias="alias ideau=\"ideau . &>/dev/null &\""

intellij_community_downloader="https://download.jetbrains.com/idea/ideaIC-2020.3.1.tar.gz"

intellij_community_launcher="[Desktop Entry]
Categories=Development;IDE;
Comment=Capable and Ergonomic IDE for JVM
Encoding=UTF-8
Exec=ideac %f
GenericName=Java programming IDE
Icon=${HOME_FOLDER}/.bin/idea-ic/bin/idea.png
Keywords=IDE;programming;java;dev;
MimeType=
Name=IntelliJ IDEA Community Edition
StartupNotify=true
StartupWMClass=jetbrains-idea
Terminal=false
TryExec=ideac
Type=Application
Version=13.0"
ideac_alias="alias ideac=\"ideac . &>/dev/null &\""

iqmol_downloader=http://www.iqmol.org/download.php?get=iqmol_2.14.deb
iqmol_icon=http://www.iqmol.org/images/icon.png

iqmol_launcher="[Desktop Entry]
Categories=Visualization;
Comment=Molecule Visualizer
Encoding=UTF-8
Exec=iqmol
GenericName=Molecule visualizer
Icon=${USR_BIN_FOLDER}/iqmol/iqmol_icon.png
Keywords=molecules;chemistry;3d;
MimeType=
Name=IQmol
StartupNotify=true
StartupWMClass=IQmol
Terminal=false
TryExec=iqmol
Type=Application
Version=1.0"
iqmol_alias="alias iqmol=\"iqmol . &>/dev/null &\""

java_downloader="https://javadl.oracle.com/webapps/download/GetFile/1.8.0_281-b09/89d678f2be164786b292527658ca1605/linux-i586/jdk-8u281-linux-x64.tar.gz"
java_globalvar="export JAVA_HOME=\"${USR_BIN_FOLDER}/jdk8\""

l_function="alias l=\"ls -lAh --color=auto\""

maven_downloader="https://ftp.cixug.es/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz"

megasync_downloader=https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/megasync_4.4.0-1.1_amd64.deb
megasync_integrator_downloader=https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/nemo-megasync_4.0.2_amd64.deb

mendeley_downloader=https://www.mendeley.com/autoupdates/installer/Linux-x64/stable-incoming

music_manager_downloader=https://dl.google.com/linux/direct/google-musicmanager-beta_current_amd64.deb

nautilus_conf=("xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search"
  "gsettings set org.gnome.desktop.background show-desktop-icons true"
  "xdg-mime default org.gnome.Nautilus.desktop inode/directory"
)

nemo_conf=("xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search"
  "gsettings set org.gnome.desktop.background show-desktop-icons false"
  "gsettings set org.nemo.desktop show-desktop-icons true"
)

nemo_desktop_launcher="[Desktop Entry]
Type=Application
Name=Files
Exec=nemo-desktop
OnlyShowIn=GNOME;Unity;
X-Ubuntu-Gettext-Domain=nemo"

netflix_url=https://www.netflix.com
netflix_icon=https://upload.wikimedia.org/wikipedia/commons/7/75/Netflix_icon.svg
netflix_alias="alias netflix=\"google-chrome ${netflix_url} &>/dev/null &\""
netflix_launcher="[Desktop Entry]
Categories=Network;VideoStreaming;Film;
Comment=Desktop app to reproduce Netflix from Chrome
Encoding=UTF-8
Exec=google-chrome ${netflix_url}
GenericName=Netflix
Icon=${USR_BIN_FOLDER}/netflix/netflix_icon.svg
Keywords=netflix;
MimeType=x-scheme-handler/tg;
Name=Netflix
StartupNotify=true
StartupWMClass=Netflix
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

openoffice_downloader="https://downloads.sourceforge.net/project/openofficeorg.mirror/4.1.9/binaries/en-US/Apache_OpenOffice_4.1.9_Linux_x86-64_install-deb_en-US.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fopenofficeorg.mirror%2Ffiles%2F4.1.9%2Fbinaries%2Fen-US%2FApache_OpenOffice_4.1.9_Linux_x86-64_install-deb_en-US.tar.gz%2Fdownload&ts=1614201028"

prompt_function="
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z \"\${debian_chroot:-}\" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=\$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we \"want\" color)
case \"\$TERM\" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n \"\$force_color_prompt\" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ \"\$color_prompt\" = yes ]; then
    # Colorful custom PS1
    PS1=\"\\[\\\e[1;37m\\]\\\\\\d \\\\\\\t \\[\\\e[0;32m\\]\\\\\u\[\\\e[4;35m\\]@\\[\\\e[0;36m\\]\\\\\\H\\[\\\e[0;33m\\] \\\\\\w\\[\\\e[0;32m\\] \\\\\\\$ \"
else
    PS1='\${debian_chroot:+(\$debian_chroot)}\u@\h:\w\\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case \"\$TERM\" in
xterm*|rxvt*)
    PS1=\"\$PS1\\[\\\e]0;\${debian_chroot:+(\$debian_chroot)}\u@\h: \w\\\a\]\"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval \"\$(dircolors -b ~/.dircolors)\" || eval \"\$(dircolors -b)\"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


"

pycharm_downloader=https://download.jetbrains.com/python/pycharm-community-2021.1.1.tar.gz
pycharm_launcher="[Desktop Entry]
Actions=NewWindow;
Categories=programming;dev;
Comment=Python IDE Community
Encoding=UTF-8
Exec=pycharm %F
GenericName=Pycharm
Icon=${HOME_FOLDER}/.bin/pycharm-community/bin/pycharm.png
Keywords=dev;programming;python;
MimeType=
Name=PyCharm
StartupNotify=true
StartupWMClass=jetbrains-pycharm
Terminal=false
TryExec=pycharm
Type=Application
Version=1.0

[Desktop Action NewWindow]
Name=Pycharm New Window
Exec=pycharm
Icon=${HOME_FOLDER}/.bin/pycharm-community/bin/pycharm.png"

pycharm_alias="alias pycharm=\"pycharm . &>/dev/null &\""

pycharm_professional_downloader=https://download.jetbrains.com/python/pycharm-professional-2020.3.2.tar.gz

pycharm_professional_launcher="[Desktop Entry]
Categories=programming;dev;
Comment=Python IDE for Professional Developers
Encoding=UTF-8
Exec=pycharm-pro %F
GenericName=Pycharm
Icon=${HOME_FOLDER}/.bin/pycharm-professional/bin/pycharm.png
Keywords=dev;programming;python;
MimeType=
Name=PyCharm Professional
StartupNotify=true
StartupWMClass=jetbrains-pycharm
Terminal=false
TryExec=pycharm-pro
Type=Application
Version=1.0"

pypy3_downloader=https://downloads.python.org/pypy/pypy3.6-v7.3.1-linux64.tar.bz2

s_function="
s()
{
  \"\$@\" &>/dev/null &
}
"

screenshots_function="
alias screenshot-full=\"gnome-screenshot -f ${XDG_PICTURES_DIR}/screenshots/Screenshot-\$(date +%Y-%m-%d-%H:%M:%S).png && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga\"
alias screenshot-window=\"gnome-screenshot -w -f ${XDG_PICTURES_DIR}/screenshots/Screenshot-\$(date +%Y-%m-%d-%H:%M:%S).png && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga\"
alias screenshot-area=\"gnome-screenshot -a -f ${XDG_PICTURES_DIR}/screenshots/Screenshot-\$(date +%Y-%m-%d-%H:%M:%S).png && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga\"
"

shell_history_optimization_function="
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=100000
export HISTFILESIZE=1000000
# append to the history file, don't overwrite it
shopt -s histappend
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoredups
# Ignore simple commands in history
HISTIGNORE=\"ls:ps:history:l:pwd:top:gitk\"
# The cmdhist shell option, if enabled, causes the shell to attempt to save each line of a multi-line command in the
# same history entry, adding semicolons where necessary to preserve syntactic correctness.
shopt -s cmdhist
# Save and reload from history before prompt appears
export PROMPT_COMMAND=\"history -a; history -r; \${PROMPT_COMMAND}\"
"

shortcut_aliases="export DESK=${XDG_DESKTOP_DIR}
export USR_BIN_FOLDER=${USR_BIN_FOLDER}
"

shotcut_desktop_launcher="[Desktop Entry]
Categories=video;
Comment= Open Source, cross-platform video editor
Encoding=UTF-8
Exec=shotcut
GenericName=shotcut
Icon=/usr/share/icons/hicolor/64x64/apps/org.shotcut.Shotcut.png
Keywords=video;editing;editor;VideoEdit;
MimeType=
Name=Shotcut
StartupNotify=true
StartupWMClass=ShotCut
Terminal=false
TryExec=shotcut
Type=Application
Version=1.0"

skype_downloader=https://go.skype.com/skypeforlinux-64.deb

slack_repository=https://downloads.slack-edge.com/linux_releases/slack-desktop-4.11.1-amd64.deb

steam_downloader=https://steamcdn-a.akamaihd.net/client/installer/steam.deb

sublime_text_downloader=https://download.sublimetext.com/sublime_text_3_build_3211_x64.tar.bz2

sublime_alias="alias sublime=\"sublime . &>/dev/null &\""
sublime_text_launcher="[Desktop Entry]
Categories=;
Comment=General Purpose Programming Text Editor
Encoding=UTF-8
Exec=sublime %F
GenericName=Text Editor, programming...
Icon=$HOME/.bin/sublime-text/Icon/256x256/sublime-text.png
Keywords=subl;sublime;
MimeType=
Name=Sublime Text
StartupNotify=true
StartupWMClass=Sublime
Terminal=false
TryExec=sublime
Type=Application
Version=1.0"

spotify_downloader=http://repository.spotify.com/pool/non-free/s/spotify-client/spotify-client_1.1.56.595.g2d2da0de_amd64.deb
telegram_icon=https://telegram.org/img/t_logo.svg?1
telegram_downloader=https://telegram.org/dl/desktop/linux
telegram_launcher="[Desktop Entry]
Categories=Network;
Comment=Instant messaging cross platform
Encoding=UTF-8
Exec=telegram -- %u
GenericName=Telegram
Icon=${USR_BIN_FOLDER}/telegram/telegram.svg
Keywords=telegram;
MimeType=x-scheme-handler/tg;
Name=Telegram
StartupNotify=true
StartupWMClass=Telegram
Terminal=false
TryExec=telegram
Type=Application
Version=1.0"

teams_downloader="https://go.microsoft.com/fwlink/p/?LinkID=2112886&clcid=0x40a&culture=es-es&country=ES"
tmux_launcher="[Desktop Entry]
Categories=Network;
Comment=Terminal Multiplexer
Encoding=UTF-8
Exec=tmux
GenericName=Terminal multiplexor with special mnemo-rules 'Ctrl+a'
Icon=/var/lib/app-info/icons/ubuntu-focal-universe/64x64/carla_carla.png
Keywords=tmux;
MimeType=
Name=tmux
StartupNotify=true
StartupWMClass=tmux
Terminal=true
TryExec=tmux
Type=Application
Version=1.0"

virtualbox_downloader=https://download.virtualbox.org/virtualbox/6.1.22/virtualbox-6.1_6.1.22-144080~Ubuntu~eoan_amd64.deb

visualstudiocode_downloader="https://go.microsoft.com/fwlink/?LinkID=620884"
code_alias="alias code=\"code . &>/dev/null &\""
visualstudiocode_launcher="[Desktop Entry]
Categories=Development;IDE;
Comment=Develop with pleasure!
Encoding=UTF-8
Exec=code %f
GenericName=IDE for programming
Icon=${HOME}/.bin/visual-studio/resources/app/resources/linux/code.png
Keywords=code;
MimeType=
Name=Visual Studio Code
StartupNotify=true
StartupWMClass=visual-studio-code
Terminal=false
TryExec=code
Type=Application
Version=1.0"

wallpapers_downloader=https://github.com/AleixMT/wallpapers
wallpapers_changer_script="#!/bin/bash
if [ -z \${DBUS_SESSION_BUS_ADDRESS+x} ]; then
  user=\$(whoami)
  fl=\$(find /proc -maxdepth 2 -user \$user -name environ -print -quit)
  while [ -z \$(grep -z DBUS_SESSION_BUS_ADDRESS \"\$fl\" | cut -d= -f2- | tr -d '\000' ) ]
  do
    fl=\$(find /proc -maxdepth 2 -user \$user -name environ -newer \"\$fl\" -print -quit)
  done
  export DBUS_SESSION_BUS_ADDRESS=\$(grep -z DBUS_SESSION_BUS_ADDRESS \"\$fl\" | cut -d= -f2-)
fi
DIR=\"${XDG_PICTURES_DIR}/wallpapers\"
PIC=\$(ls \${DIR} | shuf -n1)
dconf write \"/org/gnome/desktop/background/picture-uri\" \"'file://\${DIR}/\${PIC}'\"

#gsettings set org.gnome.desktop.background picture-uri \"'file://\${DIR}/\${PIC}'\"
"
wallpapers_cronjob="*/5 * * * * ${USR_BIN_FOLDER}/wallpaper_changer.sh"

whatsapp_url=https://web.whatsapp.com/
whatsapp_icon="https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg"
whatsapp_alias="alias whatsapp=\"google-chrome ${whatsapp_url} &>/dev/null &\""
whatsapp_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Whatsapp Web from Chrome
Encoding=UTF-8
Exec=google-chrome ${whatsapp_url}
GenericName=WhatsApp Web
Icon=${USR_BIN_FOLDER}/google-chrome/whatsapp_icon.svg
Keywords=forms;
MimeType=x-scheme-handler/tg;
Name=WhatsApp Web
StartupNotify=true
StartupWMClass=WhatsApp
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

youtube_url=https://youtube.com/
youtube_icon="https://upload.wikimedia.org/wikipedia/commons/4/4f/YouTube_social_white_squircle.svg"
youtube_alias="alias youtube=\"google-chrome ${youtube_url} &>/dev/null &\""
youtube_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open YouTube from Chrome
Encoding=UTF-8
Exec=google-chrome ${youtube_url}
GenericName=YouTube
Icon=${USR_BIN_FOLDER}/google-chrome/youtube_icon.svg
Keywords=forms;
MimeType=x-scheme-handler/tg;
Name=YouTube
StartupNotify=true
StartupWMClass=YouTube
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

youtubemusic_url=https://music.youtube.com
youtubemusic_icon="https://upload.wikimedia.org/wikipedia/commons/6/6a/Youtube_Music_icon.svg"
youtubemusic_alias="alias youtubemusic=\"google-chrome ${youtubemusic_url} &>/dev/null &\""
youtubemusic_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open YouTube Music from Chrome
Encoding=UTF-8
Exec=google-chrome ${youtubemusic_url}
GenericName=YouTube Music
Icon=${USR_BIN_FOLDER}/google-chrome/youtubemusic_icon.svg
Keywords=forms;
MimeType=x-scheme-handler/tg;
Name=YouTube Music
StartupNotify=true
StartupWMClass=YouTube Music
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

youtubedl_downloader=https://yt-dl.org/downloads/latest/youtube-dl

youtubewav_alias="alias youtubewav=\"youtube-dl --extract-audio --audio-format wav\""

zoom_downloader=https://zoom.us/client/latest/zoom_x86_64.tar.xz
zoom_icon_downloader=https://play-lh.googleusercontent.com/JgU6AIREDMsGLmrFSJ8OwLb-JJVw_jwqdwEZWUHemAj0V5Dl7i7GOpmranv2GsCKobM
zoom_launcher="[Desktop Entry]
Categories=Social;Communication;
Comment=Live Video Streaming for Meetings
Encoding=UTF-8
Exec=ZoomLauncher
GenericName=Video multiple calls
Icon=${USR_BIN_FOLDER}/zoom/zoom_icon.ico
Keywords=Social;VideoCalls;
MimeType=
Name=Zoom
StartupNotify=true
StartupWMClass=zoom
Terminal=false
TryExec=ZoomLauncher
Type=Application
Version=1.0"

###########################
##### SYSTEM FEATURES #####
###########################

### SYSTEM FEATURE RELATED VARIABLES ###

converters_downloader="https://github.com/Axlfc/converters"
converters_functions="bintooct()
{
  to \$1 2 3
}
bintoocto()
{
  to \$1 2 8
}
bintodec()
{
  to \$1 2 10
}
bintohex()
{
  to \$1 2 16
}

octtobin()
{
  to \$1 3 2
}
octtoocto()
{
  to \$1 3 8
}
octtodec()
{
  to \$1 3 10
}
octohex()
{
  to \$1 3 16
}

octotobin()
{
  to \$1 8 2
}
octotooct()
{
  to \$1 8 3
}
octotodec()
{
  to \$1 8 10
}
octotohex()
{
  to \$1 8 16
}

dectobin()
{
  to \$1 10 2
}
dectooct()
{
  to \$1 10 3
}
dectoocto()
{
  to \$1 10 8
}
dectohex()
{
  to \$1 10 16
}

hextobin()
{
  to \$1 16 2
}
hextooct()
{
  to \$1 16 3
}
hextoocto()
{
  to \$1 16 8
}
hextodec()
{
  to \$1 16 10
}"

ipe_function="
ipe()
{
  dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'\"' '{ print \$2 }';
}
"

extract_function="

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

L_function="

L()
{
  NEW_LINE=\$'\\\n'
  lsdisplay=\$(ls -lhA | tr -s \" \" | tail -n+2)
  numfiles=\$(printf \"\$lsdisplay\" | wc -l)
  dudisplay=\$(du -shxc .[!.]* * | sort -h | tr -s \"\\\t\" \" \")
  totaldu=\$(echo \${dudisplay} | rev | cut -d \" \" -f2 | rev)
  finaldisplay=\"\${totaldu} in \${numfiles} files and directories\$NEW_LINE\"
  IFS=\$'\\\n'
  for linels in \${lsdisplay}; do
    if [[ \$linels =~ ^d.* ]]; then
      foldername=\$(echo \$linels | cut -d ' ' -f9-)
      for linedu in \${dudisplay}; do
        if [[ \"\$(echo \${linedu} | cut -d ' ' -f2-)\" = \"\${foldername}\" ]]; then
          currentline=\$(echo \${linels} | cut -d \" \" -f-4)
          currentline=\"\$currentline \$(echo \${linedu} | cut -d ' ' -f1)\"
          currentline=\"\$currentline \$(echo \${linels} | cut -d ' ' -f6-)\"
          finaldisplay=\"\$finaldisplay\$NEW_LINE\$currentline\"
          break
        fi
      done
    else
      finaldisplay=\"\$finaldisplay\$NEW_LINE\$linels\"
    fi
  done
  finaldisplay=\"\${finaldisplay}\$NEW_LINE\$NEW_LINE\"
  printf \"\$finaldisplay\"
}
"

### TEMPLATES ###

c_file_template="########################################################################################################################
# -Name:
# -Description:
# -Creation Date:
# -Last Revision:
# -Author:
# -Email:
# -Permissions:
# -Args:
# -Usage:
# -License:
########################################################################################################################


#include \"c_script.h\"


int main(int nargs, char* args[])
{
  printf(\"Hello World\");
}
"

c_header_file_template="// Includes
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
"

makefile_file_template="CC = gcc
CFLAGS = -O3 -Wall

all : c_script

c_script : c_script.c
	\$(CC) \$(CFLAGS) c_script.c -o c_script -lm

run : c_script
	./c_script

.PHONY : clean
clean :
	rm -f c_script
"

python_file_template="#!/usr/bin/env python3
# -*- coding: utf-8 -*-
########################################################################################################################
# -Name:
# -Description:
# -Creation Date:
# -Last Revision:
# -Author:
# -Email:
# -Permissions:
# -Args:
# -Usage:
# -License:
########################################################################################################################


if __name__ == \"__main__\":
    print(\"HELLO WORLD!\")
    exit(0)
"

bash_file_template="#!/usr/bin/env bash

########################################################################################################################
# -Name:
# -Description:
# -Creation Date:
# -Last Modified:
# -Author:
# -Email:
# -Permissions:
# -Args:
# -Usage:
# -License:
########################################################################################################################

main()
{
  echo \"Hello World\"
  exit 0
}

set -e
main \"\$@\""

latex_file_template="%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2345678901234567890123456789012345678901234567890123456789012345678901234567890
%        1         2         3         4         5         6         7         8
\documentclass[11pt]{article}

% Use helvetica font (similar to Arial)
\renewcommand{\familydefault}{\sfdefault}
\usepackage[scaled=1]{helvet}

% Don't include Table of Contents (ToC) in ToC
% Don't include List of Figures (LoF) in ToC
% Don't include List of Tables (LoT) in ToC
% Include bibliography in ToC with its own section number
\usepackage[nottoc, notlot, notlof, numbib]{tocbibind}

% //W: Kept because error if these commands are removed
\title{}
\date{}
\author{}

\begin{document}


% Title Page
\begin{titlepage}
\centering
%\includegraphics[width=0.5\textwidth]{imgs/logourv}  % Logo
\par
\vspace{1cm}
\Large
{An exemple document of LaTeX\par}
\vspace{1cm}
{John Doe \par}
\vspace{1cm}
{\itshape\Large LaTeX FINAL PROJECT \par}
\vfill

\vspace{1cm}
%\includegraphics[width=0.7\textwidth]{imgs/grafportada}  % Portada Imagen
\par
\vspace{1cm}
\vfill

\large
\raggedright
{Tutor and supervisor: Jane Doe, UL, (jane.doe@LaTeX.cat) \par}
{In cooperation with: LaTeX and Friends \par}
\vspace{2cm}

\raggedleft
\large
November 2020
\par
\end{titlepage}

% Dont number the title page
\pagenumbering{gobble}

% Rest of the document
\setlength{\parskip}{1em}  % Set vertical separation between paragraphs
%\onehalfspacing  % spacing 1.5
\normalsize  % //Spec: normalsize = 11 pt (declared at e headers)

% Resumen (Abstract)
\newpage
\section*{Abstract}  % Use the * to not include section in ToC
  We try to explain a basic example of LaTeX. We will include ToC and references.

% Index (ToC)
\newpage
\setlength{\parskip}{0em}  % Set vertical separation = 0 between paragraphs in the index
\tableofcontents
\newpage

\setlength{\parskip}{1em}  % Set vertical separation between paragraphs for the rest of the doc
%\onehalfspacing  % //Spec: spacing 1.5

% First Section
\pagenumbering{arabic}  % Start numbering in the intro, not in the title or abstract page
\section{Hello World!}
  Hello World!

% Second Section
\section{Advanced Hello World}
  Hello, World. Basic LaTeX Operations:
  \subsection{Itemizes}
    \begin{itemize}
      \item One thing.
      \item Two things.
      \item Last
    \end{itemize}
  \subsection{Enumerates}
    \begin{enumerate}
      \item First thing
      \item Second thing
      \item Third thing \textbf{and last!}
    \end{enumerate}
  \subsection{References}
    We can use \cite{Doe20} to cite, but the same happens citing \cite{Doe19}.

% Bibliography
\newpage
\begin{thebibliography}{0}
\bibitem{Doe20} Doe, J., Martínez A. (2020). How to LaTeX with Linux Auto Customizer. University of Computing, Girona, Spain
\bibitem{Doe19} Doe, J., Priyatniva, A. \& Solanas, A. (2019). Referencing in LaTeX, 10th International Conference on Information, Intelligence, Systems and Applications. https://doi.org/20.1105/IISO.2019.8903718
\end{thebibliography}

\end{document}

"

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

help_arguments="
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


#### Feature arguments:

This arguments are used to select which features we want to install or uninstall
using install.sh or uninstall.sh respectively.
There are two types of selectable features: feature wrappers and individual
features.
  - Individual features are a certain installation, configuration or
  customization of a program or system module.
  - Feature wrappers group many individual features with the same permissions
  related to the same topic: programming, image edition, system cutomization...

## Individual features:
  --autofirma
  --androidstudio --studio                    Android Studio
  --ant|--apache_ant)
  --audacity|--Audacity)
  --atom|--Atom)
  --curl|--Curl)
  --discord|--Discord|--disc)
  --dropbox|--Dropbox|--DropBox|--Drop-box|--drop-box|--Drop-Box)
  --gcc|--GCC)
  --caffeine|--Caffeine|--cafe|--coffee)
  --calibre|--Calibre|--cali)
  --cheat|--cheat.sh|--Cheat.sh|--che)
  --cheese|--Cheese)
  --clementine|--Clementine)
  --clion|--Clion|--CLion)
  --cmatrix|--Cmatrix)
  --converters|--Converters)
  --clonezilla|--CloneZilla|--cloneZilla)
  --codium|--vscodium)
  --copyq|--copy-q|--copy_q|--copqQ|--Copyq|--copy-Q)
  --extract-function|-extract_function)
  --f-irc|--firc|--Firc|--irc)
  --firefox|--Firefox)
  --freecad|--FreeCAD|--freeCAD)
  --ffmpeg|--youtube-dl-dependencies)
  #--google-play-music|--musicmanager|--music-manager|--MusicManager|--playmusic|--GooglePlayMusic|--play-music|--google-playmusic|--Playmusic|--google-music)
  --gpaint|--paint|--Gpaint)
  --geany|--Geany)
  --git)
  --git-aliases|--git_aliases|--git-prompt)
  --GIMP|--gimp|--Gimp)
  --GNOME_Chess|--gnome_Chess|--gnomechess|--chess)
  --GParted|--gparted|--GPARTED|--Gparted)
  --gvim|--vim-gtk3|--Gvim|--GVim)
  --history-optimization)
  --parallel|--gnu_parallel|--GNUparallel|--GNUParallel|--gnu-parallel)
  --chrome|--Chrome|--google-chrome|--Google-Chrome)
  --iqmol|--IQmol)
  --inkscape|--ink-scape|--Inkscape|--InkScape)
  --intellijcommunity|--intelliJCommunity|--intelliJ-Community|--intellij-community|--ideac)
  --intellijultimate|--intelliJUltimate|--intelliJ-Ultimate|--intellij-ultimate|--ideau)
  --java|--javadevelopmentkit|--java-development-kit|--java-development-kit-11|--java-development-kit11|--jdk|--JDK|--jdk11|--JDK11|--javadevelopmentkit-11)
  --latex|--LaTeX|--tex|--TeX)
  --alias-l|--alias-ls|--l-alias|--ls-alias|--l)
  --maven|--mvn)
  --mahjongg|--Mahjongg|--gnome-mahjongg)
  --mega|--Mega|--MEGA|--MegaSync|--MEGAsync|--MEGA-sync|--megasync)
  --Mendeley|--mendeley|--mendeleyDesktop|--mendeley-desktop|--Mendeley-Desktop)
  --MendeleyDependencies|--mendeleydependencies|--mendeleydesktopdependencies|--mendeley-desktop-dependencies|--Mendeley-Desktop-Dependencies)
  --mines|--Mines|--GNU-mines|--gnome-mines|--gnomemines)
  --nemo|--nemo-desktop|--Nemo-Desktop|--Nemodesktop|--nemodesktop|--Nemo|--Nemodesk|--NemoDesktop)
  --notepadqq|--Notepadqq|--notepadQQ|--NotepadQQ|--notepadQq|--notepadQq|--NotepadQq|--NotepadqQ)
  --openoffice|--office|--Openoffice|--OpenOffice|--openOfice|--open_office|--Office)
  --OBS|--obs|--obs-studio|--obs_studio|--obs_Studio|--OBS_studio|--obs-Studio|--OBS_Studio|--OBS-Studio)
  --okular|--Okular|--okularpdf)
  --pacman|--pac-man)
  --pdfgrep|--findpdf|--pdf)
  --pluma)
  --postgreSQL|--PostGreSQL|--postgresql|--postgre-sql|--postgre-SQL|--psql|--pSQL|--p-SQL|--p-sql)
  --prompt)
  --pycharmcommunity|--pycharmCommunity|--pycharm_community|--pycharm|--pycharm-community)
  --pycharmpro|--pycharmPro|--pycharm_pro|--pycharm-pro|--Pycharm-Pro|--PyCharm-pro)
  -p|--python|--python3|--Python3|--Python)
  --pypy|--pypy3|--PyPy3|--PyPy)
  --dependencies|--pypy3_dependencies|--pypy3Dependencies|--PyPy3Dependencies|--pypy3dependencies|--pypy3-dependencies)
  --s|--s-function)
  --shotcut|--ShotCut|--Shotcut|--shot-cut|--shot_cut)
  --shortcuts)
  --sudoku|--Sudoku|--gnome-sudoku)
  --solitaire|--Solitaire|--gnome-solitaire|--aisleriot)
  --sublime|--sublimeText|--sublime_text|--Sublime|--sublime-Text|--sublime-text)
  --sudoku|--Sudoku|--GNU-sudoku|--gnome-sudoku|--gnomesudoku)
  --steam|--Steam|--STEAM)
  --Telegram|--telegram)
  --templates)
  --terminal-background|--terminal_background)
  --Terminator|--terminator)
  --Tilix|--tilix)
  --tmux|--Tmux)
  --thunderbird|--mozillathunderbird|--mozilla-thunderbird|--Thunderbird|--thunder-bird)
  --tor|--torbrowser|--tor_browser|--TOR|--TOR-browser|--TOR-BROSWER|--TORBROWSER|--TOR_BROWSER|--TOR_browser)
  --transmission|--transmission-gtk|--Transmission)
  --uget)
  --virtualbox|--virtual-box|--VirtualBox|--virtualBox|--Virtual-Box|--Virtualbox)
  --visualstudiocode|--visual-studio-code|--code|--Code|--visualstudio|--visual-studio)
  --vlc|--VLC|--Vlc)
  --Wallpapers|--wallpapers|--chwlppr)
  --youtube-dl)

## Wrapper arguments
  --user|--regular|--normal)
  --root|--superuser|--su)
  --ALL|--all|--All)
  --custom1


"

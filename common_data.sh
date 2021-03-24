#!/usr/bin/env bash
######################################
##### COMMON AUXILIARY FUNCTIONS #####
######################################

# Execute the command received in the first argument and redirect the output depending on the quietness level
# Argument 1: Bash command to execute.
# Argument 2: Quietness level [0, 1, 2].
output_proxy_executioner()
{
  if [[ $2 == 0 ]]; then
    $1
  elif [[ $2 == 1 ]]; then
    comm=$(echo "$1" | head -1 | cut -d " " -f1)
    if [[ "${comm}" == "echo" ]]; then
      # If it is a echo command, delete trailing echo and echo formatting
      rest=$(echo "$1" | sed '1 s@^echo @@')
      echo "$rest"
    else
      $1 &>/dev/null
    fi
  else
    $1 &>/dev/null
  fi
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
  export PATH=${PATH}:${DIR_IN_PATH}
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
FLAG_OVERWRITE=0  # 0 --> Skips a feature if it is already installed, 1 --> Install a feature even if it is already installed
FLAG_INSTALL=1  # 1 or more --> Install the feature provided to add_program. 0 --> DO NOT install the feature provided to add_program
# Also, flag_install is the number used to determine the installation order
FLAG_QUIETNESS=1  # 0 --> verbose mode, 1 --> only shows echoes from main script, 2 --> no output is shown
FLAG_IGNORE_ERRORS=0  # 1 --> the script will continue its execution even if an error is found. 0 --> Abort execution on error

NUM_INSTALLATION=1
SILENT=1
UPGRADE=2
AUTOCLEAN=2



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
"0;0;0;0;1;install_audacity"
"0;0;0;0;1;install_atom"
"0;0;0;0;0;install_discord"
"0;0;0;0;1;install_dropbox"
"0;0;0;0;1;install_gcc"
"0;0;0;0;1;install_caffeine"
"0;0;0;0;1;install_calibre"
"0;0;0;0;1;install_clementine"
"0;0;0;0;0;install_clion"
"0;0;0;0;0;install_cheat"
"0;0;0;0;1;install_cheese"
"0;0;0;0;1;install_cmatrix"
"0;1;0;0;0;install_codium"
"0;0;0;0;0;install_converters"
"0;0;0;0;1;install_clonezilla"
"0;0;0;0;1;install_copyq"
"0;0;0;0;1;install_curl"
"0;0;0;0;0;install_extract"
"0;0;0;0;1;install_f-irc"
"0;0;0;0;1;install_firefox"
"0;0;0;0;1;install_freecad"
"0;0;0;0;1;install_musicmanager"
"0;0;0;0;1;install_gpaint"
"0;0;0;0;1;install_geany"
"0;0;0;0;1;install_git"
"0;0;0;0;0;install_git_aliases"
"0;0;0;0;1;install_gimp"
"0;0;0;0;1;install_gparted"
"0;0;0;0;1;install_gvim"
"0;0;0;0;1;install_google-chrome"
"0;0;0;0;1;install_gnome-chess"
"0;0;0;0;1;install_parallel"
"0;0;0;0;0;install_history_optimization"
"0;0;0;0;1;install_inkscape"
"0;0;0;0;0;install_ideac"
"0;0;0;0;0;install_ideau"
"0;0;0;0;1;install_java"
"0;0;0;0;1;install_latex"
"0;0;0;0;0;install_l"
"0;0;0;0;1;install_gnome-mahjongg"
"0;0;0;0;1;install_megasync"
"0;0;0;0;1;install_mendeley_dependencies"
"0;0;0;0;1;install_gnome-mines"
"0;0;0;0;1;install_nemo"
"0;0;0;0;1;install_notepadqq"
"0;0;0;0;1;install_openoffice"
"0;0;0;0;1;install_obs"
"0;0;0;0;1;install_okular"
"0;0;0;0;1;install_pdfgrep"
"0;0;0;0;1;install_pluma"
"0;0;0;0;0;install_prompt"
"0;0;0;0;0;install_pycharm"
"0;0;0;0;0;install_pycharmpro"
"0;0;0;0;1;install_python3"
"0;0;0;0;0;install_pypy3"
"0;0;0;0;1;install_pypy3_dependencies"
"0;0;0;0;0;install_environment_aliases"
"0;0;0;0;1;install_steam"
"0;0;0;0;1;install_shotcut"
"0;0;0;0;0;install_shortcuts"
"0;0;0;0;1;install_aisleriot"
"0;0;0;0;0;install_studio"
"0;0;0;0;0;install_sublime"
"0;0;0;0;1;install_gnome-sudoku"
"0;0;0;0;0;install_telegram"
"0;0;0;0;0;install_templates"
"0;0;0;0;0;install_terminal_background"
"0;0;0;0;1;install_terminator"
"0;0;0;0;1;install_tilix"
"0;0;0;0;1;install_tmux"
"0;0;0;0;1;install_uget"
"0;0;0;0;1;install_thunderbird"
"0;0;0;0;1;install_torbrowser"
"0;0;0;0;1;install_transmission"
"0;0;0;0;1;install_virtualbox"
"0;0;0;0;0;install_code"
"0;0;0;0;1;install_vlc"
"0;0;0;0;0;install_chwlppr"
"0;0;0;0;1;install_youtube-dl"
)


####################
##### WRAPPERS #####
####################

# Associates lists representing a wrapper containing a set of related features

programming_core=( "python3" "gcc" "jdk11" "git" "GNU_parallel" "pypy3_dependencies" )
programming_ide=( "android_studio" "sublime_text" "pycharm" "intellij_community" "visualstudiocode" "pypy3" "clion" )
programming_pro=( "intellij_ultimate" "pycharm_professional" "clion" )
text_editor_core=( "atom" "openoffice" "latex" "geany" "notepadqq" "gvim" )
media_core=( "vlc" "gpaint" "okular" "clementine" )
system_core=( "virtualbox" "gparted" "clonezilla" )
internet_core=( "transmission" "thunderbird" "f-irc" "telegram" "dropbox" "discord" "megasync" "google_chrome" "firefox" "cheat" )
art_core=( "audacity" "shotcut" "gimp" "obs" "inkscape" )
games_install=( "games" "steam" "cmatrix" )
standard_install=("templates" "virtualbox" "environment" "converters" "thunderbird" "clonezilla" "gparted" "gpaint" "transmission" "vlc" "python3" "gcc" "jdk11" "pdfgrep" "nemo" "git" "openoffice" "mendeley_dependencies" "mendeley" "GNU_parallel" "pypy3_dependencies" "android_studio" "sublime_text" "pycharm" "intellij_community" "pypy3" "clion" "latex" "telegram" "dropbox" "discord" "megasync" "google_chrome" "firefox" )

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

# Variables used exclusively in the corresponding installation function. Alphabetically sorted.
#Name, GenericName, Type, Comment, Version, StartupWMClass, Icon, Exec, Terminal, Categories=IDE;Programming;, StartupNotify, MimeType=x-scheme-handler/tg;, Encoding=UTF-8
android_studio_downloader=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.1.2.0/android-studio-ide-201.7042882-linux.tar.gz
android_studio_alias="alias studio=\"studio . &>/dev/null &\""
android_studio_launcher="[Desktop Entry]
Name=Android Studio
GenericName=studio
Type=Application
Comment=IDE for developing android applications
Version=1.0
StartupWMClass=jetbrains-android-studio
Icon=${USR_BIN_FOLDER}/android-studio/bin/studio.svg
Exec=studio %F
Terminal=false
Categories=Development;IDE;
StartupNotify=true
MimeType=
Encoding=UTF-8"

atom_downloader=https://atom.io/download/deb

bash_functions_import="
source ${BASH_FUNCTIONS_PATH}
"

cheat_downloader=https://cht.sh/:cht.sh

clion_downloader=https://download.jetbrains.com/cpp/CLion-2020.1.tar.gz
clion_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=CLion
Icon=${HOME_FOLDER}/.bin/clion/bin/clion.png
Exec=clion %F
Comment=C and C++ IDE for Professional Developers
Terminal=false
StartupWMClass=jetbrains-clion"
clion_alias="alias clion=\"clion . &>/dev/null &\""

clonezilla_launcher="[Desktop Entry]
Name=CloneZilla
Comment=Create bootable clonezilla images
Icon=/usr/share/gdm/themes/drbl-gdm/clonezilla/ocslogo-1.png
Exec=sudo clonezilla
Terminal=true
Type=Application"

cmatrix_launcher="[Desktop Entry]
Name=CMatrix
StartupWMClass=cmatrix
Comment=Matrix
Terminal=true
Exec=cmatrix
Icon=/var/lib/app-info/icons/ubuntu-focal-universe/64x64/bless_bless-48x48.png
Type=Application"

codium_downloader=https://github.com/VSCodium/vscodium/releases/download/1.54.3/VSCodium-linux-x64-1.54.3.tar.gz
codium_launcher="[Desktop Entry]
Name=VSCodium
StartupWMClass=codium
Comment=Community-driven distribution of Microsoft’s editor VSCode.
GenericName=codium
Exec=codium
Icon=${USR_BIN_FOLDER}/codium/resources/app/resources/linux/code.png
Type=Application
Categories=IDE;Programming;
"

dropbox_downloader=https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb

discord_downloader="https://discord.com/api/download?platform=linux&format=tar.gz"
discord_launcher="[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=discord
Icon=${USR_BIN_FOLDER}/discord/discord.png
Type=Application
Categories=Network;InstantMessaging;"


firc_launcher="[Desktop Entry]
Name=F-irc
StartupWMClass=f-irc
Comment=IRC Simple chat
Terminal=true
Exec=f-irc
Icon=/var/lib/app-info/icons/ubuntu-focal-universe/64x64/flightgear_flightgear.png
Type=Application
"

git_aliases_function="
dummycommit()
{
  git add -A
  git commit -am \"\$1\"
  git push
}

alias gitk=\"gitk --all --date-order \"
if [ -f ${USR_BIN_FOLDER}/.bash-git-prompt/gitprompt.sh ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source ${USR_BIN_FOLDER}/.bash-git-prompt/gitprompt.sh
fi"

google_chrome_downloader=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

gpaint_icon_path=/usr/share/icons/hicolor/scalable/apps/gpaint.svg


intellij_ultimate_downloader="https://download.jetbrains.com/idea/ideaIU-2020.3.1.tar.gz"
intellij_ultimate_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Ultimate Edition
Icon=${HOME_FOLDER}/.bin/idea-iu/bin/idea.png
Exec=ideau %f
Comment=Capable and Ergonomic IDE for JVM
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea"
ideau_alias="alias ideau=\"ideau . &>/dev/null &\""


intellij_community_downloader="https://download.jetbrains.com/idea/ideaIC-2020.3.1.tar.gz"
intellij_community_launcher="[Desktop Entry]
Version=13.0
Type=Application
Terminal=false
Comment=Capable and Ergonomic IDE for JVM
Categories=Development;IDE;
Icon=${HOME_FOLDER}/.bin/idea-ic/bin/idea.png
Exec=ideac %f
Name=IntelliJ IDEA Community Edition
StartupWMClass=jetbrains-idea"
ideac_alias="alias ideac=\"ideac . &>/dev/null &\""

l_function="alias l=\"ls -lAh --color=auto\""

megasync_downloader=https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/megasync_4.3.8-1.1_amd64.deb
megasync_integrator_downloader=https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/nautilus-megasync_3.6.6_amd64.deb

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

obs_desktop_launcher="[Desktop Entry]
StartupWMClass=obs
Version=1.0
Name=OBS
GenericName=Streaming/Recording Software
Comment=Free and Open Source Streaming/Recording Software
Exec=obs
Icon=/usr/share/icons/hicolor/256x256/apps/com.obsproject.Studio.png
Terminal=false
Type=Application
Categories=AudioVideo;Recorder;
StartupNotify=true"

openoffice_downloader="https://downloads.sourceforge.net/project/openofficeorg.mirror/4.1.9/binaries/en-US/Apache_OpenOffice_4.1.9_Linux_x86-64_install-deb_en-US.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fopenofficeorg.mirror%2Ffiles%2F4.1.9%2Fbinaries%2Fen-US%2FApache_OpenOffice_4.1.9_Linux_x86-64_install-deb_en-US.tar.gz%2Fdownload&ts=1614201028"

prompt_function="export PS1=\"\\[\\\e[1;37m\\]\\\\\\d \\\\\\\t \\[\\\e[0;32m\\]\\\\\u\[\\\e[4;35m\\]@\\[\\\e[0;36m\\]\\\\\\H\\[\\\e[0;33m\\] \\\\\\w\\[\\\e[0;32m\\] \\\\\\\$ \""

pycharm_downloader=https://download.jetbrains.com/python/pycharm-community-2020.3.2.tar.gz
pycharm_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm 
Icon=${HOME_FOLDER}/.bin/pycharm-community/bin/pycharm.png
Exec=pycharm %F
Comment=Python IDE for Professional Developers
Terminal=false
StartupWMClass=jetbrains-pycharm"
pycharm_alias="alias pycharm=\"pycharm . &>/dev/null &\""

pycharm_professional_downloader=https://download.jetbrains.com/python/pycharm-professional-2020.3.2.tar.gz
pycharm_professional_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Professional
Icon=${HOME_FOLDER}/.bin/pycharm-professional/bin/pycharm.png
Exec=pycharm-pro %F
Comment=Python IDE for Professional Developers
Terminal=false
StartupWMClass=jetbrains-pycharm"
pycharmpro_alias="alias pycharmpro=\"pycharmpro . &>/dev/null &\""


pypy3_downloader=https://downloads.python.org/pypy/pypy3.6-v7.3.1-linux64.tar.bz2

shell_history_optimization_function="export HISTSIZE=10000
export HISTFILESIZE=100000
shopt -s histappend
HISTCONTROL=ignoredups
HISTIGNORE=\"ls:ps:history:l:pwd:top:gitk\"
shopt -s cmdhist"

shortcut_aliases="export DESK=${XDG_DESKTOP_DIR}
export USR_BIN_FOLDER=${USR_BIN_FOLDER}
"

shotcut_desktop_launcher="[Desktop Entry]
Type=Application
Name=Shotcut
GenericName=shotcut
Icon=/usr/share/icons/hicolor/64x64/apps/org.shotcut.Shotcut.png
Exec=shotcut
Comment= Open Source, cross-platform video editor
Terminal=false
"

slack_repository=https://downloads.slack-edge.com/linux_releases/
slack_version=slack-desktop-4.11.1-amd64.deb

steam_downloader=https://steamcdn-a.akamaihd.net/client/installer/steam.deb

sublime_text_downloader=https://download.sublimetext.com/sublime_text_3_build_3211_x64.tar.bz2
sublime_text_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=Sublime Text
GenericName=Text Editor
Icon=$HOME/.bin/sublime-text/Icon/256x256/sublime-text.png
Comment=General Purpose Programming Text Editor
Terminal=false
Exec=sublime %F"
sublime_alias="alias sublime=\"sublime . &>/dev/null &\""

telegram_downloader=https://telegram.org/dl/desktop/linux
telegram_launcher="[Desktop Entry]
Encoding=UTF-8
Name=Telegram
Exec=telegram -- %u
Icon=${USR_BIN_FOLDER}/telegram/telegram.png
Type=Application
Categories=Network;
MimeType=x-scheme-handler/tg;"

tmux_launcher="[Desktop Entry]
Name=tmux
StartupWMClass=tmux
Comment=Terminal Multiplexer
Exec=tmux
Terminal=true
Icon=/var/lib/app-info/icons/ubuntu-focal-universe/64x64/carla_carla.png
Type=Application
Categories=Network;"

virtualbox_downloader=https://download.virtualbox.org/virtualbox/6.1.12/virtualbox-6.1_6.1.12-139181~Ubuntu~eoan_amd64.deb

visualstudiocode_downloader="https://go.microsoft.com/fwlink/?LinkID=620884"
visualstudiocode_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=Visual Studio Code
Icon=$HOME/.bin/visual-studio-code/resources/app/extensions/jake/images/cowboy_hat.png
Exec=code %f
Comment=Develop with pleasure!
Categories=Development;IDE;
Terminal=false
StartupWMClass=visual-studio-code"
code_alias="alias code=\"code . &>/dev/null &\""

wallpapers_downloader=https://github.com/AleixMT/wallpapers
wallpapers_changer_script="#!/bin/bash
DIR=\"${XDG_PICTURES_DIR}\"
PIC=\$(ls \${DIR} | shuf -n1)

#if [[ -z \"\$DBUS_SESSION_BUS_ADDRESS\" ]]; then
#  TMP=~/.dbus/session-bus
#  export \$(grep -h DBUS_SESSION_BUS_ADDRESS=\$TMP/\$(ls -lt \$TMP | head -n 1))
#fi
#export \$(xargs -n 1 -0 echo </proc/\$(pidof x-session-manager)/environ | grep -Z \$DBUS_SESSION_BUS_ADDRESS=)
#echo \$DBUS_SESSION_BUS_ADDRESS > /home/aleixmt/Escritorio/test
user=\$(whoami)

fl=\$(find /proc -maxdepth 2 -user \$user -name environ -print -quit)
while [ -z \$(grep -z DBUS_SESSION_BUS_ADDRESS \"\$fl\" | cut -d= -f2- | tr -d '\000' ) ]
do
  fl=\$(find /proc -maxdepth 2 -user \$user -name environ -newer \"\$fl\" -print -quit)
done

export DBUS_SESSION_BUS_ADDRESS=\$(grep -z DBUS_SESSION_BUS_ADDRESS \"\$fl\" | cut -d= -f2-)

dconf write \"/org/gnome/desktop/background/picture-uri\" \"'file://\${DIR}/\${PIC}'\"

#gsettings set org.gnome.desktop.background picture-uri \"'file://\${DIR}/\${PIC}'\"
"
wallpapers_cronjob="* * * * * . ${USR_BIN_FOLDER}/wallpaper_changer.sh"


youtubewav_alias="alias youtubewav=\"youtube-dl --extract-audio --audio-format wav\""
###########################
##### SYSTEM FEATURES #####
###########################

### SYSTEM FEATURE RELATED VARIABLES ###

converters_downloader="https://github.com/Axlfc/converters"
converters_functions="bintohex()
{
  bintodec \$1 | dectohex
}
bintoutf()
{
  bintodec \$1 | dectoutf
}
hextobin()
{
  hextodec \$1 | dectobin
}
hextoutf()
{
  hextodec \$1 | dectoutf
}
utftobin()
{
  utftodec \$1 | dectobin
}
utftohex()
{
  utftodec \$1 | dectohex
}"

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
# Name:
# Description:
# Creation Date:
# Last Revision:
# Author:
# Email:
# Permissions:
# Args:
# Usage:
# License:
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
# Name:
# Description:
# Creation Date:
# Last Revision:
# Author:
# Email:
# Permissions:
# Args:
# Usage:
# License:
########################################################################################################################


if __name__ == \"__main__\":
    print(\"HELLO WORLD!\")
    exit(0)
"



bash_file_template="#!/usr/bin/env bash

########################################################################################################################
# Name:
# Description:
# Creation Date:
# Last Modified:
# Author:
# Email:
# Permissions:
# Args:
# Usage:
# License:
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



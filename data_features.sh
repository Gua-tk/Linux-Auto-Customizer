#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto Customizer data of features.                                                                      #
# - Description: Defines all variables containing the data needed to install and uninstall all features.               #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 11/8/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernandez Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: This script should not be executed directly, only sourced to import its variables.                    #
# - Arguments: No arguments                                                                                            #
# - Usage: Sourced from install.sh                                                                                     #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################

########################################################################################################################
######################################### IMPORT COMMON VARIABLES ######################################################
########################################################################################################################

if [ -f "${DIR}/data_common.sh" ]; then
  source "${DIR}/data_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: data_common.sh not found. Aborting..."
  exit 1
fi


########################################################################################################################
######################################## INSTALLATION SPECIFIC VARIABLES ###############################################
########################################################################################################################
# The variables in here follow a naming scheme that is required for each feature to obtain its data by variable        #
# indirect expansion. The variables that are defined for an installation determine its behaviour.                      #
# Each installations has its own FEATUREKEYNAME, which is an string that matches an unique feature. This string must   #
# be added to the array feature_keynames to be recognised by the customizer as an available installation.              #
# The variables must follow the next pattern: FEATUREKEYNAME_PROPERTY. Some variables can be defined in all features,  #
# some are only used depending on the installation type and others have to be defined always for each feature.         #
#                                                                                                                      #
#                                                                                                                      #
###### Available properties:                                                                                           #
#                                                                                                                      #
### Mandatory properties:                                                                                              #
#  - FEATUREKEYNAME_arguments: Array containing the arguments for each feature. Each argument has to be in lower case  #
#    and contain a _ in the possible parts of an argument where you could expect a separation with - or _. This is     #
#    used to match arguments ignoring case and separation symbols.                                                     #
#  - FEATUREKEYNAME_installationtype. Define the type of installation, which sets a fixed behaviour that obtains its   #
#    input from predefined sets of properties for each installation type (check next section Installation type         #
#    dependent properties). This can be set to:                                                                        #
#    * "packageinstall": Downloads a .deb package and installs it using dpkg.                                          #
#    * "packagemanager": Uses de package manager such as apt-get to install packages and dependency packages.          #
#    * "userinherit": Downloads a compressed file containing an unique folder.                                         #
#    * "repositoryclone": Clone a repository inside the directory of the current feature installing.                   #
#    * "environmental": Uses only the common part of every installation type. Has no type-dependent properties.        #
#  - FEATUREKEYNAME_readmeline: Contains the readme line of the table for each feature.                                #
#                                                                                                                      #
### Optional properties                                                                                                #
#  - FEATUREKEYNAME_launchernames: Array of names of launchers to be copied from the launchers folder of the system.   #
#    Used as fallback for autostart and associatedfiletypes.                                                           #
#  - FEATUREKEYNAME_binariesinstalledpaths: Array of relative paths from the downloaded folder of the features to      #
#    binaries that will be added to the PATH. Its name in the PATH is added by using a ";" to separate it from the     #
#    relative path: "binaries/common/handbreak.sh;handbreak".                                                          #
#  - FEATUREKEYNAME_launchercontents: Array of contents of launchers to be created in the desktop and dashboard.       #
#    They are used as fallback for autostart too.                                                                      #
#  - FEATUREKEYNAME_bashfunctions: Array of contents of functions to be executed on the start of every terminal        #
#    session, in our case .bashrc.                                                                                     #
#  - FEATUREKEYNAME_associatedfiletypes: Array of mime types to be associated with the feature. Its launchers in       #
#    launchercontents or the defined launchernames will be used as desktop launchers to associate the mime type.       #
#    Optionally it can have a custom desktop launcher added after a ; of an associated file type to use a custom       #
#    .desktop launcher: "text/x-chdr;sublime"                                                                          #
#  - FEATUREKEYNAME_keybindings: Array of keybindings to be associated with the feature. Each keybinding has 3 fields  #
#    separated. from each other using ";": Command;key_combination;keybinding_description.                             #
#  - FEATUREKEYNAME_downloads: Array of links to a valid download file separated by ";" from the desired name or full  #
#    pathfor that file.                                                                                                #
#    It will downloaded in ${BIN_FOLDER}/APPNAME/DESIREDFILENAME                                                       #
#  - FEATUREKEYNAME_manualcontentavailable: 3 bits separated by ; defining if there's manual code to be executed from  #
#    a function following the next naming rules: install_FEATUREKEYNAME_pre, install_FEATUREKEYNAME_mid,               #
#    install_FEATUREKEYNAME_post.                                                                                      #
#  - FEATUREKEYNAME_filekeys: Array contentaining the keys to indirect expand file to be created and its path          #
#  - FEATUREKEYNAME_FILEKEY_content: Variable with the content of a file identified in each feature with a particular  #
#    FILEKEY.                                                                                                          #
#  - FEATUREKEYNAME_FILEKEY_path: Variable with the path where we need to store the file with that FILEKEY.            #
#  - FEATUREKEYNAME_flagsoverride: Contains bits that will override the current state of the flags in the declared     #
#    installations. Its format is the following:                                                                       #
#            1                  2                   3                    4                  5                 6        #
#    ${FLAG_PERMISSION};${FLAG_OVERWRITE};${FLAG_IGNORE_ERRORS};${FLAG_QUIETNESS};${FLAG_FAVORITES};${FLAG_AUTOSTART}  #
#  - FEATUREKEYNAME_bashinitializations: Array containing bash scripts that executed on system boot, by default        #
#    ${HOME_FOLDER}/.profile.                                                                                          #
#  - FEATUREKEYNAME_autostartlaunchers: Array containing autostart launchers explicitly to respond to FLAG_AUTOSTART   #
#    and autostart on boot the feature where they are defined in.                                                      #
#                                                                                                                      #
### Installation type dependent properties                                                                             #
#  - FEATUREKEYNAME_packagenames: Array of names of packages to be installed using apt-get as dpendencies of the       #
#    feature. Used in: packageinstall, packagemanager.                                                                 #
#  - FEATUREKEYNAME_dependencies: Array of name of packages to be installed using apt-get before main installation.    #
#    Used in: packageinstall, packagemanager.                                                                          #
#  - FEATUREKEYNAME_packageurls: Link to the .deb file to download. Used in: packageinstall.                           #
#  - FEATUREKEYNAME_compressedfileurl: Internet link to a compressed file. Used in: userinherit and in packageinstall  #
#    as fallback if no urls are supplied in packageurls; in that case will also need a compressedfiletype.             #
#  - FEATUREKEYNAME_compressedfilepathoverride: Designs another path to perform the download and decompression.        #
#    Used in: userinherit.                                                                                             #
#  - FEATUREKEYNAME_compressedfiletype: Compression format of the compressed file in FEATUREKEYNAME_compressedfileurl. #
#    Used in userinherit and in packageinstall if no packageurls are supplied.                                         #
#  - FEATUREKEYNAME_repositoryurl: Repository to be cloned. Used in: repositoryclone.                                  #
#  - FEATUREKEYNAME_manualcontent: String containing three elements separated by ; that can be 1 or 0 and indicate if  #
#    there is manual code for that feature to be executed or not. If it is in one, it will try to execute a function   #
#    with its name following a certain pattern.                                                                        #
#  - FEATUREKEYNAME_pipinstallations: Array containing set of programs to be installed via pip. Used in: pythonvenv.   #
#  - FEATUREKEYNAME_pythoncommands: Array containing set of instructions to be executed by the venv using python3.     #
#    Used in: pythonvenv.                                                                                              #
########################################################################################################################



a_installationtype="environmental"
a_arguments=("a")
a_bashfunctions=("alias a=\"echo '---------------Alias----------------';compgen -a\"")
a_readmeline="| Function \`a\` | Prints a list of aliases using \`compgen -a\` | Command \`a\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

add_installationtype="environmental"
add_arguments=("add" "add_function")
add_bashfunctions=("alias add=\"git add\"")
add_readmeline="| Function \`add\` | alias for \`git add\` | Command \`add\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

aisleriot_installationtype="packagemanager"
aisleriot_arguments=("aisleriot" "solitaire" "gnome_solitaire")
aisleriot_launchernames=("sol")
aisleriot_packagenames=("aisleriot")
aisleriot_readmeline="| Solitaire aisleriot | Implementation of the classical game solitaire | Command \`aisleriot\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

alert_installationtype="environmental"
alert_arguments=("alert" "alert_alias" "alias_alert")
alert_bashfunctions=("
# Add an alert alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i \"\$([ \$? = 0 ] && echo terminal || echo error)\" \"\$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\\'')\"'
")
alert_readmeline="| Function \`alert\` | Alias to show a notification at the end of a command | Alias \`alert\`. Use it at the end of long running commands like so: \`sleep 10; alert\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li><li>- [ ] Debian</li></ul> |"

ansible_installationtype="packagemanager"
ansible_arguments=("ansible")
ansible_packagenames=("ansible")
ansible_readmeline="| Ansible | Automation of software | Command \`ansible\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

ant_installationtype="userinherit"
ant_arguments=("ant" "apache_ant")
ant_bashfunctions=("export ANT_HOME=\"${BIN_FOLDER}/ant\"")
ant_binariesinstalledpaths=("bin/ant;ant")
ant_compressedfiletype="z"
ant_compressedfileurl="https://ftp.cixug.es/apache//ant/binaries/apache-ant-1.10.11-bin.tar.gz"
ant_flagsoverride="1;;;;;"
ant_readmeline="| Apache Ant | Software tool for automating software build processes | Command \`ant\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |"

anydesk_installationtype="userinherit"
anydesk_arguments=("any_desk")
anydesk_bashfunctions=("alias anydesk=\"nohup anydesk &>/dev/null &\"")
anydesk_binariesinstalledpaths=("anydesk;anydesk")
anydesk_compressedfiletype="z"
anydesk_compressedfileurl="https://download.anydesk.com/linux/anydesk-6.1.1-amd64.tar.gz"
anydesk_readmelinedescription="Software to remote control other computers"
anydesk_readmeline="| Anydesk | ${anydesk_readmelinedescription} | Command \`anydesk\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
anydesk_launchercontents=("
[Desktop Entry]
Categories=Remote;control;other;
Comment=${anydesk_readmelinedescription}
Encoding=UTF-8
Exec=anydesk
GenericName=Remote desktop application
Icon=${BIN_FOLDER}/anydesk/icons/hicolor/scalable/apps/anydesk.svg
Keywords=IDE;programming;android;studio;dev;
MimeType=
Name=AnyDesk
StartupNotify=true
StartupWMClass=anydesk
Terminal=false
TryExec=anydesk
Type=Application
Version=1.0
")

ardour_installationtype="packagemanager"
ardour_arguments=("ardour")
ardour_bashfunctions=("alias ardour=\"nohup ardour &>/dev/null &\"")
ardour_packagenames=("ardour")
ardour_launchernames=("ardour")
ardour_readmeline="| Ardour | Software for music production | Commands \`ardour\`, Desktop launcher and Icon || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |  "


aspell_installationtype="packagemanager"
aspell_arguments=("aspell")
aspell_packagenames=("aspell-es" "aspell-ca")
aspell_readmeline="| Aspell | Spell checker | Command \`aspell\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

atom_installationtype="packageinstall"
atom_arguments=("atom")
atom_launchernames=("atom")
atom_packageurls=("https://atom.io/download/deb")
atom_readmeline="| Atom | Text and source code editor | Command \`atom\`, desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

audacity_installationtype="packagemanager"
audacity_arguments=("audacity")
audacity_bashfunctions=("alias audacity=\"nohup audacity &>/dev/null &\"")
audacity_launchernames=("audacity")
audacity_packagenames=("audacity" "audacity-data")
audacity_readmeline="| Audacity | Digital audio editor and recording | Command \`audacity\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

AutoFirma_installationtype="packageinstall"
AutoFirma_arguments=("auto_firma")
AutoFirma_bashfunctions=("alias autofirma=\"nohup AutoFirma &>/dev/null &\"")
AutoFirma_compressedfiletype="zip"
AutoFirma_compressedfileurl="https://estaticos.redsara.es/comunes/autofirma/currentversion/AutoFirma_Linux.zip"
AutoFirma_launchernames=("afirma")
AutoFirma_packagedependencies=("libnss3-tools")
AutoFirma_packagenames=("AutoFirma")
AutoFirma_readmeline="| AutoFirma | Electronic signature recognition | Command \`AutoFirma\` and desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

axel_installationtype="packagemanager"
axel_arguments=("axel")
axel_packagenames=("axel")
axel_readmeline="| Axel | Download manager | Command \`axel\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

b_installationtype="environmental"
b_arguments=("b" "b_function")
b_bashfunctions=("alias b=\"bash\"")
b_readmeline="| Function \`b\` | Alias for \`bash\` | Alias \`b\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

bashcolors_installationtype="environmental"
bashcolors_arguments=("bash_colors")
bashcolors_bashinitializations=("
##############################################################################################################################grey#######pink#######green######yellow#####purple#####red#######cyan#######orange####lighgrey##lightpink##lightgreen#lightyellow#lightpurple#lightred#lightcyan##lightorange
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:\${gnome_terminal_profile}/ palette \"['#262626', '#E356A7', '#42E66C', '#E4F34A', '#9B6BDF', '#E64747', '#75D7EC', '#EFA554', '#7A7A7A', '#FF79C6', '#50FA7B', '#F1FA8C', '#BD93F9', '#FF5555', '#8BE9FD', '#FFB86C']\"
")
bashcolors_bashfunctions=("
colors() {
  if [ -z \"\$(echo \"\${COLORS[@]}\")\" ]; then
    declare -Ar COLORS=(
      [BLACK]='\e[0;30m'
      [RED]='\e[0;31m'
      [GREEN]='\e[0;32m'
      [YELLOW]='\e[0;33m'
      [BLUE]='\e[0;34m'
      [PURPLE]='\e[0;35m'
      [CYAN]='\e[0;36m'
      [WHITE]='\e[0;37m'

      [BOLD_BLACK]='\e[1;30m'
      [BOLD_RED]='\e[1;31m'
      [BOLD_GREEN]='\e[1;32m'
      [BOLD_YELLOW]='\e[1;33m'
      [BOLD_BLUE]='\e[1;34m'
      [BOLD_PURPLE]='\e[1;35m'
      [BOLD_CYAN]='\e[1;36m'
      [BOLD_WHITE]='\e[1;37m'

      [UNDERLINE_BLACK]='\e[4;30m'
      [UNDERLINE_RED]='\e[4;31m'
      [UNDERLINE_GREEN]='\e[4;32m'
      [UNDERLINE_YELLOW]='\e[4;33m'
      [UNDERLINE_BLUE]='\e[4;34m'
      [UNDERLINE_PURPLE]='\e[4;35m'
      [UNDERLINE_CYAN]='\e[4;36m'
      [UNDERLINE_WHITE]='\e[4;37m'

      [BACKGROUND_BLACK]='\e[40m'
      [BACKGROUND_RED]='\e[41m'
      [BACKGROUND_GREEN]='\e[42m'
      [BACKGROUND_YELLOW]='\e[43m'
      [BACKGROUND_BLUE]='\e[44m'
      [BACKGROUND_PURPLE]='\e[45m'
      [BACKGROUND_CYAN]='\e[46m'
      [BACKGROUND_WHITE]='\e[47m'

      [CLEAR]='\e[0m'
    )
  fi

  if [ -n \"\$1\" ]; then
    local return_color=\"\${COLORS[\$(echo \"\$1\" | tr '[:lower:]' '[:upper:]')]}\"
    if [ -z \"\$(echo \"\${return_color}\")\" ]; then  # Not a color keyname
      for i in \"\${!COLORS[@]}\"; do  # Search for color and return its keyname
        if [ \"\${COLORS[\${i}]}\" == \"\$1\" ]; then
          return_color=\"\${i}\"
          echo \"\${return_color}\"
          return
        fi
      done
      # At this point \$1 is not a keyname or color
      if [ \"\$1\" == \"random\" ]; then  # Check for random color
        COLORS_arr=(\${COLORS[@]})
        echo -e \"\${COLORS_arr[\$RANDOM % \${#COLORS_arr[@]}]}\"
      elif [ \"\$1\" == \"randomkey\" ]; then
        COLORS_arr=(\${!COLORS[@]})
        echo \"\${COLORS_arr[\$RANDOM % \${#COLORS_arr[@]}]}\"
      elif [ \"\$1\" -ge 0 ]; then  # If a natural number passed return a color indexing by number
        COLORS_arr=(\${COLORS[@]})
        echo -e \"\${COLORS_arr[\$1 % \${#COLORS_arr[@]}]}\"
      else
        echo \"ERROR Not recognised option\"
      fi
    else  # Return color from indexing with dict
      echo -e \"\${return_color}\"
    fi
  else
    # Not an argument, show all colors with dictionary structure
    for i in \"\${!COLORS[@]}\"; do
      echo \"\${i}:\${COLORS[\${i}]}\"
    done
  fi
}
")
bashcolors_readmeline="| bashcolors | bring color to terminal | Command \`bashcolors\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

branch_installationtype="environmental"
branch_arguments=("branch")
branch_bashfunctions=("alias branch=\"git branch\"")
branch_readmeline="| Function \`branch\` | alias for \`git branch -vv\` | Command \`branch\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

brasero_installationtype="packagemanager"
brasero_arguments=("brasero")
brasero_bashfunctions=("alias brasero=\"nohup brasero &>/dev/null &\"")
brasero_launchernames=("brasero")
brasero_packagenames=("brasero")
brasero_readmeline="| Brasero | Software for image burning | Command \`brasero\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

c_installationtype="environmental"
c_arguments=("c")
c_bashfunctions=("
c()
{
  clear
	if [ -d \"\$1\" ]; then
		cd \$1
	elif [ -f \"\$1\" ]; then
		cat \$1
	fi
}
")
c_readmeline="| Function \`c\` | Function \`c\` that changes the directory or clears the screen | Function \`c \` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

caffeine_installationtype="packagemanager"
caffeine_arguments=("caffeine" "coffee" "cafe")
caffeine_launchernames=("caffeine-indicator")
caffeine_manualcontentavailable="1;0;1"
caffeine_packagenames=("caffeine")
caffeine_readmeline="| Caffeine | Simple indicator applet on Ubuntu panel that allows to temporarily prevent the activation of the screensaver, screen lock, and the sleep power saving mode. | Commands \`caffeine\`, \`caffeinate\` and \`caffeine-indicator\`, desktop launcher for \`caffeine\`, dashboard launcher for \`caffeine\` and \`caffeine-indicator\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

calibre_installationtype="packagemanager"
calibre_arguments=("calibre")
calibre_bashfunctions=("alias calibre=\"nohup calibre &>/dev/null &\"")
calibre_launchernames=("calibre-gui")
calibre_packagenames=("calibre")
calibre_readmeline="| Calibre | e-book reader| Commmand \`calibre\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

changebg_installationtype="repositoryclone"
changebg_arguments=("change_bg" "wallpaper" "wallpapers")
changebg_binariesinstalledpaths=".cronscript.sh;changebg"
changebg_cronscript_content="
#!/bin/bash
if [ -z \${DBUS_SESSION_BUS_ADDRESS+x} ]; then
  user=\$(whoami)
  fl=\$(find /proc -maxdepth 2 -user \$user -name environ -print -quit)
  while [ -z \$(grep -z DBUS_SESSION_BUS_ADDRESS \"\$fl\" | cut -d= -f2- | tr -d '\000' ) ]
  do
    fl=\$(find /proc -maxdepth 2 -user \$user -name environ -newer \"\$fl\" -print -quit)
  done
  export DBUS_SESSION_BUS_ADDRESS=\$(grep -z DBUS_SESSION_BUS_ADDRESS \"\$fl\" | cut -d= -f2-)
fi
DIR=\"${BIN_FOLDER}/changebg\"
PIC=\$(ls \${DIR} | shuf -n1)
echo \"\$DIR/\$PIC\"
dconf write \"/org/gnome/desktop/background/picture-uri\" \"'file://\${DIR}/\${PIC}'\"

#gsettings set org.gnome.desktop.background picture-uri \"'file://\${DIR}/\${PIC}'\"
"
changebg_cronscript_path=".cronscript.sh"
changebg_cronjob_content="*/5 * * * * ${BIN_FOLDER}/changebg/.cronscript.sh"
changebg_cronjob_path=".cronjob"
changebg_filekeys=("cronscript" "cronjob")
changebg_manualcontentavailable="0;0;1"
changebg_readmeline="| Function \`changebg\` | Function that changes the wallpaper using one random image from user images folder. It also downloads wallpapers and installs a cronjob to change the wallpaper every 5 minutes | Function \`changebg\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
changebg_repositoryurl="https://github.com/AleixMT/wallpapers"

cheat_installationtype="environmental"
cheat_arguments=("cheat" "cht.sh")
cheat_binariesinstalledpaths=("cht.sh;cheat")
cheat_downloads=("https://cht.sh/:cht.sh;cht.sh")
cheat_readmeline="| cheat.sh | Provides access to community-driven cheat sheets and snippets for Linux/UNIX commands and many programming languages | Command \`cheat\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

checkout_installationtype="environmental"
checkout_arguments=("checkout")
checkout_bashfunctions=("alias checkout=\"git checkout\"")
checkout_readmeline="| Function \`checkout\` | alias for \`git checkout\` | Command \`checkout\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

cheese_installationtype="packagemanager"
cheese_arguments=("cheese")
cheese_bashfunctions=("alias cheese=\"nohup cheese &>/dev/null &\"")
cheese_launchernames=("org.gnome.Cheese")
cheese_packagenames=("cheese")
cheese_readmeline="| Cheese | GNOME webcam application | Command \`cheese\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

clean_installationtype="environmental"
clean_arguments=("clean")
clean_bashfunctions=("
clean()
{
  if [ \${EUID} -eq 0 ]; then
    apt-get -y --fix-broken install
    apt-get update -y --fix-missing
    apt-get -y autoclean
    apt-get -y autoremove
  fi
  echo \"The recycle bin has been emptied\"
  rm -rf ${HOME}/.local/share/Trash/*
}
")
clean_readmeline="| Function \`clean\` | Remove files and contents from the trash bin and performs \`sudo apt-get -y autoclean\` and \`sudo apt-get -y autoremove\`. | Command \`clean\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

clementine_installationtype="packagemanager"
clementine_arguments=("clementine")
clementine_bashfunctions=("alias clementine=\"nohup clementine &>/dev/null &\"")
clementine_launchernames=("clementine")
clementine_packagenames=("clementine")
clementine_readmeline="| Clementine | Modern music player and library organizer | Command \`clementine\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

clion_installationtype="userinherit"
clion_arguments=("clion")
clion_associatedfiletypes=("text/x-c++hdr" "text/x-c++src" "text/x-chdr" "text/x-csrc")
clion_bashfunctions=("alias clion=\"nohup clion . &>/dev/null &\"")
clion_binariesinstalledpaths=("bin/clion.sh;clion")
clion_compressedfiletype="z"
clion_compressedfileurl="https://download.jetbrains.com/cpp/CLion-2020.1.tar.gz"
clion_launchercontents=("[Desktop Entry]
Categories=Development;IDE;
Comment=${clion_readmelinedescription}
Encoding=UTF-8
Exec=clion %F
GenericName=C Programing IDE
Icon=${BIN_FOLDER}/clion/bin/clion.png
Keywords=IDE;programming;android;studio;dev;
MimeType=
Name=CLion
StartupNotify=true
StartupWMClass=jetbrains-clion
Terminal=false
TryExec=clion
Type=Application
Version=1.0
")
clion_readmelinedescription="Cross-platform C/C++ IDE"
clion_readmeline="| Clion | ${clion_readmelinedescription} | Command \`clion\`, silent alias \`clion\`, desktop launcher, dashboard launcher, associated with mimetypes \`.c\`, \`.h\` and \`.cpp\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

clone_installationtype="environmental"
clone_arguments=("clone")
clone_bashfunctions=("
clone()
{
  if [ \$# -eq 0 ]; then
    echo \"ERROR: You need to provide at least one argument\"
    return
  else
    if [ -n \"\$(echo \"\$1\" | grep -Eo \"^http.?://.+$\")\" ]; then
      git clone \"\$1\"
    else
      git clone \"https://\$1\"
    fi
  fi
}
")
clone_readmeline="| Function \`clone\` | Function for \`git clone \$1\`|  Command \`clone\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

clonezilla_installationtype="packagemanager"
clonezilla_arguments=("clonezilla")
clonezilla_packagenames=("clonezilla")
clonezilla_launchercontents=("[Desktop Entry]
Categories=backup;images;restoration;boot;
Comment=${clonezilla_readmelinedescription}
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
Version=1.0
")
clonezilla_readmelinedescription="Disk cloning, disk imaging, data recovery, and deployment"
clonezilla_readmeline="| CloneZilla | ${clonezilla_readmelinedescription} | Command \`clonezilla\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

cmatrix_installationtype="packagemanager"
cmatrix_arguments=("cmatrix")
cmatrix_bashfunctions=("alias matrix=\"cmatrix -sC yellow\"")
cmatrix_launchercontents=("
[Desktop Entry]
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
Version=1.0
")
cmatrix_packagenames=("cmatrix")
cmatrix_readmelinedescription="Terminal screensaver from The Matrix"
cmatrix_readmeline="| Cmatrix | ${cmatrix_readmelinedescription} | Command \`cmatrix\`, function \`matrix\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

code_installationtype="userinherit"
code_arguments=("code" "visual_studio_code" "visual_studio")
code_bashfunctions=("alias code=\"nohup code . &>/dev/null &\"")
code_binariesinstalledpaths=("code;code")
code_compressedfiletype="z"
code_compressedfileurl="https://go.microsoft.com/fwlink/?LinkID=620884"
code_launchercontents=("[Desktop Entry]
Categories=Development;IDE;
Comment=${code_readmelinedescription}
Encoding=UTF-8
Exec=code %f
GenericName=IDE for programming
Icon=${BIN_FOLDER}/code/resources/app/resources/linux/code.png
Keywords=code;
MimeType=
Name=Visual Studio Code
StartupNotify=true
StartupWMClass=visual-studio-code
Terminal=false
TryExec=code
Type=Application
Version=1.0
")
code_readmelinedescription="Source-code editor"
code_readmeline="| Visual Studio Code | ${code_readmelinedescription} | Command \`code\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

codeblocks_installationtype="packagemanager"
codeblocks_arguments=("codeblocks" "code::blocks")
codeblocks_bashfunctions=("alias codeblocks=\"nohup codeblocks &>/dev/null &\"")
codeblocks_launchernames=("codeblocks")
codeblocks_packagenames=("codeblocks")
codeblocks_readmeline="| Code::Blocks | IDE for programming  | Command \`codeblocks\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

commit_installationtype="environmental"
commit_arguments=("commit")
commit_bashfunctions=("
commit()
{
    messag=\"\$@\"
    while [ -z \"\$messag\" ]; do
      read -p \"Add message: \" messag
    done
    git commit -am \"\$messag\"
}
")
commit_readmeline="| Function \`commit\` | Function \`commit\` that makes \`git commit -am \"\$1\"\` | Function \`commit\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> "

converters_installationtype="repositoryclone"
converters_arguments=("converters")
converters_bashfunctions=("
bintooct()
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
}
")
converters_binariesinstalledpaths=("converters/to.py;to" "converters/dectoutf.py;dectoutf" "converters/utftodec.py;utftodec")
converters_readmeline="| Converters | Set of converter Python scripts that integrate in your environment as \`bash\` commands | Commands \`bintodec\`, \`dectobin\`, \`dectohex\`, \`dectoutf\`, \`escaper\`, \`hextodec\`, \`to\` and \`utftodec\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "
converters_repositoryurl="https://github.com/Axlfc/converters"

copyq_installationtype="packagemanager"
copyq_arguments=("copyq")
copyq_launchernames=("com.github.hluk.copyq")
copyq_packagenames=("copyq")
copyq_readmeline="| copyq | A clipboard manager application that comes with extra features such as editing and scripting | Command \`copyq\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

curl_installationtype="packagemanager"
curl_arguments=("curl")
curl_packagenames=("curl")
curl_readmeline="| Curl | Curl is a CLI command for retrieving or sending data to a server | Command \`curl\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

customizer_installationtype="environmental"
customizer_arguments=("customizer" "linux_auto_customizer" "auto_customizer" "linux_customizer")
customizer_repositoryurl="https://github.com/AleixMT/Linux-Auto-Customizer"
customizer_manualcontentavailable="0;0;1"
customizer_flagsoverride="0;;;;;"  # Install always as root
customizer_bashfunctions=("
_customizer-install() {
  COMPREPLY=()
  local arguments=\"\$(echo \"\$(customizer-install --commands)\")\"
  COMPREPLY=( \$(compgen -W \"\${arguments}\" -- \"\${COMP_WORDS[COMP_CWORD]}\") )
}
complete -F _customizer-install customizer-install
")
customizer_readmeline="| Linux Auto Customizer | Program and function management and automations | Command \`customizer-install\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

dbeaver_installationtype="packageinstall"
dbeaver_arguments=("dbeaver")
dbeaver_packageurls=("https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb")
dbeaver_launchernames=("dbeaver")
dbeaver_readmeline="| DBeaver | SQL Client IDE | Command \`dbeaver\` desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

dconf_editor_installationtype="packagemanager"
dconf_editor_arguments=("dconf_editor" "dconf")
dconf_editor_launchernames=("ca.desrt.dconf-editor")
dconf_editor_packagenames=("dconf-editor")
dconf_editor_readmeline="| dconf-editor | Editor settings | Command \`dconf-editor\` and desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

dia_installationtype="packagemanager"
dia_arguments=("dia")
dia_packagenames=("dia-common")
dia_launchernames=("dia")
dia_bashfunctions=("alias dia=\"nohup dia &>/dev/null &\"")
dia_readmeline="| Dia | Graph and relational  | Command \`dia\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

discord_installationtype="userinherit"
discord_arguments=("discord")
discord_bashfunctions=("alias discord=\"nohup discord &>/dev/null &\"")
discord_binariesinstalledpaths=("Discord;discord")
discord_compressedfiletype="z"
discord_compressedfileurl="https://discord.com/api/download?platform=linux&format=tar.gz"
discord_launchercontents=("
[Desktop Entry]
Categories=Network;InstantMessaging;
Comment=${discord_readmelinedescription}
Encoding=UTF-8
Exec=discord
GenericName=Internet Messenger
Icon=${BIN_FOLDER}/discord/discord.png
Keywords=VoiceChat;Messaging;Social;
MimeType=
Name=Discord
StartupNotify=true
StartupWMClass=discord
Terminal=false
TryExec=discord
Type=Application
Version=1.0
")
discord_readmelinedescription="All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone."
discord_readmeline="| Discord | ${discord_readmelinedescription} | Command \`discord\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

docker_installationtype="userinherit"
docker_arguments=("docker")
docker_compressedfiletype="z"
docker_compressedfileurl="https://download.docker.com/linux/static/stable/x86_64/docker-20.10.6.tgz"
docker_binariesinstalledpaths=("docker;docker" "containerd;containerd" "containerd-shim;containerd-shim" "containerd-shim-runc-v2;containerd-shim-runc-v2" "ctr;ctr" "dockerd;dockerd" "docker-init;docker-init" "docker-proxy;docker-proxy" "runc;runc")
docker_readmeline="| Docker | Containerization service | Command \`docker\`, \`containerd\`, \`containerd-shim\`, \`containerd-shim-runc-v2\`, \`ctr\`, \`dockerd\`, \`docker-init\`, \`docker-proxy\`, \`runc\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

documents_installationtype="environmental"
documents_arguments=("documents" "google_document" "google_documents" "document")
documents_url="https://docs.google.com/document/"
documents_bashfunctions=("alias documents=\"nohup xdg-open ${documents_url} &>/dev/null &\"")
documents_downloads=("https://upload.wikimedia.org/wikipedia/commons/6/66/Google_Docs_2020_Logo.svg;documents_icon.svg")
documents_readmelinedescription="Google Documents opening in Chrome"
documents_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${documents_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${documents_url}
Icon=${BIN_FOLDER}/documents/documents_icon.svg
GenericName=Document
Keywords=documents;
MimeType=
Name=Google Documents
StartupNotify=true
StartupWMClass=Google Documents
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
documents_readmeline="| Google Documents | ${documents_readmelinedescription} | Command \`document\` and desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

drive_installationtype="environmental"
drive_arguments=("drive" "google_drive")
drive_url="https://drive.google.com/"
drive_bashfunctions=("alias drive=\"nohup xdg-open ${drive_url} &>/dev/null &\"")
drive_downloads=("https://upload.wikimedia.org/wikipedia/commons/1/12/Google_Drive_icon_%282020%29.svg;drive_icon.svg")
drive_readmelinedescription="Google Drive opening in Chrome"
drive_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${drive_readmelinedescription}
Encoding=UTF-8
GenericName=drive
Keywords=drive;
MimeType=
Name=Google Drive
StartupNotify=true
StartupWMClass=Google Drive
Terminal=false
Exec=xdg-open ${drive_url}
Icon=${BIN_FOLDER}/drive/drive_icon.svg
TryExec=google-chrome
Type=Application
Version=1.0
")
drive_readmeline="| Google Drive | ${drive_readmelinedescription} | Command \`drive\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

dropbox_installationtype="packageinstall"
dropbox_arguments=("dropbox")
dropbox_packagenames=("dropbox")
dropbox_launchernames=("dropbox")
dropbox_packagedependencies=("python3-gpg")
dropbox_packageurls=("https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb")
dropbox_readmeline="| Dropbox | File hosting service | Command \`dropbox\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

duckduckgo_installationtype="environmental"
duckduckgo_arguments=("duckduckgo")
duckduckgo_url="https://duckduckgo.com/"
duckduckgo_bashfunctions=("alias duckduckgo=\"nohup xdg-open ${duckduckgo_url} &>/dev/null &\"")
duckduckgo_downloads=("https://icon-icons.com/downloadimage.php?id=67089&root=844/SVG/&file=DuckDuckGo_icon-icons.com_67089.svg;duckduckgo_icon.svg")
duckduckgo_readmelinedescription="Opens DuckDuckGo in Chrome"
duckduckgo_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${duckduckgo_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${duckduckgo_url}
Icon=${BIN_FOLDER}/duckduckgo/duckduckgo_icon.svg
GenericName=DuckDuckGo
Keywords=duckduckgo
Name=DuckDuckGo
StartupNotify=true
StartupWMClass=DuckDuckGo
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
duckduckgo_readmeline="| DuckDuckGo | ${duckduckgo_readmelinedescription} | Command \`duckduckgo\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

dummycommit_installationtype="environmental"
dummycommit_arguments=("dummycommit")
dummycommit_bashfunctions=("
dummycommit()
{
  git add -A
  messag=\"\$@\"
  while [ -z \"\$messag\" ]; do
    read -p \"Add message: \" messag
  done
  git commit -am \"\$messag\"
  git push
}
")
dummycommit_readmeline="| Function \`dummycommit\` | Do the following commands \`git add -a\` \`git commit -am \$1\` \`git push\` | Command \`dummycommit\`|| <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"


e_installationtype="environmental"
e_arguments=("e")
e_bashfunctions=("
e()
{
  if [ -z \"\$1\" ]; then
    editor new_text_file &
  else
    if [ -f \"\$1\" ]; then
      if [ ! -z \$(echo \"\$1\" | grep -Fo \"/\") ]; then
  			local -r dir_name=\"\$(echo \"\$1\" | rev | cut -d '/' -f2- | rev)\"
  			mkdir -p \"\${dir_name}\"
				cd \"\${dir_name}\"
      fi
      case \"\$1\" in
        *)
          nohup pluma \"\$1\" &>/dev/null &
        ;;
        *.py)
          nohup pycharm \"\$1\" &>/dev/null &
        ;;
        *.tex)
          nohup texmaker \"\$1\" &>/dev/null &
        ;;
        *.pdf)
          nohup okular \"\$1\" &>/dev/null &
        ;;
        *.rtf)
          nohup gedit \"\$1\" &>/dev/null &
        ;;
      esac
		else
			if [ -d \"\$1\" ]; then
				cd \"\$1\"
				if [ -d \".git\" ]; then
				  git fetch
          nohup gitk --all --date-order &>/dev/null &
          nohup pycharm &>/dev/null &
				else
          nohup nemo \"\$1\" &>/dev/null &
				fi
			else
        #Inexistent route or new file
        if [ ! -z \$(echo \"\$1\" | grep -Fo \"/\") ]; then
          local -r dir_name=\"\$(echo \"\$1\" | rev | cut -d '/' -f2- | rev)\"
          if [ -d \"\${dir_name}\" ]; then
            cd \"\${dir_name}\"
          else
            mkdir -p \"\${dir_name}\"
            cd \"\${dir_name}\"
          fi
          editor \"\$(echo \"\$1\" | rev | cut -d '/' -f1 | rev)\" &
        else
          case \"\$1\" in
            *.py)
              nohup pycharm \"\$1\" &>/dev/null &
            ;;
            *.tex)
              nohup texmaker \"\$1\" &>/dev/null &
            ;;
            *)
              nohup pluma \"\$1\" &>/dev/null &
            ;;
         esac
        fi
			fi
		fi
	fi
}
")
e_readmeline="| Function \`e\` | Multi Function \`e\` to edit a file or project in folder | Function \`e\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

eclipse_installationtype="userinherit"
eclipse_arguments=("eclipse")
eclipse_bashfunctions="alias=\"nobup eclips &>/dev/null &\""
eclipse_binariesinstalledpaths=("eclipse;eclipse")
eclipse_compressedfiletype="z"
eclipse_compressedfileurl="http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.2.2-201302041200/eclipse-SDK-4.2.2-linux-gtk-x86_64.tar.gz"
eclipse_readmelinedescription="IDE for Java"
eclipse_launchercontents=("[Desktop Entry]
Categories=Development;IDE;
Comment=${eclipse_readmelinedescription}
Encoding=UTF-8
Exec=eclipse
GenericName=IDE
Icon=${BIN_FOLDER}/eclipse/icon.xpm
Keywords=IDE;programming;
MimeType=
Name=Eclipse IDE
StartupNotify=true
StartupWMClass=Eclipse
Terminal=false
TryExec=eclipse
Type=Application
Version=4.2.2
")
eclipse_readmeline="| Eclipse | ${eclipse_readmelinedescription} | Command \`eclipse\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

edit_installationtype="environmental"
edit_bashfunctions=("
edit() {
  declare -Arl EDITABLEFILES=(
    [aliases]=\"${HOME_FOLDER}/.bash_aliases\"
    [allbashrc]=\"${BASHRC_ALL_USERS_PATH}\"
    [bashfunctions]=\"${FUNCTIONS_PATH}\"
    [bashrc]=\"${BASHRC_PATH}\"
    [favorites]=\"${PROGRAM_FAVORITES_PATH}\"
    [initializations]=\"${INITIALIZATIONS_PATH}\"
    [keybindings]=\"${PROGRAM_KEYBINDINGS_PATH}\"
    [mime]=\"${MIME_ASSOCIATION_PATH}\"
    [profile]=\"${PROFILE_PATH}\"
    [sshconf]=\"${HOME_FOLDER}/.ssh/config\"
    [tmuxconf]=\"${HOME_FOLDER}/.tmux.conf\"
    )
  if [ \$# -eq 0 ]; then
    echo \"Recognised arguments to edit:\"
    for i in \"\${!EDITABLEFILES[@]}\"; do
      echo \"\${i}:\${EDITABLEFILES[\${i}]}\"
    done
  else
    while [ -n \"\$1\" ]; do
      local path_editable=\"\${EDITABLEFILES[\"\$1\"]}\"
      if [ -z \"\${path_editable}\" ]; then
        if [ -f \"\$1\" ]; then
          nohup editor \"\$1\" &>/dev/null &
        else
          echo \"\$1 is not a valid file or option.\"
        fi
      else
        nohup editor \"\${path_editable}\" &>/dev/null &
      fi
      shift
    done
  fi
}
")
edit_readmeline="| Function \`edit\` | Multi Function \`edit\` to edit a set of hardcoded key files using an argument | Function \`edit\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

emojis_installationtype="environmental"
emojis_arguments=("emojis" "emoji")
emojis_packagedependencies=("fonts-symbola")
emojis_readmeline=
emojis_bashfunctions=("
emoji() {
  if [ -z \"\$(echo \"\${EMOJIS[@]}\")\" ]; then
    declare -Ar EMOJIS=(
      [grinning_face]=😀
      [grinning_face_with_big_eyes]=😃
      [grinning_face_with_smiling_eyes]=😄
      [beaming_face_with_smiling_eyes]=😁
      [grinning_squinting_face]=😆
      [grinning_face_with_sweat]=😅
      [rolling_on_the_floor_laughing]=🤣
      [face_with_tears_of_joy]=😂
      [slightly_smiling_face]=🙂
      [upside_down_face]=🙃
      [winking_face]=😉
      [smiling_face_with_smiling_eyes]=😊
      [smiling_face_with_halo]=😇
      [smiling_face_with_hearts]=🥰
      [smiling_face_with_heart_eyes]=😍
      [star_struck]=🤩
      [face_blowing_a_kiss]=😘
      [kissing_face]=😗
      [smiling_face]=☺
      [kissing_face_with_closed_eyes]=😚
      [kissing_face_with_smiling_eyes]=😙
      [face_savoring_food]=😋
      [face_with_tongue]=😛
      [winking_face_with_tongue]=😜
      [zany_face]=🤪
      [squinting_face_with_tongue]=😝
      [money_mouth_face]=🤑
      [hugging_face]=🤗
      [face_with_hand_over_mouth]=🤭
      [shushing_face]=🤫
      [thinking_face]=🤔
      [zipper_mouth_face]=🤐
      [face_with_raised_eyebrow]=🤨
      [neutral_face]=😐
      [expressionless_face]=😑
      [face_without_mouth]=😶
      [smirking_face]=😏
      [unamused_face]=😒
      [face_with_rolling_eyes]=🙄
      [grimacing_face]=😬
      [lying_face]=🤥
      [relieved_face]=😌
      [pensive_face]=😔
      [sleepy_face]=😪
      [drooling_face]=🤤
      [sleeping_face]=😴
      [face_with_medical_mask]=😷
      [face_with_thermometer]=🤒
      [face_with_head_bandage]=🤕
      [nauseated_face]=🤢
      [face_vomiting]=🤮
      [sneezing_face]=🤧
      [hot_face]=🥵
      [cold_face]=🥶
      [woozy_face]=🥴
      [dizzy_face]=😵
      [exploding_head]=🤯
      [cowboy_hat_face]=🤠
      [partying_face]=🥳
      [smiling_face_with_sunglasses]=😎
      [nerd_face]=🤓
      [face_with_monocle]=🧐
      [confused_face]=😕
      [worried_face]=😟
      [slightly_frowning_face]=🙁
      [frowning_face]=☹
      [face_with_open_mouth]=😮
      [hushed_face]=😯
      [astonished_face]=😲
      [flushed_face]=😳
      [pleading_face]=🥺
      [frowning_face_with_open_mouth]=😦
      [anguished_face]=😧
      [fearful_face]=😨
      [anxious_face_with_sweat]=😰
      [sad_but_relieved_face]=😥
      [crying_face]=😢
      [loudly_crying_face]=😭
      [face_screaming_in_fear]=😱
      [confounded_face]=😖
      [persevering_face]=😣
      [disappointed_face]=😞
      [downcast_face_with_sweat]=😓
      [weary_face]=😩
      [tired_face]=😫
      [yawning_face]=🥱
      [face_with_steam_from_nose]=😤
      [pouting_face]=😡
      [angry_face]=😠
      [face_with_symbols_on_mouth]=🤬
      [smiling_face_with_horns]=😈
      [angry_face_with_horns]=👿
      [skull]=💀
      [skull_and_crossbones]=☠
      [pile_of_poo]=💩
      [clown_face]=🤡
      [ogre]=👹
      [goblin]=👺
      [ghost]=👻
      [alien]=👽
      [alien_monster]=👾
      [robot]=🤖
      [grinning_cat]=😺
      [grinning_cat_with_smiling_eyes]=😸
      [cat_with_tears_of_joy]=😹
      [smiling_cat_with_heart_eyes]=😻
      [cat_with_wry_smile]=😼
      [kissing_cat]=😽
      [weary_cat]=🙀
      [crying_cat]=😿
      [pouting_cat]=😾
      [see_no_evil_monkey]=🙈
      [hear_no_evil_monkey]=🙉
      [speak_no_evil_monkey]=🙊
      [kiss_mark]=💋
      [love_letter]=💌
      [heart_with_arrow]=💘
      [heart_with_ribbon]=💝
      [sparkling_heart]=💖
      [growing_heart]=💗
      [beating_heart]=💓
      [revolving_hearts]=💞
      [two_hearts]=💕
      [heart_decoration]=💟
      [heart_exclamation]=❣
      [broken_heart]=💔
      [red_heart]=❤
      [orange_heart]=🧡
      [yellow_heart]=💛
      [green_heart]=💚
      [blue_heart]=💙
      [purple_heart]=💜
      [brown_heart]=🤎
      [black_heart]=🖤
      [white_heart]=🤍
      [hundred_points]=💯
      [anger_symbol]=💢
      [collision]=💥
      [dizzy]=💫
      [sweat_droplets]=💦
      [dashing_away]=💨
      [hole]=🕳
      [bomb]=💣
      [speech_balloon]=💬
      [eye_in_speech_bubble]=👁️‍🗨️
      [left_speech_bubble]=🗨
      [right_anger_bubble]=🗯
      [thought_balloon]=💭
      [zzz]=💤
      [waving_hand]=👋
      [raised_back_of_hand]=🤚
      [hand_with_fingers_splayed]=🖐
      [raised_hand]=✋
      [vulcan_salute]=🖖
      [ok_hand]=👌
      [pinching_hand]=🤏
      [victory_hand]=✌
      [crossed_fingers]=🤞
      [love_you_gesture]=🤟
      [sign_of_the_horns]=🤘
      [call_me_hand]=🤙
      [backhand_index_pointing_left]=👈
      [backhand_index_pointing_right]=👉
      [backhand_index_pointing_up]=👆
      [middle_finger]=🖕
      [backhand_index_pointing_down]=👇
      [index_pointing_up]=☝
      [thumbs_up]=👍
      [thumbs_down]=👎
      [raised_fist]=✊
      [oncoming_fist]=👊
      [left_facing_fist]=🤛
      [right_facing_fist]=🤜
      [clapping_hands]=👏
      [raising_hands]=🙌
      [open_hands]=👐
      [palms_up_together]=🤲
      [handshake]=🤝
      [folded_hands]=🙏
      [writing_hand]=✍
      [nail_polish]=💅
      [selfie]=🤳
      [flexed_biceps]=💪
      [mechanical_arm]=🦾
      [mechanical_leg]=🦿
      [leg]=🦵
      [foot]=🦶
      [ear]=👂
      [ear_with_hearing_aid]=🦻
      [nose]=👃
      [brain]=🧠
      [tooth]=🦷
      [bone]=🦴
      [eyes]=👀
      [eye]=👁
      [tongue]=👅
      [mouth]=👄
      [baby]=👶
      [child]=🧒
      [boy]=👦
      [girl]=👧
      [person]=🧑
      [person_blond_hair]=👱
      [man]=👨
      [man_beard]=🧔
      [man_blond_hair]=👱‍♂️
      [man_red_hair]=👨‍🦰
      [man_curly_hair]=👨‍🦱
      [man_white_hair]=👨‍🦳
      [man_bald]=👨‍🦲
      [woman]=👩
      [woman_blond_hair]=👱‍♀️
      [woman_red_hair]=👩‍🦰
      [woman_curly_hair]=👩‍🦱
      [woman_white_hair]=👩‍🦳
      [woman_bald]=👩‍🦲
      [older_person]=🧓
      [old_man]=👴
      [old_woman]=👵
      [person_frowning]=🙍
      [man_frowning]=🙍‍♂️
      [woman_frowning]=🙍‍♀️
      [person_pouting]=🙎
      [man_pouting]=🙎‍♂️
      [woman_pouting]=🙎‍♀️
      [person_gesturing_no]=🙅
      [man_gesturing_no]=🙅‍♂️
      [woman_gesturing_no]=🙅‍♀️
      [person_gesturing_ok]=🙆
      [man_gesturing_ok]=🙆‍♂️
      [woman_gesturing_ok]=🙆‍♀️
      [person_tipping_hand]=💁
      [man_tipping_hand]=💁‍♂️
      [woman_tipping_hand]=💁‍♀️
      [person_raising_hand]=🙋
      [man_raising_hand]=🙋‍♂️
      [woman_raising_hand]=🙋‍♀️
      [deaf_person]=🧏
      [deaf_man]=🧏‍♂️
      [deaf_woman]=🧏‍♀️
      [person_bowing]=🙇
      [man_bowing]=🙇‍♂️
      [woman_bowing]=🙇‍♀️
      [person_facepalming]=🤦
      [man_facepalming]=🤦‍♂️
      [woman_facepalming]=🤦‍♀️
      [person_shrugging]=🤷
      [man_shrugging]=🤷‍♂️
      [woman_shrugging]=🤷‍♀️
      [man_health_worker]=👨‍⚕️
      [woman_health_worker]=👩‍⚕️
      [man_student]=👨‍🎓
      [woman_student]=👩‍🎓
      [man_teacher]=👨‍🏫
      [woman_teacher]=👩‍🏫
      [man_judge]=👨‍⚖️
      [woman_judge]=👩‍⚖️
      [man_farmer]=👨‍🌾
      [woman_farmer]=👩‍🌾
      [man_cook]=👨‍🍳
      [woman_cook]=👩‍🍳
      [man_mechanic]=👨‍🔧
      [woman_mechanic]=👩‍🔧
      [man_factory_worker]=👨‍🏭
      [woman_factory_worker]=👩‍🏭
      [man_office_worker]=👨‍💼
      [woman_office_worker]=👩‍💼
      [man_scientist]=👨‍🔬
      [woman_scientist]=👩‍🔬
      [man_technologist]=👨‍💻
      [woman_technologist]=👩‍💻
      [man_singer]=👨‍🎤
      [woman_singer]=👩‍🎤
      [man_artist]=👨‍🎨
      [woman_artist]=👩‍🎨
      [man_pilot]=👨‍✈️
      [woman_pilot]=👩‍✈️
      [man_astronaut]=👨‍🚀
      [woman_astronaut]=👩‍🚀
      [man_firefighter]=👨‍🚒
      [woman_firefighter]=👩‍🚒
      [police_officer]=👮
      [man_police_officer]=👮‍♂️
      [woman_police_officer]=👮‍♀️
      [detective]=🕵
      [man_detective]=🕵️‍♂️
      [woman_detective]=🕵️‍♀️
      [guard]=💂
      [man_guard]=💂‍♂️
      [woman_guard]=💂‍♀️
      [construction_worker]=👷
      [man_construction_worker]=👷‍♂️
      [woman_construction_worker]=👷‍♀️
      [prince]=🤴
      [princess]=👸
      [person_wearing_turban]=👳
      [man_wearing_turban]=👳‍♂️
      [woman_wearing_turban]=👳‍♀️
      [man_with_chinese_cap]=👲
      [woman_with_headscarf]=🧕
      [man_in_tuxedo]=🤵
      [bride_with_veil]=👰
      [pregnant_woman]=🤰
      [breast_feeding]=🤱
      [baby_angel]=👼
      [santa_claus]=🎅
      [mrs_claus]=🤶
      [superhero]=🦸
      [man_superhero]=🦸‍♂️
      [woman_superhero]=🦸‍♀️
      [supervillain]=🦹
      [man_supervillain]=🦹‍♂️
      [woman_supervillain]=🦹‍♀️
      [mage]=🧙
      [man_mage]=🧙‍♂️
      [woman_mage]=🧙‍♀️
      [fairy]=🧚
      [man_fairy]=🧚‍♂️
      [woman_fairy]=🧚‍♀️
      [vampire]=🧛
      [man_vampire]=🧛‍♂️
      [woman_vampire]=🧛‍♀️
      [merperson]=🧜
      [merman]=🧜‍♂️
      [mermaid]=🧜‍♀️
      [elf]=🧝
      [man_elf]=🧝‍♂️
      [woman_elf]=🧝‍♀️
      [genie]=🧞
      [man_genie]=🧞‍♂️
      [woman_genie]=🧞‍♀️
      [zombie]=🧟
      [man_zombie]=🧟‍♂️
      [woman_zombie]=🧟‍♀️
      [person_getting_massage]=💆
      [man_getting_massage]=💆‍♂️
      [woman_getting_massage]=💆‍♀️
      [person_getting_haircut]=💇
      [man_getting_haircut]=💇‍♂️
      [woman_getting_haircut]=💇‍♀️
      [person_walking]=🚶
      [man_walking]=🚶‍♂️
      [woman_walking]=🚶‍♀️
      [person_standing]=🧍
      [man_standing]=🧍‍♂️
      [woman_standing]=🧍‍♀️
      [person_kneeling]=🧎
      [man_kneeling]=🧎‍♂️
      [woman_kneeling]=🧎‍♀️
      [man_with_probing_cane]=👨‍🦯
      [woman_with_probing_cane]=👩‍🦯
      [man_in_motorized_wheelchair]=👨‍🦼
      [woman_in_motorized_wheelchair]=👩‍🦼
      [man_in_manual_wheelchair]=👨‍🦽
      [woman_in_manual_wheelchair]=👩‍🦽
      [person_running]=🏃
      [man_running]=🏃‍♂️
      [woman_running]=🏃‍♀️
      [woman_dancing]=💃
      [man_dancing]=🕺
      [man_in_suit_levitating]=🕴
      [people_with_bunny_ears]=👯
      [men_with_bunny_ears]=👯‍♂️
      [women_with_bunny_ears]=👯‍♀️
      [person_in_steamy_room]=🧖
      [man_in_steamy_room]=🧖‍♂️
      [woman_in_steamy_room]=🧖‍♀️
      [person_climbing]=🧗
      [man_climbing]=🧗‍♂️
      [woman_climbing]=🧗‍♀️
      [person_fencing]=🤺
      [horse_racing]=🏇
      [skier]=⛷
      [snowboarder]=🏂
      [person_golfing]=🏌
      [man_golfing]=🏌️‍♂️
      [woman_golfing]=🏌️‍♀️
      [person_surfing]=🏄
      [man_surfing]=🏄‍♂️
      [woman_surfing]=🏄‍♀️
      [person_rowing_boat]=🚣
      [man_rowing_boat]=🚣‍♂️
      [woman_rowing_boat]=🚣‍♀️
      [person_swimming]=🏊
      [man_swimming]=🏊‍♂️
      [woman_swimming]=🏊‍♀️
      [person_bouncing_ball]=⛹
      [man_bouncing_ball]=⛹️‍♂️
      [woman_bouncing_ball]=⛹️‍♀️
      [person_lifting_weights]=🏋
      [man_lifting_weights]=🏋️‍♂️
      [woman_lifting_weights]=🏋️‍♀️
      [person_biking]=🚴
      [man_biking]=🚴‍♂️
      [woman_biking]=🚴‍♀️
      [person_mountain_biking]=🚵
      [man_mountain_biking]=🚵‍♂️
      [woman_mountain_biking]=🚵‍♀️
      [person_cartwheeling]=🤸
      [man_cartwheeling]=🤸‍♂️
      [woman_cartwheeling]=🤸‍♀️
      [people_wrestling]=🤼
      [men_wrestling]=🤼‍♂️
      [women_wrestling]=🤼‍♀️
      [person_playing_water_polo]=🤽
      [man_playing_water_polo]=🤽‍♂️
      [woman_playing_water_polo]=🤽‍♀️
      [person_playing_handball]=🤾
      [man_playing_handball]=🤾‍♂️
      [woman_playing_handball]=🤾‍♀️
      [person_juggling]=🤹
      [man_juggling]=🤹‍♂️
      [woman_juggling]=🤹‍♀️
      [person_in_lotus_position]=🧘
      [man_in_lotus_position]=🧘‍♂️
      [woman_in_lotus_position]=🧘‍♀️
      [person_taking_bath]=🛀
      [person_in_bed]=🛌
      [people_holding_hands]=🧑‍🤝‍🧑
      [women_holding_hands]=👭
      [woman_and_man_holding_hands]=👫
      [men_holding_hands]=👬
      [kiss]=💏
      [kiss_woman_man]=👩‍❤️‍💋‍👨
      [kiss_man_man]=👨‍❤️‍💋‍👨
      [kiss_woman_woman]=👩‍❤️‍💋‍👩
      [couple_with_heart]=💑
      [couple_with_heart_woman_man]=👩‍❤️‍👨
      [couple_with_heart_man_man]=👨‍❤️‍👨
      [couple_with_heart_woman_woman]=👩‍❤️‍👩
      [family]=👪
      [family_man_woman_boy]=👨‍👩‍👦
      [family_man_woman_girl]=👨‍👩‍👧
      [family_man_woman_girl_boy]=👨‍👩‍👧‍👦
      [family_man_woman_boy_boy]=👨‍👩‍👦‍👦
      [family_man_woman_girl_girl]=👨‍👩‍👧‍👧
      [family_man_man_boy]=👨‍👨‍👦
      [family_man_man_girl]=👨‍👨‍👧
      [family_man_man_girl_boy]=👨‍👨‍👧‍👦
      [family_man_man_boy_boy]=👨‍👨‍👦‍👦
      [family_man_man_girl_girl]=👨‍👨‍👧‍👧
      [family_woman_woman_boy]=👩‍👩‍👦
      [family_woman_woman_girl]=👩‍👩‍👧
      [family_woman_woman_girl_boy]=👩‍👩‍👧‍👦
      [family_woman_woman_boy_boy]=👩‍👩‍👦‍👦
      [family_woman_woman_girl_girl]=👩‍👩‍👧‍👧
      [family_man_boy]=👨‍👦
      [family_man_boy_boy]=👨‍👦‍👦
      [family_man_girl]=👨‍👧
      [family_man_girl_boy]=👨‍👧‍👦
      [family_man_girl_girl]=👨‍👧‍👧
      [family_woman_boy]=👩‍👦
      [family_woman_boy_boy]=👩‍👦‍👦
      [family_woman_girl]=👩‍👧
      [family_woman_girl_boy]=👩‍👧‍👦
      [family_woman_girl_girl]=👩‍👧‍👧
      [speaking_head]=🗣
      [bust_in_silhouette]=👤
      [busts_in_silhouette]=👥
      [footprints]=👣
      [red_hair]=🦰
      [curly_hair]=🦱
      [white_hair]=🦳
      [bald]=🦲
      [monkey_face]=🐵
      [monkey]=🐒
      [gorilla]=🦍
      [orangutan]=🦧
      [dog_face]=🐶
      [dog]=🐕
      [guide_dog]=🦮
      [service_dog]=🐕‍🦺
      [poodle]=🐩
      [wolf]=🐺
      [fox]=🦊
      [raccoon]=🦝
      [cat_face]=🐱
      [cat]=🐈
      [lion]=🦁
      [tiger_face]=🐯
      [tiger]=🐅
      [leopard]=🐆
      [horse_face]=🐴
      [horse]=🐎
      [unicorn]=🦄
      [zebra]=🦓
      [deer]=🦌
      [cow_face]=🐮
      [ox]=🐂
      [water_buffalo]=🐃
      [cow]=🐄
      [pig_face]=🐷
      [pig]=🐖
      [boar]=🐗
      [pig_nose]=🐽
      [ram]=🐏
      [ewe]=🐑
      [goat]=🐐
      [camel]=🐪
      [two_hump_camel]=🐫
      [llama]=🦙
      [giraffe]=🦒
      [elephant]=🐘
      [rhinoceros]=🦏
      [hippopotamus]=🦛
      [mouse_face]=🐭
      [mouse]=🐁
      [rat]=🐀
      [hamster]=🐹
      [rabbit_face]=🐰
      [rabbit]=🐇
      [chipmunk]=🐿
      [hedgehog]=🦔
      [bat]=🦇
      [bear]=🐻
      [koala]=🐨
      [panda]=🐼
      [sloth]=🦥
      [otter]=🦦
      [skunk]=🦨
      [kangaroo]=🦘
      [badger]=🦡
      [paw_prints]=🐾
      [turkey]=🦃
      [chicken]=🐔
      [rooster]=🐓
      [hatching_chick]=🐣
      [baby_chick]=🐤
      [front_facing_baby_chick]=🐥
      [bird]=🐦
      [penguin]=🐧
      [dove]=🕊
      [eagle]=🦅
      [duck]=🦆
      [swan]=🦢
      [owl]=🦉
      [flamingo]=🦩
      [peacock]=🦚
      [parrot]=🦜
      [frog]=🐸
      [crocodile]=🐊
      [turtle]=🐢
      [lizard]=🦎
      [snake]=🐍
      [dragon_face]=🐲
      [dragon]=🐉
      [sauropod]=🦕
      [t_rex]=🦖
      [spouting_whale]=🐳
      [whale]=🐋
      [dolphin]=🐬
      [fish]=🐟
      [tropical_fish]=🐠
      [blowfish]=🐡
      [shark]=🦈
      [octopus]=🐙
      [spiral_shell]=🐚
      [snail]=🐌
      [butterfly]=🦋
      [bug]=🐛
      [ant]=🐜
      [honeybee]=🐝
      [lady_beetle]=🐞
      [cricket]=🦗
      [spider]=🕷
      [spider_web]=🕸
      [scorpion]=🦂
      [mosquito]=🦟
      [microbe]=🦠
      [bouquet]=💐
      [cherry_blossom]=🌸
      [white_flower]=💮
      [rosette]=🏵
      [rose]=🌹
      [wilted_flower]=🥀
      [hibiscus]=🌺
      [sunflower]=🌻
      [blossom]=🌼
      [tulip]=🌷
      [seedling]=🌱
      [evergreen_tree]=🌲
      [deciduous_tree]=🌳
      [palm_tree]=🌴
      [cactus]=🌵
      [sheaf_of_rice]=🌾
      [herb]=🌿
      [shamrock]=☘
      [four_leaf_clover]=🍀
      [maple_leaf]=🍁
      [fallen_leaf]=🍂
      [leaf_fluttering_in_wind]=🍃
      [grapes]=🍇
      [melon]=🍈
      [watermelon]=🍉
      [tangerine]=🍊
      [lemon]=🍋
      [banana]=🍌
      [pineapple]=🍍
      [mango]=🥭
      [red_apple]=🍎
      [green_apple]=🍏
      [pear]=🍐
      [peach]=🍑
      [cherries]=🍒
      [strawberry]=🍓
      [kiwi_fruit]=🥝
      [tomato]=🍅
      [coconut]=🥥
      [avocado]=🥑
      [eggplant]=🍆
      [potato]=🥔
      [carrot]=🥕
      [ear_of_corn]=🌽
      [hot_pepper]=🌶
      [cucumber]=🥒
      [leafy_green]=🥬
      [broccoli]=🥦
      [garlic]=🧄
      [onion]=🧅
      [mushroom]=🍄
      [peanuts]=🥜
      [chestnut]=🌰
      [bread]=🍞
      [croissant]=🥐
      [baguette_bread]=🥖
      [pretzel]=🥨
      [bagel]=🥯
      [pancakes]=🥞
      [waffle]=🧇
      [cheese_wedge]=🧀
      [meat_on_bone]=🍖
      [poultry_leg]=🍗
      [cut_of_meat]=🥩
      [bacon]=🥓
      [hamburger]=🍔
      [french_fries]=🍟
      [pizza]=🍕
      [hot_dog]=🌭
      [sandwich]=🥪
      [taco]=🌮
      [burrito]=🌯
      [stuffed_flatbread]=🥙
      [falafel]=🧆
      [egg]=🥚
      [cooking]=🍳
      [shallow_pan_of_food]=🥘
      [pot_of_food]=🍲
      [bowl_with_spoon]=🥣
      [green_salad]=🥗
      [popcorn]=🍿
      [butter]=🧈
      [salt]=🧂
      [canned_food]=🥫
      [bento_box]=🍱
      [rice_cracker]=🍘
      [rice_ball]=🍙
      [cooked_rice]=🍚
      [curry_rice]=🍛
      [steaming_bowl]=🍜
      [spaghetti]=🍝
      [roasted_sweet_potato]=🍠
      [oden]=🍢
      [sushi]=🍣
      [fried_shrimp]=🍤
      [fish_cake_with_swirl]=🍥
      [moon_cake]=🥮
      [dango]=🍡
      [dumpling]=🥟
      [fortune_cookie]=🥠
      [takeout_box]=🥡
      [crab]=🦀
      [lobster]=🦞
      [shrimp]=🦐
      [squid]=🦑
      [oyster]=🦪
      [soft_ice_cream]=🍦
      [shaved_ice]=🍧
      [ice_cream]=🍨
      [doughnut]=🍩
      [cookie]=🍪
      [birthday_cake]=🎂
      [shortcake]=🍰
      [cupcake]=🧁
      [pie]=🥧
      [chocolate_bar]=🍫
      [candy]=🍬
      [lollipop]=🍭
      [custard]=🍮
      [honey_pot]=🍯
      [baby_bottle]=🍼
      [glass_of_milk]=🥛
      [hot_beverage]=☕
      [teacup_without_handle]=🍵
      [sake]=🍶
      [bottle_with_popping_cork]=🍾
      [wine_glass]=🍷
      [cocktail_glass]=🍸
      [tropical_drink]=🍹
      [beer_mug]=🍺
      [clinking_beer_mugs]=🍻
      [clinking_glasses]=🥂
      [tumbler_glass]=🥃
      [cup_with_straw]=🥤
      [beverage_box]=🧃
      [mate]=🧉
      [ice_cube]=🧊
      [chopsticks]=🥢
      [fork_and_knife_with_plate]=🍽
      [fork_and_knife]=🍴
      [spoon]=🥄
      [kitchen_knife]=🔪
      [amphora]=🏺
      [globe_showing_europe_africa]=🌍
      [globe_showing_americas]=🌎
      [globe_showing_asia_australia]=🌏
      [globe_with_meridians]=🌐
      [world_map]=🗺
      [map_of_japan]=🗾
      [compass]=🧭
      [snow_capped_mountain]=🏔
      [mountain]=⛰
      [volcano]=🌋
      [mount_fuji]=🗻
      [camping]=🏕
      [beach_with_umbrella]=🏖
      [desert]=🏜
      [desert_island]=🏝
      [national_park]=🏞
      [stadium]=🏟
      [classical_building]=🏛
      [building_construction]=🏗
      [brick]=🧱
      [houses]=🏘
      [derelict_house]=🏚
      [house]=🏠
      [house_with_garden]=🏡
      [office_building]=🏢
      [japanese_post_office]=🏣
      [post_office]=🏤
      [hospital]=🏥
      [bank]=🏦
      [hotel]=🏨
      [love_hotel]=🏩
      [convenience_store]=🏪
      [school]=🏫
      [department_store]=🏬
      [factory]=🏭
      [japanese_castle]=🏯
      [castle]=🏰
      [wedding]=💒
      [tokyo_tower]=🗼
      [statue_of_liberty]=🗽
      [church]=⛪
      [mosque]=🕌
      [hindu_temple]=🛕
      [synagogue]=🕍
      [shinto_shrine]=⛩
      [kaaba]=🕋
      [fountain]=⛲
      [tent]=⛺
      [foggy]=🌁
      [night_with_stars]=🌃
      [cityscape]=🏙
      [sunrise_over_mountains]=🌄
      [sunrise]=🌅
      [cityscape_at_dusk]=🌆
      [sunset]=🌇
      [bridge_at_night]=🌉
      [hot_springs]=♨
      [carousel_horse]=🎠
      [ferris_wheel]=🎡
      [roller_coaster]=🎢
      [barber_pole]=💈
      [circus_tent]=🎪
      [locomotive]=🚂
      [railway_car]=🚃
      [high_speed_train]=🚄
      [bullet_train]=🚅
      [train]=🚆
      [metro]=🚇
      [light_rail]=🚈
      [station]=🚉
      [tram]=🚊
      [monorail]=🚝
      [mountain_railway]=🚞
      [tram_car]=🚋
      [bus]=🚌
      [oncoming_bus]=🚍
      [trolleybus]=🚎
      [minibus]=🚐
      [ambulance]=🚑
      [fire_engine]=🚒
      [police_car]=🚓
      [oncoming_police_car]=🚔
      [taxi]=🚕
      [oncoming_taxi]=🚖
      [automobile]=🚗
      [oncoming_automobile]=🚘
      [sport_utility_vehicle]=🚙
      [delivery_truck]=🚚
      [articulated_lorry]=🚛
      [tractor]=🚜
      [racing_car]=🏎
      [motorcycle]=🏍
      [motor_scooter]=🛵
      [manual_wheelchair]=🦽
      [motorized_wheelchair]=🦼
      [auto_rickshaw]=🛺
      [bicycle]=🚲
      [kick_scooter]=🛴
      [skateboard]=🛹
      [bus_stop]=🚏
      [motorway]=🛣
      [railway_track]=🛤
      [oil_drum]=🛢
      [fuel_pump]=⛽
      [police_car_light]=🚨
      [horizontal_traffic_light]=🚥
      [vertical_traffic_light]=🚦
      [stop_sign]=🛑
      [construction]=🚧
      [anchor]=⚓
      [sailboat]=⛵
      [canoe]=🛶
      [speedboat]=🚤
      [passenger_ship]=🛳
      [ferry]=⛴
      [motor_boat]=🛥
      [ship]=🚢
      [airplane]=✈
      [small_airplane]=🛩
      [airplane_departure]=🛫
      [airplane_arrival]=🛬
      [parachute]=🪂
      [seat]=💺
      [helicopter]=🚁
      [suspension_railway]=🚟
      [mountain_cableway]=🚠
      [aerial_tramway]=🚡
      [satellite]=🛰
      [rocket]=🚀
      [flying_saucer]=🛸
      [bellhop_bell]=🛎
      [luggage]=🧳
      [hourglass_done]=⌛
      [hourglass_not_done]=⏳
      [watch]=⌚
      [alarm_clock]=⏰
      [stopwatch]=⏱
      [timer_clock]=⏲
      [mantelpiece_clock]=🕰
      [twelve_oclock]=🕛
      [twelve_thirty]=🕧
      [one_oclock]=🕐
      [one_thirty]=🕜
      [two_oclock]=🕑
      [two_thirty]=🕝
      [three_oclock]=🕒
      [three_thirty]=🕞
      [four_oclock]=🕓
      [four_thirty]=🕟
      [five_oclock]=🕔
      [five_thirty]=🕠
      [six_oclock]=🕕
      [six_thirty]=🕡
      [seven_oclock]=🕖
      [seven_thirty]=🕢
      [eight_oclock]=🕗
      [eight_thirty]=🕣
      [nine_oclock]=🕘
      [nine_thirty]=🕤
      [ten_oclock]=🕙
      [ten_thirty]=🕥
      [eleven_oclock]=🕚
      [eleven_thirty]=🕦
      [new_moon]=🌑
      [waxing_crescent_moon]=🌒
      [first_quarter_moon]=🌓
      [waxing_gibbous_moon]=🌔
      [full_moon]=🌕
      [waning_gibbous_moon]=🌖
      [last_quarter_moon]=🌗
      [waning_crescent_moon]=🌘
      [crescent_moon]=🌙
      [new_moon_face]=🌚
      [first_quarter_moon_face]=🌛
      [last_quarter_moon_face]=🌜
      [thermometer]=🌡
      [sun]=☀
      [full_moon_face]=🌝
      [sun_with_face]=🌞
      [ringed_planet]=🪐
      [star]=⭐
      [glowing_star]=🌟
      [shooting_star]=🌠
      [milky_way]=🌌
      [cloud]=☁
      [sun_behind_cloud]=⛅
      [cloud_with_lightning_and_rain]=⛈
      [sun_behind_small_cloud]=🌤
      [sun_behind_large_cloud]=🌥
      [sun_behind_rain_cloud]=🌦
      [cloud_with_rain]=🌧
      [cloud_with_snow]=🌨
      [cloud_with_lightning]=🌩
      [tornado]=🌪
      [fog]=🌫
      [wind_face]=🌬
      [cyclone]=🌀
      [rainbow]=🌈
      [closed_umbrella]=🌂
      [umbrella]=☂
      [umbrella_with_rain_drops]=☔
      [umbrella_on_ground]=⛱
      [high_voltage]=⚡
      [snowflake]=❄
      [snowman]=☃
      [snowman_without_snow]=⛄
      [comet]=☄
      [fire]=🔥
      [droplet]=💧
      [water_wave]=🌊
      [jack_o_lantern]=🎃
      [christmas_tree]=🎄
      [fireworks]=🎆
      [sparkler]=🎇
      [firecracker]=🧨
      [sparkles]=✨
      [balloon]=🎈
      [party_popper]=🎉
      [confetti_ball]=🎊
      [tanabata_tree]=🎋
      [pine_decoration]=🎍
      [japanese_dolls]=🎎
      [carp_streamer]=🎏
      [wind_chime]=🎐
      [moon_viewing_ceremony]=🎑
      [red_envelope]=🧧
      [ribbon]=🎀
      [wrapped_gift]=🎁
      [reminder_ribbon]=🎗
      [admission_tickets]=🎟
      [ticket]=🎫
      [military_medal]=🎖
      [trophy]=🏆
      [sports_medal]=🏅
      [1st_place_medal]=🥇
      [2nd_place_medal]=🥈
      [3rd_place_medal]=🥉
      [soccer_ball]=⚽
      [baseball]=⚾
      [softball]=🥎
      [basketball]=🏀
      [volleyball]=🏐
      [american_football]=🏈
      [rugby_football]=🏉
      [tennis]=🎾
      [flying_disc]=🥏
      [bowling]=🎳
      [cricket_game]=🏏
      [field_hockey]=🏑
      [ice_hockey]=🏒
      [lacrosse]=🥍
      [ping_pong]=🏓
      [badminton]=🏸
      [boxing_glove]=🥊
      [martial_arts_uniform]=🥋
      [goal_net]=🥅
      [flag_in_hole]=⛳
      [ice_skate]=⛸
      [fishing_pole]=🎣
      [diving_mask]=🤿
      [running_shirt]=🎽
      [skis]=🎿
      [sled]=🛷
      [curling_stone]=🥌
      [direct_hit]=🎯
      [yo_yo]=🪀
      [kite]=🪁
      [pool_8_ball]=🎱
      [crystal_ball]=🔮
      [nazar_amulet]=🧿
      [video_game]=🎮
      [joystick]=🕹
      [slot_machine]=🎰
      [game_die]=🎲
      [puzzle_piece]=🧩
      [teddy_bear]=🧸
      [spade_suit]=♠
      [heart_suit]=♥
      [diamond_suit]=♦
      [club_suit]=♣
      [chess_pawn]=♟
      [joker]=🃏
      [mahjong_red_dragon]=🀄
      [flower_playing_cards]=🎴
      [performing_arts]=🎭
      [framed_picture]=🖼
      [artist_palette]=🎨
      [thread]=🧵
      [yarn]=🧶
      [glasses]=👓
      [sunglasses]=🕶
      [goggles]=🥽
      [lab_coat]=🥼
      [safety_vest]=🦺
      [necktie]=👔
      [t_shirt]=👕
      [jeans]=👖
      [scarf]=🧣
      [gloves]=🧤
      [coat]=🧥
      [socks]=🧦
      [dress]=👗
      [kimono]=👘
      [sari]=🥻
      [one_piece_swimsuit]=🩱
      [swim_brief]=🩲
      [shorts]=🩳
      [bikini]=👙
      [womans_clothes]=👚
      [purse]=👛
      [handbag]=👜
      [clutch_bag]=👝
      [shopping_bags]=🛍
      [backpack]=🎒
      [mans_shoe]=👞
      [running_shoe]=👟
      [hiking_boot]=🥾
      [flat_shoe]=🥿
      [high_heeled_shoe]=👠
      [womans_sandal]=👡
      [ballet_shoes]=🩰
      [womans_boot]=👢
      [crown]=👑
      [womans_hat]=👒
      [top_hat]=🎩
      [graduation_cap]=🎓
      [billed_cap]=🧢
      [rescue_workers_helmet]=⛑
      [prayer_beads]=📿
      [lipstick]=💄
      [ring]=💍
      [gem_stone]=💎
      [muted_speaker]=🔇
      [speaker_low_volume]=🔈
      [speaker_medium_volume]=🔉
      [speaker_high_volume]=🔊
      [loudspeaker]=📢
      [megaphone]=📣
      [postal_horn]=📯
      [bell]=🔔
      [bell_with_slash]=🔕
      [musical_score]=🎼
      [musical_note]=🎵
      [musical_notes]=🎶
      [studio_microphone]=🎙
      [level_slider]=🎚
      [control_knobs]=🎛
      [microphone]=🎤
      [headphone]=🎧
      [radio]=📻
      [saxophone]=🎷
      [guitar]=🎸
      [musical_keyboard]=🎹
      [trumpet]=🎺
      [violin]=🎻
      [banjo]=🪕
      [drum]=🥁
      [mobile_phone]=📱
      [mobile_phone_with_arrow]=📲
      [telephone]=☎
      [telephone_receiver]=📞
      [pager]=📟
      [fax_machine]=📠
      [battery]=🔋
      [electric_plug]=🔌
      [laptop_computer]=💻
      [desktop_computer]=🖥
      [printer]=🖨
      [keyboard]=⌨
      [computer_mouse]=🖱
      [trackball]=🖲
      [computer_disk]=💽
      [floppy_disk]=💾
      [optical_disk]=💿
      [dvd]=📀
      [abacus]=🧮
      [movie_camera]=🎥
      [film_frames]=🎞
      [film_projector]=📽
      [clapper_board]=🎬
      [television]=📺
      [camera]=📷
      [camera_with_flash]=📸
      [video_camera]=📹
      [videocassette]=📼
      [magnifying_glass_tilted_left]=🔍
      [magnifying_glass_tilted_right]=🔎
      [candle]=🕯
      [light_bulb]=💡
      [flashlight]=🔦
      [red_paper_lantern]=🏮
      [diya_lamp]=🪔
      [notebook_with_decorative_cover]=📔
      [closed_book]=📕
      [open_book]=📖
      [green_book]=📗
      [blue_book]=📘
      [orange_book]=📙
      [books]=📚
      [notebook]=📓
      [ledger]=📒
      [page_with_curl]=📃
      [scroll]=📜
      [page_facing_up]=📄
      [newspaper]=📰
      [rolled_up_newspaper]=🗞
      [bookmark_tabs]=📑
      [bookmark]=🔖
      [label]=🏷
      [money_bag]=💰
      [yen_banknote]=💴
      [dollar_banknote]=💵
      [euro_banknote]=💶
      [pound_banknote]=💷
      [money_with_wings]=💸
      [credit_card]=💳
      [receipt]=🧾
      [chart_increasing_with_yen]=💹
      [currency_exchange]=💱
      [heavy_dollar_sign]=💲
      [envelope]=✉
      [e_mail]=📧
      [incoming_envelope]=📨
      [envelope_with_arrow]=📩
      [outbox_tray]=📤
      [inbox_tray]=📥
      [package]=📦
      [closed_mailbox_with_raised_flag]=📫
      [closed_mailbox_with_lowered_flag]=📪
      [open_mailbox_with_raised_flag]=📬
      [open_mailbox_with_lowered_flag]=📭
      [postbox]=📮
      [ballot_box_with_ballot]=🗳
      [pencil]=✏
      [black_nib]=✒
      [fountain_pen]=🖋
      [pen]=🖊
      [paintbrush]=🖌
      [crayon]=🖍
      [memo]=📝
      [briefcase]=💼
      [file_folder]=📁
      [open_file_folder]=📂
      [card_index_dividers]=🗂
      [calendar]=📅
      [tear_off_calendar]=📆
      [spiral_notepad]=🗒
      [spiral_calendar]=🗓
      [card_index]=📇
      [chart_increasing]=📈
      [chart_decreasing]=📉
      [bar_chart]=📊
      [clipboard]=📋
      [pushpin]=📌
      [round_pushpin]=📍
      [paperclip]=📎
      [linked_paperclips]=🖇
      [straight_ruler]=📏
      [triangular_ruler]=📐
      [scissors]=✂
      [card_file_box]=🗃
      [file_cabinet]=🗄
      [wastebasket]=🗑
      [locked]=🔒
      [unlocked]=🔓
      [locked_with_pen]=🔏
      [locked_with_key]=🔐
      [key]=🔑
      [old_key]=🗝
      [hammer]=🔨
      [axe]=🪓
      [pick]=⛏
      [hammer_and_pick]=⚒
      [hammer_and_wrench]=🛠
      [dagger]=🗡
      [crossed_swords]=⚔
      [pistol]=🔫
      [bow_and_arrow]=🏹
      [shield]=🛡
      [wrench]=🔧
      [nut_and_bolt]=🔩
      [gear]=⚙
      [clamp]=🗜
      [balance_scale]=⚖
      [probing_cane]=🦯
      [link]=🔗
      [chains]=⛓
      [toolbox]=🧰
      [magnet]=🧲
      [alembic]=⚗
      [test_tube]=🧪
      [petri_dish]=🧫
      [dna]=🧬
      [microscope]=🔬
      [telescope]=🔭
      [satellite_antenna]=📡
      [syringe]=💉
      [drop_of_blood]=🩸
      [pill]=💊
      [adhesive_bandage]=🩹
      [stethoscope]=🩺
      [door]=🚪
      [bed]=🛏
      [couch_and_lamp]=🛋
      [chair]=🪑
      [toilet]=🚽
      [shower]=🚿
      [bathtub]=🛁
      [razor]=🪒
      [lotion_bottle]=🧴
      [safety_pin]=🧷
      [broom]=🧹
      [basket]=🧺
      [roll_of_paper]=🧻
      [soap]=🧼
      [sponge]=🧽
      [fire_extinguisher]=🧯
      [shopping_cart]=🛒
      [cigarette]=🚬
      [coffin]=⚰
      [funeral_urn]=⚱
      [moai]=🗿
      [atm_sign]=🏧
      [litter_in_bin_sign]=🚮
      [potable_water]=🚰
      [wheelchair_symbol]=♿
      [mens_room]=🚹
      [womens_room]=🚺
      [restroom]=🚻
      [baby_symbol]=🚼
      [water_closet]=🚾
      [passport_control]=🛂
      [customs]=🛃
      [baggage_claim]=🛄
      [left_luggage]=🛅
      [warning]=⚠
      [children_crossing]=🚸
      [no_entry]=⛔
      [prohibited]=🚫
      [no_bicycles]=🚳
      [no_smoking]=🚭
      [no_littering]=🚯
      [non_potable_water]=🚱
      [no_pedestrians]=🚷
      [no_mobile_phones]=📵
      [no_one_under_eighteen]=🔞
      [radioactive]=☢
      [biohazard]=☣
      [up_arrow]=⬆
      [up_right_arrow]=↗
      [right_arrow]=➡
      [down_right_arrow]=↘
      [down_arrow]=⬇
      [down_left_arrow]=↙
      [left_arrow]=⬅
      [up_left_arrow]=↖
      [up_down_arrow]=↕
      [left_right_arrow]=↔
      [right_arrow_curving_left]=↩
      [left_arrow_curving_right]=↪
      [right_arrow_curving_up]=⤴
      [right_arrow_curving_down]=⤵
      [clockwise_vertical_arrows]=🔃
      [counterclockwise_arrows_button]=🔄
      [back_arrow]=🔙
      [end_arrow]=🔚
      [on_arrow]=🔛
      [soon_arrow]=🔜
      [top_arrow]=🔝
      [place_of_worship]=🛐
      [atom_symbol]=⚛
      [om]=🕉
      [star_of_david]=✡
      [wheel_of_dharma]=☸
      [yin_yang]=☯
      [latin_cross]=✝
      [orthodox_cross]=☦
      [star_and_crescent]=☪
      [peace_symbol]=☮
      [menorah]=🕎
      [dotted_six_pointed_star]=🔯
      [aries]=♈
      [taurus]=♉
      [gemini]=♊
      [cancer]=♋
      [leo]=♌
      [virgo]=♍
      [libra]=♎
      [scorpio]=♏
      [sagittarius]=♐
      [capricorn]=♑
      [aquarius]=♒
      [pisces]=♓
      [ophiuchus]=⛎
      [shuffle_tracks_button]=🔀
      [repeat_button]=🔁
      [repeat_single_button]=🔂
      [play_button]=▶
      [fast_forward_button]=⏩
      [next_track_button]=⏭
      [play_or_pause_button]=⏯
      [reverse_button]=◀
      [fast_reverse_button]=⏪
      [last_track_button]=⏮
      [upwards_button]=🔼
      [fast_up_button]=⏫
      [downwards_button]=🔽
      [fast_down_button]=⏬
      [pause_button]=⏸
      [stop_button]=⏹
      [record_button]=⏺
      [eject_button]=⏏
      [cinema]=🎦
      [dim_button]=🔅
      [bright_button]=🔆
      [antenna_bars]=📶
      [vibration_mode]=📳
      [mobile_phone_off]=📴
      [female_sign]=♀
      [male_sign]=♂
      [medical_symbol]=⚕
      [infinity]=♾
      [recycling_symbol]=♻
      [fleur_de_lis]=⚜
      [trident_emblem]=🔱
      [name_badge]=📛
      [japanese_symbol_for_beginner]=🔰
      [hollow_red_circle]=⭕
      [check_mark_button]=✅
      [check_box_with_check]=☑
      [check_mark]=✔
      [multiplication_sign]=✖
      [cross_mark]=❌
      [missing_mark]=✘
      [cross_mark_button]=❎
      [plus_sign]=➕
      [minus_sign]=➖
      [division_sign]=➗
      [curly_loop]=➰
      [double_curly_loop]=➿
      [part_alternation_mark]=〽
      [eight_spoked_asterisk]=✳
      [eight_pointed_star]=✴
      [sparkle]=❇
      [double_exclamation_mark]=‼
      [exclamation_question_mark]=⁉
      [question_mark]=❓
      [white_question_mark]=❔
      [white_exclamation_mark]=❕
      [exclamation_mark]=❗
      [wavy_dash]=〰
      [copyright]=©
      [registered]=®
      [trade_mark]=™
      [keycap_hashtag]=#️⃣
      [keycap_star]=*️⃣
      [keycap_0]=0️⃣
      [keycap_1]=1️⃣
      [keycap_2]=2️⃣
      [keycap_3]=3️⃣
      [keycap_4]=4️⃣
      [keycap_5]=5️⃣
      [keycap_6]=6️⃣
      [keycap_7]=7️⃣
      [keycap_8]=8️⃣
      [keycap_9]=9️⃣
      [keycap_10]=🔟
      [input_latin_uppercase]=🔠
      [input_latin_lowercase]=🔡
      [input_numbers]=🔢
      [input_symbols]=🔣
      [input_latin_letters]=🔤
      [a_button_blood_type]=🅰
      [ab_button_blood_type]=🆎
      [b_button_blood_type]=🅱
      [cl_button]=🆑
      [cool_button]=🆒
      [free_button]=🆓
      [information]=ℹ
      [id_button]=🆔
      [circled_m]=Ⓜ
      [new_button]=🆕
      [ng_button]=🆖
      [o_button_blood_type]=🅾
      [ok_button]=🆗
      [p_button]=🅿
      [sos_button]=🆘
      [up_button]=🆙
      [vs_button]=🆚
      [japanese_here_button]=🈁
      [japanese_service_charge_button]=🈂
      [japanese_monthly_amount_button]=🈷
      [japanese_not_free_of_charge_button]=🈶
      [japanese_reserved_button]=🈯
      [japanese_bargain_button]=🉐
      [japanese_discount_button]=🈹
      [japanese_free_of_charge_button]=🈚
      [japanese_prohibited_button]=🈲
      [japanese_acceptable_button]=🉑
      [japanese_application_button]=🈸
      [japanese_passing_grade_button]=🈴
      [japanese_vacancy_button]=🈳
      [japanese_congratulations_button]=㊗
      [japanese_secret_button]=㊙
      [japanese_open_for_business_button]=🈺
      [japanese_no_vacancy_button]=🈵
      [red_circle]=🔴
      [orange_circle]=🟠
      [yellow_circle]=🟡
      [green_circle]=🟢
      [blue_circle]=🔵
      [purple_circle]=🟣
      [brown_circle]=🟤
      [black_circle]=⚫
      [white_circle]=⚪
      [red_square]=🟥
      [orange_square]=🟧
      [yellow_square]=🟨
      [green_square]=🟩
      [blue_square]=🟦
      [purple_square]=🟪
      [brown_square]=🟫
      [black_large_square]=⬛
      [white_large_square]=⬜
      [black_medium_square]=◼
      [white_medium_square]=◻
      [black_medium_small_square]=◾
      [white_medium_small_square]=◽
      [black_small_square]=▪
      [white_small_square]=▫
      [large_orange_diamond]=🔶
      [large_blue_diamond]=🔷
      [small_orange_diamond]=🔸
      [small_blue_diamond]=🔹
      [red_triangle_pointed_up]=🔺
      [red_triangle_pointed_down]=🔻
      [diamond_with_a_dot]=💠
      [radio_button]=🔘
      [white_square_button]=🔳
      [black_square_button]=🔲
      [chequered_flag]=🏁
      [triangular_flag]=🚩
      [crossed_flags]=🎌
      [black_flag]=🏴
      [white_flag]=🏳
      [rainbow_flag]=🏳️‍🌈
      [pirate_flag]=🏴‍☠️
      [flag_ascension_island]=🇦🇨
      [flag_andorra]=🇦🇩
      [flag_united_arab_emirates]=🇦🇪
      [flag_afghanistan]=🇦🇫
      [flag_antigua_and_barbuda]=🇦🇬
      [flag_anguilla]=🇦🇮
      [flag_albania]=🇦🇱
      [flag_armenia]=🇦🇲
      [flag_angola]=🇦🇴
      [flag_antarctica]=🇦🇶
      [flag_argentina]=🇦🇷
      [flag_american_samoa]=🇦🇸
      [flag_austria]=🇦🇹
      [flag_australia]=🇦🇺
      [flag_aruba]=🇦🇼
      [flag_aland_islands]=🇦🇽
      [flag_azerbaijan]=🇦🇿
      [flag_bosnia_and_herzegovina]=🇧🇦
      [flag_barbados]=🇧🇧
      [flag_bangladesh]=🇧🇩
      [flag_belgium]=🇧🇪
      [flag_burkina_faso]=🇧🇫
      [flag_bulgaria]=🇧🇬
      [flag_bahrain]=🇧🇭
      [flag_burundi]=🇧🇮
      [flag_benin]=🇧🇯
      [flag_st_barthelemy]=🇧🇱
      [flag_bermuda]=🇧🇲
      [flag_brunei]=🇧🇳
      [flag_bolivia]=🇧🇴
      [flag_caribbean_netherlands]=🇧🇶
      [flag_brazil]=🇧🇷
      [flag_bahamas]=🇧🇸
      [flag_bhutan]=🇧🇹
      [flag_bouvet_island]=🇧🇻
      [flag_botswana]=🇧🇼
      [flag_belarus]=🇧🇾
      [flag_belize]=🇧🇿
      [flag_canada]=🇨🇦
      [flag_cocos_keeling_islands]=🇨🇨
      [flag_congo___kinshasa]=🇨🇩
      [flag_central_african_republic]=🇨🇫
      [flag_congo___brazzaville]=🇨🇬
      [flag_switzerland]=🇨🇭
      [flag_cote_divoire]=🇨🇮
      [flag_cook_islands]=🇨🇰
      [flag_chile]=🇨🇱
      [flag_cameroon]=🇨🇲
      [flag_china]=🇨🇳
      [flag_colombia]=🇨🇴
      [flag_clipperton_island]=🇨🇵
      [flag_costa_rica]=🇨🇷
      [flag_cuba]=🇨🇺
      [flag_cape_verde]=🇨🇻
      [flag_curacao]=🇨🇼
      [flag_christmas_island]=🇨🇽
      [flag_cyprus]=🇨🇾
      [flag_czechia]=🇨🇿
      [flag_germany]=🇩🇪
      [flag_diego_garcia]=🇩🇬
      [flag_djibouti]=🇩🇯
      [flag_denmark]=🇩🇰
      [flag_dominica]=🇩🇲
      [flag_dominican_republic]=🇩🇴
      [flag_algeria]=🇩🇿
      [flag_ceuta_and_melilla]=🇪🇦
      [flag_ecuador]=🇪🇨
      [flag_estonia]=🇪🇪
      [flag_egypt]=🇪🇬
      [flag_western_sahara]=🇪🇭
      [flag_eritrea]=🇪🇷
      [flag_spain]=🇪🇸
      [flag_ethiopia]=🇪🇹
      [flag_european_union]=🇪🇺
      [flag_finland]=🇫🇮
      [flag_fiji]=🇫🇯
      [flag_falkland_islands]=🇫🇰
      [flag_micronesia]=🇫🇲
      [flag_faroe_islands]=🇫🇴
      [flag_france]=🇫🇷
      [flag_gabon]=🇬🇦
      [flag_united_kingdom]=🇬🇧
      [flag_grenada]=🇬🇩
      [flag_georgia]=🇬🇪
      [flag_french_guiana]=🇬🇫
      [flag_guernsey]=🇬🇬
      [flag_ghana]=🇬🇭
      [flag_gibraltar]=🇬🇮
      [flag_greenland]=🇬🇱
      [flag_gambia]=🇬🇲
      [flag_guinea]=🇬🇳
      [flag_guadeloupe]=🇬🇵
      [flag_equatorial_guinea]=🇬🇶
      [flag_greece]=🇬🇷
      [flag_south_georgia_and_south_sandwich_islands]=🇬🇸
      [flag_guatemala]=🇬🇹
      [flag_guam]=🇬🇺
      [flag_guinea_bissau]=🇬🇼
      [flag_guyana]=🇬🇾
      [flag_hong_kong_sar_china]=🇭🇰
      [flag_heard_and_mcdonald_islands]=🇭🇲
      [flag_honduras]=🇭🇳
      [flag_croatia]=🇭🇷
      [flag_haiti]=🇭🇹
      [flag_hungary]=🇭🇺
      [flag_canary_islands]=🇮🇨
      [flag_indonesia]=🇮🇩
      [flag_ireland]=🇮🇪
      [flag_israel]=🇮🇱
      [flag_isle_of_man]=🇮🇲
      [flag_india]=🇮🇳
      [flag_british_indian_ocean_territory]=🇮🇴
      [flag_iraq]=🇮🇶
      [flag_iran]=🇮🇷
      [flag_iceland]=🇮🇸
      [flag_italy]=🇮🇹
      [flag_jersey]=🇯🇪
      [flag_jamaica]=🇯🇲
      [flag_jordan]=🇯🇴
      [flag_japan]=🇯🇵
      [flag_kenya]=🇰🇪
      [flag_kyrgyzstan]=🇰🇬
      [flag_cambodia]=🇰🇭
      [flag_kiribati]=🇰🇮
      [flag_comoros]=🇰🇲
      [flag_st_kitts_and_nevis]=🇰🇳
      [flag_north_korea]=🇰🇵
      [flag_south_korea]=🇰🇷
      [flag_kuwait]=🇰🇼
      [flag_cayman_islands]=🇰🇾
      [flag_kazakhstan]=🇰🇿
      [flag_laos]=🇱🇦
      [flag_lebanon]=🇱🇧
      [flag_st_lucia]=🇱🇨
      [flag_liechtenstein]=🇱🇮
      [flag_sri_lanka]=🇱🇰
      [flag_liberia]=🇱🇷
      [flag_lesotho]=🇱🇸
      [flag_lithuania]=🇱🇹
      [flag_luxembourg]=🇱🇺
      [flag_latvia]=🇱🇻
      [flag_libya]=🇱🇾
      [flag_morocco]=🇲🇦
      [flag_monaco]=🇲🇨
      [flag_moldova]=🇲🇩
      [flag_montenegro]=🇲🇪
      [flag_st_martin]=🇲🇫
      [flag_madagascar]=🇲🇬
      [flag_marshall_islands]=🇲🇭
      [flag_macedonia]=🇲🇰
      [flag_mali]=🇲🇱
      [flag_myanmar_burma]=🇲🇲
      [flag_mongolia]=🇲🇳
      [flag_macao_sar_china]=🇲🇴
      [flag_northern_mariana_islands]=🇲🇵
      [flag_martinique]=🇲🇶
      [flag_mauritania]=🇲🇷
      [flag_montserrat]=🇲🇸
      [flag_malta]=🇲🇹
      [flag_mauritius]=🇲🇺
      [flag_maldives]=🇲🇻
      [flag_malawi]=🇲🇼
      [flag_mexico]=🇲🇽
      [flag_malaysia]=🇲🇾
      [flag_mozambique]=🇲🇿
      [flag_namibia]=🇳🇦
      [flag_new_caledonia]=🇳🇨
      [flag_niger]=🇳🇪
      [flag_norfolk_island]=🇳🇫
      [flag_nigeria]=🇳🇬
      [flag_nicaragua]=🇳🇮
      [flag_netherlands]=🇳🇱
      [flag_norway]=🇳🇴
      [flag_nepal]=🇳🇵
      [flag_nauru]=🇳🇷
      [flag_niue]=🇳🇺
      [flag_new_zealand]=🇳🇿
      [flag_oman]=🇴🇲
      [flag_panama]=🇵🇦
      [flag_peru]=🇵🇪
      [flag_french_polynesia]=🇵🇫
      [flag_papua_new_guinea]=🇵🇬
      [flag_philippines]=🇵🇭
      [flag_pakistan]=🇵🇰
      [flag_poland]=🇵🇱
      [flag_st_pierre_and_miquelon]=🇵🇲
      [flag_pitcairn_islands]=🇵🇳
      [flag_puerto_rico]=🇵🇷
      [flag_palestinian_territories]=🇵🇸
      [flag_portugal]=🇵🇹
      [flag_palau]=🇵🇼
      [flag_paraguay]=🇵🇾
      [flag_qatar]=🇶🇦
      [flag_reunion]=🇷🇪
      [flag_romania]=🇷🇴
      [flag_serbia]=🇷🇸
      [flag_russia]=🇷🇺
      [flag_rwanda]=🇷🇼
      [flag_saudi_arabia]=🇸🇦
      [flag_solomon_islands]=🇸🇧
      [flag_seychelles]=🇸🇨
      [flag_sudan]=🇸🇩
      [flag_sweden]=🇸🇪
      [flag_singapore]=🇸🇬
      [flag_st_helena]=🇸🇭
      [flag_slovenia]=🇸🇮
      [flag_svalbard_and_jan_mayen]=🇸🇯
      [flag_slovakia]=🇸🇰
      [flag_sierra_leone]=🇸🇱
      [flag_san_marino]=🇸🇲
      [flag_senegal]=🇸🇳
      [flag_somalia]=🇸🇴
      [flag_suriname]=🇸🇷
      [flag_south_sudan]=🇸🇸
      [flag_sao_tome_and_principe]=🇸🇹
      [flag_el_salvador]=🇸🇻
      [flag_sint_maarten]=🇸🇽
      [flag_syria]=🇸🇾
      [flag_eswatini]=🇸🇿
      [flag_tristan_da_cunha]=🇹🇦
      [flag_turks_and_caicos_islands]=🇹🇨
      [flag_chad]=🇹🇩
      [flag_french_southern_territories]=🇹🇫
      [flag_togo]=🇹🇬
      [flag_thailand]=🇹🇭
      [flag_tajikistan]=🇹🇯
      [flag_tokelau]=🇹🇰
      [flag_timor_leste]=🇹🇱
      [flag_turkmenistan]=🇹🇲
      [flag_tunisia]=🇹🇳
      [flag_tonga]=🇹🇴
      [flag_turkey]=🇹🇷
      [flag_trinidad_and_tobago]=🇹🇹
      [flag_tuvalu]=🇹🇻
      [flag_taiwan]=🇹🇼
      [flag_tanzania]=🇹🇿
      [flag_ukraine]=🇺🇦
      [flag_uganda]=🇺🇬
      [flag_us_outlying_islands]=🇺🇲
      [flag_united_nations]=🇺🇳
      [flag_united_states]=🇺🇸
      [flag_uruguay]=🇺🇾
      [flag_uzbekistan]=🇺🇿
      [flag_vatican_city]=🇻🇦
      [flag_st_vincent_and_grenadines]=🇻🇨
      [flag_venezuela]=🇻🇪
      [flag_british_virgin_islands]=🇻🇬
      [flag_us_virgin_islands]=🇻🇮
      [flag_vietnam]=🇻🇳
      [flag_vanuatu]=🇻🇺
      [flag_wallis_and_futuna]=🇼🇫
      [flag_samoa]=🇼🇸
      [flag_kosovo]=🇽🇰
      [flag_yemen]=🇾🇪
      [flag_mayotte]=🇾🇹
      [flag_south_africa]=🇿🇦
      [flag_zambia]=🇿🇲
      [flag_zimbabwe]=🇿🇼
      [flag_england]=🏴󠁧󠁢󠁥󠁮󠁧󠁿
      [flag_scotland]=🏴󠁧󠁢󠁳󠁣󠁴󠁿
      [flag_wales]=🏴󠁧󠁢󠁷󠁬󠁳󠁿
    )
  fi

  if [ -n \"\$1\" ]; then
    local return_emoji=\"\${EMOJIS[\$1]}\"
    if [ -z \"\$(echo \"\${return_emoji}\")\" ]; then  # Not an emoji keyname
      for i in \"\${!EMOJIS[@]}\"; do  # Search for emoji and return its keyname
        if [ \"\${EMOJIS[\${i}]}\" == \"\$1\" ]; then
          return_emoji=\"\${i}\"
          echo \"\${return_emoji}\"
          return
        fi
      done
      # At this point \$1 is not a keyname or emoji
      if [ \"\$1\" == \"random\" ]; then  # Check for random emoji
        EMOJIS_arr=(\${EMOJIS[@]})
        echo \"\${EMOJIS_arr[\$RANDOM % \${#EMOJIS_arr[@]}]}\"
      elif [[ \"\$1\" =~ ^[0-9]+$ ]] && [ \"\$1\" -ge 0 ]; then  # If a natural number passed return an emoji indexing by number
        EMOJIS_arr=(\${EMOJIS[@]})
        echo \"\${EMOJIS_arr[\$1 % \${#EMOJIS_arr[@]}]}\"
      else
        echo \"ERROR Not recognised option\"
      fi
    else  # Return emoji from indexing with dict
      echo \"\${return_emoji}\"
    fi
  else
    # Not an argument, show all emojis with dictionary structure
    for i in \"\${!EMOJIS[@]}\"; do
      echo \"\${i}:\${EMOJIS[\${i}]}\"
    done
  fi
}
")
emojis_readmeline="| emojis | Print emojis name in terminal when passing an emoji and prints emoji name when an emoji is passed to it. | Command \`emoji\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

evolution_installationtype="packagemanager"
evolution_arguments=("evolution")
evolution_bashfunctions=("alias evolution=\"nohup evolution &>/dev/null &\"")
evolution_launchernames=("evolution-calendar")
evolution_packagenames=("evolution" )
evolution_readmeline="| evolution | User calendar agend, planning | Command \`evolution\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

F_installationtype="environmental"
F_arguments=("F")
F_bashfunctions=("
F() {
  if [ \$# -eq 0 ]; then  # No arguments given
    find / 2>/dev/null
  else
    if [ -d \"\$1\" ]; then
      first_argument=\"\$1\"
      shift
    else
      first_argument=\".\"
    fi
    IFS=\$'\\n'
    while [ -n \"\$1\" ]; do
      for filename in \$(find \"\${first_argument}\" -type f 2>/dev/null); do
        local result=\"\$(cat \"\${filename}\" 2>/dev/null | grep \"\$1\")\"
        if [ -n \"\$(echo \"\${result}\")\" ]; then
          echo
          echo -e \"\\e[0;33m\${filename}\\e[0m\"
          cat \"\${filename}\" 2>/dev/null | grep -hnI -B 3 -A 3 --color='auto' \"\$1\"
         fi
      done
      shift
    done
  fi
}
")
F_readmeline="| Function \`F\` | Function to find strings in files in the directory in the 1st argument | Command \`F\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

f_installationtype="environmental"
f_arguments=("f")
f_bashfunctions=("
f() {
  if  [ \$# -eq 0 ]; then  # No arguments given
    find . 2>/dev/null
  elif [ \$# -eq 1 ]; then
    if [ -f \"\$1\" ]; then  # Searches therm in a file
      cat \"\$1\"
    elif [ -d \"\$1\" ]; then  # Searches files in directory
      find \"\$1\"
    else
      more * | grep \"\$1\"  # Searches therm in all files
    fi
  elif [ \$# -gt 1 ]; then
    local temp=\"\$1\"
    while [ \$# -gt 1 ]; do
      if [ -f \"\$temp\" ]; then  # Searches therm in a file
        more \"\$temp\" | grep \"\$2\"
      elif [ -d \"\$temp\" ]; then  # Searches file in directory
        if [ -n \"\$(find \"\$temp\" -name \"\$2\")\" ]; then  # Show files matching argument
          more \$(find \"\$temp\" -name \"\$2\")
        else
          ls -lah \"\$temp\" | grep \"\$2\"  # Show list of other matching files in elements of directory
        fi
      else  # Literal search in therm
        echo \"\$temp\" | grep \"\$2\"
      fi
      shift
    done
  fi
}
")
f_readmeline="| Function \`f\` | Function for finding strings in files, files in directories and show found files | Command \`f\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

f_irc_installationtype="packagemanager"
f_irc_arguments=("f_irc")
f_irc_packagenames=("f-irc")
f_irc_readmelinedescription="CLI IRC client"
f_irc_launchercontents=("[Desktop Entry]
Categories=InstantMessaging;Communication;
Comment=${f_irc_readmelinedescription}
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
Version=1.0
")
f_irc_readmeline="| f-irc | ${f_irc_readmelinedescription} | Command \`f-irc\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

facebook_installationtype="environmental"
facebook_arguments=("facebook")
facebook_url="https://facebook.com/"
facebook_bashfunctions=("alias facebook=\"nohup xdg-open ${facebook_url} &>/dev/null &\"")
facebook_downloads=("https://upload.wikimedia.org/wikipedia/commons/5/51/Facebook_f_logo_%282019%29.svg;facebook_icon.svg")
facebook_readmelinedescription="Desktop app to facebook from Chrome"
facebook_launchercontents=("[Desktop Entry]
Categories=Network;
Comment=${facebook_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${facebook_url}
Icon=${BIN_FOLDER}/facebook/facebook_icon.svg
GenericName=Facebook
Keywords=facebook;
MimeType=
Name=Facebook
StartupNotify=true
StartupWMClass=Facebook
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
facebook_readmeline="| Facebook | ${facebook_readmelinedescription} | Command \`facebook\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fastcommands_installationtype="environmental"
fastcommands_arguments=("fast_commands")
fastcommands_bashfunctions=("
alias rip=\"sudo shutdown -h now\"
alias up=\"sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt --fix-broken install && sudo apt-get -y autoclean && sudo apt-get -y autoremove\"
alias services=\"sudo systemctl --type=service\"
alias cls=\"clear\"
alias services=\"sudo systemctl --type=service\"
")
fastcommands_readmeline="| fast commands | Generic multi-purpose | Commands \`...\`|| <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fdupes_installationtype="packagemanager"
fdupes_arguments=("fdupes")
fdupes_packagenames=("fdupes")
fdupes_readmeline="| Fdupes | Searches for duplicated files within given directories | Command \`fdupes\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fetch_installationtype="environmental"
fetch_arguments=("fetch")
fetch_bashfunctions=("alias fetch=\"git fetch\"")
fetch_readmeline="| fetch | \`git fetch\`| Command \`fetch\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

ffmpeg_installationtype="packagemanager"
ffmpeg_arguments=("ffmpeg" "youtube_dl_dependencies")
ffmpeg_packagenames=("ffmpeg")
ffmpeg_readmeline="| ffmpeg | Super fast video / audio encoder | Command \`ffmpeg\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

firefox_installationtype="packagemanager"
firefox_arguments=("firefox")
firefox_bashfunctions=("alias firefox=\"nohup firefox &>/dev/null &\"")
firefox_launchernames=("firefox")
firefox_packagenames=("firefox")
firefox_readmeline="| Firefox | Free web browser | Command \`firefox\`, desktop launcher, dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_alegreya_sans_installationtype="userinherit"
fonts_alegreya_sans_arguments=("fonts_alegreya_sans")
fonts_alegreya_sans_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_alegreya_sans_compressedfiletype="zip"
fonts_alegreya_sans_compressedfileurl="https://fonts.google.com/download?family=Alegreya%20Sans"
fonts_alegreya_sans_readmeline="| fonts-alegreya_sans | Installs font | Install alegreya font || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_firacode_installationtype="packagemanager"
fonts_firacode_arguments=("fonts_firacode")
fonts_firacode_packagenames=("fonts-firacode")
fonts_firacode_readmeline="| fonts-firacode | Installs font | Install firacode font ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_hack_installationtype="packagemanager"
fonts_hack_arguments=("fonts_hack")
fonts_hack_packagenames=("fonts-hack")
fonts_hack_readmeline="| fonts-hack | Installs font | Install hack font ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_hermit_installationtype="packagemanager"
fonts_hermit_arguments=("fonts_hermit")
fonts_hermit_packagenames=("fonts-hermit")
fonts_hermit_readmeline="| fonts-hermit | Installs font | Install hermit font ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_lato_installationtype="userinherit"
fonts_lato_arguments=("fonts_lato")
fonts_lato_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_lato_compressedfiletype="zip"
fonts_lato_compressedfileurl="https://fonts.google.com/download?family=Lato"
fonts_lato_readmeline="| fonts-lato | Installs font | Install lato font || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_noto_sans_installationtype="userinherit"
fonts_noto_sans_arguments=("fonts_noto_sans")
fonts_noto_sans_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_noto_sans_compressedfiletype="zip"
fonts_noto_sans_compressedfileurl="https://fonts.google.com/download?family=Noto%20Sans"
fonts_noto_sans_readmeline="| fonts-noto_sans | Installs font| Install noto_sans font || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_oswald_installationtype="userinherit"
fonts_oswald_arguments=("fonts_oswald")
fonts_oswald_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_oswald_compressedfileurl="https://fonts.google.com/download?family=Oswald"
fonts_oswald_compressedfiletype="zip"
fonts_oswald_readmeline="| fonts-oswald | Installs font| Install oswald font || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_oxygen_installationtype="userinherit"
fonts_oxygen_arguments=("fonts_oxygen")
fonts_oxygen_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_oxygen_compressedfileurl="https://fonts.google.com/download?family=Oxygen"
fonts_oxygen_compressedfiletype="zip"
fonts_oxygen_readmeline="| fonts-oxygen | Installs font | Install oxygen font || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_roboto_installationtype="packagemanager"
fonts_roboto_arguments=("fonts_roboto")
fonts_roboto_packagenames=("fonts-roboto")
fonts_roboto_readmeline="| fonts-roboto | Installs font| Install roboto font ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

forms_installationtype="environmental"
forms_arguments=("forms" "google_forms")
forms_url="https://docs.google.com/forms/"
forms_bashfunctions=("alias forms=\"nohup xdg-open ${forms_url} &>/dev/null &\"")
forms_downloads=("https://upload.wikimedia.org/wikipedia/commons/5/5b/Google_Forms_2020_Logo.svg;forms_icon.svg")
forms_readmelinedescription="Google Forms opening in Chrome"
forms_launchercontents=("[Desktop Entry]
Categories=Network;
Comment=${forms_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${forms_url}
Icon=${BIN_FOLDER}/forms/forms_icon.svg
GenericName=Document
Keywords=forms;
MimeType=
Name=Google Forms
StartupNotify=true
StartupWMClass=Google Forms
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
forms_readmeline="| Forms | ${forms_readmelinedescription} | Command \`forms\`, desktop launcher, dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

freecad_installationtype="packagemanager"
freecad_arguments=("freecad")
freecad_launchernames=("freecad")
freecad_packagenames=("freecad")
freecad_readmeline="| FreeCAD | General-purpose parametric 3D computer-aided design modeler and a building information modeling | Command \`freecad\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

gcc_installationtype="packagemanager"
gcc_arguments=("gcc")
gcc_bashfunctions=("# colored GCC warnings and errors
export GCC_COLORS=\"error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01\"
")
gcc_packagenames=("gcc")
gcc_readmeline="| GNU C Compiler | C compiler for GNU systems | Command \`gcc\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

geany_installationtype="packagemanager"
geany_arguments=("geany")
geany_launchernames=("geany")
geany_packagenames=("geany")
geany_readmeline="| Geany | Lightweight GUI text editor using Scintilla and GTK, including basic IDE features | Command \`geany\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

geogebra_installationtype="userinherit"
geogebra_arguments=("geogebra" "geogebra_classic_6" "geogebra_6")
geogebra_binariesinstalledpaths=("GeoGebra;geogebra")
geogebra_compressedfiletype="zip"
geogebra_compressedfileurl="https://download.geogebra.org/package/linux-port6"
geogebra_downloads=("https://upload.wikimedia.org/wikipedia/commons/5/57/Geogebra.svg;geogebra_icon.svg")
geogebra_readmelinedescription="Geometry calculator GUI"
geogebra_launchercontents=("[Desktop Entry]
Categories=geometry;
Comment=${geogebra_readmelinedescription}
Encoding=UTF-8
Exec=geogebra
GenericName=Geometry visualization plotter
Icon=${BIN_FOLDER}/geogebra/geogebra_icon.svg
Keywords=GeoGebra;geogebra;
MimeType=
Name=GeoGebra
StartupNotify=true
StartupWMClass=geogebra
Terminal=false
TryExec=geogebra
Type=Application
Version=4.2.2
")
geogebra_readmeline="| GeoGebra | ${geogebra_readmelinedescription} | Command \`geogebra\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

ghostwriter_installationtype="packagemanager"
ghostwriter_arguments=("ghostwriter")
ghostwriter_launchernames=("ghostwriter")
ghostwriter_packagenames=("ghostwriter")
ghostwriter_readmeline="| GhostWriter | Text editor without distractions. | Command \`ghostwriter, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gimp_installationtype="packagemanager"
gimp_arguments=("gimp")
gimp_launchernames=("gimp")
gimp_packagenames=("gimp")
gimp_readmeline="| Gimp | Raster graphics editor used for image manipulation and image editing, free-form drawing, transcoding between different image file formats. | Command \`gimp\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

git_installationtype="packagemanager"
git_arguments=("git")
git_packagenames=("git-all" "git-lfs")
git_readmeline="| git | Software for tracking changes in any set of files, usually used for coordinating work among programmers collaboratively developing source code during software development | Command \`git\` and \`gitk\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gitcm_installationtype="userinherit"
gitcm_arguments=("git_c_m")
gitcm_binariesinstalledpaths=("git-credential-manager-core;gitcm")
gitcm_compressedfiletype="z"
gitcm_compressedfileurl="https://github.com/microsoft/Git-Credential-Manager-Core/releases/download/v2.0.498/gcmcore-linux_amd64.2.0.498.54650.tar.gz"
gitcm_compressedfilepathoverride="${BIN_FOLDER}/gitcm"  # It has not a folder inside
gitcm_readmeline="| Git Credentials Manager | Plug-in for git to automatically use personal tokens | Command \`gitcm\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
gitcm_manualcontentavailable="0;0;1"

github_installationtype="environmental"
github_arguments=("github")
github_url="https://github.com/"
github_bashfunctions=("alias github=\"nohup xdg-open ${github_url} &>/dev/null &\"")
github_downloads=("https://upload.wikimedia.org/wikipedia/commons/9/91/Octicons-mark-github.svg;github_icon.svg")
github_readmelinedescription="GitHub opening in Chrome"
github_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${github_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${github_url}
Icon=${BIN_FOLDER}/github/github_icon.svg
GenericName=GitHub
Keywords=github;
MimeType=
Name=GitHub
StartupNotify=true
StartupWMClass=GitHub
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
github_readmeline="| GitHub | ${github_readmelinedescription} | Command \`github\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

github_desktop_installationtype="packageinstall"
github_desktop_arguments=("github_desktop")
github_desktop_launchernames=("github-desktop")
github_desktop_packagenames=("github")
github_desktop_packageurls=("https://github.com/shiftkey/desktop/releases/download/release-2.6.3-linux1/GitHubDesktop-linux-2.6.3-linux1.deb")
github_desktop_readmeline="| GitHub Desktop | GitHub Application | Command \`github-desktop\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gitk_installationtype="packagemanager"
gitk_arguments=("gitk")
gitk_bashfunctions=("alias gitk=\"gitk --all --date-order &\"")
gitk_packagenames=("gitk")
gitk_readmeline="| Gitk | GUI for git | Command \`gitk\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gitlab_installationtype="environmental"
gitlab_arguments=("gitlab")
gitlab_url="https://gitlab.com/"
gitlab_bashfunctions=("alias gitlab=\"nohup xdg-open ${gitlab_url} &>/dev/null &\"")
gitlab_downloads=("https://about.gitlab.com/images/press/logo/svg/gitlab-icon-rgb.svg;gitlab_icon.svg")
gitlab_readmelinedescription="Gitlab opening in Chrome"
gitlab_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${gitlab_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${gitlab_url}
Icon=${BIN_FOLDER}/gitlab/gitlab_icon.svg
GenericName=Code repository online
Keywords=gitlab;
MimeType=
Name=GitLab
StartupNotify=true
StartupWMClass=GitLab
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
gitlab_readmeline="| GitLab | ${gitlab_readmelinedescription} | Command || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gitprompt_installationtype="repositoryclone"
gitprompt_arguments=("git_prompt")
gitprompt_bashfunctions=("
if [ -f ${BIN_FOLDER}/gitprompt/gitprompt.sh ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source ${BIN_FOLDER}/gitprompt/gitprompt.sh
fi
")
gitprompt_readmeline="| gitprompt | Special prompt in git repositories | Command \`gitprompt\`|| <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
gitprompt_repositoryurl="https://github.com/magicmonty/bash-git-prompt.git"

gmail_installationtype="environmental"
gmail_arguments=("gmail")
gmail_url="https://mail.google.com/"
gmail_bashfunctions=("alias gmail=\"nohup xdg-open ${gmail_url} &>/dev/null &\"")
gmail_downloads=("https://upload.wikimedia.org/wikipedia/commons/7/7e/Gmail_icon_%282020%29.svg;gmail_icon.svg")
gmail_readmelinedescription="Gmail opening in Chrome"
gmail_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${gmail_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${gmail_url}
Icon=${BIN_FOLDER}/gmail/gmail_icon.svg
GenericName=Gmail
Keywords=gmail;
MimeType=
Name=Gmail
StartupNotify=true
StartupWMClass=Gmail
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
gmail_readmeline="| Gmail | ${gmail_readmelinedescription} | Command \`gmail\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gnat_gps_installationtype="packagemanager"
gnat_gps_arguments=("gnat_gps")
gnat_gps_readmelinedescription="Programming Studio for Ada and C"
gnat_gps_launchercontents=("
[Desktop Entry]
Type=Application
Name=GNAT Programming Studio
Comment=${gnat_gps_readmelinedescription}
Exec=/usr/bin/gnat-gps
Icon=/usr/share/doc/gnat-gps/html/users_guide/_static/favicon.ico
Terminal=false
Categories=Development;IDE
Keywords=ide;editor;ada;c
")
gnat_gps_packagenames=("gnat-gps")
gnat_gps_readmeline="| GNAT | ${gnat_gps_readmelinedescription} | Command \`gnat-gps\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"


gnome_calculator_installationtype="packagemanager"
gnome_calculator_arguments=("gnome_calculator")
gnome_calculator_launchernames=("org.gnome.Calculator")
gnome_calculator_packagenames=("gnome-calculator")
gnome_calculator_readmeline="| Calculator | GUI calculator| Commmand \`calculator\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gnome_chess_installationtype="packagemanager"
gnome_chess_arguments=("gnome_chess" "chess")
gnome_chess_launchernames=("org.gnome.Chess")
gnome_chess_packagenames=("gnome-chess")
gnome_chess_readmeline="| Chess | Plays a full game of chess against a human being or other computer program | Command \`gnome-chess\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gnome_mahjongg_installationtype="packagemanager"
gnome_mahjongg_arguments=("gnome_mahjongg" "mahjongg")
gnome_mahjongg_launchernames=("org.gnome.Mahjongg")
gnome_mahjongg_packagenames=("gnome-mahjongg")
gnome_mahjongg_readmeline="| Mahjongg | Implementation for GNU systems of the famous popular chinese game Mahjongg | Command \`gnome-mahjongg\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gnome_mines_installationtype="packagemanager"
gnome_mines_arguments=("gnome_mines" "mines")
gnome_mines_launchernames=("org.gnome.Mines")
gnome_mines_packagenames=("gnome-mines")
gnome_mines_readmeline="| Mines | Implementation for GNU systems of the famous game mines | Command \`gnome-mines\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gnome_sudoku_installationtype="packagemanager"
gnome_sudoku_arguments=("gnome_sudoku" "sudoku")
gnome_sudoku_launchernames=("org.gnome.Sudoku")
gnome_sudoku_packagenames=("gnome-sudoku")
gnome_sudoku_readmeline="| sudoku | Implementation for GNU systems of the famous popular mathematical game sudoku | Command \`gnome-sudoku\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gnome_terminal_installationtype="packagemanager"
gnome_terminal_arguments=("gnome_terminal")
gnome_terminal_keybindings=("gnome-terminal;<Primary><Alt><Super>t;GNOME Terminal")
gnome_terminal_launchernames=("org.gnome.Terminal")
gnome_terminal_packagenames=("gnome-terminal")
gnome_terminal_readmeline="| GNOME terminal | Terminal of the system | Command \`gnome-terminal\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gnome_tweak_tool_installationtype="packagemanager"
gnome_tweak_tool_arguments=("gnome_tweak_tool" "tweaks" "gnome_tweak" "gnome_tweak_tools" "gnome_tweaks")
gnome_tweak_tool_packagenames=("gnome-tweak-tool")
gnome_tweak_tool_launchernames=("org.gnome.tweaks")
gnome_tweak_tool_readmeline="| GNOME Tweaks | GUI for system customization | command and desktop launcher... ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

google_installationtype="environmental"
google_arguments=("google")
google_url="https://www.google.com/"
google_bashfunctions=("alias google=\"nohup xdg-open ${google_url} &>/dev/null &\"")
google_downloads=("https://upload.wikimedia.org/wikipedia/commons/5/53/Google_\"G\"_Logo.svg;google_icon.svg")
google_readmelinedescription="Google opening in Chrome"
google_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${google_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${google_url}
Icon=${BIN_FOLDER}/google/google_icon.svg
GenericName=Google
Keywords=google;
MimeType=
Name=Google
StartupNotify=true
StartupWMClass=Google
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
google_readmeline="| Google | ${google_readmelinedescription} | Command \`google\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"


googlecalendar_installationtype="environmental"
googlecalendar_arguments=("google_calendar")
googlecalendar_url="https://calendar.google.com/"
googlecalendar_bashfunctions=("alias googlecalendar=\"nohup xdg-open ${googlecalendar_url} &>/dev/null &\"")
googlecalendar_downloads=("https://upload.wikimedia.org/wikipedia/commons/a/a5/Google_Calendar_icon_%282020%29.svg;googlecalendar_icon.svg")
googlecalendar_readmelinedescription="Google Calendar opening in Chrome"
googlecalendar_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${googlecalendar_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${googlecalendar_url}
Icon=${BIN_FOLDER}/googlecalendar/googlecalendar_icon.svg
GenericName=Google Calendar
Keywords=google-calendar;
MimeType=
Name=Google Calendar
StartupNotify=true
StartupWMClass=Google Calendar
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
googlecalendar_readmeline="| Google Calendar | ${googlecalendar_readmelinedescription} | Command \`googlecalendar\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

google_chrome_installationtype="packageinstall"
google_chrome_arguments=("google_chrome")
google_chrome_bashfunctions=("
google-chrome() {
  nohup google-chrome &>/dev/null &
}
")
google_chrome_flagsoverride=";;;;1;"
google_chrome_packagenames=("google-chrome-stable")
google_chrome_packagedependencies=("libxss1" "libappindicator1" "libindicator7" "fonts-liberation")
google_chrome_packageurls=("https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb")
google_chrome_launchernames=("google-chrome")
google_chrome_keybindings=("google-chrome;<Primary><Alt><Super>c;Google Chrome")
google_chrome_readmeline="| Google Chrome | Cross-platform web browser | Command \`google-chrome\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gpaint_installationtype="packagemanager"
gpaint_arguments=("gpaint")
gpaint_launchercontents=("
[Desktop Entry]
Name=GNU Paint
Comment=A small-scale painting program for GNOME, the GNU Desktop
TryExec=gpaint
Exec=gpaint
Icon=/usr/share/icons/hicolor/scalable/apps/gpaint.svg
Terminal=0
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;
X-Ubuntu-Gettext-Domain=gpaint-2
")
gpaint_packagenames=("gpaint")
gpaint_readmeline="| Gpaint | Raster graphics editor similar to Microsoft Paint | Command \`gpaint\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gparted_installationtype="packagemanager"
gparted_arguments=("gparted")
gparted_launchernames=("gparted")
gparted_packagenames=("gparted")
gparted_readmeline="| GParted | Creating, deleting, resizing, moving, checking, and copying disk partitions and their file systems | Command \`gparted\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gvim_installationtype="packagemanager"
gvim_arguments=("gvim" "vim_gtk3")
gvim_launchernames=("gvim")
gvim_packagenames=("vim-gtk3")
gvim_readmeline="| Gvim | Vim with a built-in GUI | Command \`gvim\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

h_installationtype="environmental"
h_arguments=("h")
h_bashfunctions=("
h()
{
  if [ \$# -eq 0 ]; then
    history
  else
    if [ \$# -eq 1 ]; then
      history | grep --color=always \"\$1\"
    else
      echo \"ERROR: Too many arguments\"
      return
    fi
  fi
}
")
h_readmeline="| Function \`h\` | Search in your history for previous commands entered, stands by \`history | grep \"\$@\"\` | Command \`h\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"


handbrake_installationtype="packagemanager"
handbrake_arguments=("handbrake")
handbrake_launchernames=("fr.handbrake.ghb")
handbrake_packagenames=("handbrake")
handbrake_readmeline="| Handbrake | Video Transcoder | Command \`handbrake\`, Desktop and dashboard launchers || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

hard_installationtype="environmental"
hard_arguments=("hard")
hard_bashfunctions=("alias hard=\"git reset HEAD --hard\"")
hard_readmeline="| Function \`hard\` | alias for \`git reset HEAD --hard\` | <-- || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

hardinfo_installationtype="packagemanager"
hardinfo_arguments=("hardinfo")
hardinfo_packagenames=("hardinfo")
hardinfo_launchernames=("hardinfo")
hardinfo_readmeline="| Hardinfo | Check pc hardware info | Command \`hardinfo\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

history_optimization_installationtype="environmental"
history_optimization_arguments=("history_optimization")
history_optimization_bashfunctions=("
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=100000
export HISTFILESIZE=10000000
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
# Store multiline commands with newlines when possible, rather that using semicolons
#shopt -s lithist
# To retrieve the commands correctly
HISTTIMEFORMAT='%F %T '
# Check the windows size on every prompt and reset the number of columns and rows if necessary
shopt -s checkwinsize  # Kinda buggy

# Save and reload from history before prompt appears
if [ -z \"\$(echo \"\${PROMPT_COMMAND}\" | grep -Fo \"history -a; history -r\")\" ]; then
  # Check if there is something inside PROMPT_COMMAND, so we put semicolon to separate or not
  if [ -z \"\${PROMPT_COMMAND}\" ]; then
    export PROMPT_COMMAND=\"history -a; history -r\"
  else
    export PROMPT_COMMAND=\"\${PROMPT_COMMAND}; history -a; history -r\"
  fi
fi
")
history_optimization_readmeline="| history optimization | Increased the size of bash history, store multiline commands in just one line, force append and not overwrite to history, ignore repeated commands when appending to history, deleted tracking history of some simple commands: \`ls\`, \`cd\`, \`gitk\`... | <-- || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

ideac_installationtype="userinherit"
ideac_arguments=("ideac" "intellij_community")
ideac_associatedfiletypes=("text/x-java")
ideac_bashfunctions="alias ideac=\"nohup ideac . &>/dev/null &\""
ideac_binariesinstalledpaths=("bin/idea.sh;ideac")
ideac_compressedfiletype="z"
ideac_compressedfileurl="https://download.jetbrains.com/idea/ideaIC-2021.1.2.tar.gz"
ideac_readmelinedescription="Integrated development environment written in Java for developing computer software"
ideac_launchercontents=("
[Desktop Entry]
Categories=Development;IDE;
Comment=${ideac_readmelinedescription}
Encoding=UTF-8
Exec=ideac %f
GenericName=Java programming IDE
Icon=${BIN_FOLDER}/ideac/bin/idea.svg
Keywords=IDE;programming;java;dev;
MimeType=
Name=IntelliJ IDEA Community Edition
StartupNotify=true
StartupWMClass=jetbrains-idea
Terminal=false
TryExec=ideac
Type=Application
Version=13.0
")
ideac_readmeline="| intelliJ Community | ${ideac_readmelinedescription} | Command \`ideac\`, silent alias for \`ideac\`, desktop launcher, dashboard launcher and association to \`.java\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |"

ideau_installationtype="userinherit"
ideau_arguments=("ideau" "intellij_ultimate")
ideau_associatedfiletypes=("text/x-java")
ideau_bashfunctions=("alias ideau=\"nohup ideau . &>/dev/null &\"")
ideau_binariesinstalledpaths=("bin/idea.sh;ideau")
ideau_compressedfiletype="z"
ideau_compressedfileurl="https://download.jetbrains.com/idea/ideaIU-2021.1.2.tar.gz"
ideau_readmelinedescription="Integrated development environment written in Java for developing computer software"
ideau_launchercontents=("
[Desktop Entry]
Categories=Development;IDE;
Comment=${ideau_readmelinedescription}
Encoding=UTF-8
Exec=ideau %f
GenericName=Java programing IDE
Icon=${BIN_FOLDER}/ideau/bin/idea.png
Keywords=IDE;programming;java;dev;
MimeType=
Name=IntelliJ IDEA Ultimate Edition
StartupNotify=true
StartupWMClass=jetbrains-idea
Terminal=false
TryExec=ideau
Type=Application
Version=1.0
")
ideau_readmeline="| intelliJ Ultimate | ${ideau_readmelinedescription} | Command \`ideau\`, silent alias for \`ideau\`, desktop launcher, dashboard launcher and association to \`.java\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |"

inkscape_installationtype="packagemanager"
inkscape_arguments=("ink_scape")
inkscape_launchernames=("inkscape")
inkscape_packagenames=("inkscape")
inkscape_readmeline="| Inkscape | Vector graphics editor used to create vector images, primarily in Scalable Vector Graphics format | Command \`inkscape\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

instagram_installationtype="environmental"
instagram_arguments=("instagram")
instagram_url="https://instagram.com"
instagram_bashfunctions="alias instagram=\"nohup xdg-open ${instagram_url} &>/dev/null &\""
instagram_downloads=("https://upload.wikimedia.org/wikipedia/commons/e/e7/Instagram_logo_2016.svg;instagram_icon.svg")
instagram_readmelinedescription="Opens Instagram in Chrome"
instagram_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${instagram_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${instagran_url}
Icon=${BIN_FOLDER}/instagram/instagram_icon.svg
GenericName=instagram
Keywords=instagram
MimeType=
Name=Instagram
StartupNotify=true
StartupWMClass=Instagram
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
instagram_readmeline="| Instagram | ${instagram_readmelinedescription} | Command \`instagram\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

ipe_installationtype="environmental"
ipe_arguments=("ipe")
ipe_bashfunctions=("
ipe()
{
  dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'\"' '{ print \$2 }';
}
")
ipe_readmeline="| ipe function | Returns the public IP | Command \`ipe\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

ipi_installationtype="environmental"
ipi_arguments=("ipi")
ipi_bashfunctions=("
ipi()
{
  hostname -I | awk '{print \$1}'
}
")
ipi_readmeline="| ipi function | Returns the private IP | Command \`ipi\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"


iqmol_installationtype="packageinstall"
iqmol_arguments=("iqmol")
iqmol_bashfunctions=("alias iqmol=\"nohup iqmol . &>/dev/null &\"")
iqmol_downloads=("http://www.iqmol.org/images/icon.png;iqmol_icon.png")
iqmol_readmelinedescription="Program to visualize molecular data"
iqmol_launchercontents=("
[Desktop Entry]
Categories=Visualization;
Comment=${iqmol_readmelinedescription}
Encoding=UTF-8
Exec=iqmol
GenericName=Molecule visualizer
Icon=${BIN_FOLDER}/iqmol/iqmol_icon.png
Keywords=molecules;chemistry;3d;
MimeType=
Name=IQmol
StartupNotify=true
StartupWMClass=IQmol
Terminal=false
TryExec=iqmol
Type=Application
Version=1.0
")
iqmol_packageurls=("http://www.iqmol.org/download.php?get=iqmol_2.14.deb")
iqmol_readmeline="| IQmol | ${iqmol_readmelinedescription} | Command \`iqmol\`, silent alias, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

j_installationtype="environmental"
j_arguments=("j")
j_bashfunctions=("alias j=\"jobs -l\"")
j_readmeline="| Function \`j\` | alias for jobs -l | Commands \`j\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

java_installationtype="userinherit"
java_arguments=("java" "javadevelopmentkit" "java_development_kit" "java_development_kit_11" "jdk" "jdk11")
java_bashfunctions=("export JAVA_HOME=\"${BIN_FOLDER}/jdk8\"")
java_binariesinstalledpaths=("bin/java;java")
java_compressedfiletype="z"
java_compressedfileurl="https://download.java.net/openjdk/jdk8u41/ri/openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz"
java_readmeline="| Java Development Kit 8 | Implementation of version 8 of the Java (programming language) SE Platform | Commands \`java\`, \`javac\` and \`jar\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

julia_installationtype="userinherit"
julia_arguments=("julia")
julia_binariesinstalledpaths=("bin/julia;julia")
julia_compressedfiletype="z"
julia_compressedfileurl="https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.5-linux-x86_64.tar.gz"
julia_readmelinedescription="High-level, high-performance dynamic language for technical computing"
julia_launchercontents=("
[Desktop Entry]
Name=Julia
Comment=${julia_readmelinedescription}
Exec=julia
Icon=${BIN_FOLDER}/julia/share/icons/hicolor/scalable/apps/julia.svg
Terminal=true
Type=Application
Categories=Development;ComputerScience;Building;Science;Math;NumericalAnalysis;ParallelComputing;DataVisualization;ConsoleOnly;
")
julia_readmeline="| Julia and IJulia| ${julia_readmelinedescription} | Commands \`julia\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

jupyter_lab_installationtype="pythonvenv"
jupyter_lab_arguments=("jupyter_lab" "jupyter" "lab")
jupyter_lab_bashfunctions=("alias lab=\"jupyter-lab\"")
jupyter_lab_binariesinstalledpaths=("bin/jupyter-lab;jupyter-lab" "bin/jupyter;jupyter" "bin/ipython;ipython" "bin/ipython3;ipython3")
jupyter_lab_bashfunctions=("alias lab=\"jupyter-lab\"")
jupyter_lab_flagsoverride=";;1;;;"  # Ignore Errors to check dependencies
jupyter_lab_readmelinedescription="IDE with a lot of possible customization and usable for different programming languages."
jupyter_lab_launchercontents=("
[Desktop Entry]
Categories=IDE; text_editor;
Comment=${jupyter_lab_readmelinedescription}
Encoding=UTF-8
GenericName=jupyter-lab
Keywords=jupyter; programming; text; webpage;
MimeType=
Name=Jupyter Lab
StartupNotify=true
StartupWMClass=jupyter
Terminal=false
Type=Application
Version=1.0
Icon=${BIN_FOLDER}/jupyter_lab/share/icons/hicolor/scalable/apps/notebook.svg
Exec=jupyter-lab &
")
jupyter_lab_manualcontentavailable="1;1;0"
jupyter_lab_pipinstallations=("jupyter jupyterlab jupyterlab-git jupyterlab_markup" "bash_kernel" "pykerberos pywinrm[kerberos]" "powershell_kernel" "iarm" "ansible-kernel" "kotlin-jupyter-kernel" "vim-kernel" "theme-darcula")
jupyter_lab_pythoncommands=("bash_kernel.install" "iarm_kernel.install" "ansible_kernel.install" "vim_kernel.install")  # "powershell_kernel.install --powershell-command powershell"  "kotlin_kernel fix-kernelspec-location"
jupyter_lab_readmeline="| Jupyter Lab | ${jupyter_lab_readmelinedescription} | alias \`lab\`, commands \`jupyter-lab\`, \`jupyter-lab\`, \`ipython\`, \`ipython3\`, desktop launcher and dashboard launcher. Recognized programming languages: Python, Ansible, Bash, IArm, Kotlin, PowerShell, Vim. || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

k_installationtype="environmental"
k_arguments=("k")
k_bashfunctions=("
k() {    #sudo kill \`lsof -i:3000 -t\` \"\$1\"  # kill by port
  [ \"\$1\" -eq \"\$1\" ] 2>/dev/null
  if [ \$? -eq 0 ]; then
    sudo kill -9 \"\$1\"
  else
    if [ -n \"\$1\" ]; then
      pkill \"\$1\"
    else
      # Introduce port to be killed
      echo \"Kill port nº:\"
      read portkillnumber
      for pid_program in \$(sudo lsof -i:\"\${portkillnumber}\" | tail -n+2 | tr -s \" \"  | cut -d \" \" -f2 | sort | uniq); do
        sudo kill \${pid_program}
      done
    fi
  fi
}
")
k_readmeline="| Function \`k\` | Kill processes by PID and name of process | Command \`k\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |  "


keep_installationtype="environmental"
keep_arguments=("keep" "google_keep")
keep_url="https://keep.google.com/"
keep_bashfunctions=("alias keep=\"nohup xdg-open ${keep_url} &>/dev/null &\"")
keep_downloads=("https://upload.wikimedia.org/wikipedia/commons/b/bd/Google_Keep_icon_%282015-2020%29.svg;keep_icon.svg")
keep_readmelinedescription="Google Keep opening in Chrome"
keep_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${keep_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${keep_url}
Icon=${BIN_FOLDER}/keep/keep_icon.svg
GenericName=Google Calendar
Keywords=google-keep;keep;
MimeType=
Name=Google Keep
StartupNotify=true
StartupWMClass=Google Keep
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
keep_readmeline="| Google Keep | ${keep_readmelinedescription} | Command \`keep\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

L_installationtype="environmental"
L_arguments=("L")
L_bashfunctions=("
L()
{
  # Work around because du options are hard to parametrize for a different directory that the current one for showing size of hiddent directories
  if [ -n \"\$1\" ]; then
    local -r current_path=\"\$(pwd)\"
    cd \"\$1\"
  fi
  local -r NEW_LINE=\$'\\n'
  local -r lsdisplay=\"\$(ls -lhA | tr -s \" \" | tail -n+2)\"  # Obtain ls data in list format
  local -r numfiles=\"\$(echo \"\$lsdisplay\" | wc -l)\"  # Obtain number of elements in the folder
  local -r dudisplay=\"\$(du -shxc .[!.]* * 2>/dev/null | sort -h | tr -s \"\\\t\" \" \" | head -n -1)\"  # Obtain du data for the real size of the directories, deleting the line of the total size
  local -r totaldu=\"\$(echo \${dudisplay} | tail -1 | rev | cut -d \" \" -f2 | rev)\"  # Obtain the total size of the folder
  local finaldisplay=\"\"
  # Iterate over every line in ls and check if it is a directory in order to change the size shown in ls (4 KB) for the real size of directory from the output of du
  local IFS=\$'\\n'
  for linels in \${lsdisplay}; do
    element_name=\"\$(echo \${linels} | cut -d ' ' -f9-)\"  # Obtain full name of the element that we are goind to add
    if [[ \"\${linels}\" =~ ^d.* ]]; then  # If a directory, perform substitution of size
      for linedu in \${dudisplay}; do  # Search for matching du line using name from both ls and du
        if [[ \"\$(echo \${linedu} | cut -d ' ' -f2-)\" = \"\${element_name}\" ]]; then  # Search for match using directory name
          currentline=\$(echo \${linels} | cut -d \" \" -f-4)  # Obtain prefix of line (before the column of the size in ls)
          currentline=\"\${currentline} \$(echo \${linedu} | cut -d ' ' -f1)\"  # Obtain size from du and append
          currentline=\"\${currentline} \$(echo \${linels} | cut -d ' ' -f6-)\"  # Obtain rest of the line
          # Now add the semicolons in between columns in order to work with column command

          finaldisplay=\"\$finaldisplay\$NEW_LINE\$(echo \"\${currentline}\" | cut -d ' ' -f-8 | tr \" \" \";\");\${element_name}\"
          break
        fi
      done
    else
      finaldisplay=\"\${finaldisplay}\${NEW_LINE}\$(echo \"\${linels}\" | cut -d ' ' -f-8 | tr \" \" \";\");\${element_name}\"  # Change spaces for semicolons for using column
    fi
  done
  finaldisplay=\"\$(echo \"\${finaldisplay}\"  | column -ts \";\")\"  # Construct table by using column
  finaldisplay=\"\${totaldu} in \${numfiles} files and directories\${NEW_LINE}\${finaldisplay}\"  # Prepend first line of output with general summary
  echo \"\${finaldisplay}\"
  if [ -n \"\${current_path}\" ]; then
    cd \"\${current_path}\"
  fi
}
")
L_readmeline="| Function \`L\` | Function that lists files in a directory, but listing the directory sizes | Function \`L\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

l_installationtype="environmental"
l_arguments=("l")
l_bashfunctions=("alias l=\"ls -lAh --color=auto\"")
l_readmeline="| Function \`l\` | alias for \`ls\` | command \`l\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

latex_installationtype="packagemanager"
latex_arguments=("latex")
latex_readmelinedescription="Software system for document preparation"
latex_launchercontents=("
[Desktop Entry]
Name=TeXdoctk
Exec=texdoctk
Comment=${latex_readmelinedescription}
Type=Application
Type=Application
Terminal=false
Categories=Settings;
Icon=/usr/share/icons/Yaru/256x256/mimetypes/text-x-tex.png")
latex_launchernames=("texmaker")
latex_packagedependencies=("perl-tk" )
latex_packagenames=("texlive-latex-extra" "texmaker" "perl-tk")
latex_readmeline="| LaTeX | ${latex_readmelinedescription} | Command \`tex\` (LaTeX compiler) and \`texmaker\` (LaTeX IDE), desktop launchers for \`texmaker\` and LaTeX documentation ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

libgtkglext1_installationtype="packagemanager"
libgtkglext1_arguments=("libgtkglext1" "anydesk_dependencies")
libgtkglext1_packagenames=("libgtkglext1")
libgtkglext1_readmeline="| libgtkglext1 | Anydesk dependency | Used when Anydesk is run ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

libkrb5_dev_installationtype="packagemanager"
libkrb5_dev_arguments=("libkrb5_dev" "kerberos_dependencies")
libkrb5_dev_packagenames=("libkrb5-dev")
libkrb5_dev_readmeline="| libkrb5-dev | Kerberos dependency | Used when Jupiter Lab is run ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

libxcb_xtest0_installationtype="packagemanager"
libxcb_xtest0_arguments=("libxcb_xtest0")
libxcb_xtest0_packagenames=("libxcb-xtest0")
libxcb_xtest0_readmeline="| libxcb-xtest0 | Zoom dependency | Used when Zoom is run ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

lmms_installationtype="packagemanager"
lmms_arguments=("lmms")
lmms_bashfunctions=("alias lmms=\"nohup lmms &>/dev/null &\"")
lmms_packagenames=("lmms")
lmms_launchernames=("lmms")
lmms_readmeline="| lmms | Software for making music | command \`lmms\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

lolcat_installationtype="packagemanager"
lolcat_arguments=("lolcat")
lolcat_bashfunctions=("alias lol=\"lolcat\"")
lolcat_packagenames=("lolcat")
lolcat_readmeline="| lolcat | Same as the command \`cat\` but outputting the text in rainbow color and concatenate string | command \`lolcat\`, alias \`lol\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

mdadm_installationtype="packagemanager"
mdadm_arguments=("mdadm")
mdadm_packagenames=("mdadm")
mdadm_readmeline="| mdadm | Manage RAID systems | Command \`mdadm\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

megasync_installationtype="packageinstall"
megasync_arguments=("megasync" "mega")
megasync_packagedependencies=("nautilus" "libc-ares2" "libmediainfo0v5" "libqt5x11extras5" "libzen0v5")
megasync_packageurls=("https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/megasync_4.5.3-2.1_amd64.deb" "https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/nautilus-megasync_3.6.6_amd64.deb")
megasync_launchernames=("megasync")
megasync_packagenames=("nautilus-megasync" "megasync")
megasync_readmeline="| MegaSync | Synchronises folders between your computer and your MEGA Cloud Drive | Command \`megasync\`, desktop launcher, dashboard launcher and integration with \`nemo\` file explorer ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

mendeley_dependencies_installationtype="packagemanager"
mendeley_dependencies_arguments=("mendeley_dependencies" "mendeley_desktop_dependencies")
mendeley_dependencies_packagedependencies=("gconf2" "qt5-default" "qt5-doc" "qt5-doc-html" "qtbase5-examples" "qml-module-qtwebengine")
mendeley_dependencies_readmeline="| MendeleyDependencies | Installs Mendeley Desktop dependencies \`gconf2\`, \`qt5-default\`, \`qt5-doc\`, \`qt5-doc-html\`, \`qtbase5-examples\` and \`qml-module-qtwebengine\` | Used when installing Mendeley and other dependent software || <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

mendeley_installationtype="userinherit"
mendeley_arguments=("mendeley")
mendeley_compressedfileurl="https://www.mendeley.com/autoupdates/installer/Linux-x64/stable-incoming"
mendeley_compressedfiletype="j"
mendeley_binariesinstalledpaths="bin/mendeleydesktop;mendeley"
mendeley_readmelinedescription="It is most known for its reference manager which is used to manage and share research papers and generate bibliographies for scholarly articles"
mendeley_readmeline="| Mendeley | ${mendeley_readmelinedescription} | Command \`mendeley\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
mendeley_launchercontents=("
[Desktop Entry]
Name=Mendeley Desktop
GenericName=Research Paper Manager
Comment=${mendeley_readmelinedescription}
Exec=mendeley %f
Icon=${BIN_FOLDER}/mendeley/share/icons/hicolor/128x128/apps/mendeleydesktop.png
Terminal=false
Type=Application
Categories=Education;Literature;Qt;
X-SuSE-translate=false
MimeType=x-scheme-handler/mendeley;application/pdf;text/x-bibtex;
X-Mendeley-Version=1
")

msttcorefonts_installationtype="packagemanager"
msttcorefonts_arguments=("msttcorefonts")
msttcorefonts_packagenames=("msttcorefonts")
msttcorefonts_readmeline="| font Msttcorefonts | Windows classic fonts | Install mscore fonts ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

mvn_installationtype="userinherit"
mvn_arguments=("mvn")
mvn_binariesinstalledpaths=("bin/mvn;mvn")
mvn_compressedfiletype="z"
mvn_compressedfileurl="https://ftp.cixug.es/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz"
mvn_readmeline="| Maven | Build automation tool used primarily for Java projects | Command \`mvn\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |"

nautilus_installationtype="packagemanager"
nautilus_arguments=("nautilus")
nautilus_bashfunctions=("
xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search
gsettings set org.gnome.desktop.background show-desktop-icons true
xdg-mime default org.gnome.Nautilus.desktop inode/directory
")
nautilus_launchernames=("org.gnome.Nautilus")
nautilus_packagenames=("nautilus")
nautilus_readmeline="| Nautilus | Standard file and desktop manager | Command \`nautilus\` Desktop launcher and dashboard launcher for the file manager ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

nedit_installationtype="packagemanager"
nedit_arguments=("nedit")
nedit_packagenames=("nedit")
nedit_launchernames=("nedit")
nedit_readmeline="| NEdit | Multi-purpose text editor and source code editor | Command \`nedit\` desktop launcher, dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

nemo_installationtype="packagemanager"
nemo_arguments=("nemo" "nemo_desktop")
nemo_bashfunctions=("
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
gsettings set org.gnome.desktop.background show-desktop-icons false
gsettings set org.nemo.desktop show-desktop-icons true
"

"
nemo()
{
  nohup nemo \"\$1\" &>/dev/null &
}
")
nemo_packagedependencies=("dconf-editor" "gnome-tweak-tool")
nemo_readmelinedescription="File and desktop manager, usually with better options and less bugs than nautilus. *We recommend this explorer to view correctly the launchers*"
nemo_launchercontents=("
[Desktop Entry]
OnlyShowIn=GNOME;Unity;
X-Ubuntu-Gettext-Domain=nemo

Name=Files
Name[am]=ፋይሎች
Name[ar]=الملفات
Name[bg]=Файлове
Name[ca]=Fitxers
Name[ca@valencia]=Fitxers
Name[cs]=Soubory
Name[cy]=Ffeiliau
Name[da]=Filer
Name[de]=Dateien
Name[el]=Αρχεία
Name[eo]=Dosieroj
Name[es]=Archivos
Name[et]=Failid
Name[eu]=Fitxategiak
Name[fi]=Tiedostot
Name[fr]=Fichiers
Name[fr_CA]=Fichiers
Name[he]=קבצים
Name[hr]=Nemo
Name[hu]=Fájlok
Name[id]=Berkas
Name[is]=Skrár
Name[kab]=Ifuyla
Name[ko]=파일
Name[lt]=Failai
Name[nl]=Bestanden
Name[pl]=Pliki
Name[pt]=Ficheiros
Name[pt_BR]=Arquivos
Name[ro]=Fișiere
Name[ru]=Файлы
Name[sk]=Súbory
Name[sl]=Datoteke
Name[sr]=Датотеке
Name[sr@latin]=Датотеке
Name[sv]=Filer
Name[th]=แฟ้ม
Name[tr]=Dosyalar
Name[uk]=Файли
Name[zh_CN]=文件
Name[zh_HK]=檔案
Comment=Access and organize files
Comment[am]=ፋይሎች ጋር መድረሻ እና ማደራጃ
Comment[ar]=الوصول إلى الملفات وتنظيمها
Comment[bg]=Достъп и управление на файлове
Comment[ca]=Organitzeu i accediu als fitxers
Comment[ca@valencia]=Organitzeu i accediu als fitxers
Comment[cs]=Přístup k souborům a jejich správa
Comment[cy]=Mynediad i drefnu ffeiliau
Comment[da]=Tilgå og organisér filer
Comment[de]=Dateien aufrufen und organisieren
Comment[el]=Πρόσβαση και οργάνωση αρχείων
Comment[en_GB]=Access and organise files
Comment[eo]=Atingi kaj organizi dosierojn
Comment[es]=Acceder a los archivos y organizarlos
Comment[et]=Ligipääs failidele ning failipuu korrastamine
Comment[eu]=Atzitu eta antolatu fitxategiak
Comment[fi]=Avaa ja järjestä tiedostoja
Comment[fr]=Accéder aux fichiers et les organiser
Comment[fr_CA]=Accéder aux fichiers et les organiser
Comment[he]=גישה לקבצים וארגונם
Comment[hr]=Pristupite i organizirajte datoteke
Comment[hu]=Fájlok elérése és rendszerezése
Comment[ia]=Acceder e organisar le files
Comment[id]=Akses dan kelola berkas
Comment[ie]=Accesse e ordina files
Comment[is]=Aðgangur og skipulag skráa
Comment[it]=Accede ai file e li organizza
Comment[kab]=Kcem udiɣ suddes ifuyla
Comment[ko]=파일 접근 및 정리
Comment[lt]=Gauti prieigą prie failų ir juos tvarkyti
Comment[nl]=Bestanden gebruiken en organiseren
Comment[pl]=Porządkowanie i dostęp do plików
Comment[pt]=Aceder e organizar ficheiros
Comment[pt_BR]=Acesse e organize arquivos
Comment[ro]=Accesează și organizează fișiere
Comment[ru]=Управление и доступ к файлам
Comment[sk]=Prístup a organizácia súborov
Comment[sl]=Dostop in razvrščanje datotek
Comment[sr]=Приступите датотекама и организујте их
Comment[sr@latin]=Приступите датотекама и организујте их
Comment[sv]=Kom åt och organisera filer
Comment[th]=เข้าถึงและจัดระเบียบแฟ้ม
Comment[tr]=Dosyalara eriş ve düzenle
Comment[uk]=Доступ до файлів та впорядковування файлів
Comment[zh_CN]=访问和组织文件
Comment[zh_HK]=存取與組織檔案
Exec=nemo
Icon=folder
# Translators: these are keywords of the file manager
Keywords=folders;filesystem;explorer;
Terminal=false
Type=Application
StartupNotify=false
Categories=GNOME;GTK;Utility;Core;
MimeType=inode/directory;application/x-gnome-saved-search;
Actions=open-home;open-computer;open-trash;

[Desktop Action open-home]
Name=Home
Name[af]=Tuis
Name[am]=ቤት
Name[ar]=المجلد الرئيسي
Name[be]=Дом
Name[bg]=Домашна папка
Name[bn]=হোম
Name[bs]=Početni direktorij
Name[ca]=Carpeta de l'usuari
Name[ca@valencia]=Carpeta de l'usuari
Name[cs]=Domov
Name[cy]=Cartref
Name[da]=Hjem
Name[de]=Persönlicher Ordner
Name[el]=Προσωπικός φάκελος
Name[eo]=Hejmo
Name[es]=Carpeta personal
Name[et]=Kodu
Name[eu]=Karpeta nagusia
Name[fi]=Koti
Name[fr]=Dossier personnel
Name[fr_CA]=Dossier personnel
Name[ga]=Baile
Name[gd]=Dhachaigh
Name[gl]=Cartafol persoal
Name[he]=בית
Name[hr]=Osobna mapa
Name[hu]=Saját mappa
Name[ia]=Al domo
Name[id]=Beranda
Name[ie]=Hem
Name[is]=Heimamappa
Name[ja]=ホーム
Name[kab]=Agejdan
Name[kk]=Үй
Name[kn]=ಮನೆ
Name[ko]=홈
Name[ku]=Mal
Name[lt]=Namai
Name[ml]=ആസ്ഥാനം
Name[mr]=मुख्य
Name[ms]=Rumah
Name[nb]=Hjem
Name[nl]=Persoonlijke map
Name[oc]=Dorsièr personal
Name[pl]=Katalog domowy
Name[pt]=Pasta Pessoal
Name[pt_BR]=Pasta pessoal
Name[ro]=Dosar personal
Name[ru]=Домашняя папка
Name[sk]=Domov
Name[sl]=Domov
Name[sr]=Почетна
Name[sr@latin]=Početna
Name[sv]=Hem
Name[ta]=இல்லம்
Name[tg]=Асосӣ
Name[th]=บ้าน
Name[tr]=Ev Dizini
Name[uk]=Домівка
Name[ur]=المنزل
Name[vi]=Nhà
Name[zh_CN]=主目录
Name[zh_HK]=家
Name[zh_TW]=家
Exec=nemo %U

[Desktop Action open-computer]
Name=Computer
Name[af]=Rekenaar
Name[am]=ኮምፒዩተር
Name[ar]=الكمبيوتر
Name[ast]=Ordenador
Name[be]=Кампутар
Name[bg]=Компютър
Name[bn]=কম্পিউটার
Name[bs]=Računar
Name[ca]=Ordinador
Name[ca@valencia]=Ordinador
Name[cs]=Počítač
Name[cy]=Cyfrifiadur
Name[de]=Rechner
Name[el]=Υπολογιστής
Name[eo]=Komputilo
Name[es]=Equipo
Name[et]=Arvuti
Name[eu]=Ordenagailua
Name[fi]=Tietokone
Name[fr]=Poste de travail
Name[fr_CA]=Poste de travail
Name[gd]=Coimpiutair
Name[gl]=Computador
Name[he]=מחשב
Name[hr]=Računalo
Name[hu]=Számítógép
Name[ia]=Computator
Name[id]=Komputer
Name[ie]=Computator
Name[is]=Tölva
Name[ja]=コンピュータ
Name[kab]=Aselkim
Name[kk]=Компьютер
Name[kn]=ಗಣಕ
Name[ko]=컴퓨터
Name[ku]=Komputer
Name[lt]=Kompiuteris
Name[ml]=കമ്പ്യൂട്ടർ
Name[mr]=संगणक
Name[ms]=Komputer
Name[nb]=Datamaskin
Name[nn]=Datamaskin
Name[oc]=Ordenador
Name[pl]=Komputer
Name[pt]=Computador
Name[pt_BR]=Computador
Name[ru]=Компьютер
Name[sk]=Počítač
Name[sl]=Računalnik
Name[sq]=Kompjuteri
Name[sr]=Рачунар
Name[sr@latin]=Računar
Name[sv]=Dator
Name[ta]=கணினி
Name[tg]=Компютер
Name[th]=คอมพิวเตอร์
Name[tr]=Bilgisayar
Name[uk]=Комп’ютер
Name[ur]=کمپیوٹر
Name[vi]=Máy tính
Name[zh_CN]=计算机
Name[zh_HK]=電腦
Name[zh_TW]=電腦
Exec=nemo computer:///

[Desktop Action open-trash]
Name=Trash
Name[af]=Asblik
Name[am]=ቆሻሻ
Name[ar]=سلة المهملات
Name[ast]=Papelera
Name[be]=Сметніца
Name[bg]=Кошче
Name[bn]=ট্র্যাশ
Name[bs]=Smeće
Name[ca]=Paperera
Name[ca@valencia]=Paperera
Name[cs]=Koš
Name[cy]=Sbwriel
Name[da]=Papirkurv
Name[de]=Papierkorb
Name[el]=Απορρίμματα
Name[en_GB]=Rubbish Bin
Name[eo]=Rubujo
Name[es]=Papelera
Name[et]=Prügi
Name[eu]=Zakarrontzia
Name[fi]=Roskakori
Name[fr]=Corbeille
Name[fr_CA]=Corbeille
Name[ga]=Bruscar
Name[gd]=An sgudal
Name[gl]=Lixo
Name[he]=אשפה
Name[hr]=Smeće
Name[hu]=Kuka
Name[ia]=Immunditia
Name[id]=Tempat sampah
Name[ie]=Paper-corb
Name[is]=Rusl
Name[it]=Cestino
Name[ja]=ゴミ箱
Name[kab]=Iḍumman
Name[kk]=Себет
Name[kn]=ಕಸಬುಟ್ಟಿ
Name[ko]=휴지통
Name[ku]=Avêtî
Name[lt]=Šiukšlinė
Name[ml]=ട്രാഷ്
Name[mr]=कचरापेटी
Name[ms]=Tong Sampah
Name[nb]=Papirkurv
Name[nds]=Papierkorb
Name[nl]=Prullenbak
Name[nn]=Papirkorg
Name[oc]=Escobilhièr
Name[pl]=Kosz
Name[pt]=Lixo
Name[pt_BR]=Lixeira
Name[ro]=Coș de gunoi
Name[ru]=Корзина
Name[sk]=Kôš
Name[sl]=Smeti
Name[sq]=Koshi
Name[sr]=Смеће
Name[sr@latin]=Kanta
Name[sv]=Papperskorg
Name[ta]=குப்பைத் தொட்டி
Name[tg]=Сабад
Name[th]=ถังขยะ
Name[tr]=Çöp
Name[uk]=Смітник
Name[ur]=ردی
Name[vi]=Thùng rác
Name[zh_CN]=回收站
Name[zh_HK]=垃圾桶
Name[zh_TW]=回收筒
Exec=nemo trash:///
")
nemo_readmeline="| Nemo Desktop | Access and organise files | Command \`nemo\` for the file manager, and \`nemo-desktop\` for the desktop manager service. Desktop launcher and dashboard launcher for the file manager ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
nemo_autostartlaunchers=("
[Desktop Entry]
Type=Application
Name=Nemo
Comment=Start Nemo desktop at log in
Exec=nemo-desktop
AutostartCondition=GSettings org.nemo.desktop show-desktop-icons
X-GNOME-AutoRestart=true
X-GNOME-Autostart-Delay=2
NoDisplay=false
")
nemo_flagsoverride=";;;;;1"  # Always autostart

netflix_installationtype="environmental"
netflix_arguments=("netflix")
netflix_url="https://www.netflix.com"
netflix_bashfunctions=("alias netflix=\"nohup xdg-open ${netflix_url} &>/dev/null &\"")
netflix_downloads=("https://upload.wikimedia.org/wikipedia/commons/7/75/Netflix_icon.svg;netflix_icon.svg")
netflix_readmelinedescription="Netflix opening in Chrome"
netflix_launchercontents=("
[Desktop Entry]
Categories=Network;VideoStreaming;Film;
Comment=${netflix_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${netflix_url}
Icon=${BIN_FOLDER}/netflix/netflix_icon.svg
GenericName=Netflix
Keywords=netflix;
MimeType=
Name=Netflix
StartupNotify=true
StartupWMClass=Netflix
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
netflix_readmeline="| Netflix | ${netflix_readmelinedescription} | Command \`netflix\`. Desktop launcher and dashboard launcher for the file manager | --netflix --Netflix |  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

net_tools_installationtype="packagemanager"
net_tools_arguments=("net_tools")
net_tools_bashfunctions=("
alias ports=\"netstat -tulanp\"
alias nr=\"net-restart\"
")
net_tools_packagenames=("net-tools")
net_tools_readmeline="| net-tools | GUI network interfaces. *We recommend this explorer to view correctly the launchers* | Command \`net-tools\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

npm_installationtype="userinherit"
npm_arguments=("npm")
npm_binariesinstalledpaths=("bin/node;node" "bin/npm;npm" "bin/npx;npx")
npm_compressedfiletype="J"
npm_compressedfileurl="https://nodejs.org/dist/v14.17.0/node-v14.17.0-linux-x64.tar.xz"
npm_readmeline="| NodeJS npm | JavaScript packagemanager for the developers. | Command \`node\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

notepadqq_installationtype="packagemanager"
notepadqq_arguments=("notepad_qq")
notepadqq_packagenames=("notepadqq")
notepadqq_launchernames=("notepadqq")
notepadqq_readmeline="| Notepadqq | Text editor that is designed by developers for the developers. It supports more than 100 programming languages | Command \`notepadqq\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

o_installationtype="environmental"
o_arguments=("o")
o_bashfunctions=("
o()
{
	if [[ -z \"\$1\" ]]; then
		nemo \"\$(pwd)\" &>/dev/null &
	else
		nemo \"\$1\" &>/dev/null &
	fi
}
")
o_readmeline="| Function \`o\` | Alias for \`nemo-desktop\` | Alias \`o\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"


obs_studio_installationtype="packagemanager"
obs_studio_arguments=("obs_studio" "obs")
obs_studio_launchernames=("com.obsproject.Studio")
obs_studio_packagedependencies=("ffmpeg")
obs_studio_packagenames=("obs-studio")
obs_studio_readmeline="| OBS | Streaming and recording program | Command \`obs\`, desktop launcher and dashboard launcher. ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

octave_installationtype="packagemanager"
octave_arguments=("octave" "gnu_octave" "octave_cli")
octave_bashfunctions=("alias octave=\"nohup /usr/bin/octave --gui %f &>/dev/null &\"")
octave_packagenames=("octave")
octave_launchernames=("org.octave.Octave")
octave_readmeline="| GNU Octave | Programming language and IDE | Command \`octave\`, desktop launcher and dashboard launcher. ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

okular_installationtype="packagemanager"
okular_arguments=("okular")
okular_launchernames=("org.kde.okular")
okular_packagenames=("okular")
okular_readmeline="| Okular | PDF viewer | Command \`okular\`, desktop launcher and dashboard launcher ||   <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

onedrive_installationtype="environmental"
onedrive_arguments=("onedrive")
onedrive_url="https://onedrive.live.com/"
onedrive_bashfunctions=("alias onedrive=\"nohup xdg-open ${onedrive_url} &>/dev/null &\"")
onedrive_downloads=("https://upload.wikimedia.org/wikipedia/commons/3/3c/Microsoft_Office_OneDrive_%282019%E2%80%93present%29.svg;onedrive_icon.svg")
onedrive_readmelinedescription="Microsoft OneDrive opening in Chrome"
onedrive_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${onedrive_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${onedrive_url}
Icon=${BIN_FOLDER}/onedrive/onedrive_icon.svg
GenericName=OneDrive
Keywords=onedrive;
MimeType=
Name=OneDrive
StartupNotify=true
StartupWMClass=OneDrive
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
onedrive_readmeline="| OneDrive | ${onedrive_readmelinedescription} | Command \`onedrive\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

openoffice_installationtype="packageinstall"
openoffice_arguments=("open_office")
openoffice_packagenames=("libreoffice-base-core" "libreoffice-impress" "libreoffice-calc"
      "libreoffice-math" "libreoffice-common" "libreoffice-ogltrans" "libreoffice-core" "libreoffice-pdfimport"
      "libreoffice-draw" "libreoffice-style-breeze" "libreoffice-gnome" "libreoffice-style-colibre" "libreoffice-gtk3"
      "libreoffice-style-elementary" "libreoffice-help-common" "libreoffice-style-tango" "libreoffice-help-en-us"
      "libreoffice-writer")
openoffice_compressedfileurl="https://downloads.sourceforge.net/project/openofficeorg.mirror/4.1.9/binaries/en-US/Apache_OpenOffice_4.1.9_Linux_x86-64_install-deb_en-US.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fopenofficeorg.mirror%2Ffiles%2F4.1.9%2Fbinaries%2Fen-US%2FApache_OpenOffice_4.1.9_Linux_x86-64_install-deb_en-US.tar.gz%2Fdownload&ts=1614201028"
openoffice_compressedfiletype="z"
openoffice_launchernames=("openoffice4-base" "openoffice4-calc" "openoffice4-draw" "openoffice4-math" "openoffice4-writer")
openoffice_readmeline="| OpenOffice | Office suite for open-source systems | Command \`openoffice4\` in PATH, desktop launchers for \`base\`, \`calc\`, \`draw\`, \`math\` and \`writer\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

openssl102_installationtype="packageinstall"
openssl102_arguments=("openssl102")
openssl102_packageurls=("http://security.debian.org/debian-security/pool/updates/main/o/openssl1.0/libssl1.0.2_1.0.2u-1~deb9u4_amd64.deb")
openssl102_readmeline="| openssl1.0 | RStudio dependency | Used for running rstudio ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

openssh_server_installationtype="packagemanager"
openssh_server_arguments=("openssh_server")
openssh_server_packagenames=("openssh-server")
openssh_server_bashfunctions=("
alias sshDisable=\"sudo systemctl disable sshd\"
alias sshEnable=\"sudo systemctl enable ssh\"
alias sshRestart=\"sudo systemctl restart sshd\"
alias sshStart=\"sudo systemctl start sshd\"
alias sshStatus=\"sudo systemctl status sshd\"
alias sshStop=\"sudo systemctl stop sshd\"
")
openssh_server_readmeline="| openssh-server | SSH server | Used for running an SSH server ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

outlook_installationtype="environmental"
outlook_arguments=("outlook")
outlook_url="https://outlook.live.com"
outlook_bashfunctions=("alias outlook=\"nohup xdg-open ${outlook_url} &>/dev/null &\"")
outlook_downloads=("https://upload.wikimedia.org/wikipedia/commons/d/df/Microsoft_Office_Outlook_%282018%E2%80%93present%29.svg;outlook_icon.svg")
outlook_readmelinedescription="Microsoft Outlook e-mail opening in Chrome"
outlook_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${outlook_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${outlook_url}
Icon=${BIN_FOLDER}/outlook/outlook_icon.svg
GenericName=Outlook
Keywords=outlook;
MimeType=
Name=Outlook
StartupNotify=true
StartupWMClass=Outlook
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
outlook_readmeline="| Outlook | ${outlook_readmelinedescription} | Command \`outlook\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

overleaf_installationtype="environmental"
overleaf_arguments=("overleaf")
overleaf_url="https://www.overleaf.com/"
overleaf_bashfunctions=("alias overleaf=\"nohup xdg-open ${overleaf_url} &>/dev/null &\"")
overleaf_downloads="https://images.ctfassets.net/nrgyaltdicpt/h9dpHuVys19B1sOAWvbP6/5f8d4c6d051f63e4ba450befd56f9189/ologo_square_colour_light_bg.svg;overleaf_icon.svg"
overleaf_readmelinedescription="Online LaTeX editor opening in Chrome"
overleaf_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${overleaf_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${overleaf_url}
Icon=${BIN_FOLDER}/overleaf/overleaf_icon.svg
GenericName=Overleaf
Keywords=overleaf;
MimeType=
Name=Overleaf
StartupNotify=true
StartupWMClass=Overleaf
#Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
overleaf_readmeline="| Overleaf | ${overleaf_readmelinedescription} | Command \`overleaf\`, desktop launcher and dashboard launcher ||   <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

pacman_installationtype="packagemanager"
pacman_arguments=("pacman")
pacman_launchernames=("pacman")
pacman_packagenames=("pacman")
pacman_readmeline="| Pac-man | Implementation of the classical arcade game | Command \`pacman\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li>x</li><li>- [ ] Debian</li></ul> |"

parallel_installationtype="packagemanager"
parallel_arguments=("parallel" "gnu_parallel")
parallel_packagenames=("parallel")
parallel_readmeline="| GNUparallel | Command-line driven utility for Linux and other Unix-like operating systems which allows the user to execute shell scripts or commands in parallel | Command \`parallel\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

pdfgrep_installationtype="packagemanager"
pdfgrep_arguments=("pdfgrep")
pdfgrep_packagenames=("pdfgrep")
pdfgrep_readmeline="| pdfgrep | CLI utility that makes it possible to search for text in a PDF file without opening the file | Command \`pdfgrep\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

pgadmin_installationtype="pythonvenv"
pgadmin_arguments=("pgadmin" "pgadmin4")
pgadmin_binariesinstalledpaths=("lib/python3.8/site-packages/pgadmin4/pgAdmin4.py;pgadmin")
pgadmin_confoverride_path="lib/python3.8/site-packages/pgadmin4/config_local.py"
pgadmin_confoverride_content=("
import os
DATA_DIR = os.path.realpath(os.path.expanduser(u'${BIN_FOLDER}/pgadmin'))
LOG_FILE = os.path.join(DATA_DIR, 'pgadmin4.log')
SQLITE_PATH = os.path.join(DATA_DIR, 'pgadmin4.db')
SESSION_DB_PATH = os.path.join(DATA_DIR, 'sessions')
STORAGE_DIR = os.path.join(DATA_DIR, 'storage')
SERVER_MODE = False
")
pgadmin_executionscript_path="pgadmin_exec.sh"
pgadmin_executionscript_content="
pgadmin &
sleep 2  # Wait two seconds, so pgadmin can have time to init
xdg-open http://127.0.0.1:5050/browser
"
pgadmin_filekeys=("confoverride" "executionscript")
pgadmin_readmelinedescription="PostgreSQL Tools"
pgadmin_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${pgadmin_readmelinedescription}
Encoding=UTF-8
GenericName=pgadmin4
Keywords=pgadmin
MimeType=
Name=pgAdmin 4
StartupNotify=true
StartupWMClass=pgadmin
Terminal=false
Type=Application
Version=1.0
Icon=${BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgadmin/static/img/logo-256.png
Exec=bash ${BIN_FOLDER}/pgadmin/pgadmin_exec.sh
")
pgadmin_manualcontentavailable="0;1;0"
pgadmin_pipinstallations=("pgadmin4")
pgadmin_packagedependencies=("libgmp3-dev" "libpq-dev" "libapache2-mod-wsgi-py3")
pgadmin_readmeline="| pgAdmin | ${pgadmin_readmelinedescription} | Command \`pgadmin4\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

php_installationtype="packagemanager"
php_arguments=("php")
php_packagenames=("php" "libapache2-mod-php")
php_readmeline="| php | Programming language | Command \`php\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

pluma_installationtype="packagemanager"
pluma_arguments=("pluma")
pluma_bashfunctions=("
pluma()
{
  if [ \$# -eq 0 ]; then
    nohup pluma &>/dev/null &
  else
    while [ -n \"\$1\" ]; do
      nohup pluma \"\$1\" &>/dev/null &
      shift
    done
  fi
}
")
pluma_launchernames=("pluma")
pluma_packagenames=("pluma")
pluma_readmeline="| pluma | Fork of gedit 2.0 that supports many plugins and new features | Command \`pluma\`, desktop launcjer and dashboard launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

p_installationtype="environmental"
p_arguments=("p" "port" "port_function")
p_bashfunctions=("
p()
{
  if [ -n \"\$1\" ]; then
    sudo lsof -i:\"\$1\" | tail -n+2 | tr -s \" \"  | cut -d \" \" -f-2 | sort | uniq | column -ts \" \"
  else
    sudo lsof -Pan -i tcp -i udp
  fi
}
")
port_readmeline="| Function \`port\` | Check processes names and PID's from given port | Command \`port\` ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"


postman_installationtype="userinherit"
postman_arguments=("postman")
postman_binariesinstalledpaths=("Postman;postman")
postman_compressedfiletype="z"
postman_compressedfileurl="https://dl.pstmn.io/download/latest/linux64"
postman_readmelinedescription="Application to maintain and organize collections of REST API calls"
postman_launchercontents=("
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=postman
Comment=${postman_readmelinedescription}
Icon=${BIN_FOLDER}/postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
")
postman_readmeline="| Postman | ${postman_readmelinedescription} | Command \`postman\`, desktop launcher and dashboard launcher  ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

presentation_installationtype="environmental"
presentation_arguments=("presentation" "google_presentation")
presentation_url="https://docs.google.com/presentation/"
presentation_bashfunctions=("alias presentation=\"nohup xdg-open ${presentation_url} &>/dev/null &\"")
presentation_downloads=("https://upload.wikimedia.org/wikipedia/commons/1/16/Google_Slides_2020_Logo.svg;presentation_icon.svg")
presentation_readmelinedescription="Google Presentation opening in Chrome"
presentation_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=D${presentation_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${presentation_url}
Icon=${BIN_FOLDER}/presentation/presentation_icon.svg
GenericName=Document
Keywords=presentations;
MimeType=
Name=Google Presentation
StartupNotify=true
StartupWMClass=Google Presentation
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
presentation_readmeline="| Presentation | ${presentation_readmelinedescription} | Command \`presentation\`, desktop launcher and dashboard launcher||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

prompt_installationtype="environmental"
prompt_arguments=("prompt")
prompt_bashfunctions=(
"
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
  if [ -n \"\${GIT_PROMPT_LAST_COMMAND_STATE}\" ]; then
    if [ \${GIT_PROMPT_LAST_COMMAND_STATE} -gt 0 ]; then  # Red color if error
      color_dollar=\"\\[\\e[1;31m\\]\"
    else  # light green color if last command is ok
      color_dollar=\"\\[\\e[1;32m\\]\"
    fi
  else
    color_dollar=\"\\[\\e[2;32m\\]\"
  fi

    PS1=\"\\[\\e[1;33m\\]\$(date \"+%a %d %b %Y\") \\[\\e[0;35m\\]\\u\\[\\e[0;0m\\]@\\[\\e[0;36m\\]\\H \\[\\e[0;33m\\]\\w
\\[\\e[0;37m\\]\\t \${color_dollar}\\$ \\[\\e[0;0m\\]\"
else
    PS1='\${debian_chroot:+(\$debian_chroot)}\u@\h:\w\\$ '
fi
unset color_prompt force_color_prompt color_dollar

# If this is an xterm set the title to user@host:dir
case \"\$TERM\" in
xterm*|rxvt*)
    :
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

"
# Save and reload from history before prompt appears to be sure the prompt is being charged correctly because it conflicts with gitprompt.
if [ -z \"\$(echo \"\${PROMPT_COMMAND}\" | grep -Fo \" [ ! -d .git ] && source \"${FUNCTIONS_FOLDER}/prompt.sh\"\")\" ]; then
  # Check if there is something inside PROMPT_COMMAND, so we put semicolon to separate or not
  if [ -z \"\${PROMPT_COMMAND}\" ]; then
    export PROMPT_COMMAND=\" [ ! -d .git ] && source \"${FUNCTIONS_FOLDER}/prompt.sh\"\"
  else
    export PROMPT_COMMAND=\"\${PROMPT_COMMAND}; [ ! -d .git ] && source \"${FUNCTIONS_FOLDER}/prompt.sh\"\"
  fi
fi
")

prompt_readmeline="| prompt | Installs a new colourful prompt on terminal window including and upgrading the default ones in Ubuntu | Adds a personalized prompt that shows the date, return code of last executed program, user, group and working directory. It also changes the prompt colour of introduced text to green. It changes the terminal windows title, adds colourful aliases and ensures completion || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

psql_installationtype="packagemanager"
psql_arguments=("psql" "postgresql")
psql_packagedependencies=("libc6-i386" "lib32stdc++6" "libc6=2.31-0ubuntu9.2")
psql_packagenames=("postgresql-client-12" "postgresql-12" "libpq-dev" "postgresql-server-dev-12")
psql_readmeline="| PostGreSQL | Installs \`psql\`|  Command \`psql\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

pull_installationtype="environmental"
pull_arguments=("pull")
pull_bashfunctions=("
pull()
{
  if [ -z \"\$1\" ]; then
	  git pull
	else
	  git pull origin \"\$1\"
	fi
}
")
pull_readmeline="| \`pull\` | Alias for \`git pull\`|  Command \`pull\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

push_installationtype="environmental"
push_arguments=("push")
push_bashfunctions=("
push()
{
  if [ -z \"\$1\" ]; then
	  git push
	else
	  git push origin \"\$1\"
	fi
}
")
push_readmeline="| \`push\` | Alias for \`git push\`|  Command \`push\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

pycharm_installationtype="userinherit"
pycharm_arguments=("pycharm" "pycharm_community")
pycharm_associatedfiletypes=("text/sh" "text/x-python" "text/x-python3")
pycharm_bashfunctions=("alias pycharm=\"pycharm . &>/dev/null &\"")
pycharm_binariesinstalledpaths=("bin/pycharm.sh;pycharm")
pycharm_compressedfiletype="z"
pycharm_compressedfileurl="https://download.jetbrains.com/python/pycharm-community-2021.1.1.tar.gz"
pycharm_keybindings=("pycharm;<Primary><Alt><Super>p;Pycharm")
pycharm_readmelinedescription="Integrated development environment used in computer programming"
pycharm_launchercontents=("
[Desktop Entry]
Actions=NewWindow;
Categories=programming;dev;
Comment=${pycharm_readmelinedescription}
Encoding=UTF-8
Exec=pycharm %F
GenericName=Pycharm
Icon=${BIN_FOLDER}/pycharm/bin/pycharm.png
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
Icon=${BIN_FOLDER}/pycharm/bin/pycharm.png
")
pycharm_readmeline="| Pycharm Community | ${pycharm_readmelinedescription} | Command \`pycharm\`, silent alias for \`pycharm-pro\`, desktop launcher, dashboard launcher, associated to the mime type of \`.py\` files  || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"


pycharmpro_installationtype="userinherit"
pycharmpro_arguments=("pycharm_pro")
pycharmpro_associatedfiletypes=("text/sh" "text/x-python" "text/x-python3")
pycharmpro_bashfunctions=("alias pycharmpro=\"pycharmpro . &>/dev/null &\"")
pycharmpro_binariesinstalledpaths=("bin/pycharm.sh;pycharmpro")
pycharmpro_compressedfiletype="z"
pycharmpro_compressedfileurl="https://download.jetbrains.com/python/pycharm-professional-2020.3.2.tar.gz"
pycharmpro_readmelinedescription="Integrated development environment used in computer programming"
pycharmpro_launchercontents=("
[Desktop Entry]
Categories=programming;dev;
Comment=${pycharmpro_readmelinedescription}
Encoding=UTF-8
Exec=pycharmpro %F
GenericName=Pycharm Pro
Icon=${BIN_FOLDER}/pycharmpro/bin/pycharm.png
Keywords=dev;programming;python;
MimeType=
Name=PyCharm Professional
StartupNotify=true
StartupWMClass=jetbrains-pycharm
Terminal=false
TryExec=pycharmpro
Type=Application
Version=1.0
")
pycharmpro_readmeline="| Pycharm Pro | ${pycharmpro_readmelinedescription} | Command \`pycharm-pro\`, silent alias for \`pycharm-pro\`, desktop launcher, dashboard launcher, associated to the mime type of \`.py\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

pypy3_installationtype="userinherit"
pypy3_arguments=("pypy3" "pypy")
pypy3_binariesinstalledpaths=("bin/pypy3;pypy3" "bin/pip3.6;pypy3-pip")
pypy3_compressedfiletype="j"
pypy3_compressedfileurl="https://downloads.python.org/pypy/pypy3.6-v7.3.1-linux64.tar.bz2"
pypy3_manualcontentavailable="0;1;0"
pypy3_readmeline="| pypy3 | Faster interpreter for the Python3 programming language | Commands \`pypy3\` and \`pypy3-pip\` in the PATH || <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

pypy3_dependencies_installationtype="packagemanager"
pypy3_dependencies_arguments=("pypy3_dependencies" "pypy_dependencies")
pypy3_dependencies_packagenames=("pkg-config" "libfreetype6-dev" "libpng-dev" "libffi-dev")
pypy3_dependencies_readmeline="| pypy3_dependencies | Dependencies to run pypy3 | Libraries \`pkg-config\`, \`libfreetype6-dev\`, \`libpng-dev\` and \`libffi-dev\` used when deploying \`pypy\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

python3_installationtype="packagemanager"
python3_arguments=("python_3" "python" "v")
python3_bashfunctions=("
# Create and source a venv with the given name passed as parameter.
# If already exists, only sources activate
# If already activated, do deactivate
v()
{
  if [ \$# -eq 0 ]; then
    if [ -n \"\${VIRTUAL_ENV}\" ]; then
      deactivate
    else
      if [ -f activate ]; then
        source activate
        return
      elif [ -f bin/activate ]; then
        source bin/activate
        return
      else
        for i in \$(ls); do
          if [ -d \"\${i}\" ]; then
            if [ -f \"\${i}/bin/activate\" ]; then
              source \"\${i}/bin/activate\"
              return
            fi
          fi
        done
      fi
      python3 -m venv venv
    fi
  else
    if [ -n \"\${VIRTUAL_ENV}\" ]; then
      deactivate
    else
      python3 -m venv \"\$1\"
    fi
  fi
}
")
python3_packagenames=("python-dev" "python3-dev" "python3-pip" "python3-venv" "python3-wheel" "python3.8-venv")  # "python3-pyqt5" "python3-pyqt4" "python-qt4"
python3_readmeline="| Python3 | Interpreted, high-level and general-purpose programming language | Commands \`python\`, \`python3\`, \`pip3\` and Function \`v\` is for activate/deactivate python3 virtual environments (venv) can be used as default \`v\` as a command creates the /venv/ environment we can activate/deactivate new or existing virtual environments, command \`v namevenv\` creates /namevenv/ we can activate the virtual environment again using \`v namenv\` or deactivate same again, using \`v namenv\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

q_installationtype="environmental"
q_arguments=("q")
q_bashfunctions=("alias q=\"exit\"")
q_readmeline="| Function \`q\` | Programming language | Commands \`R\`, Dashboard Launcher, Desktop Launcher|| <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |  "

R_installationtype="packagemanager"
R_arguments=("R" "r_base")
R_jupyter_lab_function=("
install.packages('IRkernel')
install.packages(c('rzmq', 'repr', 'uuid','IRdisplay'),
                  repos = c('http://irkernel.github.io/',
                  getOption('repos')),
                  type = 'source')
IRkernel::installspec()
")
R_launchernames=("R")
R_packagenames=("r-base")
R_packagedependencies=("libzmq3-dev" "python3-zmq")
R_readmeline="| R | Programming language | Commands \`R\`, Dashboard Launcher, Desktop Launcher|| <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |  "

reddit_installationtype="environmental"
reddit_arguments=("reddit")
reddit_url="https://www.reddit.com/"
reddit_bashfunctions=("alias reddit=\"nohup xdg-open ${reddit_url} &>/dev/null &\"")
reddit_downloads=("https://www.svgrepo.com/download/14413/reddit.svg;reddit_icon.svg")
reddit_readmelinedescription="Opens Reddit in Chrome"
reddit_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${reddit_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${reddit_url}
Icon=${BIN_FOLDER}/reddit/reddit_icon.svg
GenericName=reddit
Keywords=reddit
MimeType=
Name=Reddit
StartupNotify=true
StartupWMClass=Reddit
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
reddit_readmeline="| Reddit | ${reddit_readmelinedescription} | Commands \`reddit\`|| <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

remmina_installationtype="packagemanager"
remmina_arguments=("remmina")
remmina_packagenames=("remmina")
remmina_launchernames=("org.remmina.Remmina")
remmina_readmeline="| Remmina | Remote Desktop Contol | Commands \`remmina\`, Desktop launcher and Icon || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |  "

rosegarden_installationtype="packagemanager"
rosegarden_arguments=("rosegarden")
rosegarden_bashfunctions=("alias rosegarden=\"nohup rosegarden &>/dev/null &\"")
rosegarden_packagenames=("rosegarden")
rosegarden_launchernames=("com.rosegardenmusic.rosegarden")
rosegarden_readmeline="| Rosegarden | Software for music production | Commands \`rosegarden\`, Desktop launcher and Icon || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |  "

rstudio_installationtype="userinherit"
rstudio_arguments=("r_studio")
rstudio_associatedfiletypes=("text/plain")
rstudio_bashfunctions=("alias rstudio=\"nohup rstudio &>/dev/null &\"")
rstudio_binariesinstalledpaths=("bin/rstudio;rstudio")
rstudio_compressedfiletype="z"
rstudio_compressedfileurl="https://download1.rstudio.org/desktop/debian9/x86_64/rstudio-1.4.1717-amd64-debian.tar.gz"
rstudio_readmelinedescription="Default application for .R files "
rstudio_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${rstudio_readmelinedescription}
Encoding=UTF-8
Exec=rstudio
GenericName=RStudio
Icon=${BIN_FOLDER}/rstudio/www/images/favicon.ico
Keywords=rstudio
MimeType=text/plain;
Name=RStudio
StartupNotify=true
StartupWMClass=RStudio
Terminal=false
TryExec=rstudio
Type=Application
Version=1.0
")
#rstudio_packagedependencies=("libssl-dev")
rstudio_readmeline="| RStudio | ${rstudio_readmelinedescription} | Commands \`rstudio\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |  "

rsync_installationtype="packagemanager"
rsync_arguments=("rsync" "grsync")
rsync_packagedependencies=("libcanberra-gtk-module" "libcanberra-gtk3-module" "libcanberra-gtk-module:i386")
rsync_packagenames=("rsync" "grsync")
rsync_launchernames=("grsync")
rsync_bashfunctions=("alias rs=\"rsync -av --progress\"")
rsync_readmeline="| Grsync | Software for file/folders synchronization | Commands \`grsync\`, desktop launcher and \`rsync\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

rustc_installationtype="packagemanager"
rustc_arguments=("rustc")
rustc_packagenames=("rustc")
rustc_packagedependencies=("cmake" "build-essential")
rustc_readmeline="| Rust | Programming Language | Installs \`rustc\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
# rustc_url=("https://sh.rustup.rs")

s_installationtype="environmental"
s_arguments=("s")
s_bashfunctions=("
s()
{
  \"\$@\" &>/dev/null &
}
")
s_readmeline="| Function \`s\` | Function to execute any program silently and in the background | Function \`s \"command\"\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

scala_installationtype="packagemanager"
scala_arguments=("scala")
scala_packagenames=("scala")
scala_readmeline="| Scala | Programming language | Command \`scala\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

scilab_installationtype="userinherit"
scilab_arguments=("scilab")
scilab_bashfunctions=("alias scilab=\"nohup scilab &>/dev/null &\"" "alias scinotes=\"nohup scinotes &>/dev/null &\"")
scilab_binariesinstalledpaths=("bin/scilab;scilab" "bin/scilab-cli;scilab-cli" "bin/scinotes;scinotes")
scilab_packagedependencies=("openjdk-8-jdk-headless" "libtinfo5")
scilab_compressedfiletype="z"
scilab_compressedfileurl="https://www.scilab.org/download/6.1.0/scilab-6.1.0.bin.linux-x86_64.tar.gz"
scilab_packagenames=("scilab")
scilab_launchercontents=("
[Desktop Entry]
Comment=Scientific software package for numerical computations
Comment[fr]=Logiciel scientifique de calcul numérique
Comment[de]=eine Wissenschaftssoftware für numerische Berechnungen
Comment[ru]=Научная программа для численных расчётов
Exec=bash ${BIN_FOLDER}/scilab/bin/scilab
GenericName=Scientific Software Package
GenericName[fr]=Logiciel de calcul numérique
GenericName[de]=Wissenschaftssoftware
GenericName[ru]=Научный программный комплекс
Icon=${BIN_FOLDER}/scilab/share/icons/hicolor/256x256/apps/scilab.png
MimeType=application/x-scilab-sci;application/x-scilab-sce;application/x-scilab-tst;application/x-scilab-dem;application/x-scilab-sod;application/x-scilab-xcos;application/x-scilab-zcos;application/x-scilab-bin;application/x-scilab-cosf;application/x-scilab-cos;
Name=Scilab
StartupNotify=false
Terminal=false
Type=Application
Categories=Science;Math;
Keywords=Science;Math;Numerical;Simulation
")
scilab_readmeline="| Scilab | Programming language | Command \`scala\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

screenshots_installationtype="environmental"
screenshots_arguments=("screenshots")
screenshots_filekeys=("screenshotwindow" "screenshotarea" "screenshotfull")
screenshots_keybindings=("scr-area;<Primary><Alt><Super>a;Screenshot Area" "scr-full;<Primary><Alt><Super>f;Screenshot Full" "scr-window;<Primary><Alt><Super>w;Screenshot Window")
screenshots_screenshotwindow_path="screenshot_window.sh"
screenshots_screenshotwindow_content="
mkdir -p \"${XDG_PICTURES_DIR}/screenshots\"
declare -r screenshotname=\"Screenshot-\$(date +%Y-%m-%d-%H:%M:%S).png\"
gnome-screenshot -w -f \"${XDG_PICTURES_DIR}/screenshots/\$screenshotname\" && xclip -in -selection clipboard -target image/png \"${XDG_PICTURES_DIR}/screenshots/\$screenshotname\" && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga
"
screenshots_screenshotarea_path="screenshot_area.sh"
screenshots_screenshotarea_content="
mkdir -p \"${XDG_PICTURES_DIR}/screenshots\"
declare -r screenshotname=\"Screenshot-\$(date +%Y-%m-%d-%H:%M:%S).png\"
gnome-screenshot -a -f \"${XDG_PICTURES_DIR}/screenshots/\$screenshotname\" && xclip -in -selection clipboard -target image/png \"${XDG_PICTURES_DIR}/screenshots/\$screenshotname\" && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga
"
screenshots_screenshotfull_path="screenshot_full.sh"
screenshots_screenshotfull_content="
mkdir -p \"${XDG_PICTURES_DIR}/screenshots\"
declare -r screenshotname=\"Screenshot-\$(date +%Y-%m-%d-%H:%M:%S).png\"
gnome-screenshot -f \"${XDG_PICTURES_DIR}/screenshots/\$screenshotname\" && xclip -in -selection clipboard -target image/png \"${XDG_PICTURES_DIR}/screenshots/\$screenshotname\" && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga
"
screenshots_binariesinstalledpaths=("screenshot_area.sh;scr-area" "screenshot_window.sh;scr-window" "screenshot_full.sh;scr-full")
screenshots_packagedependencies=("gnome-screenshot" "xclip")
screenshots_readmeline="| Screenshots | Takes a screenshot and saves it to custom ~/Images/screenshots folder and save it to the clipboard for pasting | Commands \`screenshot-full\` \`screenshot-window\` \`screenshot-area\`||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

shortcuts_installationtype="environmental"
shortcuts_arguments=("shortcuts")
shortcuts_bashfunctions=("
ALLBIN=\"${ALL_USERS_PATH_POINTED_FOLDER}\"
AUTOSTART=\"${AUTOSTART_FOLDER}\"
BIN=\"${BIN_FOLDER}\"
CUSTOMIZER=\"${DIR}\"
DESK=\"${XDG_DESKTOP_DIR}\"
DOCUMENTS=\"${XDG_DOCUMENTS_DIR}\"
DOWNLOAD=\"${XDG_DOWNLOAD_DIR}\"
FONTS=\"${FONTS_FOLDER}\"
FUNCTIONSD=\"${FUNCTIONS_FOLDER}\"
FUNCTIONS=\"${FUNCTIONS_PATH}\"
GIT=\"${XDG_DESKTOP_DIR}/git\"
LAUNCHERS=\"${ALL_USERS_LAUNCHERS_DIR}\"
LOCALBIN=\"${PATH_POINTED_FOLDER}\"
MUSIC=\"${XDG_MUSIC_DIR}\"
PERSONAL_LAUNCHERS=\"${PERSONAL_LAUNCHERS_DIR}\"
PICTURES=\"${XDG_PICTURES_DIR}\"
TEMPLATES=\"${XDG_TEMPLATES_DIR}\"
TRASH=\"${HOME_FOLDER}/.local/share/Trash/\"
VIDEOS=\"${XDG_VIDEOS_DIR}\"
INITIALIZATIONSD=\"${INITIALIZATIONS_FOLDER}\"
if [ ! -d \$GIT ]; then
  mkdir -p \$GIT
fi
")
shortcuts_readmeline="| shortcuts | Installs custom key commands | variables... (\$DESK...) || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

shotcut_installationtype="packagemanager"
shotcut_arguments=("shotcut")
shotcut_readmelinedescription="Cross-platform video editing"
shotcut_launchercontents=("
[Desktop Entry]
Categories=video;
Comment=${shotcut_readmelinedescription}
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
Version=1.0")
shotcut_packagenames=("shotcut")
shotcut_readmeline="| ShotCut | ${shotcut_readmelinedescription} | Command \`shotcut\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

shotwell_installationtype="packagemanager"
shotwell_arguments=("shotwell")
shotwell_launchernames=("shotwell")
shotwell_packagenames=("shotwell")
shotwell_readmeline="| Shotwell | Cross-platform video editing | Command \`shotwell\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

skype_installationtype="packageinstall"
skype_arguments=("skype")
skype_packagenames=("skype")
skype_launchernames=("skypeforlinux")
skype_packageurls=("https://go.skype.com/skypeforlinux-64.deb")
skype_readmeline="| Skype | Call & conversation tool service | Icon Launcher... ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

slack_installationtype="packageinstall"
slack_arguments=("slack")
slack_packagenames=("slack-desktop")
slack_packageurls=("https://downloads.slack-edge.com/linux_releases/slack-desktop-4.11.1-amd64.deb")
slack_launchernames=("slack")
slack_readmeline="| Slack | Platform to coordinate your work with a team | Icon Launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

sonic_pi_installationtype="packagemanager"
sonic_pi_arguments=("sonic_pi")
sonic_pi_launchernames=("sonic-pi")
sonic_pi_packagenames=("sonic-pi")
sonic_pi_readmeline="| Sonic Pi | programming language that ouputs sounds as compilation product | Command \`sonic-pi\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

soundcloud_installationtype="environmental"
soundcloud_arguments=("soundcloud")
soundcloud_url="https://www.soundcloud.com/"
soundcloud_bashfunctions=("alias soundcloud=\"nohup xdg-open ${soundcloud_url} &>/dev/null &\"")
soundcloud_downloads=("https://upload.wikimedia.org/wikipedia/commons/a/a2/Antu_soundcloud.svg;soundcloud_icon.svg")
soundcloud_readmelinedescription="SoundCloud opening in Chrome"
soundcloud_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${soundcloud_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${soundcloud_url}
Icon=${BIN_FOLDER}/soundcloud/soundcloud_icon.svg
GenericName=Soundcloud
Keywords=sound;
MimeType=
Name=SoundCloud
StartupNotify=true
StartupWMClass=Soundcloud
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
soundcloud_readmeline="| Soundcloud | ${soundcloud_readmelinedescription} | Command \`soundcloud\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

spotify_installationtype="packageinstall"
spotify_arguments=("spotify")
spotify_bashfunctions=("alias spotify=\"spotify &>/dev/null &\"")
spotify_launchernames=("spotify")
spotify_packageurls=("http://repository.spotify.com/pool/non-free/s/spotify-client/spotify-client_1.1.56.595.g2d2da0de_amd64.deb")
spotify_packagenames=("spotify-desktop")
spotify_readmeline="| Spotify | Music streaming service | Command \`spotify\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

spreadsheets_installationtype="environmental"
spreadsheets_arguments=("spreadsheets" "google_spreadsheets")
spreadsheets_url="https://docs.google.com/spreadsheets/"
spreadsheets_bashfunctions=("alias spreadsheets=\"nohup xdg-open ${spreadsheets_url} &>/dev/null &\"")
spreadsheets_downloads=("https://upload.wikimedia.org/wikipedia/commons/a/ae/Google_Sheets_2020_Logo.svg;spreadsheets_icon.svg")
spreadsheets_readmelinedescription="Google Spreadsheets opening in Chrome"
spreadsheets_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${spreadsheets_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${spreadsheets_url}
Icon=${BIN_FOLDER}/spreadsheets/spreadsheets_icon.svg
GenericName=Spreadsheets
Keywords=spreadsheets;
MimeType=
Name=Google Spreadsheets
StartupNotify=true
StartupWMClass=Google Spreadsheets
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
spreadsheets_readmeline="| Spreadsheets | ${spreadsheets_readmelinedescription} | Command \`spreadsheets\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

ssh_installationtype="packagemanager"
ssh_arguments=("ssh")
ssh_packagenames=("ssh")
ssh_readmeline="| ssh | SSH client | Using SSH connections ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

status_installationtype="environmental"
status_arguments=("status")
status_bashfunctions=("alias status=\"git status\"")
status_readmeline="| status | \`git status\` | Command \`status\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

steam_installationtype="packageinstall"
steam_arguments=("steam")
steam_launchernames=("steam")
steam_packagenames=("steam-launcher")
steam_packageurls=("https://steamcdn-a.akamaihd.net/client/installer/steam.deb")
steam_readmeline="| Steam | Video game digital distribution service | Command \`steam\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

studio_installationtype="userinherit"
studio_arguments=("studio" "android_studio")
studio_bashfunctions=("alias studio=\"studio . &>/dev/null &\"")
studio_binariesinstalledpaths=("bin/studio.sh;studio")
studio_compressedfiletype="z"
studio_compressedfileurl="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.1.2.0/android-studio-ide-201.7042882-linux.tar.gz"
studio_readmelinedescription="Development environment for Google's Android operating system"
studio_launchercontents=("
[Desktop Entry]
Categories=Development;IDE;
Comment=${studio_readmelinedescription}
Encoding=UTF-8
Exec=studio %F
GenericName=studio
Icon=${BIN_FOLDER}/studio/bin/studio.svg
Keywords=IDE;programming;android;studio;dev;
MimeType=
Name=Android Studio
StartupNotify=true
StartupWMClass=jetbrains-android-studio
Terminal=false
TryExec=studio
Type=Application
Version=1.0
")
studio_readmeline="| Android Studio | ${studio_readmelinedescription} | Command \`studio\`, alias \`studio\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

sublime_keybindings=("sublime;<Primary><Alt><Super>s;Sublime Text")
sublime_installationtype="userinherit"
sublime_arguments=("sublime" "sublime_text" "subl")
sublime_associatedfiletypes=("text/x-sh" "text/x-c++hdr" "text/x-c++src" "text/x-chdr" "text/x-csrc" "text/x-python" "text/x-python3")
sublime_bashfunctions=("alias sublime=\"sublime . &>/dev/null &\"")
sublime_binariesinstalledpaths=("sublime_text;sublime")
sublime_compressedfiletype="J"
sublime_compressedfileurl="https://download.sublimetext.com/sublime_text_build_4113_x64.tar.xz"
sublime_readmelinedescription="Source code editor with an emphasis on source code editing"
sublime_launchercontents=("
[Desktop Entry]
Categories=;
Comment=${sublime_readmelinedescription}
Encoding=UTF-8
Exec=sublime %F
GenericName=Text Editor, programming...
Icon=${BIN_FOLDER}/sublime/Icon/256x256/sublime-text.png
Keywords=subl;sublime;
MimeType=
Name=Sublime Text
StartupNotify=true
StartupWMClass=Sublime
Terminal=false
TryExec=sublime
Type=Application
Version=1.0
")
sublime_readmeline="| Sublime | ${sublime_readmelinedescription} | Command \`sublime\`, silent alias for \`sublime\`, desktop launcher, dashboard launcher, associated with the mime type of \`.c\`, \`.h\`, \`.cpp\`, \`.hpp\`, \`.sh\` and \`.py\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

synaptic_installationtype="packagemanager"
synaptic_arguments=("synaptic")
synaptic_packagenames=("synaptic")
synaptic_launchernames=("synaptic")
synaptic_readmelinedescription="Graphical installation manager to install, remove and upgrade software packages"
synaptic_readmeline="| Synaptic | ${synaptic_readmelinedescription} | Command \`synaptic\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "
synaptic_launchercontents=("
[Desktop Entry]
Name=Synaptic Package Manager
GenericName=Package Manager
Comment=${synaptic_readmelinedescription}
Exec=synaptic
Icon=synaptic
Terminal=false
Type=Application
Categories=PackageManager;GTK;System;Settings;
X-Ubuntu-Gettext-Domain=synaptic
StartupNotify=true
StartupWMClass=synaptic
")

sysmontask_installationtype="repositoryclone"
sysmontask_arguments=("sysmontask")
sysmontask_flagsoverride="0;;;;;"  # To install the cloned software it has to be run as root
sysmontask_bashfunctions=("alias sysmontask=\"nohup sysmontask &>/dev/null &\"")
sysmontask_launchernames=("SysMonTask")
sysmontask_manualcontentavailable="0;1;0"
sysmontask_readmeline="| Sysmontask | Control panel for linux | Command \`sysmontask\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "
sysmontask_repositoryurl="https://github.com/KrispyCamel4u/SysMonTask.git"

system_fonts_installationtype="environmental"
system_fonts_arguments=("system_fonts")
system_fonts_manualcontentavailable="0;1;0"
system_fonts_readmeline="| Change default fonts | Sets pre-defined fonts to desktop environment. | A new set of fonts is updated in the system's screen. || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

teamviewer_installationtype="packageinstall"
teamviewer_arguments=("teamviewer")
teamviewer_launchernames=("com.teamviewer.TeamViewer")
teamviewer_packageurls=("https://download.teamviewer.com/download/linux/teamviewer_amd64.deb")
teamviewer_readmeline="| Team Viewer | Video remote pc control | Command \`teamviewer\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

teams_installationtype="packageinstall"
teams_arguments=("teams" "microsoftteams")
teams_launchernames=("teams")
teams_packagenames=("teams")
teams_packageurls=("https://go.microsoft.com/fwlink/p/?LinkID=2112886&clcid=0x40a&culture=es-es&country=ES")
teams_readmeline="| Microsoft Teams | Video Conference, calls and meetings | Command \`teams\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

telegram_installationtype="userinherit"
telegram_arguments=("telegram")
telegram_binariesinstalledpaths=("Telegram;telegram")
telegram_compressedfiletype="J"
telegram_compressedfileurl="https://telegram.org/dl/desktop/linux"
telegram_downloads=("https://telegram.org/img/t_logo.svg?1;telegram_icon.svg")
telegram_readmelinedescription="Cloud-based instant messaging software and application service"
telegram_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${telegram_readmelinedescription}
Encoding=UTF-8
Exec=telegram -- %u
GenericName=Telegram
Icon=${BIN_FOLDER}/telegram/telegram_icon.svg
Keywords=telegram;
MimeType=x-scheme-handler/tg;
Name=Telegram
StartupNotify=true
StartupWMClass=Telegram
Terminal=false
TryExec=telegram
Type=Application
Version=1.0
")
telegram_readmeline="| Telegram | ${telegram_readmelinedescription} | Command \`telegram\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

templates_installationtype="environmental"
templates_arguments=("templates")
templates_filekeys=("c" "headers" "makefile" "python" "bash" "latex" "empty")
templates_c_path="${XDG_TEMPLATES_DIR}/c_script.c"
templates_c_content="
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


#include \"c_script_header.h\"


int main(int nargs, char* args[])
{
  printf(\"Hello World\");
}
"
templates_headers_path="${XDG_TEMPLATES_DIR}/c_script_header.h"
templates_headers_content="
// Includes
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
"
templates_makefile_path="${XDG_TEMPLATES_DIR}/makefile"
templates_makefile_content="
CC = gcc
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
templates_python_path="${XDG_TEMPLATES_DIR}/python3_script.py"
templates_python_content="
#!/usr/bin/env python3
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
templates_bash_path="${XDG_TEMPLATES_DIR}/shell_script.sh"
templates_bash_content="
#!/usr/bin/env bash
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
templates_latex_path="${XDG_TEMPLATES_DIR}/latex_document.tex"
templates_latex_content="
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
templates_empty_path="${XDG_TEMPLATES_DIR}/empty_text_file.txt"
templates_empty_content=""
templates_readmeline="| Templates | Different collection of templates for starting code projects: Python3 script (\`.py\`), Bash script (\`.sh\`), LaTeX document (\`.tex\`), C script (\`.c\`), C header script (\`.h\`), makefile example (\`makefile\`) and empty text file (\`.txt\`) | In the file explorer, right click on any folder to see the contextual menu of \"create document\", where all the templates are located || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

terminal_background_installationtype="environmental"
terminal_background_arguments=("terminal_background")
terminal_background_bashinitializations=("
profile_uuid=\"\$(gsettings get org.gnome.Terminal.ProfilesList default | cut -d \"'\" -f2)\"
if [ -n \"\${profile_uuid}\" ]; then
  # make sure the profile is set to not use theme colors
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/\${profile_uuid}/ use-theme-colors false # --> Don't use system color theme

  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:\${profile_uuid}/ use-transparent-background true
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:\${profile_uuid}/ background-transparency-percent \"10\"

  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:\${profile_uuid}/ bold-color \"#6E46A4\"
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:\${profile_uuid}/ background-color \"#282A36\"
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:\${profile_uuid}/ foreground-color \"#F8F8F2\"

  # Cursor like in a text editor
  gsettings set org.gnome.Terminal.Legacy.Profile:/:\"\${profile_uuid}\"/ cursor-shape 'ibeam'

  unset profile_uuid
else
  echo \"ERROR, non terminal default profile list found\"
fi
")
terminal_background_readmeline="| Terminal background | Change background of the terminal to black | Every time you open a terminal || <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

terminator_installationtype="packagemanager"
terminator_arguments=("terminator")
terminator_launchernames=("terminator")
terminator_packagenames=("terminator")
terminator_readmeline="| Terminator | Terminal emulator for Linux programmed in Python | Command \`terminator\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

thunderbird_installationtype="packagemanager"
thunderbird_arguments=("thunderbird")
thunderbird_launchernames=("thunderbird")
thunderbird_packagenames=("thunderbird")
thunderbird_readmeline="| Thunderbird | Email, personal information manager, news, RSS and chat client | Command \`thunderbird\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

tilix_installationtype="packagemanager"
tilix_arguments=("tilix")
tilix_launchernames=("com.gexperts.Tilix")
tilix_packagenames=("tilix")
tilix_readmeline="| Tilix | Advanced GTK3 tiling terminal emulator | Command \`tilix\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

tmux_installationtype="packagemanager"
tmux_arguments=("tmux")
tmux_readmelinedescription="Terminal multiplexer for Unix-like operating systems"
tmux_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${tmux_readmelinedescription}
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
Version=1.0")
tmux_packagenames=("tmux")
tmux_readmeline="| Tmux | ${tmux_readmelinedescription} | Command \`tmux\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

tomcat_installationtype="userinherit"
tomcat_arguments=("tomcat" "apache_tomcat" "tomcat_server")
tomcat_compressedfiletype="z"
tomcat_compressedfileurl="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.43/bin/apache-tomcat-9.0.43.tar.gz"
tomcat_readmeline="| Apache Tomcat 9.0.43 | Open-source server to run web apps written in Jakarta Server Pages | Tomcat available in \${USER_BIN_FOLDER} to deploy web apps || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li>|"

tor_installationtype="packagemanager"
tor_arguments=("tor" "tor_browser")
tor_launchernames=("torbrowser")
tor_packagenames=("torbrowser-launcher")
tor_readmeline="| Tor browser | Software for enabling anonymous communication by directing Internet traffic. | Command \`tor\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

translator_installationtype="environmental"
translator_arguments=("translator")
translator_url="https://translate.google.com/"
translator_bashfunctions=("alias translator=\"nohup xdg-open ${translator_url} &>/dev/null &\"")
translator_downloads=("https://upload.wikimedia.org/wikipedia/commons/d/db/Google_Translate_Icon.png;translator_icon.png")
translator_readmelinedescription="Google Translate opening in Chrome"
translator_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${translator_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${translator_url}
Icon=${BIN_FOLDER}/translator/translator_icon.png
GenericName=Google Translator
Keywords=google;
MimeType=
Name=Google Translate
StartupNotify=true
StartupWMClass=Google Translator
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
translator_readmeline="| Translator | ${google_readmelinedescription} | Command \`translator\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

transmission_gtk_installationtype="packagemanager"
transmission_gtk_arguments=("transmission_gtk" "transmission")
transmission_gtk_launchernames=("transmission-gtk")
transmission_gtk_packagenames=("transmission")
transmission_gtk_readmeline="| Transmission | A set of lightweight Torrent client (in GUI, CLI and daemon form) | Executable \`transmission\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

trello_installationtype="environmental"
trello_arguments=("trello")
trello_url="https://trello.com"
trello_bashfunctions=("alias trello=\"nohup xdg-open ${trello_url} &>/dev/null &\"")
trello_downloads=("https://en.wikipedia.org/wiki/File:Antu_trello.svg;trello_icon.svg")
trello_readmelinedescription="Trello web opens in Chrome"
trello_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${trello_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${trello_url}
Icon=${BIN_FOLDER}/trello/trello_icon.svg
GenericName=Trello
Keywords=trello;
MimeType=
Name=Trello
StartupNotify=true
StartupWMClass=Trello
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
trello_readmeline="| Trello | ${trello_readmelinedescription} | Command \`trello\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

tumblr_installationtype="environmental"
tumblr_arguments=("tumblr")
tumblr_url="https://www.tumblr.com/"
tumblr_bashfunctions=("alias tumblr=\"nohup xdg-open ${tumblr_url} &>/dev/null &\"")
tumblr_downloads=("https://upload.wikimedia.org/wikipedia/commons/4/43/Tumblr.svg;tumblr_icon.svg")
tumblr_readmelinedescription="Tumblr web opens in Chrome"
tumblr_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${tumblr_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${tumblr_url}
Icon=${BIN_FOLDER}/tumblr/tumblr_icon.svg
GenericName=tumblr
Keywords=tumblr
MimeType=
Name=Tumblr
StartupNotify=true
StartupWMClass=Tumblr
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
tumblr_readmeline="| Tumblr | ${tumblr_readmelinedescription} | Command \`tumblr\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

twitch_installationtype="environmental"
twitch_arguments=("twitch" "twitch_tv")
twitch_url="https://twitch.tv/"
twitch_bashfunctions=("alias twitch=\"nohup xdg-open ${twitch_url} &>/dev/null &\"")
twitch_downloads=("https://commons.wikimedia.org/wiki/File:Twitch_Glitch_Logo_Purple.svg;twitch_icon.svg")
twitch_readmelinedescription="Twitch web opens in Chrome"
twitch_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${twitch_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${twitch_url}
Icon=${BIN_FOLDER}/twitch/twitch_icon.svg
GenericName=Twitch.tv
Keywords=twitch;Twitch;
MimeType=
Name=Twitch
StartupNotify=true
StartupWMClass=Twitch
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
twitch_readmeline="| Twitch | ${twitch_readmelinedescription} | Command \`twitch\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

twitter_installationtype="environmental"
twitter_arguments=("twitter")
twitter_url="https://twitter.com/"
twitter_bashfunctions=("alias twitter=\"nohup xdg-open ${twitter_url} &>/dev/null &\"")
twitter_downloads=("https://upload.wikimedia.org/wikipedia/commons/1/19/Twitter_icon.svg;twitter_icon.svg")
twitter_readmelinedescription="Twitter web opens in Chrome"
twitter_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${twitter_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${twitter_url}
Icon=${BIN_FOLDER}/twitter/twitter_icon.svg
GenericName=Twitter
Keywords=twitter
MimeType=
Name=Twitter
StartupNotify=true
StartupWMClass=Twitter
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
twitter_readmeline="| Twitter | ${twitter_readmelinedescription} | Command \`twitter\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

u_installationtype="environmental"
u_arguments=("u")
u_bashfunctions=("
u()
{
  if [ \$# -eq 0 ]; then
    echo \"ERROR: You need to provide at least one argument\"
    return
  else
    for url_address in \"\$@\"; do
      if [ -n \"\$(echo \"\${url_address}\" | grep -Eo \"^[a-z]+://.+$\")\" ]; then
        xdg-open \"\${url_address}\" &>/dev/null
      else
        xdg-open \"https://\${url_address}\" &>/dev/null
      fi
    done
  fi
}
")
u_readmeline="| Function \`u\` | Opens given link in default web browser | Command \`u\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

uget_installationtype="packagemanager"
uget_arguments=("uget")
uget_launchernames=("uget-gtk")
uget_packagedependencies=("aria2")
uget_packagenames=("uget")
uget_readmeline="| uget | GUI utility to manage downloads | Command \`uget\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

virtualbox_installationtype="packageinstall"
virtualbox_arguments=("virtual_box")
virtualbox_launchernames=("virtualbox")
virtualbox_packagedependencies=("libqt5opengl5")
virtualbox_packagenames=("virtualbox-6.1")
virtualbox_packageurls=("https://download.virtualbox.org/virtualbox/6.1.22/virtualbox-6.1_6.1.22-144080~Ubuntu~eoan_amd64.deb")
virtualbox_readmeline="| VirtualBox | Hosted hypervisor for x86 virtualization | Command \`virtualbox\`, desktop launcher and dashboard launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

vlc_installationtype="packagemanager"
vlc_arguments=("vlc")
vlc_launchernames=("vlc")
vlc_packagenames=("vlc")
vlc_readmeline="| VLC | Media player software, and streaming media server | Command \`vlc\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

whatsapp_installationtype="environmental"
whatsapp_arguments=("whatsapp")
whatsapp_url="https://web.whatsapp.com/"
whatsapp_bashfunctions=("alias whatsapp=\"nohup xdg-open ${whatsapp_url} &>/dev/null &\"")
whatsapp_downloads=("https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg;whatsapp_icon.svg")
whatsapp_readmelinedescription="Whatsapp web opens in Chrome"
whatsapp_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${whatsapp_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${whatsapp_url}
Icon=${BIN_FOLDER}/whatsapp/whatsapp_icon.svg
GenericName=WhatsApp Web
Keywords=whatsapp;
MimeType=
Name=WhatsApp Web
StartupNotify=true
StartupWMClass=WhatsApp
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
whatsapp_readmeline="| Whatsapp Web | ${whatsapp_readmelinedescription} | Command \`whatsapp\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

wikipedia_installationtype="environmental"
wikipedia_arguments=("wikipedia")
wikipedia_url="https://www.wikipedia.org/"
wikipedia_bashfunctions=("alias wikipedia=\"nohup xdg-open ${wikipedia_url} &>/dev/null &\"")
wikipedia_downloads=("https://upload.wikimedia.org/wikipedia/commons/2/20/Wikipedia-logo-simple.svg;wikipedia_icon.svg")
wikipedia_readmelinedescription="Wikipedia web opens in Chrome"
wikipedia_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${wikipedia_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${wikipedia_url}
Icon=${BIN_FOLDER}/wikipedia/wikipedia_icon.svg
GenericName=reddit
Keywords=wikipedia
MimeType=
Name=Wikipedia
StartupNotify=true
StartupWMClass=Wikipedia
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
wikipedia_readmeline="| Wikipedia | ${wikipedia_readmelinedescription} | Command \`wikipedia\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

wireshark_installationtype="packagemanager"
wireshark_arguments=("wireshark")
wireshark_launchercontents=("
[Desktop Entry]
# The format of this file is specified at
# https://specifications.freedesktop.org/desktop-entry-spec/1.0/
# The entries are in the order they are listed in version 1.0
Type=Application
# This is the version of the spec for this file, not the application version.
Version=1.0
Name=Wireshark
Name[vi]=Wireshark
GenericName=Network Analyzer
GenericName[af]=Netwerk Analiseerder
GenericName[az]=Şəbəkə Analiz Proqramı
GenericName[bg]=Анализатор на мрежови трафик
GenericName[bs]=Mrežni analizer
GenericName[ca]=Analitzador de xarxa
GenericName[cs]=Analyzátor sítě
GenericName[da]=Netværksanalyse
GenericName[de]=Programm für die Netzwerk-Analyse
GenericName[el]=Αναλυτής Δικτύων
GenericName[en_GB]=Network Analyser
GenericName[eo]=Retanalizilo
GenericName[es]=Analizador de redes
GenericName[et]=Võrguliikluse analüsaator
GenericName[eu]=Sare ikerketaria
GenericName[fa]=تحلیل‌گر شبکه
GenericName[fi]=Verkkoanalysaattori
GenericName[fr]=Analyseur réseau
GenericName[he]=מאבחן רשת
GenericName[hr]=Program za analiziranje mreža
GenericName[hu]=hálózatanalizáló
GenericName[id]=Analisis jaringan
GenericName[is]=Netskoðunartól
GenericName[it]=Analizzatore di rete
GenericName[ja]=ネットワークアナライザ
GenericName[ko]=네트워크 분석기
GenericName[lo]=ເຄື່ອງມືວິເຄາະເຄືອຂ່າຍ
GenericName[lt]=Tinklo analizatorius
GenericName[lv]=Tīkla Analizators
GenericName[mk]=Анализатор на мрежи
GenericName[mn]=Сүлжээ-шинжлэлийн програм
GenericName[mt]=Analizzatur tan-network
GenericName[nb]=Nettverksanalysator
GenericName[nl]=netwerkanalyseprogramma
GenericName[nn]=Nettverksanalysator
GenericName[nso]=Moahlaahli wa Kgokagano
GenericName[pl]=Analizator sieci
GenericName[pt]=Analisador de Redes
GenericName[pt_BR]=Analisador de rede
GenericName[ro]=Analizor de reţea
GenericName[ru]=Анализатор сетевого трафика
GenericName[se]=Fierbmeanalysa
GenericName[sk]=Analyzátor siete
GenericName[sl]=Analizator omrežij
GenericName[sr]=Analizatror mreže
GenericName[ss]=Sihlatiyi seluchungechunge
GenericName[sv]=Nätverksanalyserare
GenericName[ta]=Å¨Ä ¬öÅ¡Ç÷
GenericName[th]=เครื่องมือวิเคราะห์เครือข่าย
GenericName[tr]=Ağ Analiz Programı
GenericName[uk]=Аналізатор мережі
GenericName[ven]=Musengulusi wa Vhukwamani
GenericName[vi]=Trình phân tích  mạng
GenericName[xh]=Umcukucezi Womsebenzi womnatha
GenericName[zh_CN]=网络分析程序
GenericName[zh_TW]=網路分析程式
GenericName[zu]=Umhloli Woxhumano olusakazekile
Comment=Network traffic analyzer
Comment[fi]=Verkkoliikenne analysaattori
Comment[fr]=Analyseur de trafic réseau
Comment[sv]=Nätverkstrafikanalysator
Comment[af]=Netwerkverkeer analiseerder
Comment[sq]=Analizues i trafikut të rrjetit
Comment[ast]=Analizador de tráficu de rede
Comment[bn]=নেটওয়ার্ক ট্রাফিক বিশ্লেষক
Comment[bg]=Анализатор на мрежовия трафик
Comment[bs]=Analizator mrežnoga prometa
Comment[pt_BR]=Analisador de tráfego de rede
Comment[et]=Võrguliikluse analüüsija
Comment[nl]=Netwerkverkeer analyseren
Comment[da]=Netværkstrafikanalyse
Comment[cs]=Analyzátor síťového přenosu
Comment[gl]=Analizador do tráfico de rede
Comment[el]=Ανάλυση κίνησης δικτύου
Comment[de]=Netzwerkverkehr-Analyseprogramm
Comment[hu]=Hálózatiforgalom-elemző
Comment[it]=Analizzatore del traffico di rete
Comment[ja]=ネットワークトラフィックアナライザー
Comment[ko]=네트워크 트래픽 분석기
Comment[ky]=Тармактык трафикти анализдөө
Comment[lt]=Tinklo duomenų srauto analizatorius
Comment[ms]=Penganalisa trafik rangkaian
Comment[nb]=Nettverkstrafikk-analysator
Comment[oc]=Analisador de tramas de ret
Comment[pt]=Analisador de tráfego da rede
Comment[pl]=Analizator ruchu sieciowego
Comment[ro]=Analizator trafic de rețea
Comment[ru]=Анализ сетевого трафика
Comment[sk]=Analyzátor sieťovej premávky
Comment[es]=Analizador de tráfico de red
Comment[sl]=Preučevalnik omrežnega prometa
Comment[tr]=Ağ trafiği çözümleyicisi
Comment[vi]=Trình phân tích giao thông mạng
Comment[uk]=Аналізатор мережевого трафіку
Icon=/usr/share/icons/hicolor/scalable/apps/wireshark.svg
TryExec=wireshark
Exec=wireshark %f
Terminal=false
MimeType=application/vnd.tcpdump.pcap;application/x-pcapng;application/x-snoop;application/x-iptrace;application/x-lanalyzer;application/x-nettl;application/x-radcom;application/x-etherpeek;application/x-visualnetworks;application/x-netinstobserver;application/x-5view;application/x-tektronix-rf5;application/x-micropross-mplog;application/x-apple-packetlogger;application/x-endace-erf;application/ipfix;application/x-ixia-vwr;
# Category entry according to:
# https://specifications.freedesktop.org/menu-spec/1.0/
Categories=Network;Monitor;Qt;
")
wireshark_packagenames=("wireshark")
wireshark_readmeline="| Wireshark | Net sniffer | Command \`wireshark\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

x_installationtype="environmental"
x_arguments=("x" "extract" "extract_function")
x_bashfunctions=("
x() {
  local first_compressed_file_arg_pos=
  if [ -d \"\$1\" ]; then
    local -r decompression_folder=\"\$1\"
    mkdir -p \"\${decompression_folder}\"
    local old_folder=\"\$(pwd)\"
    shift  # With this we expect files in \$1 and the following positions.
  fi

  while [ -n \"\$1\" ]; do
    local absolute_first_arg=
    if [ -n \"\${decompression_folder}\" ]; then
      if [ -n \"\$(echo \"\$1\" | grep -Eo \"^/\")\" ]; then  # Absolute path
        absolute_first_arg=\"\$1\"
      else  # relative path
        absolute_first_arg=\"\$(pwd)/\$1\"
      fi
      cd \"\${decompression_folder}\"
    else
      absolute_first_arg=\"\$1\"
    fi
    if [ -f \"\${absolute_first_arg}\" ] ; then
      case \"\${absolute_first_arg}\" in
        *.tar.bz2)
          tar xjf \"\${absolute_first_arg}\"
        ;;
        *.tar.gz)
          tar xzf \"\${absolute_first_arg}\"
        ;;
        *.bz2)
          bunzip2 \"\${absolute_first_arg}\"
        ;;
        *.rar)
          rar x \"\${absolute_first_arg}\"
        ;;
        *.gz)
          gzip -dk \"\${absolute_first_arg}\"
        ;;
        *.tar)
          tar xf \"\${absolute_first_arg}\"
        ;;
        *.tbz2)
          tar xjf \"\${absolute_first_arg}\"
        ;;
        *.tgz)
          tar xzf \"\${absolute_first_arg}\"
        ;;
        *.zip)
          unzip \"\${absolute_first_arg}\"
        ;;
        *.Z)
          uncompress \"\${absolute_first_arg}\"
        ;;
        *.7z)
          7z x \"\${absolute_first_arg}\"
        ;;
        *)
          echo \"\${absolute_first_arg} cannot be extracted via x\"
        ;;
      esac
    else
      echo \"'\${absolute_first_arg}' is not a valid file for x\"
    fi
    if [ -n \"\${decompression_folder}\" ]; then
      cd \"\${old_folder}\"
    fi

    shift
  done
  if [ ! -n \"\$(echo \"\${absolute_first_arg}\")\" ]; then
    echo \"ERROR: x needs at least an argument. The first arg can be a file or directory where compressed files will be extracted. The rest o arguments are paths to different compressed files.\"
  fi


}
")
x_readmeline="| Function \`x\` | Function to extract from a compressed file, no matter its format | Function \`x \"filename\"\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

xclip_installationtype="packagemanager"
xclip_arguments=("x_clip")
xclip_packagenames=("xclip")
xclip_readmeline="| \`xclip\` | Utility for pasting. | Command \`xclip\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

youtube_installationtype="environmental"
youtube_arguments=("youtube")
youtube_url="https://youtube.com/"
youtube_bashfunctions=("alias youtube=\"nohup xdg-open ${youtube_url} &>/dev/null &\"")
youtube_downloads=("https://upload.wikimedia.org/wikipedia/commons/4/4f/YouTube_social_white_squircle.svg;youtube_icon.svg")
youtube_readmelinedescription="YouTube opens in Chrome"
youtube_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${youtube_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${youtube_url}
Icon=${BIN_FOLDER}/youtube/youtube_icon.svg
GenericName=YouTube
Keywords=youtube;
MimeType=
Name=YouTube
StartupNotify=true
StartupWMClass=YouTube
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
youtube_readmeline="| Youtube| ${youtube_readmelinedescription} | Command \`youtube\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

youtube_dl_installationtype="environmental"
youtube_dl_arguments=("youtube_dl")
youtube_dl_bashfunctions=("alias youtubewav=\"youtube-dl --extract-audio --audio-format wav\"")
youtube_dl_binariesinstalledpaths=("youtube-dl;youtube-dl")
youtube_dl_downloads=("https://yt-dl.org/downloads/latest/youtube-dl;youtube-dl")
youtube_dl_readmeline="| youtube-dl | Download manager for video and audio from YouTube and over 1000 other video hosting websites. | Command \`youtube-dl\` in the PATH and alias \`youtube-wav\` to scratch a mp3 from youtube || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

youtubemusic_installationtype="environmental"
youtubemusic_url="https://music.youtube.com"
youtubemusic_filekeys=("youtubemusicscript")
youtubemusic_youtubemusicscript_path="youtubemusic.sh"
youtubemusic_youtubemusicscript_content="
nohup xdg-open ${youtubemusic_url} &>/dev/null &
"
youtubemusic_binariesinstalledpaths=("youtubemusic.sh;youtubemusic")
youtubemusic_arguments=("youtube_music")
youtubemusic_downloads=("https://upload.wikimedia.org/wikipedia/commons/6/6a/Youtube_Music_icon.svg;youtubemusic_icon.svg")
youtubemusic_readmelinedescription="YouTube music opens in Chrome."
youtubemusic_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${youtubemusic_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${youtubemusic_url}
Icon=${BIN_FOLDER}/youtubemusic/youtubemusic_icon.svg
GenericName=YouTube Music
Keywords=youtubemusic;
MimeType=
Name=YouTube Music
StartupNotify=true
StartupWMClass=YouTube Music
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0
")
youtubemusic_readmeline="| Youtube Music | ${youtubemusic_readmelinedescription} | Command \`youtubemusic\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

z_installationtype="environmental"
z_arguments=("z" "z_function")
z_readmeline="| z function | function to compress files given a type and a set of pats to files | Command \`z\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
z_bashfunctions=("
z() {
  local first_compressed_file_arg_pos=
  if [ -d \"\$1\" ]; then
    local -r decompression_folder=\"\$1\"
    mkdir -p \"\${decompression_folder}\"
    local old_folder=\"\$(pwd)\"
    shift  # With this we expect files in \$1 and the following positions.
  fi

  while [ -n \"\$1\" ]; do
    local absolute_first_arg=
    if [ -n \"\${decompression_folder}\" ]; then
      if [ -n \"\$(echo \"\$1\" | grep -Eo \"^/\")\" ]; then  # Absolute path
        absolute_first_arg=\"\$1\"
      else  # relative path
        absolute_first_arg=\"\$(pwd)/\$1\"
      fi
      cd \"\${decompression_folder}\"
    else
      absolute_first_arg=\"\$1\"
    fi

    local compression_type=\"\$1\"
    shift
    if [ -f \"\${absolute_first_arg}\" ]; then
      local first_arg_name=\"\$(echo \"\$1\" | rev | cut -d \"/\" -f1 | rev)\"
      case \"\${compression_type}\" in
        tar.bz2)
          tar cvjf \"\${first_arg_name}.tar.bz2\" \"\${absolute_first_arg}\"
        ;;
        tar.gz)
          tar cvzf \"\${first_arg_name}.tar.gz\" \"\${absolute_first_arg}\"
        ;;
        bz2)
          bzip2 \"\${first_arg_name}.bz2\" \"\${absolute_first_arg}\"
        ;;
        rar)
          rar a \"\${first_arg_name}.rar\" \"\${absolute_first_arg}\"
        ;;
        gz)
          gzip -c \"\${absolute_first_arg}.gz\" > \"\${first_arg_name}\"
        ;;
        tar)
          tar cf \"\${first_arg_name}.tar\" \"\${absolute_first_arg}\"
        ;;
        tbz2)
          tar cvjf \"\${first_arg_name}.tbz2\" \"\${absolute_first_arg}\"
        ;;
        tgz)
          tar cvzf \"\${first_arg_name}.tgz\" \"\${absolute_first_arg}\"
        ;;
        zip)
          zip \"\${first_arg_name}.zip\" \"\${absolute_first_arg}\"
        ;;
        Z)
          compress \"\${first_arg_name}.Z\" \"\${absolute_first_arg}\"
        ;;
        7z)
          7z a \"\${first_arg_name}.7z\" \"\${absolute_first_arg}\"
        ;;
        *)
          echo \"\${absolute_first_arg} cannot be extracted via x\"
        ;;
      esac
    else
      echo \"'\${absolute_first_arg}' is not a valid file for z\"
    fi
    if [ -n \"\${decompression_folder}\" ]; then
      cd \"\${old_folder}\"
    fi

    shift
  done
  if [ ! -n \"\$(echo \"\${absolute_first_arg}\")\" ]; then
    echo \"ERROR: z needs at least an argument. The first arg can be a file or directory where compressed files will be created. The rest o arguments are paths to different files that have to be compressed.\"
  fi
}
")

zoom_installationtype="userinherit"
zoom_arguments=("zoom")
zoom_binariesinstalledpaths=("ZoomLauncher;ZoomLauncher" "zoom;zoom")
zoom_compressedfileurl="https://zoom.us/client/latest/zoom_x86_64.tar.xz"
zoom_compressedfiletype="J"
zoom_downloads=("https://uxwing.com/wp-content/themes/uxwing/download/10-brands-and-social-media/zoom.svg;zoom_icon.svg")
zoom_readmelinedescription="Live Video Streaming for Meetings"
zoom_launchercontents=("
[Desktop Entry]
Categories=Social;Communication;
Comment=${zoom_readmelinedescription}
Encoding=UTF-8
GenericName=Video multiple calls
Icon=${BIN_FOLDER}/zoom/zoom_icon.svg
Keywords=Social;VideoCalls;
MimeType=
Name=Zoom
StartupNotify=true
StartupWMClass=zoom
Terminal=false
TryExec=ZoomLauncher
Type=Application
Version=1.0
Exec=ZoomLauncher
")
zoom_readmeline="| Zoom | ${zoom_readmelinedescription} | Command \`zoom\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

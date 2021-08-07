########################################################################################################################
# - Name: Linux Auto-Customizer exclusive functions of install.sh.                                                     #
# - Description: Contains the different pieces of data used to install and uninstall all features that can be generic.
# Here we have all the data relating to each feature: desktop launchers, icon URLs, aliases, bash_functions, paths to
# the binaries of each program, etc
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 16/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernandez Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: This script can not be executed directly, only sourced to import its functions and process its own    #
# imports. See the header of each function to see its privilege requirements                                           #
# - Arguments: No arguments                                                                                            #
# - Usage: Sourced from install.sh                                                                                     #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################

# Here are the definition of most long strings, that are used in installation
# functions. All the variables follow the same name convention:
# 1 .- the first word is the name in the path, variable, function of the software
# to be installed.
# 2.- This is followed by a underscore _
# 3.- Then the second word is the type of variable:
#   * launcher: contains the contents of a desktop launcher file
#   * icon: Contains a URL that points to a valid icon for that feature
#   * url: Variables that contain an URL that is expected to be in the feature as-is
#   * downloader: Variables that contains an URL that points to a file resource
#   * alias: Contains code that will be integrated into the user environment. This
#     code will be parsed by bash only when run manually by the user, that means that
#     the variable with this suffix contains potentially harmless code such as alias or
#     variable definitions...
#   * function: Contains code that will be integrated into the user environment, but in
#   this case, the code is parsed every time the user reloads its environment indirectly,
#   that means that the variable with this suffix contains potentially harmful code, such
#   as bash functions or code that does some tweaking to the environment
#

########################################################################################################################
######################################### IMPORT COMMON VARIABLES ######################################################
########################################################################################################################

if [[ -f "${DIR}/data_common.sh" ]]; then
  source "${DIR}/data_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: data_common.sh not found. Aborting..."
  exit 1
fi

########################################################################################################################
################################### DATA FOR COMMON INSTALLATION CAPABILITIES ##########################################
########################################################################################################################


bash_functions_import="
source ${BASH_FUNCTIONS_PATH}
"
bash_functions_init="
# If not running interactively, don't do anything
case \$- in
    *i*) ;;
      *) return;;
esac

# Make sure that PATH is pointing to ${DIR_IN_PATH} (where we will put our soft links to the software)
if [ -z \"\$(echo \$PATH | grep -Eo \"${DIR_IN_PATH}\")\" ]; then
  export PATH=\$PATH:${DIR_IN_PATH}
fi
"

# The variables in here follow a naming scheme that is required for the code of each feature to obtain its data by
# variable indirect expansion.
# The variables must follow the next pattern: FEATUREKEYNAME_PROPERTY.
# The variables that are used by the code depend on the type of installation, defined as:
# FEATUREKEYNAME_installationtype. This can be set to:
# "environmental": Uses only the common part of the installation to install bash code in bashrc, desktop launchers...
# "packageinstall": Downloads a .deb package and installs it using dpkg.
# "packagemanager": Uses de package manager such as apt-get to install packages.
# "userinherit": Downloads a compressed file containing an unique folder.
# "repositoryclone": Clone a reposiotory inside the directory of the current feature installing.
# Available properties
# - FEATUREKEYNAME_launchernames: Array of names of launchers to be copied from the launchers folder. (packageinstall, packagemanager)
# - FEATUREKEYNAME_packagenames: Array of names of packages to be installed using apt-get. (packageinstall, packagemanager)
# - FEATUREKEYNAME_packageurls: Link to the .deb file to download (packageinstall)
# - FEATUREKEYNAME_compressedfileurl: Internet link to a compressed file. (userinherit)
# - FEATUREKEYNAME_compressedfilepathoverride: Designs another path to perform the download and decompression (userinherit)
# - FEATUREKEYNAME_compressedfiletype: Compression format of the the compressed file from FEATUREKEYNAME_compressedfileurl (userinherit)
# - FEATUREKEYNAME_binariesinstalledpaths: Array of relative paths from the downloaded folder of the features to
#   binaries that will be added to the PATH (userinherit) and its name in the path separated by ";"
# - FEATUREKEYNAME_dependencies: Array of name of packages to be installed using apt-get before main installation (packageinstall, packagemanager)
# - FEATUREKEYNAME_launchercontents: Array of contents of launchers to be created (all)
# - FEATUREKEYNAME_bashfunctions: Array of contents of functions to be added in .bashrc (all)
# - FEATUREKEYNAME_associatedfiletypes: Array of mime types to be associated with the feature.
# - FEATUREKEYNAME_keybinds: Array of keybinds to be associated with the feature (all). Each keybind has 3 fields separated
#   from each other using ";": Command;key_combination;keybind_description. It needs a desktop launcher
# - FEATUREKEYNAME_autostart: Overrides the autostart flag. Set to "yes" in order to autostart the application.
# - FEATUREKEYNAME_downloads: Array of links to avalid donwload file separated by ";" from the desired name for that file.
#   It will downloaded in ${USR_BIN_FOLDER}/APPNAME/DESIREDFILENAME
# - FEATUREKEYNAME_repositoryurl: Repository to be cloned. (repositoryclone)
# - FEATUREKEYNAME_manualcontent: String containing three elements separated by ; that can be 1 or 0 and indicate if
#   there is manual code for that feature to be executed or not. If it is in one, it will try to execute a function
#   with its name following a certain pattern
# - FEATUREKEYNAME_pipinstallations: Array containing set of programs to be installed via pip (pythonvenv)
# - FEATUREKEYNAME_pythoncommands: Array containing set of instructions to be executed by the venv using python3 (pythonvenv)
# - FEATUREKEYNAME_manualcontentavailable: 3 bits separated by ; defining if there's manual code to be executed from a
#   function following the next naming rules: install_FEATUREKEYNAME_pre, install_FEATUREKEYNAME_mid, install_FEATUREKEYNAME_post (pythonvenv)
# - FEATUREKEYNAME_filekeys: Array contentaining the keys to indirect expand file to be created and its path
# - FEATUREKEYNAME_FILEKEY_content: Variable with the content of a file
# - FEATUREKEYNAME_FILEKEY_path: Variable with the path where we need to store the file with that FILEKEY

# - FEATUREKEYNAME_flagsoverride: Contains bits that will override the current state fo the flags for that feature
#   Its format is the following:
#   ${FLAG_PERMISSION};${FLAG_IGNORE_ERRORS};${FLAG_OVERWRITE};${FLAG_QUIETNESS};${FLAG_FAVORITES};${FLAG_AUTOSTART}
#   If we want to override permissions for being executed as root at all times:
#   FEATUREKEYNAME_flagsoverride="0;;;;;"
########################################################################################################################
######################################## INSTALLATION SPECIFIC VARIABLES ###############################################
########################################################################################################################

a_installationtype="environmental"
a_arguments=("a")
a_bashfunctions=("alias a=\"echo '---------------Alias----------------';compgen -a\"")
#a_flagsoverride="2;;;;;"
a_readmeline="| Function \`a\` | Prints a list of aliases using \`compgen -a\` | Command \`a\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

add_installationtype="environmental"
add_arguments=("add" "add_function")
add_bashfunctions=("alias add=\"git add\"")
#add_flagsoverride="1;;;;;"
add_readmeline="| Function \`add\` | alias for \`git add\` | Command \`add\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

aisleriot_installationtype="packagemanager"
aisleriot_arguments=("aisleriot" "solitaire" "gnome-solitaire")
#aisleriot_flagsoverride="0;;;;;"
aisleriot_launchernames=("sol")
aisleriot_packagenames=("aisleriot")
aisleriot_readmeline="| Solitaire aisleriot | Implementation of the classical game solitaire | Command \`aisleriot\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

# Line of the test. The Above is refactored (not yet!). The Below is not (of course).

alert_installationtype="environmental"
alert_arguments=("alert" "alert-alias" "alias-alert")
alert_bashfunctions=("
# Add an alert alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i \"\$([ \$? = 0 ] && echo terminal || echo error)\" \"\$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\\'')\"'
")
#alert_flagsoverride="0;;;;;"
alert_readmeline="| Function \`alert\` | Alias to show a notification at the end of a command | Alias \`alert\`. Use it at the end of long running commands like so: \`sleep 10; alert\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

ansible_installationtype="packagemanager"
ansible_arguments=("ansible")
#ansible_flagsoverride="0;;;;;"
ansible_packagenames=("ansible")
ansible_readmeline="| Ansible | Automation of software | Command \`ansible\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

ant_installationtype="userinherit"
ant_arguments=("ant" "apache_ant")
ant_bashfunctions=("export ANT_HOME=\"${USR_BIN_FOLDER}/ant\"")
ant_binariesinstalledpaths=("bin/ant;ant")
ant_compressedfiletype="z"
ant_compressedfileurl="https://ftp.cixug.es/apache//ant/binaries/apache-ant-1.10.11-bin.tar.gz"
ant_flagsoverride="1;;;;;"
ant_readmeline="| Apache Ant | Software tool for automating software build processes | Command \`ant\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |"

anydesk_installationtype="userinherit"
anydesk_arguments=("any_desk")
anydesk_bashfunctions=("alias anydesk=\"nohup anydesk &>/dev/null &\"")
anydesk_binariesinstalledpaths=("anydesk;anydesk")
anydesk_compressedfiletype="z"
anydesk_compressedfileurl="https://download.anydesk.com/linux/anydesk-6.1.1-amd64.tar.gz"
anydesk_readmelinedescription="Software to remote control other computers"
anydesk_readmeline="| Anydesk | ${anydesk_readmelinedescription} | Command \`anydesk\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
anydesk_launchercontents=("
[Desktop Entry]
Categories=Remote;control;other;
Comment=${anydesk_readmelinedescription}
Encoding=UTF-8
Exec=anydesk
GenericName=Remote desktop application
Icon=${USR_BIN_FOLDER}/anydesk/icons/hicolor/scalable/apps/anydesk.svg
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

aspell_installationtype="packagemanager"
aspell_arguments=("aspell")
aspell_packagenames=("aspell-es" "aspell-ca")
aspell_readmeline="| Aspell | Spell checker | Command \`aspell\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

atom_installationtype="packageinstall"
atom_arguments=("atom")
atom_launchernames=("atom")
atom_packageurls=("https://atom.io/download/deb")
atom_readmeline="| Atom | Text and source code editor | Command \`atom\`, desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

audacity_installationtype="packagemanager"
audacity_arguments=("audacity")
audacity_bashfunctions=("alias audacity=\"nohup audacity &>/dev/null &\"")
audacity_launchernames=("audacity")
audacity_packagenames=("audacity")
audacity_readmeline="| Audacity | Digital audio editor and recording | Command \`audacity\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

AutoFirma_installationtype="packageinstall"
AutoFirma_arguments=("AutoFirma" "autofirma")
AutoFirma_bashfunctions=("alias autofirma=\"nohup AutoFirma &>/dev/null &\"")
AutoFirma_compressedfiletype="zip"
AutoFirma_compressedfileurl="https://estaticos.redsara.es/comunes/autofirma/currentversion/AutoFirma_Linux.zip"
AutoFirma_launchernames=("afirma")
AutoFirma_packagedependencies=("libnss3-tools")
AutoFirma_readmeline="| AutoFirma | Electronic signature recognition | Command \`AutoFirma\` and desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

axel_installationtype="packagemanager"
axel_arguments=("axel")
axel_packagenames=("axel")
axel_readmeline="| Axel | Download manager | Command \`axel\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

b_installationtype="environmental"
b_arguments=("b")
b_bashfunctions=("alias b=\"bash\"")
b_readmeline="| Function \`b\` | Alias for \`bash\` | Alias \`b\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

bashcolors_installationtype="environmental"
bashcolors_arguments=("bashcolors")
bashcolors_bashfunctions=("
# Consider dracula color palette
CLEAR='\033[0m' # No Color
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0,35m'
CYAN='\033[1;36m'
LIGHTGREY='\033[0;37m'
DARKGREY='\033[1;30m'
LIGHTGREY='\033[0;37m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;34m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
")
bashcolors_readmeline="| bashcolors | bring color to terminal | Command \`bashcolors\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

branch_installationtype="environmental"
branch_arguments=("branch")
branch_bashfunctions=("alias branch=\"git branch\"")
branch_readmeline="| Function \`branch\` | alias for \`git branch -vv\` | Command \`branch\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

brasero_installationtype="packagemanager"
brasero_arguments=("brasero")
brasero_bashfunctions=("alias brasero=\"nohup brasero &>/dev/null &\"")
brasero_launchernames=("brasero")
brasero_packagenames=("brasero")
brasero_readmeline="| Brasero | Software for image burning | Command \`brasero\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
c_readmeline="| Function \`c\` | Function \`c\` that changes the directory or clears the screen | Function \`c \` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

caffeine_installationtype="packagemanager"
caffeine_arguments=("caffeine" "coffee" "cafe")
#caffeine_flagsoverride="0;;;;;"
caffeine_launchernames=("caffeine-indicator")
caffeine_manualcontentavailable="1;0;1"
caffeine_packagenames=("caffeine")
caffeine_readmeline="| Caffeine | Simple indicator applet on Ubuntu panel that allows to temporarily prevent the activation of the screensaver, screen lock, and the “sleep” power saving mode. | Commands \`caffeine\`, \`caffeinate\` and \`caffeine-indicator\`, desktop launcher for \`caffeine\`, dashboard launcher for \`caffeine\` and \`caffeine-indicator\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

calibre_installationtype="packagemanager"
calibre_arguments=("calibre")
calibre_bashfunctions=("alias calibre=\"nohup calibre &>/dev/null &\"")
calibre_launchernames=("calibre-gui")
calibre_packagenames=("calibre")
calibre_readmeline="| Calibre | e-book reader| Commmand \`calibre\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

changebg_installationtype="repositoryclone"
changebg_arguments=("changebg" "wallpaper" "wallpapers" "change_bg")
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
DIR=\"${USR_BIN_FOLDER}/changebg\"
PIC=\$(ls \${DIR} | shuf -n1)
echo \"\$DIR/\$PIC\"
dconf write \"/org/gnome/desktop/background/picture-uri\" \"'file://\${DIR}/\${PIC}'\"

#gsettings set org.gnome.desktop.background picture-uri \"'file://\${DIR}/\${PIC}'\"
"
changebg_cronscript_path=".cronscript.sh"
changebg_cronjob_content="*/5 * * * * ${USR_BIN_FOLDER}/changebg/.cronscript.sh"
changebg_cronjob_path=".cronjob"
changebg_filekeys=("cronscript" "cronjob")
changebg_repositoryurl="https://github.com/AleixMT/wallpapers"
changebg_manualcontentavailable="0;0;1"
changebg_readmeline="| Function \`changebg\` | Function that changes the wallpaper using one random image from user images folder. It also downloads wallpapers and installs a cronjob to change the wallpaper every 5 minutes | Function \`changebg\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

cheat_installationtype="environmental"
cheat_arguments=("cheat" "cheat.sh")
cheat_binariesinstalledpaths=("cht.sh;cheat")
cheat_downloads=("https://cht.sh/:cht.sh;cht.sh")
cheat_readmeline="| cheat.sh | Provides access to community-driven cheat sheets and snippets for Linux/UNIX commands and many programming languages | Command \`cheat\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

checkout_installationtype="environmental"
checkout_arguments=("checkout")
checkout_bashfunctions=("alias checkout=\"git checkout\"")
checkout_readmeline="| Function \`checkout\` | alias for \`git checkout\` | Command \`checkout\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

cheese_installationtype="packagemanager"
cheese_arguments=("cheese")
cheese_bashfunctions=("alias cheese=\"nohup cheese &>/dev/null &\"")
cheese_launchernames=("org.gnome.Cheese")
cheese_packagenames=("cheese")
cheese_readmeline="| Cheese | GNOME webcam application | Command \`cheese\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
clean_readmeline="| Function \`clean\` | Remove files and contents from the trash bin and performs \`sudo apt-get -y autoclean\` and \`sudo apt-get -y autoremove\`. | Command \`clean\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

clementine_installationtype="packagemanager"
clementine_arguments=("clementine")
clementine_bashfunctions=("alias clementine=\"nohup clementine &>/dev/null &\"")
clementine_launchernames=("clementine")
clementine_packagenames=("clementine")
clementine_readmeline="| Clementine | Modern music player and library organizer | Command \`clementine\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/clion/bin/clion.png
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
clion_readmeline="| Clion | ${clion_readmelinedescription} | Command \`clion\`, silent alias \`clion\`, desktop launcher, dashboard launcher, associated with mimetypes \`.c\`, \`.h\` and \`.cpp\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
clonezilla_readmeline="| CloneZilla | ${clonezilla_readmelinedescription} | Command \`clonezilla\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
cmatrix_readmeline="| Cmatrix |  | Command \`cmatrix\`, function \`matrix\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

code_installationtype="userinherit"
code_arguments=("code" "visualstudiocode" "visual-studio-code" "visual-studio")
code_bashfunctions=("alias code=\"nohup code . &>/dev/null &\"")
code_binariesinstallpaths=("code;code")
code_compressedfiletype="z"
code_compressedfileurl="https://go.microsoft.com/fwlink/?LinkID=620884"
code_launchercontents=("[Desktop Entry]
Categories=Development;IDE;
Comment=${code_readmelinedescription}
Encoding=UTF-8
Exec=code %f
GenericName=IDE for programming
Icon=${USR_BIN_FOLDER}/code/resources/app/resources/linux/code.png
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
code_readmeline="| Visual Studio Code | ${code_readmelinedescription} | Command \`code\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

codeblocks_installationtype="packagemanager"
codeblocks_arguments=("codeblocks" "code::blocks")
codeblocks_bashfunctions=("alias codeblocks=\"nohup codeblocks &>/dev/null &\"")
codeblocks_launchernames=("codeblocks")
codeblocks_packagenames=("codeblocks")
codeblocks_readmeline="| Code::Blocks | IDE for programming  | Command \`codeblocks\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
commit_readmeline="| Function \`commit\` | Function \`commit\` that makes \`git commit -am \"\$1\"\` | Function \`commit\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> "

converters_installationtype="repositoryclone"
converters_arguments=("converters")
converters_repositoryurl="https://github.com/Axlfc/converters"
converters_readmeline="| Converters | Set of converter Python scripts that integrate in your environment as \`bash\` commands | Commands \`bintodec\`, \`dectobin\`, \`dectohex\`, \`dectoutf\`, \`escaper\`, \`hextodec\`, \`to\` and \`utftodec\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
converters_binariesinstalledpaths=("converters/to.py;to" "converters/dectoutf.py;dectoutf" "converters/utftodec.py;utftodec")
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

copyq_installationtype="packagemanager"
copyq_arguments=("copyq")
#copyq_flagsoverride="0;;;;;"
copyq_launchernames=("com.github.hluk.copyq")
copyq_packagenames=("copyq")
copyq_readmeline="| copyq | A clipboard manager application that comes with extra features such as editing and scripting | Command \`copyq\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

curl_installationtype="packagemanager"
curl_arguments=("curl")
curl_packagenames=("curl")
curl_readmeline="| Curl | Curl is a CLI command for retrieving or sending data to a server | Command \`curl\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

dbeaver_installationtype="packageinstall"
dbeaver_arguments=("dbeaver")
dbeaver_packageurls=("https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb")
dbeaver_launchernames=("dbeaver")
dbeaver_readmeline="| DBeaver | SQL Client IDE | Command \`dbeaver\` desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

dconf_editor_installationtype="packagemanager"
dconf_editor_arguments=("dconf_editor" "dconf")
dconf_editor_launchernames=("ca.desrt.dconf-editor")
dconf_editor_packagenames=("dconf-editor")
dconf_editor_readmeline="| dconf-editor | Editor settings | Command \`dconf-editor\` and desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

dia_installationtype="packagemanager"
dia_arguments=("dia")
dia_packagenames=("dia-common")
dia_launchernames=("dia")
dia_bashfunctions=("alias dia=\"nohup dia &>/dev/null &\"")
dia_readmeline="| Dia | Graph and relational  | Command \`dia\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/discord/discord.png
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
discord_readmeline="| Discord | ${discord_readmelinedescription} | Command \`discord\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

docker_installationtype="userinherit"
docker_arguments=("docker")
docker_compressedfiletype="z"
docker_compressedfileurl="https://download.docker.com/linux/static/stable/x86_64/docker-20.10.6.tgz"
docker_binariesinstalledpaths=("docker;docker" "containerd;containerd" "containerd-shim;containerd-shim" "containerd-shim-runc-v2;containerd-shim-runc-v2" "ctr;ctr" "dockerd;dockerd" "docker-init;docker-init" "docker-proxy;docker-proxy" "runc;runc")
docker_readmeline="| Docker | Containerization service | Command \`docker\`, \`containerd\`, \`containerd-shim\`, \`containerd-shim-runc-v2\`, \`ctr\`, \`dockerd\`, \`docker-init\`, \`docker-proxy\`, \`runc\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

documents_installationtype="environmental"
documents_arguments=("documents" "google-document" "google-documents")
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
Icon=${USR_BIN_FOLDER}/documents/documents_icon.svg
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
documents_readmeline="| Google Documents | ${documents_readmelinedescription} | Command \`document\` and desktop and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/drive/drive_icon.svg
TryExec=google-chrome
Type=Application
Version=1.0
")
drive_readmeline="| Google Drive | ${drive_readmelinedescription} | Command \`drive\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

dropbox_installationtype="packageinstall"
dropbox_arguments=("dropbox")
dropbox_launchernames=("dropbox")
dropbox_packagedependencies=("python3-gpg")
dropbox_packageurls=("https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb")
dropbox_readmeline="| Dropbox | File hosting service | Command \`dropbox\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

duckduckgo_installationtype="environmental"
duckduckgo_arguments=("duckduckgo")
duckduckgo_url="https://duckduckgo.com/"
duckduckgo_bashfunctions=("alias duckduckgo=\"nohup xdg-open ${duckduckgo_url} &>/dev/null &\"")
duckduckgo_downloads=("https://iconape.com/wp-content/png_logo_vector/cib-duckduckgo.png;duckduckgo_icon.png")
duckduckgo_readmelinedescription="Opens DuckDuckGo in Chrome"
duckduckgo_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${duckduckgo_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${duckduckgo_url}
Icon=${USR_BIN_FOLDER}/duckduckgo/duckduckgo_icon.png
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
duckduckgo_readmeline="| DuckDuckGo | ${duckduckgo_readmelinedescription} | Command \`duckduckgo\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
dummycommit_readmeline="| Function \`dummycommit\` | Do the following commands \`git add -a\` \`git commit -am \$1\` \`git push\` | Command \`dummycommit\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"


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
e_readmeline="| Function \`e\` | Multi Function \`e\` to edit a file or project in folder | Function \`e\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/eclipse/icon.xpm
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
eclipse_readmeline="| Eclipse | ${eclipse_readmelinedescription} | Command \`eclipse\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

evolution_installationtype="packagemanager"
evolution_arguments=("evolution")
evolution_bashfunctions=("alias evolution=\"nohup evolution &>/dev/null &\"")
evolution_launchernames=("evolution-calendar")
evolution_packagenames=("evolution" )
evolution_readmeline="| evolution | User calendar agend, planning | Command \`evolution\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
f_irc_readmeline="| f-irc | ${f_irc_readmelinedescription} | Command \`f-irc\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/facebook/facebook_icon.svg
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
facebook_readmeline="| Facebook | ${facebook_readmelinedescription} | Command \`facebook\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

fdupes_installationtype="packagemanager"
fdupes_arguments=("fdupes")
fdupes_packagenames=("fdupes")
fdupes_readmeline="| Fdupes| Searches for duplicated files within given directories | Command \`fdupes\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

fetch_installationtype="environmental"
fetch_arguments=("fetch")
fetch_bashfunctions=("alias fetch=\"git fetch\"")
fetch_readmeline="| fetch| \`git fetch\`| Command \`fetch\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

ffmpeg_installationtype="packagemanager"
ffmpeg_arguments=("ffmpeg" "youtube-dl-dependencies")
ffmpeg_packagenames=("ffmpeg")
ffmpeg_readmeline="| ffmpeg | Super fast video / audio encoder | Command \`ffmpeg\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

firefox_installationtype="packagemanager"
firefox_arguments=("firefox")
firefox_launchernames=("firefox")
firefox_packagenames=("firefox")
firefox_readmeline="| Firefox | Free web browser | Command \`firefox\`, desktop launcher, dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

fonts_alegreya_sans_installationtype="userinherit"
fonts_alegreya_sans_arguments=("fonts_alegreya_sans")
fonts_alegreya_sans_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_alegreya_sans_compressedfiletype="zip"
fonts_alegreya_sans_compressedfileurls=("https://fonts.google.com/download?family=Alegreya%20Sans")
fonts_alegreya_sans_readmeline="| fonts-alegreya_sans | Installs font | Install alegreya font || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

fonts_firacode_installationtype="packagemanager"
fonts_firacode_arguments=("fonts_firacode")
fonts_firacode_packagenames=("fonts-firacode")
fonts_firacode_readmeline="| fonts-firacode | Installs font | Install firacode font ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

fonts_hack_installationtype="packagemanager"
fonts_hack_arguments=("fonts_hack")
fonts_hack_packagenames=("fonts-hack")
fonts_hack_readmeline="| fonts-hack | Installs font | Install hack font ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

fonts_hermit_installationtype="packagemanager"
fonts_hermit_arguments=("fonts_hermit")
fonts_hermit_packagenames=("fonts-hermit")
fonts_hermit_readmeline="| fonts-hermit | Installs font | Install hermit font ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

fonts_lato_installationtype="userinherit"
fonts_lato_arguments=("fonts_lato")
fonts_lato_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_lato_compressedfiletype="zip"
fonts_lato_compressedfileurls=("https://fonts.google.com/download?family=Lato")
fonts_lato_readmeline="| fonts-lato | Installs font | Install lato font || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

fonts_noto_sans_installationtype="userinherit"
fonts_noto_sans_arguments=("fonts_noto_sans")
fonts_noto_sans_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_noto_sans_compressedfiletype="zip"
fonts_noto_sans_compressedfileurls=("https://fonts.google.com/download?family=Noto%20Sans")
fonts_noto_sans_readmeline="| fonts-noto_sans | Installs font| Install noto_sans font || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

fonts_oswald_installationtype="userinherit"
fonts_oswald_arguments=("fonts_oswald")
fonts_oswald_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_oswald_compressedfileurls=("https://fonts.google.com/download?family=Oswald")
fonts_oswald_compressedfiletype="zip"
fonts_oswald_readmeline="| fonts-oswald | Installs font| Install oswald font || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

fonts_oxygen_installationtype="userinherit"
fonts_oxygen_arguments=("fonts_oxygen")
fonts_oxygen_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_oxygen_compressedfileurl="https://fonts.google.com/download?family=Oxygen"
fonts_oxygen_compressedfiletype="zip"
fonts_oxygen_readmeline="| fonts-oxygen | Installs font | Install oxygen font || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

fonts_roboto_installationtype="packagemanager"
fonts_roboto_arguments=("fonts_roboto")
fonts_roboto_packagenames=("fonts-roboto")
fonts_roboto_readmeline="| fonts-roboto | Installs font| Install roboto font ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/forms/forms_icon.svg
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
forms_readmeline="| Forms | ${forms_readmelinedescription} | Command \`forms\`, desktop launcher, dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

freecad_installationtype="packagemanager"
freecad_arguments=("freecad")
freecad_launchernames=("freecad")
freecad_packagenames=("freecad")
freecad_readmeline="| FreeCAD | General-purpose parametric 3D computer-aided design modeler and a building information modeling | Command \`freecad\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "

gcc_installationtype="packagemanager"
gcc_arguments=("gcc")
gcc_bashfunctions=("# colored GCC warnings and errors
export GCC_COLORS=\"error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01\"
")
gcc_packagenames=("gcc")
gcc_readmeline="| GNU C Compiler | C compiler for GNU systems | Command \`gcc\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

geany_installationtype="packagemanager"
geany_arguments=("geany")
geany_launchernames=("geany")
geany_packagenames=("geany")
geany_readmeline="| Geany | Lightweight GUI text editor using Scintilla and GTK, including basic IDE features | Command \`geany\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/geogebra/geogebra_icon.svg
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
geogebra_readmeline="| GeoGebra | ${geogebra_readmelinedescription} | Command \`geogebra\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

ghostwriter_installationtype="packagemanager"
ghostwriter_arguments=("ghostwriter")
ghostwriter_launchernames=("ghostwriter")
ghostwriter_packagenames=("ghostwriter")
ghostwriter_readmeline="| GhostWriter | Text editor without distractions. | Command \`ghostwriter, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

gimp_installationtype="packagemanager"
gimp_arguments=("gimp")
gimp_launchernames=("gimp")
gimp_packagenames=("gimp")
gimp_reameline="| Gimp | Raster graphics editor used for image manipulation and image editing, free-form drawing, transcoding between different image file formats. | Command \`gimp\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

git_installationtype="packagemanager"
git_arguments=("git")
git_packagenames=("git-all" "git-lfs")
git_readmeline="| git | Software for tracking changes in any set of files, usually used for coordinating work among programmers collaboratively developing source code during software development | Command \`git\` and \`gitk\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/github/github_icon.svg
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
github_readmeline="| GitHub | ${github_readmelinedescription} | Command \`github\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

github_desktop_installationtype="packageinstall"
github_desktop_arguments=("github_desktop")
github_desktop_launchernames=("github-desktop")
github_desktop_packagenames=("github")
github_desktop_packageurls=("https://github.com/shiftkey/desktop/releases/download/release-2.6.3-linux1/GitHubDesktop-linux-2.6.3-linux1.deb")
github_desktop_readmeline="| GitHub Desktop | GitHub Application | Command \`github-desktop\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

gitk_installationtype="packagemanager"
gitk_arguments=("gitk")
gitk_bashfunctions=("alias gitk=\"gitk --all --date-order &\"")
gitk_packagenames=("gitk")
gitk_readmeline="| Gitk | GUI for git | Command \`gitk\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/gitlab/gitlab_icon.svg
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
gitlab_readmeline="| GitLab | ${gitlab_readmelinedescription} | Command || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

gitprompt_installationtype="repositoryclone"
gitprompt_arguments=("gitprompt" "git_prompt")
gitprompt_bashfunctions=("
if [ -f ${USR_BIN_FOLDER}/gitprompt/gitprompt.sh ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source ${USR_BIN_FOLDER}/gitprompt/gitprompt.sh
fi
")
gitprompt_readmeline="| gitprompt | Special prompt in git repositories | Command \`gitprompt\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
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
Icon=${USR_BIN_FOLDER}/gmail/gmail_icon.svg
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
gmail_readmeline="| Gmail | ${gmail_readmelinedescription} | Command \`gmail\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
gnat_gps_readmeline="| GNAT | ${gnat_gps_readmelinedescription} | Command \`gnat-gps\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"


gnome_calculator_installationtype="packagemanager"
gnome_calculator_arguments=("gnome_calculator")
gnome_calculator_launchernames=("org.gnome.Calculator")
gnome_calculator_packagenames=("gnome-calculator")
gnome_calculator_readmeline="| Calculator | GUI calculator| Commmand \`calculator\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

gnome_chess_installationtype="packagemanager"
gnome_chess_arguments=("gnome_chess")
gnome_chess_launchernames=("org.gnome.Chess")
gnome_chess_packagenames=("gnome-chess")
gnome_chess_readmeline="| Chess | Plays a full game of chess against a human being or other computer program | Command \`gnome-chess\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

gnome_mahjongg_installationtype="packagemanager"
gnome_mahjongg_arguments=("gnome_mahjongg")
gnome_mahjongg_launchernames=("org.gnome.Mahjongg")
gnome_mahjongg_packagenames=("gnome-mahjongg")
gnome_mahjongg_readmeline="| Mahjongg | Implementation for GNU systems of the famous popular chinese game Mahjongg | Command \`gnome-mahjongg\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

gnome_mines_installationtype="packagemanager"
gnome_mines_arguments=("gnome_mines")
gnome_mines_launchernames=("org.gnome.Mines")
gnome_mines_packagenames=("gnome-mines")
gnome_mines_readmeline="| Mines | Implementation for GNU systems of the famous game mines | Command \`gnome-mines\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

gnome_sudoku_installationtype="packagemanager"
gnome_sudoku_arguments=("gnome_sudoku")
gnome_sudoku_launchernames=("org.gnome.Sudoku")
gnome_sudoku_packagenames=("gnome-sudoku")
gnome_sudoku_readmeline="| sudoku | Implementation for GNU systems of the famous popular mathematical game sudoku | Command \`gnome-sudoku\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

gnome_terminal_installationtype="packagemanager"
gnome_terminal_arguments=("gnome_terminal")
gnome_terminal_launchernames=("org.gnome.Terminal")
gnome_terminal_packagenames=("gnome-terminal")
gnome_terminal_readmeline="| GNOME terminal | Terminal of the system | Command \`gnome-terminal\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

gnome_tweak_tool_installationtype="packagemanager"
gnome_tweak_tool_arguments=("gnome_tweak_tool" "tweaks" "gnome_tweak" "gnome_tweak_tools" "gnome_tweaks")
gnome_tweak_tool_packagenames=("gnome-tweak-tool")
gnome_tweak_tool_launchernames=("org.gnome.tweaks")
gnome_tweak_tool_readmeline="| GNOME Tweaks | GUI for system customization | command and desktop launcher... ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

googlecalendar_installationtype="environmental"
googlecalendar_arguments=("googlecalendar" "google_calendar")
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
Icon=${USR_BIN_FOLDER}/googlecalendar/googlecalendar_icon.svg
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
googlecalendar_readmeline="| Google Calendar | ${googlecalendar_readmelinedescription} | Command \`googlecalendar\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

google_chrome_installationtype="packageinstall"
google_chrome_arguments=("google_chrome")
google_chrome_packagedependencies=("libxss1" "libappindicator1" "libindicator7")
google_chrome_packageurls=("https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb")
google_chrome_launchernames=("google-chrome")
google_chrome_keybindings=("google-chrome;<Primary><Alt><Super>c;Google Chrome")
google_chrome_readmeline="| Google Chrome | Cross-platform web browser | Command \`google-chrome\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
gpaint_readmeline="| Gpaint | Raster graphics editor similar to Microsoft Paint | Command \`gpaint\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

gparted_installationtype="packagemanager"
gparted_arguments=("gparted")
gparted_launchernames=("gparted")
gparted_packagenames=("gparted")
gparted_readmeline="| GParted | Creating, deleting, resizing, moving, checking, and copying disk partitions and their file systems | Command \`gparted\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

gvim_installationtype="packagemanager"
gvim_arguments=("gvim" "vim_gtk3")
gvim_launchernames=("gvim")
gvim_packagenames=("vim-gtk3")
gvim_readmeline="| Gvim | Vim with a built-in GUI | Command \`gvim\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
h_readmeline="| Function \`h\` | Search in your history for previous commands entered, stands by \`history | grep \"\$@\"\` | Command \`h\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"


handbrake_installationtype="packagemanager"
handbrake_arguments=("handbrake")
handbrake_launchernames=("fr.handbrake.ghb")
handbrake_packagenames=("handbrake")
handbrake_readmeline="| Handbrake | Video Transcoder | Command \`handbrake\`, Desktop and dashboard launchers || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

hard_installationtype="environmental"
hard_arguments=("hard")
hard_bashfunctions=("alias hard=\"git reset HEAD --hard\"")
hard_readmeline="| Function \`hard\` | alias for \`git reset HEAD --hard\` | <-- || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

hardinfo_installationtype="packagemanager"
hardinfo_arguments=("hardinfo")
hardinfo_packagenames=("hardinfo")
hardinfo_launchernames=("hardinfo")
hardinfo_readmeline="| Hardinfo | Check pc hardware info | Command \`hardinfo\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
history_optimization_readmeline="| history optimization | Increased the size of bash history, store multiline commands in just one line, force append and not overwrite to history, ignore repeated commands when appending to history, deleted tracking history of some simple commands: \`ls\`, \`cd\`, \`gitk\`... | <-- || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

ideac_installationtype="userinherit"
ideac_arguments=("ideac" "intellijcommunity" "intellij_community")
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
Icon=${USR_BIN_FOLDER}/ideac/bin/idea.svg
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
ideac_readmeline="| intelliJ Community | ${ideac_readmelinedescription} | Command \`ideac\`, silent alias for \`ideac\`, desktop launcher, dashboard launcher and association to \`.java\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |"

ideau_installationtype="userinherit"
ideau_arguments=("ideau" "intellijultimate" "intellij_ultimate")
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
Icon=${USR_BIN_FOLDER}/ideau/bin/idea.png
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
ideau_readmeline="| intelliJ Ultimate | ${ideau_readmelinedescription} | Command \`ideau\`, silent alias for \`ideau\`, desktop launcher, dashboard launcher and association to \`.java\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |"

inkscape_installationtype="packagemanager"
inkscape_arguments=("inkscape" "ink_scape")
inkscape_launchernames=("inkscape")
inkscape_packagenames=("inkscape")
inkscape_readmeline="| Inkscape | Vector graphics editor used to create vector images, primarily in Scalable Vector Graphics format | Command \`inkscape\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/instagram/instagram_icon.svg
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
instagram_readmeline="| Instagram | ${instagram_readmelinedescription} | Command \`instagram\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

ipe_installationtype="environmental"
ipe_arguments=("ipe")
ipe_bashfunctions=("
ipe()
{
  dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'\"' '{ print \$2 }';
}
")
ipe_readmeline="| ipe function | Returns the public IP | Command \`ipe\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

ipi_installationtype="environmental"
ipi_arguments=("ipi")
ipi_bashfunctions=("
ipi()
{
  hostname -I | awk '{print \$1}'
}
")
ipi_readmeline="| ipi function | Returns the private IP | Command \`ipi\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"


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
Icon=${USR_BIN_FOLDER}/iqmol/iqmol_icon.png
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
iqmol_readmeline="| IQmol | ${iqmol_readmelinedescription} | Command \`iqmol\`, silent alias, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

j_installationtype="environmental"
j_arguments=("j")
j_bashfunctions=("alias j=\"jobs -l\"")
j_readmeline="| Function \`j\` | alias for jobs -l | Commands \`j\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

java_installationtype="userinherit"
java_arguments=("java" "javadevelopmentkit" "java_development_kit" "java_development_kit_11" "jdk")
java_bashfunctions=("export JAVA_HOME=\"${USR_BIN_FOLDER}/jdk8\"")
java_binariesinstalledpaths=("bin/java;java")
java_compressedfiletype="z"
java_compressedfileurl="https://download.java.net/openjdk/jdk8u41/ri/openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz"
java_readmeline="| Java Development Kit 8 | Implementation of version 8 of the Java (programming language) SE Platform | Commands \`java\`, \`javac\` and \`jar\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/julia/share/icons/hicolor/scalable/apps/julia.svg
Terminal=true
Type=Application
Categories=Development;ComputerScience;Building;Science;Math;NumericalAnalysis;ParallelComputing;DataVisualization;ConsoleOnly;
")
julia_readmeline="| Julia and IJulia| ${julia_readmelinedescription} | Commands \`julia\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

jupyter_lab_installationtype="pythonvenv"
jupyter_lab_arguments=("jupyter_lab" "jupyterlab")
jupyter_lab_bashfunctions=("alias lab=\"jupyter-lab\"")
jupyter_lab_binariesinstalledpaths=("bin/jupyter-lab;jupyter-lab" "bin/jupyter;jupyter" "bin/ipython;ipython" "bin/ipython3;ipython3")
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
Icon=${USR_BIN_FOLDER}/jupyter_lab/share/icons/hicolor/scalable/apps/notebook.svg
Exec=jupyter-lab &
")
jupyter_lab_manualcontentavailable="1;1;0"
jupyter_lab_pipinstallations=("jupyter jupyterlab jupyterlab-git jupyterlab_markup" "bash_kernel" "pykerberos pywinrm[kerberos]" "powershell_kernel" "iarm" "ansible-kernel" "kotlin-jupyter-kernel" "vim-kernel" "theme-darcula")
jupyter_lab_pythoncommands=("bash_kernel.install" "iarm_kernel.install" "ansible_kernel.install" "vim_kernel.install")  # "powershell_kernel.install --powershell-command powershell"  "kotlin_kernel fix-kernelspec-location"
jupyter_lab_readmeline="| Jupyter Lab | ${jupyter_lab_readmelinedescription} | alias \`lab\`, commands \`jupyter-lab\`, \`jupyter-lab\`, \`ipython\`, \`ipython3\`, desktop launcher and dashboard launcher. Recognized programming languages: Python, Ansible, Bash, IArm, Kotlin, PowerShell, Vim. || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/keep/keep_icon.svg
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
keep_readmeline="| Google Keep | ${keep_readmelinedescription} | Command \`keep\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

L_installationtype="environmental"
L_arguments=("L")
L_bashfunctions=("
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
  finaldisplay=\"\${finaldisplay}\"
  echo \"\$finaldisplay\"
}
")
L_readmeline="| Function \`L\` | Function that lists files in a directory, but listing the directory sizes | Function \`L\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

l_installationtype="environmental"
l_arguments=("l")
l_bashfunctions=("alias l=\"ls -lAh --color=auto\"")
l_readmeline="| Function \`l\` | alias for \`ls\` | command \`l\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
latex_packagenames=("texlive-latex-extra" "texmaker")
latex_readmeline="| LaTeX | ${latex_readmelinedescription} | Command \`tex\` (LaTeX compiler) and \`texmaker\` (LaTeX IDE), desktop launchers for \`texmaker\` and LaTeX documentation ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

libgtkglext1_installationtype="packagemanager"
libgtkglext1_arguments=("libgtkglext1" "anydesk_dependencies")
libgtkglext1_packagenames=("libgtkglext1")
libgtkglext1_readmeline="| libgtkglext1 | Anydesk dependency | Used when Anydesk is run ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

libkrb5_dev_installationtype="packagemanager"
libkrb5_dev_arguments=("libkrb5_dev" "kerberos_dependencies")
libkrb5_dev_packagenames=("libkrb5-dev")
libkrb5_dev_readmeline="| libkrb5-dev | Kerberos dependency | Used when Jupiter Lab is run ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

libxcb_xtest0_installationtype="packagemanager"
libxcb_xtest0_arguments=("libxcb_xtest0")
libxcb_xtest0_packagenames=("libxcb-xtest0")
libxcb_xtest0_readmeline="| libxcb-xtest0 | Zoom dependency | Used when Zoom is run ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

lolcat_installationtype="packagemanager"
lolcat_arguments=("lolcat")
lolcat_bashfunctions=("alias lol=\"lolcat\"")
lolcat_packagenames=("lolcat")
lolcat_readmeline="| lolcat | Same as the command \`cat\` but outputting the text in rainbow color and concatenate string | command \`lolcat\`, alias \`lol\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

mdadm_installationtype="packagemanager"
mdadm_arguments=("mdadm")
mdadm_packagenames=("mdadm")
mdadm_readmeline="| mdadm | Manage RAID systems | Command \`mdadm\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

megasync_installationtype="packageinstall"
megasync_arguments=("megasync" "mega")
megasync_packagedependencies=("nautilus" "libc-ares2" "libmediainfo0v5" "libqt5x11extras5" "libzen0v5")
megasync_packageurls=("https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/megasync_4.4.0-1.1_amd64.deb" "https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/nemo-megasync_4.0.2_amd64.deb")
megasync_launchernames=("megasync")
megasync_readmeline="| MegaSync | Synchronises folders between your computer and your MEGA Cloud Drive | Command \`megasync\`, desktop launcher, dashboard launcher and integration with \`nemo\` file explorer ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

mendeley_dependencies_installationtype="packagemanager"
mendeley_dependencies_arguments=("mendeley_dependencies" "mendeley_desktop_dependencies")
mendeley_dependencies_packagedependencies=("gconf2" "qt5-default" "qt5-doc" "qt5-doc-html" "qtbase5-examples" "qml-module-qtwebengine")
mendeley_dependencies_readmeline="| MendeleyDependencies | Installs Mendeley Desktop dependencies \`gconf2\`, \`qt5-default\`, \`qt5-doc\`, \`qt5-doc-html\`, \`qtbase5-examples\` and \`qml-module-qtwebengine\` | Used when installing Mendeley and other dependent software || <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"

mendeley_installationtype="userinherit"
mendeley_arguments=("mendeley")
mendeley_compressedfileurl="https://www.mendeley.com/autoupdates/installer/Linux-x64/stable-incoming"
mendeley_compressedfiletype="j"
mendeley_binariesinstalledpaths="bin/mendeleydesktop;mendeley"
mendeley_readmelinedescription="It is most known for its reference manager which is used to manage and share research papers and generate bibliographies for scholarly articles"
mendeley_readmeline="| Mendeley | ${mendeley_readmelinedescription} | Command \`mendeley\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
mendeley_launchercontents=("
[Desktop Entry]
Name=Mendeley Desktop
GenericName=Research Paper Manager
Comment=${mendeley_readmelinedescription}
Exec=mendeley %f
Icon=${USR_BIN_FOLDER}/mendeley/share/icons/hicolor/128x128/apps/mendeleydesktop.png
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
msttcorefonts_readmeline="| font Msttcorefonts | Windows classic fonts | Install mscore fonts ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "

mvn_installationtype="userinherit"
mvn_arguments=("mvn")
mvn_binariesinstalledpaths=("bin/mvn;mvn")
mvn_compressedfiletype="z"
mvn_compressedfileurl="https://ftp.cixug.es/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz"
mvn_readmeline="| Maven | Build automation tool used primarily for Java projects | Command \`mvn\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |"

nautilus_installationtype="packagemanager"
nautilus_arguments=("nautilus")
nautilus_bashfunctions=("
xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search
gsettings set org.gnome.desktop.background show-desktop-icons true
xdg-mime default org.gnome.Nautilus.desktop inode/directory
")
nautilus_launchernames=("org.gnome.Nautilus")
nautilus_packagenames=("nautilus")
nautilus_readmeline="| Nautilus | Standard file and desktop manager | Command \`nautilus\` Desktop launcher and dashboard launcher for the file manager ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

nedit_installationtype="packagemanager"
nedit_arguments=("nedit")
nedit_packagenames=("nedit")
nedit_launchernames=("nedit")
nedit_readmeline="| NEdit | Multi-purpose text editor and source code editor | Command \`nedit\` desktop launcher, dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

nemo_installationtype="packagemanager"
nemo_arguments=("nemo" "nemo_desktop" "nemodesktop")
nemo_bashfunctions=("
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
gsettings set org.gnome.desktop.background show-desktop-icons false
gsettings set org.nemo.desktop show-desktop-icons true
""
alias nemo=\"nohup nemo . &>/dev/null &\"
")
nemo_packagedependencies=("dconf-editor" "gnome-tweak-tool")
#nemo_flagsoverride="0;;;;;"
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
Exec=nemo-desktop
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
nemo_readmeline="| Nemo Desktop | Access and organise files | Command \`nemo\` for the file manager, and \`nemo-desktop\` for the desktop manager service. Desktop launcher and dashboard launcher for the file manager ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/netflix/netflix_icon.svg
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
netflix_readmeline="| Netflix | ${netflix_readmelinedescription} | Command \`netflix\`. Desktop launcher and dashboard launcher for the file manager | --netflix --Netflix |  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

net_tools_installationtype="packagemanager"
net_tools_arguments=("net_tools")
net_tools_bashfunctions=("
alias ports=\"netstat -tulanp\"
alias nr=\"net-restart\
")
net_tools_packagenames=("net-tools")
net_tools_readmeline="| net-tools | GUI network interfaces. *We recommend this explorer to view correctly the launchers* | Command \`net-tools\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

npm_installationtype="userinherit"
npm_arguments=("npm")
npm_binariesinstalledpaths=("bin/node;node" "bin/npm;npm" "bin/npx;npx")
npm_compressedfiletype="J"
npm_compressedfileurl="https://nodejs.org/dist/v14.17.0/node-v14.17.0-linux-x64.tar.xz"
npm_readmeline="| NodeJS npm | JavaScript packagemanager for the developers. | Command \`node\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

notepadqq_installationtype="packagemanager"
notepadqq_arguments=("notepadqq")
notepadqq_packagenames=("notepadqq")
notepadqq_launchernames=("notepadqq")
notepadqq_readmeline="| Notepadqq | Text editor that is designed by developers for the developers. It supports more than 100 programming languages | Command \`notepadqq\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
o_readmeline="| Function \`o\` | Alias for \`nemo-desktop\` | Alias \`o\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"


obs_studio_installationtype="packagemanager"
obs_studio_arguments=("obs_studio" "obs" "obsstudio")
obs_studio_launchernames=("com.obsproject.Studio")
obs_studio_packagedependencies=("ffmpeg")
obs_studio_packagenames=("obs-studio")
obs_studio_readmeline="| OBS | Streaming and recording program | Command \`obs\`, desktop launcher and dashboard launcher. ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

okular_installationtype="packagemanager"
okular_arguments=("okular")
okular_launchernames=("org.kde.okular")
okular_packagenames=("okular")
okular_readmeline="| Okular | PDF viewer | Command \`okular\`, desktop launcher and dashboard launcher ||   <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/onedrive/onedrive_icon.svg
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
onedrive_readmeline="| OneDrive | ${onedrive_readmelinedescription} | Command \`onedrive\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

openoffice_installationtype="packageinstall"
openoffice_arguments=("openoffice" "open_office")
openoffice_compressedfileurl="https://downloads.sourceforge.net/project/openofficeorg.mirror/4.1.9/binaries/en-US/Apache_OpenOffice_4.1.9_Linux_x86-64_install-deb_en-US.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fopenofficeorg.mirror%2Ffiles%2F4.1.9%2Fbinaries%2Fen-US%2FApache_OpenOffice_4.1.9_Linux_x86-64_install-deb_en-US.tar.gz%2Fdownload&ts=1614201028"
openoffice_compressedfiletype="z"
openoffice_launchernames=("openoffice4-base" "openoffice4-calc" "openoffice4-draw" "openoffice4-math" "openoffice4-writer")
openoffice_readmeline="| OpenOffice | Office suite for open-source systems | Command \`openoffice4\` in PATH, desktop launchers for \`base\`, \`calc\`, \`draw\`, \`math\` and \`writer\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
#openoffice_associatedfiletypes=("")

openssl102_installationtype="packageinstall"
openssl102_arguments=("openssl102")
openssl102_packageurls=("http://security.debian.org/debian-security/pool/updates/main/o/openssl1.0/libssl1.0.2_1.0.2u-1~deb9u4_amd64.deb")
openssl102_readmeline="| openssl1.0 | RStudio dependency | Used for running rstudio ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/outlook/outlook_icon.svg
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
outlook_readmeline="| Outlook | ${outlook_readmelinedescription} | Command \`outlook\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

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
Icon=${USR_BIN_FOLDER}/overleaf/overleaf_icon.svg
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
overleaf_readmeline="| Overleaf | ${overleaf_readmelinedescription} | Command \`overleaf\`, desktop launcher and dashboard launcher ||   <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

pacman_installationtype="packagemanager"
pacman_arguments=("pacman")
pacman_launchernames=("pacman")
pacman_packagenames=("pacman")
pacman_readmeline="| Pac-man | Implementation of the classical arcade game | Command \`pacman\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

parallel_installationtype="packagemanager"
parallel_arguments=("parallel" "gnu_parallel" "gnuparallel")
parallel_packagenames=("parallel")
parallel_readmeline="| GNUparallel | Command-line driven utility for Linux and other Unix-like operating systems which allows the user to execute shell scripts or commands in parallel | Command \`parallel\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

pdfgrep_installationtype="packagemanager"
pdfgrep_arguments=("pdfgrep")
pdfgrep_packagenames=("pdfgrep")
pdfgrep_readmeline="| pdfgrep | CLI utility that makes it possible to search for text in a PDF file without opening the file | Command \`pdfgrep\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

pgadmin_installationtype="pythonvenv"
pgadmin_arguments=("pgadmin" "pgadmin4")
pgadmin_binariesinstalledpaths=("lib/python3.8/site-packages/pgadmin4/pgAdmin4.py;pgadmin")
pgadmin_confoverride_path="lib/python3.8/site-packages/pgadmin4/config_local.py"
pgadmin_confoverride_content=("
import os
DATA_DIR = os.path.realpath(os.path.expanduser(u'${USR_BIN_FOLDER}/pgadmin'))
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
Icon=${USR_BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgadmin/static/img/logo-256.png
Exec=bash ${USR_BIN_FOLDER}/pgadmin/pgadmin_exec.sh
")
pgadmin_manualcontentavailable="0;1;0"
pgadmin_pipinstallations=("pgadmin4")
pgadmin_readmeline="| pgAdmin | ${pgadmin_readmelinedescription} | Command \`pgadmin4\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

php_installationtype="packagemanager"
php_arguments=("php")
php_packagenames=("php" "libapache2-mod-php")
php_readmeline="| php | Programming language | Command \`php\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

pluma_installationtype="packagemanager"
pluma_arguments=("pluma")
pluma_bashfunctions=("
pluma()
{
  nohup pluma \"\$1\" &>/dev/null &
}
")
pluma_launchernames=("pluma")
pluma_packagenames=("pluma")
pluma_readmeline="| pluma | Fork of gedit 2.0 that supports many plugins and new features | Command \`pluma\`, desktop launcjer and dashboard launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"

postman_installationtype="userinherit"
_arguments=("")
postman_compressedfileurl="https://dl.pstmn.io/download/latest/linux64"
postman_compressedfiletype="z"
postman_binariesinstalledpaths=("Postman;postman")
postman_readmelinedescription="Application to maintain and organize collections of REST API calls"
postman_readmeline="| Postman | ${postman_readmelinedescription} | Command \`postman\`, desktop launcher and dashboard launcher  ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"
postman_launchercontents=("
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=postman
Comment=${postman_readmelinedescription}
Icon=${USR_BIN_FOLDER}/postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
")

presentation_installationtype="environmental"
_arguments=("")
presentation_url="https://docs.google.com/presentation/"
presentation_downloads=("https://upload.wikimedia.org/wikipedia/commons/1/16/Google_Slides_2020_Logo.svg;presentation_icon.svg")
presentation_bashfunctions=("alias presentation=\"nohup xdg-open ${presentation_url} &>/dev/null &\"")
presentation_readmelinedescription="Google Presentation opening in Chrome"
presentation_readmeline="| Presentation | ${presentation_readmelinedescription} | Command \`presentation\`, desktop launcher and dashboard launcher||  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"
presentation_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=D${presentation_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${presentation_url}
Icon=${USR_BIN_FOLDER}/presentation/presentation_icon.svg
GenericName=Document
Keywords=presentations;
MimeType=
Name=Google Presentation
StartupNotify=true
StartupWMClass=Google Presentation
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0")

prompt_installationtype="environmental"
_arguments=("")
prompt_readmeline="| prompt | Installs a new colourful prompt on terminal window including and upgrading the default ones in Ubuntu | Adds a personalized prompt that shows the date, return code of last executed program, user, group and working directory. It also changes the prompt colour of introduced text to green. It changes the terminal windows title, adds colourful aliases and ensures completion || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
prompt_bashfunctions=("
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
    PS1=\"\\[\\\e[1;37m\\]\\\\\\d \\\\\\\t \\[\\\e[0;32m\\]\\\\\u\[\\\e[4;35m\\]@\\[\\\e[0;36m\\]\\\\\\H\\[\\\e[0;33m\\] \\\\\\w\\[\\\e[0;32m\\] \\\\\\\$ \\[\\033[0m\\]\"
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


")

psql_installationtype="packagemanager"
_arguments=("")
psql_packagedependencies=("libc6-i386" "lib32stdc++6" "libc6=2.31-0ubuntu9.2")
psql_packagenames=("postgresql-client-12" "postgresql-12" "libpq-dev" "postgresql-server-dev-12")
psql_readmeline="| PostGreSQL | Installs \`psql\`|  Command \`psql\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

pull_installationtype="environmental"
_arguments=("")
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
pull_readmeline="| \`pull\` | Alias for \`git pull\`|  Command \`pull\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

push_installationtype="environmental"
_arguments=("")
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
push_readmeline="| \`push\` | Alias for \`git push\`|  Command \`push\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

pycharm_installationtype="userinherit"
_arguments=("")
pycharm_keybinds=("pycharm;<Primary><Alt><Super>p;Pycharm")
pycharm_compressedfileurl="https://download.jetbrains.com/python/pycharm-community-2021.1.1.tar.gz"
pycharm_bashfunctions=("alias pycharm=\"pycharm . &>/dev/null &\"")
pycharm_compressedfiletype="z"
pycharm_binariesinstalledpaths=("bin/pycharm.sh;pycharm")
pycharm_associatedfiletypes=("text/sh" "text/x-python" "text/x-python3")
pycharm_readmelinedescription="Integrated development environment used in computer programming"
pycharm_readmeline="| Pycharm Community | ${pycharm_readmelinedescription} | Command \`pycharm\`, silent alias for \`pycharm-pro\`, desktop launcher, dashboard launcher, associated to the mime type of \`.py\` files  || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
pycharm_launchercontents=("
[Desktop Entry]
Actions=NewWindow;
Categories=programming;dev;
Comment=${pycharm_readmelinedescription}
Encoding=UTF-8
Exec=pycharm %F
GenericName=Pycharm
Icon=${USR_BIN_FOLDER}/pycharm/bin/pycharm.png
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
Icon=${USR_BIN_FOLDER}/pycharm/bin/pycharm.png")

pycharmpro_installationtype="userinherit"
_arguments=("")
pycharmpro_compressedfileurl="https://download.jetbrains.com/python/pycharm-professional-2020.3.2.tar.gz"
pycharmpro_bashfunctions=("alias pycharmpro=\"pycharmpro . &>/dev/null &\"")
pycharmpro_compressedfiletype="z"
pycharmpro_binariesinstalledpaths=("bin/pycharm.sh;pycharmpro")
pycharmpro_associatedfiletypes=("text/sh" "text/x-python" "text/x-python3")
pycharmpro_readmelinedescription="Integrated development environment used in computer programming"
pycharmpro_readmeline="| Pycharm Pro | ${pycharmpro_readmelinedescription} | Command \`pycharm-pro\`, silent alias for \`pycharm-pro\`, desktop launcher, dashboard launcher, associated to the mime type of \`.py\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
pycharmpro_launchercontents=("
[Desktop Entry]
Categories=programming;dev;
Comment=${pycharmpro_readmelinedescription}
Encoding=UTF-8
Exec=pycharmpro %F
GenericName=Pycharm Pro
Icon=${USR_BIN_FOLDER}/pycharmpro/bin/pycharm.png
Keywords=dev;programming;python;
MimeType=
Name=PyCharm Professional
StartupNotify=true
StartupWMClass=jetbrains-pycharm
Terminal=false
TryExec=pycharmpro
Type=Application
Version=1.0")

pypy3_installationtype="userinherit"
_arguments=("")
pypy3_compressedfileurl="https://downloads.python.org/pypy/pypy3.6-v7.3.1-linux64.tar.bz2"
pypy3_compressedfiletype="j"
pypy3_manualcontentavailable="0;1;0"
pypy3_binariesinstalledpaths=("bin/pypy3;pypy3" "bin/pip3.6;pypy3-pip")
pypy3_readmeline="| pypy3 | Faster interpreter for the Python3 programming language | Commands \`pypy3\` and \`pypy3-pip\` in the PATH || <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"

pypy3_dependencies_installationtype="packagemanager"
_arguments=("")
pypy3_dependencies_packagenames=("pkg-config" "libfreetype6-dev" "libpng-dev" "libffi-dev")
pypy3_dependencies_readmeline="| pypy3_dependencies | Dependencies to run pypy3 | Libraries \`pkg-config\`, \`libfreetype6-dev\`, \`libpng-dev\` and \`libffi-dev\` used when deploying \`pypy\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

python3_installationtype="packagemanager"
_arguments=("")
python3_packagenames=("python-dev" "python3-dev" "python3-pip" "python3-venv" "python3-wheel" "python3.8-venv")  # "python3-pyqt5" "python3-pyqt4" "python-qt4"
python3_readmeline="| Python3 | Interpreted, high-level and general-purpose programming language | Commands \`python\`, \`python3\`, \`pip3\` and Function \`v\` is for activate/deactivate python3 virtual environments (venv) can be used as default \`v\` as a command creates the /venv/ environment we can activate/deactivate new or existing virtual environments, command \`v namevenv\` creates /namevenv/ we can activate the virtual environment again using \`v namenv\` or deactivate same again, using \`v namenv\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
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

R_installationtype="packagemanager"
_arguments=("")
R_packagenames=("r-base")
R_packagedependencies=("libzmq3-dev" "python3-zmq")
R_launchernames=("R")
R_readmeline="| R | Programming language | Commands \`R\`, Dashboard Launcher, Desktop Launcher|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
R_jupyter_lab_function=("
install.packages('IRkernel')
install.packages(c('rzmq', 'repr', 'uuid','IRdisplay'),
                  repos = c('http://irkernel.github.io/',
                  getOption('repos')),
                  type = 'source')
IRkernel::installspec()
")

reddit_installationtype="environmental"
_arguments=("")
reddit_url="https://www.reddit.com/"
reddit_downloads=("https://duckduckgo.com/i/b6b8ccc2.png;reddit_icon.svg")
reddit_bashfunctions=("alias reddit=\"nohup xdg-open ${reddit_url} &>/dev/null &\"")
reddit_readmelinedescription="Opens Reddit in Chrome"
reddit_readmeline="| Reddit | ${reddit_readmelinedescription} | Commands \`reddit\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
reddit_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${reddit_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${reddit_url}
Icon=${USR_BIN_FOLDER}/reddit/reddit_icon.svg
GenericName=reddit
Keywords=reddit
MimeType=
Name=Reddit
StartupNotify=true
StartupWMClass=Reddit
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0")

remmina_installationtype="packagemanager"
_arguments=("")
remmina_packagenames=("remmina")
remmina_launchernames=("org.remmina.Remmina")
remmina_readmeline="| Remmina | Remote Desktop Contol | Commands \`remmina\`, Desktop launcher and Icon || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "

rstudio_installationtype="userinherit"
_arguments=("")
rstudio_compressedfileurl="https://download1.rstudio.org/desktop/debian9/x86_64/rstudio-1.4.1717-amd64-debian.tar.gz"
rstudio_compressedfiletype="z"
rstudio_binariesinstalledpaths=("bin/rstudio;rstudio")
rstudio_associatedfiletypes=("text/plain")
rstudio_bashfunctions=("alias rstudio=\"nohup rstudio &>/dev/null &\"")
rstudio_readmelinedescription="Default application for .R files "
rstudio_readmeline="| RStudio | ${rstudio_readmelinedescription} | Commands \`rstudio\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  "
rstudio_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${rstudio_readmelinedescription}
Encoding=UTF-8
Exec=rstudio
GenericName=RStudio
Icon=${USR_BIN_FOLDER}/rstudio/www/images/favicon.ico
Keywords=rstudio
MimeType=text/plain;
Name=RStudio
StartupNotify=true
StartupWMClass=RStudio
Terminal=false
TryExec=rstudio
Type=Application
Version=1.0")

rsync_installationtype="packagemanager"
_arguments=("")
rsync_packagedependencies=("canberra-gtk-module")
rsync_packagenames=("rsync" "grsync")
rsync_launchernames=("grsync")
rsync_bashfunctions=("alias rs=\"rsync -av --progress\"")
rsync_readmeline="| Grsync | Software for file/folders synchronization | Commands \`grsync\`, desktop launcher and \`rsync\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

rustc_installationtype="packagemanager"
_arguments=("")
rustc_packagenames=("rustc")
rustc_packagedependencies=("cmake" "build-essential")
rustc_readmeline="| Rust | Programming Language | Installs \`rustc\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
# rustc_url=("https://sh.rustup.rs")

s_installationtype="environmental"
_arguments=("")
s_readmeline="| Function \`s\` | Function to execute any program silently and in the background | Function \`s \"command\"\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
s_bashfunctions=("
s()
{
  \"\$@\" &>/dev/null &
}
")

scala_installationtype="packagemanager"
_arguments=("")
scala_packagenames=("scala")
scala_readmeline="| Scala | Programming language | Command \`scala\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

screenshots_installationtype="environmental"
_arguments=("")
screenshots_readmeline="| Screenshots | Takes a screenshot and saves it to custom ~/Images/screenshots folder and save it to the clipboard for pasting | Commands \`screenshot-full\` \`screenshot-window\` \`screenshot-area\`||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
screenshots_bashfunctions=("

screenshot-area()
{
  mkdir -p \"${XDG_PICTURES_DIR}/screenshots\"
  local -r screenshotname=\"Screenshot-\$(date +%Y-%m-%d-%H:%M:%S).png\"
  gnome-screenshot -a -f \"${XDG_PICTURES_DIR}/screenshots/\$screenshotname\" && xclip -in -selection clipboard -target image/png \"${XDG_PICTURES_DIR}/screenshots/\$screenshotname\" && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga
}

screenshot-full()
{
  mkdir -p \"${XDG_PICTURES_DIR}/screenshots\"
  local -r screenshotname=\"Screenshot-\$(date +%Y-%m-%d-%H:%M:%S).png\"
  gnome-screenshot -f \"${XDG_PICTURES_DIR}/screenshots/\$screenshotname\" && xclip -in -selection clipboard -target image/png \"${XDG_PICTURES_DIR}/screenshots/\$screenshotname\" && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga
}

screenshot-window()
{
  mkdir -p \"${XDG_PICTURES_DIR}/screenshots\"
  local -r screenshotname=\"Screenshot-\$(date +%Y-%m-%d-%H:%M:%S).png\"
  gnome-screenshot -w -f \"${XDG_PICTURES_DIR}/screenshots/\$screenshotname\" && xclip -in -selection clipboard -target image/png \"${XDG_PICTURES_DIR}/screenshots/\$screenshotname\" && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga
}

")

shortcuts_installationtype="environmental"
_arguments=("")
shortcuts_readmeline="| shortcuts | Installs custom key commands | variables... (\$DESK...) || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
shortcuts_bashfunctions=("DESK=${XDG_DESKTOP_DIR}
FONTS=${FONTS_FOLDER}
AUTOSTART=${AUTOSTART_FOLDER}
DOWNLOAD=${XDG_DOWNLOAD_DIR}
DOCUMENTS=${XDG_DOCUMENTS_DIR}
BIN=${USR_BIN_FOLDER}
LAUNCHERS=${ALL_USERS_LAUNCHERS_DIR}
PERSONAL_LAUNCHERS=${PERSONAL_LAUNCHERS_DIR}
FUNCTIONSD=${BASH_FUNCTIONS_FOLDER}
FUNCTIONS=${BASH_FUNCTIONS_PATH}
PICTURES=${XDG_PICTURES_DIR}
TEMPLATES=${XDG_TEMPLATES_DIR}
MUSIC=${XDG_MUSIC_DIR}
TRASH=${HOME_FOLDER}/.local/share/Trash/
CUSTOMIZER=${DIR}
VIDEOS=${XDG_VIDEOS_DIR}
GIT=${XDG_DESKTOP_DIR}/git
if [ ! -d \$GIT ]; then
  mkdir -p \$GIT
fi
")

shotcut_installationtype="packagemanager"
_arguments=("")
shotcut_packagenames=("shotcut")
shotcut_readmelinedescription="Cross-platform video editing"
shotcut_readmeline="| ShotCut | ${shotcut_readmelinedescription} | Command \`shotcut\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
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

shotwell_installationtype="packagemanager"
_arguments=("")
shotwell_packagenames=("shotwell")
shotwell_launchernames=("shotwell")
shotwell_readmeline="| Shotwell | Cross-platform video editing | Command \`shotwell\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

skype_installationtype="packageinstall"
_arguments=("")
skype_packageurls=("https://go.skype.com/skypeforlinux-64.deb")
skype_launchernames=("skypeforlinux")
skype_readmeline="| Skype | Call & conversation tool service | Icon Launcher... ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"

slack_installationtype="packageinstall"
_arguments=("")
slack_repository=("https://downloads.slack-edge.com/linux_releases/slack-desktop-4.11.1-amd64.deb")
slack_launchernames=("slack")
slack_readmeline="| Slack | Platform to coordinate your work with a team | Icon Launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"

sonic_pi_installationtype="packagemanager"
_arguments=("")
sonic_pi_packagenames=("sonic-pi")
sonic_pi_launchernames=("sonic-pi")
sonic_pi_readmeline="| Sonic Pi | programming language that ouputs sounds as compilation product | Command \`sonic-pi\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "

spotify_installationtype="packageinstall"
_arguments=("")
spotify_packageurls=("http://repository.spotify.com/pool/non-free/s/spotify-client/spotify-client_1.1.56.595.g2d2da0de_amd64.deb")
spotify_launchernames=("spotify")
spotify_bashfunctions=("alias spotify=\"spotify &>/dev/null &\"")
spotify_readmeline="| Spotify | Music streaming service | Command \`spotify\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "

spreadsheets_installationtype="environmental"
_arguments=("")
spreadsheets_url="https://docs.google.com/spreadsheets/"
spreadsheets_downloads=("https://upload.wikimedia.org/wikipedia/commons/a/ae/Google_Sheets_2020_Logo.svg;spreadsheets_icon.svg")
spreadsheets_bashfunctions=("alias spreadsheets=\"nohup xdg-open ${spreadsheets_url} &>/dev/null &\"")
spreadsheets_readmelinedescription="Google Spreadsheets opening in Chrome"
spreadsheets_readmeline="| Spreadsheets | ${spreadsheets_readmelinedescription} | Command \`spreadsheets\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
spreadsheets_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${spreadsheets_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${spreadsheets_url}
Icon=${USR_BIN_FOLDER}/spreadsheets/spreadsheets_icon.svg
GenericName=Spreadsheets
Keywords=spreadsheets;
MimeType=
Name=Google Spreadsheets
StartupNotify=true
StartupWMClass=Google Spreadsheets
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0")

status_installationtype="environmental"
_arguments=("")
status_bashfunctions=("alias status=\"git status\"")
status_readmeline="| status | \`git status\` | Command \`status\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

steam_installationtype="packageinstall"
_arguments=("")
steam_packageurls=("https://steamcdn-a.akamaihd.net/client/installer/steam.deb")
steam_launchernames=("steam")
steam_readmeline="| Steam | Video game digital distribution service | Command \`steam\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

studio_installationtype="userinherit"
_arguments=("")
studio_compressedfileurl="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.1.2.0/android-studio-ide-201.7042882-linux.tar.gz"
studio_compressedfiletype="z"
studio_binariesinstalledpaths=("bin/studio.sh;studio")
studio_bashfunctions=("alias studio=\"studio . &>/dev/null &\"")
studio_readmelinedescription="Development environment for Google's Android operating system"
studio_readmeline="| Android Studio | ${studio_readmelinedescription} | Command \`studio\`, alias \`studio\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
studio_launchercontents=("
[Desktop Entry]
Categories=Development;IDE;
Comment=${studio_readmelinedescription}
Encoding=UTF-8
Exec=studio %F
GenericName=studio
Icon=${USR_BIN_FOLDER}/studio/bin/studio.svg
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

sublime_keybinds=("sublime;<Primary><Alt><Super>s;Sublime Text")
sublime_installationtype="userinherit"
_arguments=("")
sublime_compressedfileurl="https://download.sublimetext.com/sublime_text_3_build_3211_x64.tar.bz2"
sublime_bashfunctions=("alias sublime=\"sublime . &>/dev/null &\"")
sublime_compressedfiletype="j"
sublime_binariesinstalledpaths=("sublime_text;sublime")
sublime_associatedfiletypes=("text/x-sh" "text/x-c++hdr" "text/x-c++src" "text/x-chdr" "text/x-csrc" "text/x-python" "text/x-python3")
sublime_readmelinedescription="Source code editor with an emphasis on source code editing"
sublime_readmeline="| Sublime | ${sublime_readmelinedescription} | Command \`sublime\`, silent alias for \`sublime\`, desktop launcher, dashboard launcher, associated with the mime type of \`.c\`, \`.h\`, \`.cpp\`, \`.hpp\`, \`.sh\` and \`.py\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
sublime_launchercontents=("
[Desktop Entry]
Categories=;
Comment=${sublime_readmelinedescription}
Encoding=UTF-8
Exec=sublime %F
GenericName=Text Editor, programming...
Icon=$HOME/.bin/sublime/Icon/256x256/sublime-text.png
Keywords=subl;sublime;
MimeType=
Name=Sublime Text
StartupNotify=true
StartupWMClass=Sublime
Terminal=false
TryExec=sublime
Type=Application
Version=1.0")

synaptic_installationtype="packagemanager"
_arguments=("")
synaptic_packagenames=("synaptic")
synaptic_launchernames=("synaptic")
synaptic_readmelinedescription="Graphical installation manager to install, remove and upgrade software packages"
synaptic_readmeline="| Synaptic | ${synaptic_readmelinedescription} | Command \`synaptic\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
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
_arguments=("")
sysmontask_repositoryurl="https://github.com/KrispyCamel4u/SysMonTask.git"
sysmontask_manualcontentavailable="0;1;0"
sysmontask_launchernames=("SysMonTask")
sysmontask_bashfunctions=("alias sysmontask=\"nohup sysmontask &>/dev/null &\"")
sysmontask_readmeline="| Sysmontask | Control panel for linux | Command \`sysmontask\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "

system_fonts_installationtype="environmental"
_arguments=("")
system_fonts_manualcontentavailable="0;1;0"
system_fonts_readmeline="| Change default fonts | Sets pre-defined fonts to desktop environment. | A new set of fonts is updated in the system's screen. || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "

teamviewer_installationtype="packageinstall"
_arguments=("")
teamviewer_packageurls=("https://download.teamviewer.com/download/linux/teamviewer_amd64.deb")
teamviewer_launchernames=("com.teamviewer.TeamViewer")
teamviewer_readmeline="| Team Viewer | Video remote pc control | Command \`teamviewer\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "

teams_installationtype="packageinstall"
_arguments=("")
teams_packageurls=("https://go.microsoft.com/fwlink/p/?LinkID=2112886&clcid=0x40a&culture=es-es&country=ES")
teams_launchernames=("teams")
teams_readmeline="| Microsoft Teams | Video Conference, calls and meetings | Command \`teams\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "

telegram_installationtype="userinherit"
_arguments=("")
telegram_downloads=("https://telegram.org/img/t_logo.svg?1;telegram_icon.svg")
telegram_compressedfileurl="https://telegram.org/dl/desktop/linux"
telegram_compressedfiletype="J"
telegram_binariesinstalledpaths=("Telegram;telegram")
telegram_readmelinedescription="Cloud-based instant messaging software and application service"
telegram_readmeline="| Telegram | ${telegram_readmelinedescription} | Command \`telegram\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
telegram_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${telegram_readmelinedescription}
Encoding=UTF-8
Exec=telegram -- %u
GenericName=Telegram
Icon=${USR_BIN_FOLDER}/telegram/telegram_icon.svg
Keywords=telegram;
MimeType=x-scheme-handler/tg;
Name=Telegram
StartupNotify=true
StartupWMClass=Telegram
Terminal=false
TryExec=telegram
Type=Application
Version=1.0")

templates_installationtype="environmental"
_arguments=("")
templates_readmeline="| Templates | Different collection of templates for starting code projects: Python3 script (\`.py\`), Bash script (\`.sh\`), LaTeX document (\`.tex\`), C script (\`.c\`), C header script (\`.h\`), makefile example (\`makefile\`) and empty text file (\`.txt\`) | In the file explorer, right click on any folder to see the contextual menu of \"create document\", where all the templates are located || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
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

terminal_background_installationtype="environmental"
_arguments=("")
terminal_background_manualcontentavailable="0;1;0"
terminal_background_readmeline="| Terminal background | Change background of the terminal to black | Every time you open a terminal || <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"

terminator_installationtype="packagemanager"
_arguments=("")
terminator_packagenames=("terminator")
terminator_launchernames=("terminator")
terminator_readmeline="| Terminator | Terminal emulator for Linux programmed in Python | Command \`terminator\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

thunderbird_installationtype="packagemanager"
_arguments=("")
thunderbird_packagenames=("thunderbird")
thunderbird_launchernames=("thunderbird")
thunderbird_readmeline="| Thunderbird | Email, personal information manager, news, RSS and chat client | Command \`thunderbird\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

tilix_installationtype="packagemanager"
_arguments=("")
tilix_packagenames=("tilix")
tilix_launchernames=("com.gexperts.Tilix")
tilix_readmeline="| Tilix | Advanced GTK3 tiling terminal emulator | Command \`tilix\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

tmux_installationtype="packagemanager"
_arguments=("")
tmux_packagenames=("tmux")
tmux_readmelinedescription="Terminal multiplexer for Unix-like operating systems"
tmux_readmeline="| Tmux | ${tmux_readmelinedescription} | Command \`tmux\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
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

tomcat_installationtype="userinherit"
_arguments=("")
tomcat_compressedfileurl="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.43/bin/apache-tomcat-9.0.43.tar.gz"
tomcat_compressedfiletype="z"
tomcat_readmeline="| Apache Tomcat 9.0.43 | Open-source server to run web apps written in Jakarta Server Pages | Tomcat available in \${USER_BIN_FOLDER} to deploy web apps || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li>|"

tor_installationtype="packagemanager"
_arguments=("")
tor_packagenames=("torbrowser-launcher")
tor_launchernames=("torbrowser")
tor_readmeline="| Tor browser | Software for enabling anonymous communication by directing Internet traffic. | Command \`tor\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

transmission_gtk_installationtype="packagemanager"
_arguments=("")
transmission_gtk_packagenames=("transmission")
transmission_gtk_launchernames=("transmission-gtk")
transmission_gtk_readmeline="| Transmission | A set of lightweight Torrent client (in GUI, CLI and daemon form) | Executable \`transmission\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

trello_installationtype="environmental"
_arguments=("")
trello_url="https://trello.com"
trello_downloads=("https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Antu_trello.svg/512px-Antu_trello.svg.png;trello_icon.svg.png")
trello_bashfunctions=("alias trello=\"nohup xdg-open ${trello_url} &>/dev/null &\"")
trello_readmelinedescription="Trello web opens in Chrome"
trello_readmeline="| Trello | ${trello_readmelinedescription} | Command \`trello\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
trello_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${trello_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${trello_url}
Icon=${USR_BIN_FOLDER}/trello/trello_icon.svg.png
GenericName=Trello
Keywords=trello;
MimeType=
Name=Trello
StartupNotify=true
StartupWMClass=Trello
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0")

tumblr_installationtype="environmental"
_arguments=("")
tumblr_url="https://www.tumblr.com/"
tumblr_downloads=("https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Tumblr.svg/1200px-Tumblr.svg.png;tumblr_icon.svg")
tumblr_bashfunctions=("alias tumblr=\"nohup xdg-open ${tumblr_url} &>/dev/null &\"")
tumblr_readmelinedescription="Tumblr web opens in Chrome"
tumblr_readmeline="| Tumblr | ${tumblr_readmelinedescription} | Command \`tumblr\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
tumblr_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${tumblr_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${tumblr_url}
Icon=${USR_BIN_FOLDER}/tumblr/tumblr_icon.svg
GenericName=tumblr
Keywords=tumblr
MimeType=
Name=Tumblr
StartupNotify=true
StartupWMClass=Tumblr
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0")

twitch_installationtype="environmental"
_arguments=("")
twitch_url="https://twitch.tv/"
twitch_downloads=("http://img1.wikia.nocookie.net/__cb20140727180700/logopedia/images/thumb/8/83/Twitch_icon.svg/500px-Twitch_icon.svg.png;twitch_icon.svg")
twitch_bashfunctions=("alias twitch=\"nohup xdg-open ${twitch_url} &>/dev/null &\"")
twitch_readmelinedescription="Twitch web opens in Chrome"
twitch_readmeline="| Twitch | ${twitch_readmelinedescription} | Command \`twitch\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
twitch_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${twitch_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${twitch_url}
Icon=${USR_BIN_FOLDER}/twitch/twitch_icon.svg
GenericName=Twitch.tv
Keywords=twitch;Twitch;
MimeType=
Name=Twitch
StartupNotify=true
StartupWMClass=Twitch
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0")

twitter_installationtype="environmental"
_arguments=("")
twitter_url="https://twitter.com/"
twitter_downloads=("https://upload.wikimedia.org/wikipedia/commons/1/19/Twitter_icon.svg;twitter_icon.svg")
twitter_bashfunctions=("alias twitter=\"nohup xdg-open ${twitter_url} &>/dev/null &\"")
twitter_readmelinedescription="Twitter web opens in Chrome"
twitter_readmeline="| Twitter | ${twitter_readmelinedescription} | Command \`twitter\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
twitter_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${twitter_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${twitter_url}
Icon=${USR_BIN_FOLDER}/twitter/twitter_icon.svg
GenericName=Twitter
Keywords=twitter
MimeType=
Name=Twitter
StartupNotify=true
StartupWMClass=Twitter
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0")

u_installationtype="environmental"
_arguments=("")
u_readmeline="| Function \`u\` | Opens given link in default web browser | Command \`u\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
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

uget_installationtype="packagemanager"
_arguments=("")
uget_packagedependencies=("aria2")
uget_packagenames=("uget")
uget_launchernames=("uget-gtk")
uget_readmeline="| uget | GUI utility to manage downloads | Command \`uget\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

virtualbox_installationtype="packageinstall"
_arguments=("")
virtualbox_packagedependencies=("libqt5opengl5")
virtualbox_packageurls=("https://download.virtualbox.org/virtualbox/6.1.22/virtualbox-6.1_6.1.22-144080~Ubuntu~eoan_amd64.deb")
virtualbox_launchernames=("virtualbox")
virtualbox_readmeline="| VirtualBox | Hosted hypervisor for x86 virtualization | Command \`virtualbox\`, desktop launcher and dashboard launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |"

vlc_installationtype="packagemanager"
_arguments=("")
vlc_packagenames=("vlc")
vlc_launchernames=("vlc")
vlc_readmeline="| VLC | Media player software, and streaming media server | Command \`vlc\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

whatsapp_installationtype="environmental"
_arguments=("")
whatsapp_url="https://web.whatsapp.com/"
whatsapp_downloads=("https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg;whatsapp_icon.svg")
whatsapp_bashfunctions=("alias whatsapp=\"nohup xdg-open ${whatsapp_url} &>/dev/null &\"")
whatsapp_readmelinedescription="Whatsapp web opens in Chrome"
whatsapp_readmeline="| Whatsapp Web | ${whatsapp_readmelinedescription} | Command \`whatsapp\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
whatsapp_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${whatsapp_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${whatsapp_url}
Icon=${USR_BIN_FOLDER}/whatsapp/whatsapp_icon.svg
GenericName=WhatsApp Web
Keywords=whatsapp;
MimeType=
Name=WhatsApp Web
StartupNotify=true
StartupWMClass=WhatsApp
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0")

wikipedia_installationtype="environmental"
_arguments=("")
wikipedia_url="https://www.wikipedia.org/"
wikipedia_downloads=("https://upload.wikimedia.org/wikipedia/commons/2/20/Wikipedia-logo-simple.svg;wikipedia_icon.svg")
wikipedia_bashfunctions=("alias wikipedia=\"nohup xdg-open ${wikipedia_url} &>/dev/null &\"")
wikipedia_readmelinedescription="Wikipedia web opens in Chrome"
wikipedia_readmeline="| Wikipedia | ${wikipedia_readmelinedescription} | Command \`wikipedia\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
wikipedia_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${wikipedia_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${wikipedia_url}
Icon=${USR_BIN_FOLDER}/wikipedia/wikipedia_icon.svg
GenericName=reddit
Keywords=wikipedia
MimeType=
Name=Wikipedia
StartupNotify=true
StartupWMClass=Wikipedia
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0")

wireshark_installationtype="packagemanager"
_arguments=("")
wireshark_packagenames=("wireshark")
wireshark_readmeline="| Wireshark | Net sniffer | Command \`wireshark\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
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

x_installationtype="environmental"
_arguments=("")
x_readmeline="| Function \`x\` | Function to extract from a compressed file, no matter its format | Function \`x \"filename\"\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
x_bashfunctions=("
x() {
  if [ -f \"\$1\" ] ; then
    case \"\$1\" in
      *.tar.bz2)
        tar xjf \"\$1\"
      ;;
      *.tar.gz)
        tar xzf \"\$1\"
      ;;
      *.bz2)
        bunzip2 \"\$1\"
      ;;
      *.rar)
        rar x \"\$1\"
      ;;
      *.gz)
        gunzip \"\$1\"
      ;;
      *.tar)
        tar xf \"\$1\"
      ;;
      *.tbz2)
        tar xjf \"\$1\"
      ;;
      *.tgz)
        tar xzf \"\$1\"
      ;;
      *.zip)
        unzip \"\$1\"
      ;;
      *.Z)
        uncompress \"\$1\"
      ;;
      *.7z)
        7z x \"\$1\"
      ;;
      *)
        echo \"\$1 cannot be extracted via x\"
      ;;
    esac
  else
      echo \"'\$1' is not a valid file for x\"
  fi
}")

xclip_installationtype="packagemanager"
_arguments=("")
xclip_packagenames=("xclip")
xclip_readmeline="| \`xclip\` | Utility for pasting. | Command \`xclip\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"


youtube_installationtype="environmental"
_arguments=("")
youtube_url="https://youtube.com/"
youtube_downloads=("https://upload.wikimedia.org/wikipedia/commons/4/4f/YouTube_social_white_squircle.svg;youtube_icon.svg")
youtube_bashfunctions=("alias youtube=\"nohup xdg-open ${youtube_url} &>/dev/null &\"")
youtube_readmelinedescription="YouTube opens in Chrome"
youtube_readmeline="| Youtube| ${youtube_readmelinedescription} | Command \`youtube\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
youtube_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${youtube_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${youtube_url}
Icon=${USR_BIN_FOLDER}/youtube/youtube_icon.svg
GenericName=YouTube
Keywords=youtube;
MimeType=
Name=YouTube
StartupNotify=true
StartupWMClass=YouTube
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0")

youtube_dl_installationtype="environmental"
_arguments=("")
youtube_dl_downloads=("https://yt-dl.org/downloads/latest/youtube-dl;youtube-dl")
youtube_dl_binariesinstalledpaths=("youtube-dl;youtube-dl")
youtube_dl_bashfunctions=("alias youtubewav=\"youtube-dl --extract-audio --audio-format wav\"")
youtube_dl_readmeline="| youtube-dl | Download manager for video and audio from YouTube and over 1000 other video hosting websites. | Command \`youtube-dl\` in the PATH and alias \`youtube-wav\` to scratch a mp3 from youtube || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"

youtubemusic_installationtype="environmental"
_arguments=("")
youtubemusic_url="https://music.youtube.com"
youtubemusic_downloads=("https://upload.wikimedia.org/wikipedia/commons/6/6a/Youtube_Music_icon.svg;youtubemusic_icon.svg")
youtubemusic_bashfunctions="alias youtubemusic=\"nohup xdg-open ${youtubemusic_url} &>/dev/null &\""
youtubemusic_readmelinedescription="YouTube music opens in Chrome."
youtubemusic_readmeline="| Youtube Music | ${youtubemusic_readmelinedescription} | Command \`youtubemusic\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
youtubemusic_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${youtubemusic_readmelinedescription}
Encoding=UTF-8
Exec=xdg-open ${youtubemusic_url}
Icon=${USR_BIN_FOLDER}/youtubemusic/youtubemusic_icon.svg
GenericName=YouTube Music
Keywords=youtubemusic;
MimeType=
Name=YouTube Music
StartupNotify=true
StartupWMClass=YouTube Music
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0")

zoom_installationtype="userinherit"
_arguments=("")
zoom_compressedfileurl="https://zoom.us/client/latest/zoom_x86_64.tar.xz"
zoom_compressedfiletype="J"
zoom_binariesinstalledpaths=("ZoomLauncher;ZoomLauncher" "zoom;zoom")
zoom_downloads=("https://play-lh.googleusercontent.com/JgU6AIREDMsGLmrFSJ8OwLb-JJVw_jwqdwEZWUHemAj0V5Dl7i7GOpmranv2GsCKobM;zoom_icon.ico")
zoom_readmelinedescription="Live Video Streaming for Meetings"
zoom_readmeline="| Zoom | ${zoom_readmelinedescription} | Command \`zoom\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
zoom_launchercontents=("
[Desktop Entry]
Categories=Social;Communication;
Comment=${zoom_readmelinedescription}
Encoding=UTF-8
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
Version=1.0
Exec=ZoomLauncher
")

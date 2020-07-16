

# GLOBAL VARIABLES
# Contains variables XDG_DESKTOP_DIR, XDG_PICTURES_DIR, XDG_TEMPLATES_DIR
if [[ "$(whoami)" != "root" ]]; then
  # declare lenguage specific user environment variables
  source ${HOME}/.config/user-dirs.dirs

  # Fill var to locate user software
  USR_BIN_FOLDER=${HOME}/.bin

  # Locate bash customizing files
  BASHRC_PATH=${HOME}/.bashrc
else
  # declare same variables but with absolute path
  declare $(cat /home/${SUDO_USER}/.config/user-dirs.dirs | sed 's/#.*//g' | sed "s|\$HOME|/home/$SUDO_USER|g" | sed "s|\"||g")

  # Fill var to locate user software
  USR_BIN_FOLDER=/home/${SUDO_USER}/.bin

  # Locate bash customizing files
  BASHRC_PATH=/home/${SUDO_USER}/.bashrc
fi



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
  
discord_version=discord-0.0.10
megasync_version=megasync_4.3.3-5.1_amd64.deb
megasync_repository=https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/
megasync_integrator_version=nautilus-megasync_3.6.6_amd64.deb

discord_launcher="[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=discord
Icon=${USR_BIN_FOLDER}/Discord/discord.png
Type=Application
Categories=Network;InstantMessaging;"

sublime_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=Sublime Text
GenericName=Text Editor
Icon=$HOME/.bin/sublime_text_3/Icon/256x256/sublime-text.png
Comment=General Purpose Programming Text Editor
Terminal=false
Exec=subl %F"


clion_version=CLion-2020.1  # Targeted version of CLion
clion_version_caps_down=$(echo "${clion_version}" | tr '[:upper:]' '[:lower:]')  # Desirable filename in lowercase

clion_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=CLion
Icon=$HOME/.bin/${clion_version_caps_down}/bin/clion.png
Exec=clion %F
Comment=C and C++ IDE for Professional Developers
Terminal=false
StartupWMClass=jetbrains-clion"

pycharm_version=pycharm-community-2019.1.1  # Targeted version of pycharm
pycharm_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Professional
Icon=$HOME/.bin/pycharm-$pycharm_ver/bin/pycharm.png
Exec=pycharm-pro %F
Comment=Python IDE for Professional Developers
Terminal=false
StartupWMClass=jetbrains-pycharm"

pycharm_professional_version=pycharm-professional-2020.1  # Targeted version of pycharm
pycharm_professional_ver=$(echo $pycharm_version | cut -d '-' -f3)
pycharm_professional_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm
Icon=$HOME/.bin/$pycharm_version/bin/pycharm.png
Exec=pycharm %F
Comment=Python IDE for Professional Developers
Terminal=false
StartupWMClass=jetbrains-pycharm"

android_studio_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Exec=studio %F
Icon=${USR_BIN_FOLDER}/android-studio/bin/studio.svg
Categories=Development;IDE;
Terminal=false
StartupNotify=true
StartupWMClass=jetbrains-android-studio
Name[en_GB]=android-studio.desktop"


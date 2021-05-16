#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer uninstallation of features.                                                            #
# - Description: Portable script to remove all installation features installed by install.sh                           #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 16/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernández Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when   #
# logged as root) to install some of the features.                                                                     #
# - Arguments: Accepts behavioural arguments with one hyphen (-f, -o, etc.) and feature to uninstall with two hyphens  #
# (--pycharm, --gcc).                                                                                                  #
# - Usage: Uninstalls the features given by argument.                                                                  #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


################################
###### AUXILIAR FUNCTIONS ######
################################

# - [ ] Add special func in `uninstall` that uninstalls the file structures that the customizer creates (~/.bash_functions, ~/.bin, etc.) That cannot be removed directly using uninstall
purge_all_features()
{
  # Remove the contents of USR_BIN_FOLDER
  rm -Rf "${USR_BIN_FOLDER}"
  # Remove links in path
  for filename in ${ls "${DIR_IN_PATH}"}; do
    if [[ ! -e "${DIR_IN_PATH}/filename" ]]; then
      rm -f "${DIR_IN_PATH}/filename"
    fi
  done
}

# - [ ] Program function in `uninstall.sh` to remove bash functions
# - Argument 1: Name of the filename sourced by own .bash_functions of customizer
remove_bash_function()
{
  sed "s@source ${BASH_FUNCTIONS_FOLDER}/$1\$@@g" -i ${BASH_FUNCTIONS_PATH}
  rm -f "${BASH_FUNCTIONS_FOLDER}/$1"
}

# - [ ] Program function to remove desktop icons from the bar's favorite in `uninstall.sh`
remove_from_favorites()
{
  if [[ ${EUID} -eq 0 ]]; then
    # This code search and export the variable DBUS_SESSIONS_BUS_ADDRESS for root access to gsettings and dconf
    if [[ -z ${DBUS_SESSION_BUS_ADDRESS+x} ]]; then
      user=$(whoami)
      fl=$(find /proc -maxdepth 2 -user $user -name environ -print -quit)
      while [ -z $(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2- | tr -d '\000' ) ]
      do
        fl=$(find /proc -maxdepth 2 -user $user -name environ -newer "$fl" -print -quit)
      done
      export DBUS_SESSION_BUS_ADDRESS="$(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2-)"
    fi
  fi
  if [[ -z $(echo "$(gsettings get org.gnome.shell favorite-apps)" | grep -Fo "$1.desktop") ]]; then
    output_proxy_executioner "echo WARNING: $1 is not in favourites, so cannot be removed. Skipping..." ${FLAG_QUIETNESS}
  else
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s@'google-chrome.desktop'@@g" | sed "s@, ,@,@g" | sed "s@\[, @[@g" | sed "s@, \]@]@g" | sed "s@@@g"sed "s@, \]@]@g")"
  fi
}

# - [ ] Program function to unregister default opening applications on `uninstall.sh`
# First argument: name of the .desktop whose associations will be removed
remove_file_associations()
{
  if [[ -f "${MIME_ASSOCIATION_PATH}" ]]; then
    if [[ ! -z "${MIME_ASSOCIATION_PATH}" ]]; then
      sed "s@^.*=$1@@g" -i "${MIME_ASSOCIATION_PATH}"
    fi
  else
    output_proxy_executioner "echo WARNING: ${MIME_ASSOCIATION_PATH} is not present, so $1 cannot be removed from favourites. Skipping..." ${FLAG_QUIETNESS}
  fi
}


uninstall_converters()
{
  rm -f /home/${SUDO_USER}/.local/bin/dectohex
  rm -f /home/${SUDO_USER}/.local/bin/hextodec
  rm -f /home/${SUDO_USER}/.local/bin/bintodec
  rm -f /home/${SUDO_USER}/.local/bin/dectobin
  rm -f /home/${SUDO_USER}/.local/bin/dectoutf
  rm -f /home/${SUDO_USER}/.local/bin/dectooct
  rm -f /home/${SUDO_USER}/.local/bin/utftodec
  echo "attempting to delete converters functions from bashrc"
  # //RF
  sed "s-${converters_bashrc_call}--" -i ${BASHRC_PATH}
  rm -f /home/${SUDO_USER}/.bash_functions
}
uninstall_copyq()
{
  apt-get purge -y copyq
  rm -f "${XDG_DESKTOP_DIR}/com.github.hluk.copyq.desktop"
}

uninstall_android_studio()
{
  rm -Rf ${USR_BIN_FOLDER}/android-studio
  rm -f /home/${SUDO_USER}/.local/bin/studio
  rm -f "${XDG_DESKTOP_DIR}/Android Studio.desktop"
  rm -f "/home/${SUDO_USER}/.local/share/applications/Android Studio.desktop"
}


uninstall_audacity()
{
  apt-get purge -y audacity audacity-data
  rm -f ${XDG_DESKTOP_DIR}/audacity.desktop
}


uninstall_atom()
{
  apt purge -y atom
  rm -f ${XDG_DESKTOP_DIR}/atom.desktop
}


uninstall_caffeine()
{
  apt purge -y caffeine
  rm -f ${XDG_DESKTOP_DIR}/caffeine-indicator.desktop
}

uninstall_calibre()
{
  apt purge -y calibre
  rm -f ${XDG_DESKTOP_DIR}/calibre.desktop
}

uninstall_cheat()
{
  #there's a curl dependency for cht.sh
  apt-get purge -y curl
  rm -f ${USR_BIN_FOLDER}/cht.sh
  rm -f /home/${SUDO_USER}/.local/bin/cheat
}

unistall_cheese()
{
  apt purge -y cheese
  rm -f ${XDG_DESKTOP_DIR}/org.gnome.Cheese.desktop.desktop
}

uninstall_gnome-chess()
{
  apt-get purge -y gnome-chess
  rm -f ${XDG_DESKTOP_DIR}/org.gnome.Chess.desktop
}

uninstall_cmatrix()
{
  apt-get purge -y cmatrix
  rm -f ${XDG_DESKTOP_DIR}/cmatrix.desktop
}


uninstall_clementine()
{
  apt purge -y clementine
  rm -f ${XDG_DESKTOP_DIR}/clementine.desktop
}

uninstall_clion()
{
  rm -Rf ${USR_BIN_FOLDER}/clion
  rm -f ${XDG_DESKTOP_DIR}/clion.desktop
  rm -f /home/${SUDO_USER}/.local/bin/clion
  rm -f /home/${SUDO_USER}/.local/share/applications/clion.desktop
}

uninstall_clonezilla()
{
  apt-get purge -y clonezilla
  rm -f ${XDG_DESKTOP_DIR}/clonezilla.desktop
  # {LAUNCHERS_DIR}
  rm -f /home/${SUDO_USER}/.local/share/applications/clonezilla.desktop
}


uninstall_discord()
{
  rm -f /home/${SUDO_USER}/.local/bin/discord
  rm -f ${XDG_DESKTOP_DIR}/discord.desktop
  rm -f /home/${SUDO_USER}/.local/share/applications/discord.desktop
  rm -Rf ${USR_BIN_FOLDER}/discord
}


uninstall_dropbox()
{
  apt-get purge -y dropbox
  rm -f ${XDG_DESKTOP_DIR}/dropbox.desktop
}


uninstall_firefox()
{
  apt-get purge -y firefox
  rm -f ${XDG_DESKTOP_DIR}/firefox.desktop
}


uninstall_f-irc()
{
  apt-get purge -y f-irc
  rm -f ${XDG_DESKTOP_DIR}/f-irc.desktop
}


uninstall_games()
{
  apt-get purge -y pacman
  rm -f ${XDG_DESKTOP_DIR}/pacman.desktop
  apt-get purge -y gnome-mines
  rm -f ${XDG_DESKTOP_DIR}/org.gnome.Mines.desktop
  apt-get purge -y aisleriot
  rm -f ${XDG_DESKTOP_DIR}/sol.desktop
  apt-get purge -y gnome-mahjongg
  rm -f ${XDG_DESKTOP_DIR}/org.gnome.Mahjongg.desktop
  apt-get purge -y gnome-sudoku
  rm -f ${XDG_DESKTOP_DIR}/org.gnome.Sudoku.desktop
}


uninstall_gcc()
{
  apt-get purge -y gcc
}


uninstall_geany()
{
  apt-get purge -y geany
  rm -f ${XDG_DESKTOP_DIR}/geany.desktop
}


uninstall_gimp()
{
  apt purge -y gimp
  rm -f ${XDG_DESKTOP_DIR}/gimp.desktop
}


uninstall_git()
{
  apt-get purge -y git-all
  apt-get purge -y git-lfs
}


uninstall_GNU_parallel()
{
  apt-get purge -y parallel
}


uninstall_google_chrome()
{
  apt-get purge -y google-chrome-stable
  rm -f ${XDG_DESKTOP_DIR}/google-chrome.desktop
  rm -f ${XDG_DESKTOP_DIR}/chrome*.desktop
  rm -f /home/${SUDO_USER}/.local/share/applications/chrome*.desktop
}


uninstall_gparted()
{
  apt purge -y gparted
  rm -f ${XDG_DESKTOP_DIR}/gparted.desktop
}


uninstall_gvim()
{
  apt purge -y vim-gtk3
  rm -f ${XDG_DESKTOP_DIR}/gvim.desktop
}


uninstall_gpaint()
{
  apt purge -y gpaint
  rm -f ${XDG_DESKTOP_DIR}/gpaint.desktop
}


uninstall_inkscape()
{
  apt purge -y inkscape
  rm -f ${XDG_DESKTOP_DIR}/inkscape.desktop
}


uninstall_intellij_ultimate()
{
  rm -Rf ${USR_BIN_FOLDER}/idea-IU
  rm -f /home/${SUDO_USER}/.local/bin/ideau
  rm -f ${XDG_DESKTOP_DIR}/ideau.desktop
  rm -f /home/${SUDO_USER}/.local/share/applications/ideau.desktop
}


uninstall_intellij_community()
{
  rm -Rf ${USR_BIN_FOLDER}/idea-IC
  rm -f /home/${SUDO_USER}/.local/bin/ideac
  rm -f ${XDG_DESKTOP_DIR}/ideac.desktop
  rm -f /home/${SUDO_USER}/.local/share/applications/ideac.desktop
}


uninstall_jdk11()
{
  apt -y purge default-jdk
}


uninstall_latex()
{
  apt-get purge -y texlive-latex-extra perl-tk
  rm -f ${XDG_DESKTOP_DIR}/texdoctk.desktop
  rm -f ${XDG_DESKTOP_DIR}/texmaker.desktop
}


uninstall_megasync()
{
  dpkg -P nautilus-megasync
  dpkg -P megasync
  rm -f ${XDG_DESKTOP_DIR}/megasync.desktop
  apt-get purge -y libc-ares2 libmediainfo0v5 libqt5x11extras5 libzen0v5
}


uninstall_mendeley()
{
  rm -Rf ${USR_BIN_FOLDER}/mendeley
  rm -f /home/${SUDO_USER}/.local/bin/mendeley
  rm -f ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
  rm -f /home/${SUDO_USER}/.local/share/applications/mendeleydesktop.desktop
}


uninstall_mendeley_dependencies()
{
  apt-get -y purge gconf2 qt5-default qt5-doc qt5-doc-html qtbase5-examples qml-module-qtwebengine
}


uninstall_musicmanager()
{
  apt-get purge -y google-musicmanager google-musicmanager-beta
  rm -f ${XDG_DESKTOP_DIR}/google-musicmanager.desktop
  rm -f /home/${SUDO_USER}/.local/share/applications/google-musicmanager.desktop
}


uninstall_nemo()
{
  apt -y purge nemo
  apt -y purge dconf-editor gnome-tweak-tool
  apt install -y nautilus gnome-shell-extension-desktop-icons
  rm -f /etc/xdg/autostart/nemo-autostart.desktop
  #for command in "${nemo_conf[@]}"; do
   # sed "s:${command}::g" -i /home/${SUDO_USER}/.profile
  #done
  for command in "${nautilus_conf[@]}"; do
    $command
    #echo "${command}" >> /home/${SUDO_USER}/.profile
  done
  echo "WARNING: If Nemo has been uninstalled restart Ubuntu to update the desktop back to Nautilus"
}


uninstall_notepadqq()
{
  apt purge -y notepadqq
  rm -f ${XDG_DESKTOP_DIR}/notepadqq.desktop
}


uninstall_obs-studio()
{
  # Remove dependency
  apt purge -y ffmpeg
  # Uninstall OBS Studio
  apt purge -y obs-studio
  rm -f ${XDG_DESKTOP_DIR}/obs-studio.desktop
}


uninstall_openoffice()
{
  apt-get purge -y openoffice*.*
  rm -f ${XDG_DESKTOP_DIR}/openoffice4-base.desktop
  rm -f ${XDG_DESKTOP_DIR}/openoffice4-calc.desktop
  rm -f ${XDG_DESKTOP_DIR}/openoffice4-draw.desktop
  rm -f ${XDG_DESKTOP_DIR}/openoffice4-math.desktop
  rm -f ${XDG_DESKTOP_DIR}/openoffice4-writer.desktop
}


install_okular()
{
  apt purge -y okular
  rm -f ${XDG_DESKTOP_DIR}/okular.desktop
}


uninstall_pdfgrep()
{
  apt-get purge -y pdfgrep
}


uninstall_pycharm_professional()
{
  rm -Rf ${USR_BIN_FOLDER}/pycharm-pro
  rm -f ${XDG_DESKTOP_DIR}/pycharm-pro.desktop
  rm -f /home/${SUDO_USER}/.local/bin/pycharm-pro
  rm -f /home/${SUDO_USER}/.local/share/applications/pycharm-pro.desktop
}


uninstall_pycharm_community()
{
  rm -Rf ${USR_BIN_FOLDER}/pycharm-community
  rm -f ${XDG_DESKTOP_DIR}/pycharm.desktop
  rm -f /home/${SUDO_USER}/.local/bin/pycharm
  rm -f /home/${SUDO_USER}/.local/share/applications/pycharm.desktop
}


uninstall_pypy3()
{
  rm -Rf ${USR_BIN_FOLDER}/pypy3
  rm -f /home/${SUDO_USER}/.local/bin/pypy3
  rm -f /home/${SUDO_USER}/.local/bin/pypy3-pip
}


uninstall_python3()
{
  apt-get purge -y python3-dev
  apt-get purge -y python-dev
}


uninstall_pypy3_dependencies()
{
  apt-get purge -y pkg-config libfreetype6-dev libpng-dev libffi-dev
}


uninstall_shell_customization()
{
  mv /home/${SUDO_USER}/.bashrc.bak /home/${SUDO_USER}/.bashrc
  chmod 775 /home/${SUDO_USER}/.bashrc
  chgrp ${SUDO_USER} /home/${SUDO_USER}/.bashrc
  chown ${SUDO_USER} /home/${SUDO_USER}/.bashrc
  
  # uninstall git bash prompt here
  # Rf
  rm -Rf ${USR_BIN_FOLDER}/.bash-git-prompt
  dconf write /org/gnome/terminal/legacy/profiles:/$(dconf list /org/gnome/terminal/legacy/profiles:/)background-color "'rgb(48,10,36)'"
}


uninstall_shotcut()
{
  apt purge -y shotcut
  rm -f ${XDG_DESKTOP_DIR}/shotcut.desktop
}


uninstall_slack()
{
  dpkg -P slack-desktop
  rm -f ${XDG_DESKTOP_DIR}/slack.desktop
}


uninstall_steam()
{
  dpkg -P steam-launcher
  rm -f ${XDG_DESKTOP_DIR}/steam.desktop
}


uninstall_sublime()
{
  rm -Rf ${USR_BIN_FOLDER}/sublime
  rm -f ${XDG_DESKTOP_DIR}/sublime.desktop
  rm -f /home/${SUDO_USER}/.local/bin/sublime
  rm -f /home/${SUDO_USER}/.local/share/applications/sublime.desktop
}


uninstall_telegram()
{
  rm -Rf ${USR_BIN_FOLDER}/telegram
  rm -f /home/${SUDO_USER}/.local/bin/telegram
  rm -f ${XDG_DESKTOP_DIR}/telegram.desktop
  rm -f /home/${SUDO_USER}/.local/share/applications/telegram.desktop
}


uninstall_templates()
{
  rm -f ${XDG_TEMPLATES_DIR}/*
}


uninstall_thunderbird()
{
  apt-get purge -y thunderbird
  rm -f ${XDG_DESKTOP_DIR}/thunderbird.desktop
}


uninstall_terminator()
{
  apt-get purge -y terminator
  rm -f ${XDG_DESKTOP_DIR}/terminator.desktop
}


uninstall_tilix()
{
  apt-get purge -y tilix
  rm -f ${XDG_DESKTOP_DIR}/tilix.desktop
}


uninstall_tmux()
{
  apt purge -y tmux
  rm -f ${XDG_DESKTOP_DIR}/tmux.desktop
  rm -f /home/${SUDO_USER}/.local/share/applications/tmux.desktop
}

uninstall_torbrowser()
{
  apt-get purge -y transmission
  rm -f ${XDG_DESKTOP_DIR}/torbrowser.desktop

}
uninstall_transmission()
{
  apt-get purge -y transmission
  rm -f ${XDG_DESKTOP_DIR}/transmission-gtk.desktop
}


uninstall_virtualbox()
{
  dpkg -P virtualbox-6.1
  rm -f ${XDG_DESKTOP_DIR}/virtualbox.desktop
}


uninstall_visualstudiocode()
{
  rm -Rf ${USR_BIN_FOLDER}/visual-studio-code
  rm -f /home/${SUDO_USER}/.local/share/applications/visual-studio-code.desktop
  rm -f /home/${SUDO_USER}/.local/bin/code
  rm -f ${XDG_DESKTOP_DIR}/visual-studio-code.desktop
}


uninstall_vlc()
{
  apt-get purge -y vlc
  rm -f ${XDG_DESKTOP_DIR}/vlc.desktop
}


uninstall_wireshark()
{
  rm -f ${XDG_DESKTOP_DIR}/wireshark.desktop
  apt-get purge -y wireshark
  apt-get autoremove -y --purge wireshark
}

uninstall_youtube-dl()
{

  rm -f ${USR_BIN_FOLDER}/youtube-dl

}


##################
###### MAIN ######
##################
main()
{
  ################################
  ### DATA AND FILE STRUCTURES ###
  ################################

  FLAG_MODE=0  # Uninstall mode
  FLAG_OVERWRITE=1  # Set in uninstall always to true or it skips the program if it is installed


  #################################
  ###### ARGUMENT PROCESSING ######
  #################################

  # If we don't receive arguments we try to install everything that we can given our permissions
  if [[ -z "$@" ]]; then
    uninstall_all
  else
    while [[ $# -gt 0 ]]; do
      key="$1"

      case ${key} in
        ### BEHAVIOURAL ARGUMENTS ###
      -v|--verbose)
        FLAG_QUIETNESS=0
      ;;
      -q|--quiet)
        FLAG_QUIETNESS=1
      ;;
      -Q|--Quiet)
        FLAG_QUIETNESS=2
      ;;

      -f|--fear|--fearlessly)
        FLAG_OVERWRITE=0
      ;;
      -u|--uninstall)
        FLAG_OVERWRITE=1
      ;;

      -e|--exit|--exit-on-error)
        FLAG_IGNORE_ERRORS=0
      ;;
      -i|--ignore|--ignore-errors)
        FLAG_IGNORE_ERRORS=1
      ;;


      -d|--dirty|--no-autoclean)
        FLAG_AUTOCLEAN=0
      ;;
      -c|--clean)
        FLAG_AUTOCLEAN=1
      ;;
      -C|--Clean)
        FLAG_AUTOCLEAN=2
      ;;

      -n|--not|-!)
        FLAG_INSTALL=0
      ;;
      -y|--yes)
        # To know the order of execution of programs
        FLAG_INSTALL=${NUM_INSTALLATION}
      ;;

      -h)
        output_proxy_executioner "echo ${help_common}${help_simple}" ${FLAG_QUIETNESS}
        exit 0
      ;;

      -H|--help)
        output_proxy_executioner "echo ${help_common}${help_arguments}" ${FLAG_QUIETNESS}
        exit 0
      ;;
        
        ### WRAPPER ARGUMENT(S) ###
      -|--all)
        add_programs_with_x_permissions 2
      ;;


      *)  # Individual arguments
        process_argument ${key}
      ;;
      esac
    shift
  done
fi

  ####################
  ### INSTALLATION ###
  ####################

  execute_installation


  ###############################
  ### POST-INSTALLATION CLEAN ###
  ###############################

  post_install_clean

  bell_sound
}

# Import file of common variables in a relative way, so customizer can be called system-wide
# RF, duplication in uninstall. Common extraction in the future in the common endpoint customizer.sh
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then
  DIR="${PWD}"
fi
if [[ -f "${DIR}/data_common.sh" ]]; then
  source "${DIR}/data_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: common_data.sh does not exist. Aborting..."
  exit 1
fi

# Call main function
main "$@"

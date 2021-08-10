#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer uninstallation of features.                                                            #
# - Description: Portable script to remove all installation features installed by install.sh                           #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 19/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernández Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when   #
# logged as root) to uninstall some of the features. The features that need to be installed as privileged user also    #
# need to be uninstalled as privileged user.                                                                           #
# - Arguments: Accepts behavioural arguments with one hyphen (-f, -o, etc.) and feature to uninstall with two hyphens  #
# (--pycharm, --gcc).                                                                                                  #
# - Usage: Uninstalls the features given by argument.                                                                  #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


############################
###### ROOT FUNCTIONS ######
############################

uninstall_aisleriot()
{
  apt-get purge -y aisleriot
  rm -f ${XDG_DESKTOP_DIR}/sol.desktop
}

uninstall_atom()
{
  apt purge -y atom
  rm -f ${XDG_DESKTOP_DIR}/atom.desktop
}

uninstall_audacity()
{
  apt-get purge -y audacity audacity-data
  rm -f ${XDG_DESKTOP_DIR}/audacity.desktop
}

uninstall_AutoFirma()
{
  apt-get purge -y libnss3-tools
  dpkg -P AutoFirma
  rm -f ${XDG_DESKTOP_DIR}/afirma.desktop
}

uninstall_caffeine()
{
  apt purge -y caffeine
}

uninstall_calibre()
{
  apt purge -y calibre
  rm -f ${XDG_DESKTOP_DIR}/calibre.desktop
}

unistall_cheese()
{
  apt purge -y cheese
  rm -f ${XDG_DESKTOP_DIR}/org.gnome.Cheese.desktop.desktop
}

uninstall_clementine()
{
  apt purge -y clementine
  rm -f ${XDG_DESKTOP_DIR}/clementine.desktop
}

uninstall_clonezilla()
{
  apt-get purge -y clonezilla
  rm -f ${XDG_DESKTOP_DIR}/clonezilla.desktop
  # {LAUNCHERS_DIR}
  rm -f /home/${SUDO_USER}/.local/share/applications/clonezilla.desktop
}

uninstall_cmatrix()
{
  apt-get purge -y cmatrix
  rm -f ${XDG_DESKTOP_DIR}/cmatrix.desktop
}

uninstall_copyq()
{
  apt-get purge -y copyq
  rm -f "${XDG_DESKTOP_DIR}/com.github.hluk.copyq.desktop"
}

uninstall_curl()
{
  apt-get purge -y copyq
}

uninstall_dropbox()
{
  apt-get purge -y dropbox
  rm -f ${XDG_DESKTOP_DIR}/dropbox.desktop
}

uninstall_f-irc()
{
  apt-get purge -y f-irc
  rm -f ${XDG_DESKTOP_DIR}/f-irc.desktop
}

uninstall_firefox()
{
  apt-get purge -y firefox
  rm -f ${XDG_DESKTOP_DIR}/firefox.desktop
}

uninstall_freecad()
{
  apt-get purge -y freecad
  rm -f ${XDG_DESKTOP_DIR}/freecad.desktop
}

uninstall_ffmpeg()
{
  apt purge -y ffmpeg
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

uninstall_gnome-chess()
{
  apt-get purge -y gnome-chess
  rm -f ${XDG_DESKTOP_DIR}/org.gnome.Chess.desktop
}

uninstall_gnome-mahjongg()
{
  apt-get purge -y gnome-mahjongg
  rm -f ${XDG_DESKTOP_DIR}/org.gnome.Mahjongg.desktop
}

uninstall_gnome-mines()
{
  apt-get purge -y gnome-mines
  rm -f ${XDG_DESKTOP_DIR}/org.gnome.Mines.desktop
}

uninstall_gnome-sudoku()
{
  apt-get purge -y gnome-sudoku
  rm -f ${XDG_DESKTOP_DIR}/org.gnome.Sudoku.desktop
}

uninstall_google-chrome()
{
  apt-get purge -y google-chrome-stable
  rm -f ${XDG_DESKTOP_DIR}/google-chrome.desktop
  rm -f ${XDG_DESKTOP_DIR}/chrome*.desktop
  rm -f /home/${SUDO_USER}/.local/share/applications/chrome*.desktop
}

uninstall_gpaint()
{
  apt purge -y gpaint
  rm -f ${XDG_DESKTOP_DIR}/gpaint.desktop
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

uninstall_inkscape()
{
  apt purge -y inkscape
  rm -f ${XDG_DESKTOP_DIR}/inkscape.desktop
}

uninstall_iqmol()
{
  echo "oo"
}

uninstall_latex()
{
  apt-get purge -y texlive-latex-extra perl-tk
  rm -f ${XDG_DESKTOP_DIR}/texdoctk.desktop
  rm -f ${XDG_DESKTOP_DIR}/texmaker.desktop
}

uninstall_parallel()
{
  apt-get purge -y parallel
}

uninstall_libgtkglext1()
{
  apt-get purge -y libgtkglext1
}

uninstall_libxcb-xtest0()
{
  apt-get purge -y libxcb-xtest0
}

uninstall_megasync()
{
  dpkg -P nautilus-megasync
  dpkg -P megasync
  rm -f ${XDG_DESKTOP_DIR}/megasync.desktop
  apt-get purge -y libc-ares2 libmediainfo0v5 libqt5x11extras5 libzen0v5
}

uninstall_mendeley_dependencies()
{
  apt-get -y purge gconf2 qt5-default qt5-doc qt5-doc-html qtbase5-examples qml-module-qtwebengine
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

uninstall_net-tools()
{
  apt-get purge -y net-tools
}

uninstall_notepadqq()
{
  apt purge -y notepadqq
  rm -f ${XDG_DESKTOP_DIR}/notepadqq.desktop
}

uninstall_obs-studio()
{
  apt purge -y obs-studio
  rm -f ${XDG_DESKTOP_DIR}/obs-studio.desktop
}

install_okular()
{
  apt purge -y okular
  rm -f ${XDG_DESKTOP_DIR}/okular.desktop
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

uninstall_pacman()
{
  apt-get purge -y pacman
  rm -f ${XDG_DESKTOP_DIR}/pacman.desktop
}

uninstall_pdfgrep()
{
  apt-get purge -y pdfgrep
}

uninstall_psql()
{
  apt-get purge -y postgresql-client-12	postgresql-12 libpq-dev postgresql-server-dev-12
}

uninstall_pypy3_dependencies()
{
  apt-get purge -y pkg-config libfreetype6-dev libpng-dev libffi-dev
}

uninstall_python3()
{
  apt-get purge -y python3-dev
  apt-get purge -y python-dev
}

uninstall_pluma()
{
  apt-get purge -y uninstall_pluma
  #Remove from favorites (?)
}

uninstall_shotcut()
{
  apt-get purge -y shotcut
  rm -f ${XDG_DESKTOP_DIR}/shotcut.desktop
}

uninstall_skype()
{
  echo "ooo"
  dpkg -P skype
  rm -f ${XDG_DESKTOP_DIR}/skype.desktop
}

uninstall_slack()
{
  dpkg -P slack-desktop
  rm -f ${XDG_DESKTOP_DIR}/slack.desktop
}

uninstall_spotify()
{
  echo "oo"
  dpkg -P spotify-desktop
  rm -f ${XDG_DESKTOP_DIR}/spotify.desktop
}

uninstall_steam()
{
  dpkg -P steam-launcher
  rm -f ${XDG_DESKTOP_DIR}/steam.desktop
}

uninstall_teams()
{
  echo "o"
  dpkg -P teams
  rm -f ${XDG_DESKTOP_DIR}/teams.desktop
}

uninstall_terminator()
{
  apt-get purge -y terminator
  rm -f ${XDG_DESKTOP_DIR}/terminator.desktop
}

uninstall_thunderbird()
{
  apt-get purge -y thunderbird
  rm -f ${XDG_DESKTOP_DIR}/thunderbird.desktop
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

uninstall_tor()
{
  apt-get purge -y transmission
  rm -f ${XDG_DESKTOP_DIR}/torbrowser.desktop
}

uninstall_transmission()
{
  apt-get purge -y transmission
  rm -f ${XDG_DESKTOP_DIR}/transmission-gtk.desktop
}

uninstall_uget()
{
  apt-get purge -y aria2
  apt-get purge -y uget
  rm -f ${XDG_DESKTOP_DIR}/uget-gtk.desktop
}

uninstall_virtualbox()
{
  dpkg -P virtualbox-6.1
  rm -f ${XDG_DESKTOP_DIR}/virtualbox.desktop
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


#####################################
###### USER SOFTWARE FUNCTIONS ######
#####################################

uninstall_ant()
{
  remove_manual_feature ant
}

uninstall_anydesk()
{
  remove_manual_feature anydesk
}

uninstall_clion()
{
  remove_manual_feature clion
}

uninstall_code()
{
  remove_manual_feature code
}

uninstall_codium()
{
  remove_manual_feature codium
}

uninstall_discord()
{
  remove_manual_feature discord
}

uninstall_docker()
{
  remove_manual_feature docker
}

uninstall_eclipse()
{
  remove_manual_feature eclipse
}

uninstall_geogebra()
{
  remove_manual_feature geogebra
}

uninstall_github()
{
  remove_manual_feature github
}

uninstall_gitlab()
{
  remove_manual_feature gitlab
}

uninstall_ideac()
{
  rm -Rf ${USR_BIN_FOLDER}/idea-IC
  rm -f /home/${SUDO_USER}/.local/bin/ideac
  rm -f ${XDG_DESKTOP_DIR}/ideac.desktop
  rm -f /home/${SUDO_USER}/.local/share/applications/ideac.desktop
}

uninstall_ideau()
{
  rm -Rf ${USR_BIN_FOLDER}/idea-IU
  rm -f /home/${SUDO_USER}/.local/bin/ideau
  rm -f ${XDG_DESKTOP_DIR}/ideau.desktop
  rm -f /home/${SUDO_USER}/.local/share/applications/ideau.desktop
}

uninstall_java()
{
  apt -y purge default-jdk
}

uninstall_mendeley()
{
  rm -Rf ${USR_BIN_FOLDER}/mendeley
  rm -f /home/${SUDO_USER}/.local/bin/mendeley
  rm -f ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
  rm -f /home/${SUDO_USER}/.local/share/applications/mendeleydesktop.desktop
}

uninstall_mvn()
{
  remove_manual_feature mvn
}

uninstall_studio()
{
  remove_manual_feature studio
}

uninstall_pycharm()
{
  rm -Rf ${USR_BIN_FOLDER}/pycharm-community
  rm -f ${XDG_DESKTOP_DIR}/pycharm.desktop
  rm -f /home/${SUDO_USER}/.local/bin/pycharm
  rm -f /home/${SUDO_USER}/.local/share/applications/pycharm.desktop
}

uninstall_pycharmpro()
{
  rm -Rf ${USR_BIN_FOLDER}/pycharm-pro
  rm -f ${XDG_DESKTOP_DIR}/pycharm-pro.desktop
  rm -f /home/${SUDO_USER}/.local/bin/pycharm-pro
  rm -f /home/${SUDO_USER}/.local/share/applications/pycharm-pro.desktop
}

uninstall_pypy3()
{
  rm -Rf ${USR_BIN_FOLDER}/pypy3
  rm -f /home/${SUDO_USER}/.local/bin/pypy3
  rm -f /home/${SUDO_USER}/.local/bin/pypy3-pip
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

uninstall_youtube-dl()
{
  rm -f ${USR_BIN_FOLDER}/youtube-dl
}

uninstall_zoom()
{
  echo "zoom"
}

#######################################
###### USER-ENVIRONMENT FEATURES ######
#######################################
# Most (all) of them just use user permissions RF #RF

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

uninstall_cheat()
{
  #there's a curl dependency for cht.sh
  apt-get purge -y curl
  rm -f ${USR_BIN_FOLDER}/cht.sh
  rm -f /home/${SUDO_USER}/.local/bin/cheat
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


uninstall_templates()
{
  rm -f ${XDG_TEMPLATES_DIR}/*
}

##################
###### MAIN ######
##################
main()
{
  ################################
  ### DATA AND FILE STRUCTURES ###
  ################################

  FLAG_MODE=uninstall  # Uninstall mode
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
        add_program ${key}
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
local PRG="$BASH_SOURCE"
while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`"/$link"
    fi
done
DIR=$(dirname "$PRG")

if [ -f "${DIR}/functions_uninstall.sh" ]; then
  source "${DIR}/functions_uninstall.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_uninstall.sh does not exist. Aborting..."
  exit 1
fi

# Call main function
main "$@"

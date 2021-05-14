#!/usr/bin/env bash

###### AUXILIAR FUNCTIONS ######

# Prints the given arguments to the stderr
err()
{
  echo "$*" >&2
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
  apt-get purge -y curl
  dpkg -P steam-launcher
  rm -f ${XDG_DESKTOP_DIR}/steam.desktop
}


uninstall_sublime_text()
{
  rm -Rf ${USR_BIN_FOLDER}/sublime-text
  rm -f ${XDG_DESKTOP_DIR}/sublime-text.desktop
  rm -f /home/${SUDO_USER}/.local/bin/sublime
  rm -f /home/${SUDO_USER}/.local/share/applications/sublime-text.desktop
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


# Uninstall all functions
uninstall_all()
{
  uninstall_android_studio
  uninstall_audacity
  uninstall_atom
  uninstall_caffeine
  uninstall_calibre
  uninstall_cheat
  unistall_cheese
  uninstall_gnome-chess
  uninstall_clion
  uninstall_clonezilla
  uninstall_cmatrix
  uninstall_converters
  uninstall_discord
  uninstall_dropbox
  uninstall_firefox
  uninstall_f-irc
  uninstall_games
  uninstall_gcc
  uninstall_geany
  uninstall_gimp
  uninstall_git
  uninstall_GNU_parallel
  uninstall_google_chrome
  uninstall_gparted
  uninstall_gvim
  uninstall_gpaint
  uninstall_inkscape
  uninstall_intellij_community
  uninstall_intellij_ultimate
  uninstall_jdk11
  uninstall_latex
  uninstall_megasync
  uninstall_mendeley
  uninstall_mendeley_dependencies
  uninstall_musicmanager
  uninstall_nemo
  uninstall_obs-studio
  uninstall_openoffice
  uninstall_pdfgrep
  uninstall_pycharm_professional
  uninstall_pycharm_community
  uninstall_pypy3
  uninstall_pypy3_dependencies
  uninstall_python3
  uninstall_shell_customization
  uninstall_shotcut
  uninstall_slack
  uninstall_steam
  uninstall_sublime_text
  uninstall_telegram
  uninstall_templates
  uninstall_terminator
  uninstall_thunderbird
  uninstall_tilix
  uninstall_tmux
  uninstall_torbrowser
  uninstall_transmission
  uninstall_virtualbox
  uninstall_visualstudiocode
  uninstall_vlc
  uninstall_wireshark
  uninstall_youtube-dl
}

##################
###### MAIN ######
##################
main()
{
  FLAG_MODE=0
  if [[ "$(whoami)" != "root" ]]; then
  	err "Exiting. You are not root"
  fi

  ###### ARGUMENT PROCESSING ######

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

      -s|--skip|--skip-if-installed)
        FLAG_OVERWRITE=0
      ;;
      -o|--overwrite|--overwrite-if-present)
        FLAG_OVERWRITE=1
      ;;

      -e|--exit|--exit-on-error)
        FLAG_IGNORE_ERRORS=0
      ;;
      -i|--ignore|--ignore-errors)
        FLAG_IGNORE_ERRORS=1
      ;;

      # Force is the two previous active behaviours in one
      -f|--force)
        FLAG_IGNORE_ERRORS=1
        FLAG_OVERWRITE=1
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

      -k|--keep-system-outdated)
        FLAG_UPGRADE=0
      ;;
      -u|--update)
        FLAG_UPGRADE=1
      ;;
      -U|--upgrade|--Upgrade)
        FLAG_UPGRADE=2
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

        ### INDIVIDUAL ARGUMENTS ###
        # Sorted alphabetically by function name:
        --android|--AndroidStudio|--androidstudio|--studio|--android-studio|--android_studio|--Androidstudio)
          uninstall_android_studio
        ;;
        --audacity|--Audacity)
          uninstall_audacity
        ;;
        --atom|--Atom)
          uninstall_atom
        ;;
        --caffeine|--Caffeine|--cafe|--coffee)
          uninstall_caffeine
        ;;
        --calibre|--Calibre|--cali)
          uninstall_calibre
        ;;
        --cheat|--cheat.sh|--Cheat.sh|--che)
          uninstall_cheat
        ;;
        --cheese|--Cheese)
          unistall_cheese
        ;;
        --GNOME_Chess|--gnome_Chess|--gnomechess|--chess)
          uninstall_gnome-chess
        ;;
        --clementine|--Clementine)
          uninstall_clementine
        ;;
        --clion|--Clion|--CLion)
          uninstall_clion
        ;;
        --cmatrix|--Cmatrix)
          uninstall_cmatrix
        ;;
        --clonezilla|--CloneZilla|--cloneZilla)
          uninstall_clonezilla
        ;;
        --converters|--Converters)
          uninstall_converters
        ;;
        --copyq|--copy-q|--copy_q|--copqQ|--Copyq|--copy-Q)
          uninstall_copyq
        ;;
        --discord|--Discord|--disc)
          uninstall_discord
        ;;
        --dropbox|--Dropbox|--DropBox|--Drop-box|--drop-box|--Drop-Box)
          uninstall_dropbox
        ;;
        -c|--gcc)
          uninstall_gcc
        ;;
        --f-irc|--firc|--Firc|--irc)
          uninstall_f-irc
        ;;
        --firefox|--Firefox)
          uninstall_firefox
        ;;
        --games|--Gaming|--Games)
          uninstall_games
        ;;
        --geany|--Geany)
          uninstall_geany
        ;;
        --git)
          uninstall_git
        ;;
        --GIMP|--gimp|--Gimp)
          uninstall_gimp
        ;;
        --google-play-music|--musicmanager|--music-manager|--MusicManager|--playmusic|--GooglePlayMusic|--play-music|--google-playmusic|--playmusic|--google-music)
          uninstall_musicmanager
        ;;
        --gpaint|--paint|--Gpaint)
          uninstall_gpaint
        ;;
        --GParted|--gparted|--GPARTED|--Gparted)
          uninstall_gparted
        ;;
        --gvim|--vim-gtk3|--Gvim|--GVim)
          uninstall_gvim
        ;;
        --inkscape|--ink-scape|--Inkscape|--InkScape)
          uninstall_inkscape
        ;;
        --parallel|--gnu_parallel|--GNUparallel|--GNUParallel|--gnu-parallel)
          uninstall_GNU_parallel
        ;;
        --chrome|--Chrome|--google-chrome|--Google-Chrome)
          uninstall_google_chrome
        ;;
        --intellijcommunity|--intelliJCommunity|--intelliJ-Community|--intellij-community|--ideac)
          uninstall_intellij_community
        ;;
        --intellijultimate|--intelliJUltimate|--intelliJ-Ultimate|--intellij-ultimate|--ideau)
          uninstall_intellij_ultimate
        ;;
        --java|--javadevelopmentkit|--java-development-kit|--java-development-kit-11|--java-development-kit11|--jdk|--JDK|--jdk11|--JDK11)
          uninstall_jdk11
        ;;
        --latex|--LaTeX|--tex|--TeX)
          uninstall_latex
        ;;
        --mega|--Mega|--MEGA|--MegaSync|--MEGAsync|--MEGA-sync|--megasync)
          uninstall_megasync
        ;;
        --Mendeley|--mendeley|--mendeleyDesktop|--mendeley-desktop|--Mendeley-Desktop)
          uninstall_mendeley
        ;;
        --MendeleyDependencies|--mendeleydependencies|--mendeleydesktopdependencies|--mendeley-desktop-dependencies|--Mendeley-Desktop-Dependencies)
          uninstall_mendeley_dependencies
        ;;
         --nemo|--nemo-desktop|--Nemo-Desktop|--Nemodesktop|--nemodesktop|--Nemo|--Nemodesk|--NemoDesktop)
          uninstall_nemo
        ;;
        --notepadqq|--Notepadqq|--notepadQQ|--NotepadQQ|--notepadQq|--notepadqQ|--NotepadQq|--NotepadqQ|--NotePadQQ|NotePadqq)
          uninstall_notepadqq
        ;;
        --pdfgrep|--findpdf|--pdf)
          uninstall_pdfgrep
        ;;
        --pycharmcommunity|--pycharmCommunity|--pycharm_community|--pycharm|--pycharm-community)
          uninstall_pycharm_community
        ;;
        --pycharmpro|--pycharmPro|--pycharm_pro|--pycharm-pro|--Pycharm-Pro|--PyCharm-pro)
          uninstall_pycharm_professional
        ;;
        --OBS|--obs|--obs-studio|--obs_studio|--obs_Studio|--OBS_studio|--obs-Studio|--OBS_Studio|--OBS-Studio)
          uninstall_obs-studio
        ;;
        --office|--Openoffice|--OpenOffice|--openOfice|--open_office|--Office)
          uninstall_openoffice
        ;;
        --okular|--Okular|--okularpdf)
          install_okular
        ;;
        -p|--python|--python3|--Python3|--Python)
          uninstall_python3
        ;;
        --pypy|--pypy3|--PyPy3|--PyPy)
          uninstall_pypy3
        ;;
        --dependencies|--pypy3_dependencies|--pypy3Dependencies|--PyPy3Dependencies|--pypy3dependencies|--pypy3-dependencies)
          uninstall_pypy3_dependencies
        ;;
        --shell|--shellCustomization|--shellOptimization|--environment|--environmentaliases|--environment_aliases|--environmentAliases|--alias|--Aliases)  # Considered "shell" in order
          uninstall_shell_customization
        ;;
        --shotcut|--ShotCut|--Shotcut|--shot-cut|--shot_cut)
          uninstall_shotcut
        ;;
        --slack|--Slack)
          uninstall_slack
        ;;
        --sublime|--sublimeText|--sublime_text|--Sublime|--sublime-Text|--sublime-text)
          uninstall_sublime_text
        ;;
        --steam|--Steam|--STEAM)
          uninstall_steam
        ;;
        --Telegram|--telegram)
          uninstall_telegram
        ;;
        --templates)
          uninstall_templates
        ;;
        --Terminator|--terminator)
          uninstall_terminator
        ;;
        --thunderbird|--mozillathunderbird|--mozilla-thunderbird|--Thunderbird|--thunder-bird)
          uninstall_thunderbird
        ;;
        --tilix|--tilix)
          uninstall_tilix
        ;;
        --tmux|--Tmux)
          uninstall_tmux
        ;;
        --tor|--torbrowser|--tor_browser|--TOR|--TOR-browser|--TOR-BROSWER|--TORBROWSER|--TOR_BROWSER|--TOR_browser)
          uninstall_torbrowser
        ;;
        --transmission|--transmission-gtk|--Transmission)
          uninstall_transmission
        ;;
        --virtualbox|--virtual-box|--VirtualBox|--virtualBox|--Virtual-Box|--Virtualbox)
          uninstall_virtualbox
        ;;
        --visualstudiocode|--visual-studio-code|--code|--Code|--visualstudio|--visual-studio)
          uninstall_visualstudiocode
        ;;
        --vlc|--VLC|--Vlc)
          uninstall_vlc
        ;;
        --wireshark|--Wireshark)
          uninstall_wireshark
        ;;
        --youtube|--youtube-dl)
          uninstall_youtube-dl
        ;;
        
        ### WRAPPER ARGUMENT(S) ###
        -|--all)
          uninstall_all
        ;;
        
        
        *)  # Individual arguments
          process_argument ${key}
        ;;
      esac
      shift
    done
  fi


  ###############################
  ### POST-INSTALLATION CLEAN ###
  ###############################

  if [[ ${EUID} == 0 ]]; then
    if [[ ${FLAG_AUTOCLEAN} -gt 0 ]]; then
      output_proxy_executioner "echo INFO: Attempting to clean orphaned dependencies via apt-get autoremove." ${FLAG_QUIETNESS}
      output_proxy_executioner "apt-get -y autoremove" ${FLAG_QUIETNESS}
      output_proxy_executioner "echo INFO: Finished." ${FLAG_QUIETNESS}
    fi
    if [[ ${FLAG_AUTOCLEAN} == 2 ]]; then
      output_proxy_executioner "echo INFO: Attempting to delete useless files in cache via apt-get autoremove." ${FLAG_QUIETNESS}
      output_proxy_executioner "apt-get -y autoclean" ${FLAG_QUIETNESS}
      output_proxy_executioner "echo INFO: Finished." ${FLAG_QUIETNESS}
    fi
  fi

  # Make the bell sound at the end
  echo -en "\07"; echo -en "\07"; echo -en "\07"}


# Import file of common variables in a relative way, so customizer can be called system-wide
# RF, duplication in uninstall. Common extraction in the future in the common endpoint customizer.sh
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then
  DIR="${PWD}"
fi
if [[ -f "${DIR}/common_data.sh" ]]; then
  source "${DIR}/common_data.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: common_data.sh does not exist. Aborting..."
  exit 1
fi

# Call main function
main "$@"

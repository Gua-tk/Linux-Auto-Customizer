#!/usr/bin/env bash

###### AUXILIAR FUNCTIONS ######

# Prints the given arguments to the stderr
err()
{
  echo "$*" >&2
}

uninstall_gcc()
{
  apt-get purge -y gcc
}

uninstall_google_chrome()
{
  apt-get purge -y google-chrome-stable
  rm -f ${XDG_DESKTOP_DIR}/chrome*
}

uninstall_git()
{
  apt-get purge -y git-all
}

uninstall_latex()
{
  apt-get purge -y texlive-latex-extra
  rm -f ${XDG_DESKTOP_DIR}/texdoctk.desktop
  rm -f ${XDG_DESKTOP_DIR}/texmaker.desktop
}

uninstall_python3()
{
  apt-get purge -y python3-dev
  apt-get purge -y python-dev
}

uninstall_GNU_parallel()
{
  apt-get purge -y parallel
}

uninstall_pypy3_dependencies()
{
  apt-get purge -y pkg-config libfreetype6-dev libpng-dev libffi-dev
}

uninstall_templates()
{
  rm -f ${XDG_TEMPLATES_DIR}/*
}

uninstall_shell_customization()
{
  mv /home/${SUDO_USER}/.bashrc.bak /home/${SUDO_USER}/.bashrc
  chmod 775 /home/${SUDO_USER}/.bashrc
  chgrp ${SUDO_USER} $/home/${SUDO_USER}/.bashrc
  chown ${SUDO_USER} /home/${SUDO_USER}/.bashrc
}

uninstall_pycharm_professional()
{
  rm -Rf ${USR_BIN_FOLDER}/pycharm-${pycharm_professional_ver}
  rm -f ${XDG_DESKTOP_DIR}/pycharm-pro
  rm -f /home/${SUDO_USER}/.local/bin/pycharm-pro
  rm -f /home/${SUDO_USER}/.local/share/applications/pycharm-pro.desktop
}

uninstall_pycharm_community()
{
  rm -Rf ${USR_BIN_FOLDER}/${pycharm_version}
  rm -f ${XDG_DESKTOP_DIR}/pycharm
  rm -f /home/${SUDO_USER}/.local/bin/pycharm
  rm -f /home/${SUDO_USER}/.local/share/applications/pycharm.desktop
}

uninstall_clion()
{
  rm -Rf ${USR_BIN_FOLDER}/${clion_version_caps_down}
  rm -f ${XDG_DESKTOP_DIR}/clion
  rm -f /home/${SUDO_USER}/.local/bin/clion
  rm -f /home/${SUDO_USER}/.local/share/applications/clion.desktop
}

uninstall_sublime_text()
{
  rm -Rf ${USR_BIN_FOLDER}/sublime_text_3
  rm -f ${XDG_DESKTOP_DIR}/sublime
  rm -f /home/${SUDO_USER}/.local/bin/sublime
  rm -f /home/${SUDO_USER}/.local/share/applications/sublime.desktop
}

uninstall_pypy3()
{
  rm -Rf ${USR_BIN_FOLDER}/${pypy3_version}
  rm -f /home/${SUDO_USER}/.local/bin/pypy3
  rm -f /home/${SUDO_USER}/.local/bin/pypy3-pip
}

uninstall_android_studio()
{
  rm -Rf ${USR_BIN_FOLDER}/android-studio
  rm -f /home/${SUDO_USER}/.local/bin/studio
  rm -f "${XDG_DESKTOP_DIR}/Android Studio.desktop"
  rm -f "/home/${SUDO_USER}/.local/share/applications/Android Studio.desktop"
}

uninstall_pdfgrep()
{
  apt-get purge -y pdfgrep
}

uninstall_vlc()
{
  apt-get purge -y vlc
}

uninstall_steam()
{
  apt-get install -y curl
  dpkg -P steam-launcher
}

uninstall_discord()
{
  rm -f ${HOME}/.local/bin/discord
  rm -f ${XDG_DESKTOP_DIR}/Discord.Desktop
  rm -Rf ${USR_BIN_FOLDER}/Discord
}

uninstall_megasync()
{
  dpkg -P megasync
  dpkg -P nautilus-megasync
  rm -f ${XDG_DESKTOP_DIR}/megasync.desktop
}

# Uninstall all functions
uninstall_all()
{
  uninstall_gcc
  uninstall_google_chrome
  uninstall_git
  uninstall_latex
  uninstall_python3
  uninstall_GNU_parallel
  uninstall_pypy3_dependencies
  uninstall_templates
  uninstall_shell_customization
  uninstall_pycharm_professional
  uninstall_pycharm_community
  uninstall_clion
  uninstall_sublime_text
  uninstall_pypy3
  uninstall_android_studio
  uninstall_pdfgrep
  uninstall_vlc
  uninstall_steam
  uninstall_discord
  uninstall_megasync
}

##################
###### MAIN ######
##################
main()
{
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
        -c|--gcc)
          uninstall_gcc
        ;;
        -o|--chrome|--Chrome|--google-chrome|--Google-Chrome)
          uninstall_google_chrome
        ;;
        -g|--git)
          uninstall_git
        ;;
        -x|--latex|--LaTeX)
          uninstall_latex
        ;;
        -p|--python|--python3|--Python3|--Python)
          uninstall_python3
        ;;
        -l|--parallel|--gnu_parallel|--GNUparallel|--GNUParallel|--gnu-parallel)
          uninstall_GNU_parallel
        ;;
        -d|--dependencies|--pypy3_dependencies|--pypy3Dependencies|--PyPy3Dependencies|--pypy3dependencies|--pypy3-dependencies)
          uninstall_pypy3_dependencies
        ;;
        -t|--templates)
          uninstall_templates
        ;;
        -e|--shell|--shellCustomization|--shellOptimization|--environment|--environmentaliases|--environment_aliases|--environmentAliases|--alias|--Aliases)
          uninstall_shell_customization
        ;;
        -h|--pycharmpro|--pycharmPro|--pycharm_pro)
          uninstall_pycharm_professional
        ;;
        -m|--pycharmcommunity|--pycharmCommunity|--pycharm_community|--pycharm|--pycharm-community)
          uninstall_pycharm_community
        ;;
        -n|--clion|--Clion|--CLion)
          uninstall_clion
        ;;
        -s|--sublime|--sublimeText|--sublime_text|--Sublime|--sublime-Text|--sublime-text)
          uninstall_sublime_text
        ;;
        -y|--pypy|--pypy3|--PyPy3|--PyPy)
          uninstall_pypy3
        ;;
        -a|--android|--AndroidStudio|--androidstudio|--studio|--android-studio|--android_studio|--Androidstudio)
          uninstall_android_studio
        ;;
        -f|--pdfgrep|--findpdf|--pdf)
          uninstall_pdfgrep
        ;;
        -v|--vlc|--VLC|--Vlc)
          uninstall_vlc
        ;;
        -w|--steam|--Steam|--STEAM)
          uninstall_steam
        ;;
        -i|--discord|--Discord|--disc)
          uninstall_discord
        ;;
        --mega|--Mega|--MEGA|--MegaSync|--MEGAsync|--MEGA-sync|--megasync)
          uninstall_megasync
        ;;
        -|--all)
          uninstall_all
        ;;
        *)    # unknown option
          POSITIONAL+=("$1") # save it in an array for later
          shift # past argument
          ;;
      esac
      shift
    done
  fi

  # Clean 
  apt -y -qq autoremove
  apt -y -qq autoclean

  return 0
}







# Import file of common variables
# WARNING: That makes that the script has to be executed from the directory containing it
source common_data.sh

# Call main function
main "$@"
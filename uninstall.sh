#!/usr/bin/env bash
rm -Rf /home/${SUDO_USER}/.bin

rm -f /home/${SUDO_USER}/.local/bin/pip-pypy3
rm -f /home/${SUDO_USER}/.local/bin/pypy3
rm -f /home/${SUDO_USER}/.local/bin/pycharm
rm -f /home/${SUDO_USER}/.local/bin/pycharm-pro
rm -f /home/${SUDO_USER}/.local/bin/subl
rm -f /home/${SUDO_USER}/.local/bin/sublime
rm -f /home/${SUDO_USER}/.local/bin/clion
rm -f /home/${SUDO_USER}/.local/bin/studio

rm -f /home/${SUDO_USER}/.local/share/applications/pycharm.desktop
rm -f /home/${SUDO_USER}/.local/share/applications/sublime.desktop
rm -f /home/${SUDO_USER}/.local/share/applications/sublime_text.desktop
rm -f /home/${SUDO_USER}/.local/share/applications/sublime-text.desktop
rm -f /home/${SUDO_USER}/.local/share/applications/clion.desktop
rm -f /home/${SUDO_USER}/.local/share/applications/jetbrains-clion.desktop
rm -f "/home/${SUDO_USER}/.local/share/applications/Android Studio.desktop"

rm -f /home/${SUDO_USER}/Escritorio/pycharm.desktop
rm -f /home/${SUDO_USER}/Escritorio/pycharm-pro.desktop
rm -f /home/${SUDO_USER}/Escritorio/sublime.desktop
rm -f /home/${SUDO_USER}/Escritorio/sublime_text.desktop
rm -f /home/${SUDO_USER}/Escritorio/sublime-text.desktop
rm -f /home/${SUDO_USER}/Escritorio/clion.desktop
rm -f /home/${SUDO_USER}/Escritorio/jetbrains-clion.desktop
rm -f "/home/${SUDO_USER}/Escritorio/Android Studio.desktop"

rm -f /home/${SUDO_USER}/Plantillas/*

apt-get remove -y git-all gcc python3-dev python-dev parallel pkg-config libfreetype6-dev libpng-dev libffi-dev texlive-latex-extra google-chrome-stable
apt -y -qq autoremove
apt -y -qq autoclean
# //RF chrome

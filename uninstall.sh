#!/usr/bin/env bash
rm -Rf ~/.bin

rm -f ~/.local/bin/pip-pypy3
rm -f ~/.local/bin/pypy3
rm -f ~/.local/bin/pycharm
rm -f ~/.local/bin/pycharm-pro
rm -f ~/.local/bin/subl
rm -f ~/.local/bin/sublime
rm -f ~/.local/bin/clion
rm -f ~/.local/bin/studio

rm -f ~/.local/share/applications/pycharm.desktop
rm -f ~/.local/share/applications/sublime.desktop
rm -f ~/.local/share/applications/sublime_text.desktop
rm -f ~/.local/share/applications/clion.desktop
rm -f ~/.local/share/applications/jetbrains-clion.desktop
rm -f "~/.local/share/applications/Android Studio.desktop"

rm -f ~/Escritorio/pycharm.desktop
rm -f ~/Escritorio/pycharm-pro.desktop
rm -f ~/Escritorio/sublime.desktop
rm -f ~/Escritorio/sublime_text.desktop
rm -f ~/Escritorio/clion.desktop
rm -f ~/Escritorio/jetbrains-clion.desktop
rm -f "~/Escritorio/Android Studio.desktop"

rm -f ~/Plantillas/*

apt-get remove git-all gcc python3-dev python-dev parallel pkg-config libfreetype6-dev libpng-dev texlive-latex-extra google-chrome-stable
apt -y -qq autoremove
apt -y -qq autoclean
# //RF chrome

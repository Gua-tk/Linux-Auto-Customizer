#!/usr/bin/env bash


# GLOBAL VARIABLES
# PERSONAL_LAUNCHERS_DIR: /home/username/.local/share/applications
# ALL_USERS_LAUNCHERS_DIR: /usr/share/applications
# USR_BIN_FOLDER: /home/username/.bin
# BASHRC_PATH: /home/username/.bashrc
# DIR_IN_PATH: /home/username/.local/bin

# Imported from ${HOME}/.config/user-dirs.dirs
# XDG_DESKTOP_DIR: /home/username/Desktop
# XDG_PICTURES_DIR: /home/username/Images
# XDG_TEMPLATES_DIR: /home/username/Templates
if [[ "$(whoami)" != "root" ]]; then
  # declare lenguage specific user environment variables
  source ${HOME}/.config/user-dirs.dirs

  # Fill var to locate user software
  USR_BIN_FOLDER=${HOME}/.bin

  # Locate bash customizing files
  BASHRC_PATH=${HOME}/.bashrc

  PERSONAL_LAUNCHERS_DIR=${HOME}/.local/share/applications

  ALL_USERS_LAUNCHERS_DIR=/usr/share/applications

  DIR_IN_PATH=${HOME}/.local/bin
else
  # declare same variables but with absolute path
  declare $(cat /home/${SUDO_USER}/.config/user-dirs.dirs | sed 's/#.*//g' | sed "s|\$HOME|/home/$SUDO_USER|g" | sed "s|\"||g")

  # Fill var to locate user software
  USR_BIN_FOLDER=/home/${SUDO_USER}/.bin

  # Locate bash customizing files
  BASHRC_PATH=/home/${SUDO_USER}/.bashrc

  PERSONAL_LAUNCHERS_DIR=/home/${SUDO_USER}/.local/share/applications

  ALL_USERS_LAUNCHERS_DIR=/usr/share/applications

  DIR_IN_PATH=/home/${SUDO_USER}/.local/bin
fi

# If there is no backup of bashrc do it conserving permissions
if  [[ ! -f ${BASHRC_PATH}.bak ]]; then
  cp -p ${BASHRC_PATH} ${BASHRC_PATH}.bak
fi


##### COMMON VARIABLES #####

android_studio_downloader=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.1.2.0/android-studio-ide-201.7042882-linux.tar.gz
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


clion_downloader=https://download.jetbrains.com/cpp/CLion-2020.1.tar.gz
clion_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=CLion
Icon=$HOME/.bin/clion/bin/clion.png
Exec=clion %F
Comment=C and C++ IDE for Professional Developers
Terminal=false
StartupWMClass=jetbrains-clion"

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

converters_downloader="https://github.com/Axlfc/asix1Atesting"

converters_bashrc_call="source ${HOME}/.bash_functions"

converters_links="

bintohex()
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

dropbox_version=2020.03.04

discord_launcher="[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=discord
Icon=${USR_BIN_FOLDER}/discord/discord.png
Type=Application
Categories=Network;InstantMessaging;"

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

gpaint_icon_path=/usr/share/icons/hicolor/scalable/apps/gpaint.svg

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

intellij_ultimate_version=ideaIU-2020.3.1
intellij_ultimate_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Ultimate Edition
Icon=${HOME}/.bin/idea-IU/bin/idea.png
Exec=ideau %f
Comment=Capable and Ergonomic IDE for JVM
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea"


intellij_community_version=ideaIC-2020.3.1
intellij_community_launcher="[Desktop Entry]
Version=13.0
Type=Application
Terminal=false
Comment=Capable and Ergonomic IDE for JVM
Categories=Development;IDE;
Icon=${HOME}/.bin/idea-IC/bin/idea.png
Exec=ideac %f
Name=IntelliJ IDEA Community Edition
StartupWMClass=jetbrains-idea"
megasync_version=megasync_4.3.8-1.1_amd64.deb
megasync_repository=https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/
megasync_integrator_version=nautilus-megasync_3.6.6_amd64.deb

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
PS1_custom="\[\e[1;37m\]\\d \\t \[\e[0;32m\]\\u\[\e[4;35m\]@\[\e[0;36m\]\\H\[\e[0;33m\] \\w\[\e[0;32m\] \\$ "

pycharm_version=pycharm-community-2020.3.2  # Targeted version of pycharm
pycharm_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm 
Icon=$HOME/.bin/pycharm-community/bin/pycharm.png
Exec=pycharm %F
Comment=Python IDE for Professional Developers
Terminal=false
StartupWMClass=jetbrains-pycharm"

pycharm_professional_version=pycharm-professional-2020.3.2  # Targeted version of pycharm
pycharm_professional_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Professional
Icon=$HOME/.bin/pycharm-pro/bin/pycharm.png
Exec=pycharm-pro %F
Comment=Python IDE for Professional Developers
Terminal=false
StartupWMClass=jetbrains-pycharm"

pypy3_downloader=https://downloads.python.org/pypy/pypy3.6-v7.3.1-linux64.tar.bz2
pypy3_version=$(echo ${pypy3_downloader} | rev | cut -d '/' -f1 | cut -d '.' -f3- | rev)  # get last piece of the last string

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

sublime_text_version=sublime_text_3_build_3211_x64  # Targeted version of sublime text
sublime_launcher="[Desktop Entry]
Version=1.0
Type=Application
Name=Sublime Text
GenericName=Text Editor
Icon=$HOME/.bin/sublime-text/Icon/256x256/sublime-text.png
Comment=General Purpose Programming Text Editor
Terminal=false
Exec=sublime %F"

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

c_file_template="#include \"c_script.h\"
  int main(int nargs, char* args[])
{
  printf(\"Hello World\");
}
"

c_header_file_template="// Includes
#include <stdio.h>
#include <stdbool.h>  // To use booleans
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

if __name__ == \"__main__\":
    exit(0)
"

bash_git_prompt_bashrc="
if [ -f ${USR_BIN_FOLDER}/.bash-git-prompt/gitprompt.sh ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source ${USR_BIN_FOLDER}/.bash-git-prompt/gitprompt.sh
fi
"

bash_file_template="#!/usr/bin/env bash\

main()
{
  echo \"Hello World\"
  exit 0
}

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



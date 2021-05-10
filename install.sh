#!/usr/bin/env bash
########################################################################################################################
# -Name: Linux Auto-Customizer installation of features.
# -Description: A set of programs, functions, aliases, templates, environment variables, wallpapers, desktop
# features... collected in a simple portable shell script to customize a Linux working environment.
# -Creation Date: 28/5/19
# -Last Modified: 28/5/21
# -Author: Aleix Mariné-Tena
# -Email: aleix.marine@estudiants.urv.cat
# -Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when
# logged as root).
# -Args: Accepts behavioural arguments with one hyphen (-f, -o, etc.) and feature selection with two hyphens
# (--pycharm, --gcc).
# -Usage: Installs the features given by argument.
# -License:
########################################################################################################################


################################
###### AUXILIAR FUNCTIONS ######
################################

create_folder_as_root()
{
  mkdir -p $1
  # Convert folder to a SUDO_ROOT user
  chgrp ${SUDO_USER} $1
  chown ${SUDO_USER} $1
  chmod 775 $1
}

# Associate a file type (mime type) to a certain application using its desktop launcher.
# Argument 1: File types. Example: application/x-shellscript
# Argument 2: Application. Example: sublime_text.desktop
register_file_associations()
{
# Check if mimeapps exists
if [[ -f ${HOME}/.config/mimeapps.list ]]; then
  # Check if the association between a mime type and desktop launcher is already existent
  if [[ -z "$(more ${HOME_FOLDER}/.config/mimeapps.list | grep -Eo "$1=.*$2" )" ]]; then
    # If mime type is not even present we can add the hole line
    if [[ -z "$(more ${HOME_FOLDER}/.config/mimeapps.list | grep -Fo "$1=" )" ]]; then
      sed -i "/\[Added Associations\]/a $1=$2;" ${HOME_FOLDER}/.config/mimeapps.list
    else
      # If not, mime type is already registered. We need to register another application for it
      if [[ -z "$(more ${HOME_FOLDER}/.config/mimeapps.list | grep -Eo "$1=.*;$" )" ]]; then
        # File type(s) is registered without comma. Add the program at the end of the line with comma
        sed -i "s|$1=.*$|&;$2;|g" ${HOME_FOLDER}/.config/mimeapps.list
      else
        # File type is registered with comma at the end. Just add program at end of line
        sed -i "s|$1=.*;$|&$2;|g" ${HOME_FOLDER}/.config/mimeapps.list
      fi
    fi
  fi
fi
}

# Creates a valid launcher for the normal user in the desktop using an
# already created launcher from an automatic install (using apt-get or dpkg).
# This function does not need to have root permissions for its instructions,
# but is expected to be call as root since it uses the variable $SUDO_USER 
# Argument 1: name of the desktop launcher in /usr/share/applications
copy_launcher()
{
  if [[ -f ${ALL_USERS_LAUNCHERS_DIR}/$1 ]]; then
    cp ${ALL_USERS_LAUNCHERS_DIR}/$1 ${XDG_DESKTOP_DIR}
    chmod 775 ${XDG_DESKTOP_DIR}/$1
    chgrp ${SUDO_USER} ${XDG_DESKTOP_DIR}/$1
    chown ${SUDO_USER} ${XDG_DESKTOP_DIR}/$1
  fi
}

# This function creates a valid launcher in the desktop using a a given string with the given name
# Argument 1: The string of the text of the desktop.
# Argument 2: The name of the launcher.
create_manual_launcher()
{
# If user
if [[ ${EUID} -ne 0 ]]; then
  echo -e "$1" > ${PERSONAL_LAUNCHERS_DIR}/$2.desktop
  chmod 775 ${PERSONAL_LAUNCHERS_DIR}/$2.desktop
  cp -p ${PERSONAL_LAUNCHERS_DIR}/$2.desktop ${XDG_DESKTOP_DIR}
else  # if root
  echo -e "$1" > ${ALL_USERS_LAUNCHERS_DIR}/$2.desktop
  chmod 775 ${ALL_USERS_LAUNCHERS_DIR}/$2.desktop
  chgrp ${SUDO_USER} ${ALL_USERS_LAUNCHERS_DIR}/$2.desktop
  chown ${SUDO_USER} ${ALL_USERS_LAUNCHERS_DIR}/$2.desktop
  cp -p ${ALL_USERS_LAUNCHERS_DIR}/$2.desktop ${XDG_DESKTOP_DIR}
fi
}

# Download and decompress a compressed file pointed by the provided link into USR_BIN_FOLDER.
# We assume that this compressed file contains only one folder in the root.
# Argument 1: link to the compressed file
# Argument 2: Final name of the folder
# Argument 3: Decompression options: [z, j, J, zip]
# Argument 4: Relative path to the selected binary to create the links in the path from the just decompressed folder
# Argument 5: Desired name for the hard-link that points to the previous binary
# Argument 6 and 7, 8 and 9, 10 and 11... : Same as argument 4 and 5
download_and_decompress()
{
  # Clean to avoid conflicts with previously installed software or aborted installation
  rm -f ${USR_BIN_FOLDER}/downloading_program*
  # Download in a subshell to avoid changing the working directory in the current shell
  (cd ${USR_BIN_FOLDER}; wget -qO "downloading_program" --show-progress "$1")

  if [[ "${3}" == "zip" ]]; then
    program_folder_name="$( unzip -l "${USR_BIN_FOLDER}/downloading_program" | head -4 | tail -1 | tr -s " " | cut -d " " -f5 | cut -d "/" -f1 )"
    unzip -l "${USR_BIN_FOLDER}/downloading_program"
  else
    # Capture root folder name
    program_folder_name=$( (tar -t$3f - | head -1 | cut -d "/" -f1) < ${USR_BIN_FOLDER}/downloading_program)
  fi


  # Check that variable program_folder_name is set, if not abort
  # Clean to avoid conflicts with previously installed software or aborted installation
  rm -Rf "${USR_BIN_FOLDER}/${program_folder_name:?"ERROR: The name of the installed program could not been captured"}"
  if [[ "${3}" == "zip" ]]; then
    (cd ${USR_BIN_FOLDER}; unzip "${USR_BIN_FOLDER}/downloading_program" )  # To avoid collisions
  else
    # Decompress in a subshell to avoid changing the working directory in the current shell
    (cd ${USR_BIN_FOLDER}; tar -x$3f -) < ${USR_BIN_FOLDER}/downloading_program
  fi
  # Delete downloaded files which will be no longer used
  rm -f ${USR_BIN_FOLDER}/downloading_program*
  # Clean older installation to avoid conflicts
  if [[ "${program_folder_name}" != "$2" ]]; then
    rm -Rf "${USR_BIN_FOLDER}/$2"
    # Rename folder for coherence
    mv "${USR_BIN_FOLDER}/${program_folder_name}" "${USR_BIN_FOLDER}/$2"
  fi
  # Save the final name of the folder to regenerate the full path after the shifts
  program_folder_name="$2"
  # Shift the first 3 arguments to have only from 4th argument to the last in order to call create_links_in_path
  shift
  shift
  shift
  # Create links in the PATH
  while [[ $# -gt 0 ]]; do
    # Clean to avoid collisions
    create_links_in_path "${USR_BIN_FOLDER}/${program_folder_name}/$1" $2
    shift
    shift
  done
}

# Argument 1: Absolute path to the binary you want to be in the PATH
# Argument 2: Name of the hard-link that will be created in the path
# Argument 3 and 4, 5 and 6, 7 and 8... : Same as argument 1 and 2
create_links_in_path()
{
  while [[ $# -gt 0 ]]; do
    # Clean to avoid collisions
    ln -sf "$1" ${DIR_IN_PATH}/$2
    shift
    shift
  done
}

# Installs a new bash feature, installing its script into your environment using .bashrc, which uses .bash_functions
# Can be called as root or as normal user with presumably with the same behaviour.
# Argument 1: Text containing all the code that will be saved into file, which will be sourced from bash_functions
# Argument 2: Name of the file.
add_bash_function()
{
  # Write code to bash functions folder with the name of the feature we want to install
  echo -e "$1" > ${BASH_FUNCTIONS_FOLDER}/$2

  if [[ ${EUID} == 0 ]]; then
    chgrp ${SUDO_USER} ${BASH_FUNCTIONS_FOLDER}/$2
    chown ${SUDO_USER} ${BASH_FUNCTIONS_FOLDER}/$2
    chmod 775 ${BASH_FUNCTIONS_FOLDER}/$2
  fi

  import_line="source ${BASH_FUNCTIONS_FOLDER}/$2"
  # Add import_line to .bash_functions (BASH_FUNCTIONS_PATH)
  if [[ -z $(cat ${BASH_FUNCTIONS_PATH} | grep -Fo "${import_line}") ]]; then
    echo ${import_line} >> ${BASH_FUNCTIONS_PATH}
  fi
}

# Download a package temporarily in USR_BIN_FOLDER and install it using dpkg or other package manager.
# Argument 1: Link to the package file to download
download_and_install_package()
{
  rm -f ${USR_BIN_FOLDER}/downloading_package*
  (cd ${USR_BIN_FOLDER}; wget -qO downloading_package --show-progress $1)
  dpkg -i ${USR_BIN_FOLDER}/downloading_package
  rm -f ${USR_BIN_FOLDER}/downloading_package*
}

############################
###### ROOT FUNCTIONS ######
############################

install_audacity()
{
  apt-get install -y audacity
  copy_launcher audacity.desktop
}

install_AutoFirma()
{
  apt-get install -y libnss3-tools

  rm -f ${USR_BIN_FOLDER}/downloading_package*
  (cd ${USR_BIN_FOLDER}; wget -qO downloading_package --show-progress "${autofirma_downloader}")
  rm -Rf ${USR_BIN_FOLDER}/autOfirma
  (cd ${USR_BIN_FOLDER}; unzip downloading_package -d autOfirma)  # To avoid collisions
  rm -f ${USR_BIN_FOLDER}/downloading_package
  dpkg -i ${USR_BIN_FOLDER}/autOfirma/AutoFirma*.deb
  rm -Rf ${USR_BIN_FOLDER}/autOfirma
}

install_atom()
{
  download_and_install_package ${atom_downloader}
  copy_launcher atom.desktop
}

install_caffeine()
{
  apt-get install -y caffeine
  copy_launcher caffeine-indicator.desktop
}

install_calibre()
{
  apt-get install -y calibre
  copy_launcher calibre-gui.desktop
}

install_cheese()
{
  apt-get install -y cheese
  copy_launcher org.gnome.Cheese.desktop
}

install_clementine()
{
  apt-get install -y clementine
  copy_launcher clementine.desktop
}

install_clonezilla()
{
  apt-get install -y clonezilla
  create_manual_launcher "${clonezilla_launcher}" "clonezilla"
}

install_cmatrix()
{
  apt-get install -y cmatrix
  create_manual_launcher "${cmatrix_launcher}" "cmatrix"
}

install_curl()
{
  apt-get install -y curl
}

# Dropbox desktop client and integration
install_dropbox()
{
  # Dependency
  apt-get -y install python3-gpg

  download_and_install_package ${dropbox_downloader}
  copy_launcher dropbox.desktop
}

install_copyq()
{
  apt-get install -y copyq
  copy_launcher "com.github.hluk.copyq.desktop"
}

install_ffmpeg()
{
  apt-get install -y ffmpeg
}

install_firefox()
{
  apt-get install -y firefox
  copy_launcher "firefox.desktop"
}

install_f-irc()
{
  apt-get install -y f-irc
  create_manual_launcher "${firc_launcher}" f-irc
}

install_freecad()
{
  apt-get install -y freecad
  copy_launcher "freecad.desktop"
}

install_gcc()
{
  apt-get install -y gcc
  add_bash_function "${gcc_function}" "gcc_function.sh"
}

install_geany()
{
  apt-get install -y geany
  copy_launcher geany.desktop
}

install_gimp()
{
  apt-get install -y gimp
  copy_launcher "gimp.desktop"
}

# Install GIT and all its related utilities (gitk e.g.)
install_git()
{
  apt-get install -y git-all
  apt-get install -y git-lfs
}

install_gnome-chess()
{
  apt-get install -y gnome-chess
  copy_launcher "org.gnome.Chess.desktop"
}

install_parallel()
{
  apt-get -y install parallel
}

install_gparted()
{
  apt-get install -y gparted
  copy_launcher "gparted.desktop"
}

install_google-chrome()
{
  # Dependencies
  apt-get install -y libxss1 libappindicator1 libindicator7

  download_and_install_package ${google_chrome_downloader}
  copy_launcher "google-chrome.desktop"
}

install_gvim()
{
  apt-get -y install vim-gtk3
  copy_launcher "gvim.desktop"
}

install_gpaint()
{
  apt-get -y install gpaint
  copy_launcher "gpaint.desktop"
  sed "s|Icon=gpaint.svg|Icon=${gpaint_icon_path}|" -i ${XDG_DESKTOP_DIR}/gpaint.desktop
}

install_iqmol()
{
  download_and_install_package ${iqmol_downloader}
  create_folder_as_root ${USR_BIN_FOLDER}/iqmol
  # Obtain icon for iqmol
  (cd ${USR_BIN_FOLDER}/iqmol; wget -q -O iqmol_icon.png ${iqmol_icon})
  create_manual_launcher "${iqmol_launcher}" iqmol
  add_bash_function "${iqmol_alias}" "iqmol_alias.sh"
}

install_inkscape()
{
  apt-get install -y inkscape
  copy_launcher "inkscape.desktop"
}

install_latex()
{
  # Dependencies
  apt-get install -y perl-tk texlive-latex-extra texmaker
  copy_launcher "texmaker.desktop"
  copy_launcher "texdoctk.desktop"
  echo "Icon=/usr/share/icons/Yaru/256x256/mimetypes/text-x-tex.png" >> ${XDG_DESKTOP_DIR}/texdoctk.desktop
}

install_libxcb-xtest0()
{
  apt-get install -y libxcb-xtest0
}

install_gnome-mahjongg()
{
  apt-get install -y gnome-mahjongg
  copy_launcher "org.gnome.Mahjongg.desktop"
}

# megasync + megasync nautilus.
install_megasync()
{
  # Dependencies
  apt-get install -y nautilus libc-ares2 libmediainfo0v5 libqt5x11extras5 libzen0v5

  download_and_install_package ${megasync_downloader}
  download_and_install_package ${megasync_integrator_downloader}
  copy_launcher megasync.desktop
}

# Mendeley Dependencies
install_mendeley_dependencies()
{
  # Mendeley dependencies
  apt-get install -y gconf2 qt5-default qt5-doc qt5-doc-html qtbase5-examples qml-module-qtwebengine
}

install_gnome-mines()
{
  apt-get install -y gnome-mines
  copy_launcher "org.gnome.Mines.desktop"
}

# Automatic install + Creates desktop launcher in launcher and in desktop.
# Deprecated app, is not maintained by google anymore
install_musicmanager()
{
  download_and_install_package ${music_manager_downloader}
  copy_launcher "google-musicmanager.desktop"
}

install_nemo()
{
  # Delete Nautilus, the default desktop manager to avoid conflicts
  apt-get purge -y nautilus gnome-shell-extension-desktop-icons
  apt-get install -y nemo dconf-editor gnome-tweak-tool
  # Create special launcher to execute nemo daemon at system start
  echo -e "${nemo_desktop_launcher}" > /etc/xdg/autostart/nemo-autostart.desktop
  # nemo configuration
  xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
  gsettings set org.gnome.desktop.background show-desktop-icons false
  gsettings set org.nemo.desktop show-desktop-icons true

  copy_launcher "nemo.desktop"
}

install_net-tools()
{
  apt-get install -y net-tools
}

install_notepadqq()
{
  apt-get install -y notepadqq
  copy_launcher notepadqq.desktop
}

install_openoffice()
{
  # Delete old versions of openoffice to avoid conflicts
  apt-get remove -y libreoffice-base-core libreoffice-impress libreoffice-calc libreoffice-math libreoffice-common libreoffice-ogltrans libreoffice-core libreoffice-pdfimport libreoffice-draw libreoffice-style-breeze libreoffice-gnome libreoffice-style-colibre libreoffice-gtk3 libreoffice-style-elementary libreoffice-help-common libreoffice-style-tango libreoffice-help-en-us libreoffice-writer
  echo $?

  rm -f ${USR_BIN_FOLDER}/office*
  (cd ${USR_BIN_FOLDER}; wget -q --show-progress -O office ${openoffice_downloader})

  echo $?
  rm -Rf ${USR_BIN_FOLDER}/en-US
  echo si
  (cd ${USR_BIN_FOLDER}; tar -xzf -) < ${USR_BIN_FOLDER}/office
  echo no
  rm -f ${USR_BIN_FOLDER}/office

  dpkg -i ${USR_BIN_FOLDER}/en-US/DEBS/*.deb
  dpkg -i ${USR_BIN_FOLDER}/en-US/DEBS/desktop-integration/*.deb
  rm -Rf ${USR_BIN_FOLDER}/en-US

  copy_launcher "openoffice4-base.desktop"
  copy_launcher "openoffice4-calc.desktop"
  copy_launcher "openoffice4-draw.desktop"
  copy_launcher "openoffice4-math.desktop"
  copy_launcher "openoffice4-writer.desktop"
}

install_obs()
{
  install_ffmpeg

  apt-get install -y obs-studio
  create_manual_launcher "${obs_desktop_launcher}" obs-studio
}

install_okular()
{
  apt-get -y install okular
  copy_launcher "org.kde.okular.desktop"
}

install_pacman()
{
  apt-get install -y pacman
  copy_launcher "pacman.desktop"
}

install_pdfgrep()
{
  apt-get install -y pdfgrep
}

install_psql()
{
  apt-get install -y postgresql-client-12	postgresql-12 libpq-dev postgresql-server-dev-12
}

install_pluma()
{
  apt-get install -y pluma
  copy_launcher "pluma.desktop"
}

install_pypy3_dependencies()
{
  apt-get install -y -qq pkg-config libfreetype6-dev libpng-dev libffi-dev
}

install_python3()
{
  apt-get install -y python3-dev python-dev python3-pip
}

install_shotcut()
{
  apt-get install -y shotcut
  create_manual_launcher "${shotcut_desktop_launcher}" shotcut
}

install_slack()
{
  download_and_install_package ${slack_repository}
  copy_launcher "slack.desktop"
}

install_aisleriot()
{
  apt-get install -y aisleriot
  copy_launcher sol.desktop
}

# steam ubuntu client
install_steam()
{
  download_and_install_package ${steam_downloader}
  copy_launcher steam.desktop
}

install_gnome-sudoku()
{
  apt-get install -y gnome-sudoku
  copy_launcher org.gnome.Sudoku.desktop
}

install_terminator()
{
  apt-get -y install terminator
  copy_launcher terminator.desktop
}

install_thunderbird()
{
  apt-get install -y thunderbird
  copy_launcher thunderbird.desktop
}

install_tilix()
{
  apt-get install -y tilix
  copy_launcher com.gexperts.Tilix.desktop
}

install_tmux()
{
  apt-get install -y tmux
  create_manual_launcher "${tmux_launcher}" tmux
}

install_tor()
{
  apt-get install -y torbrowser-launcher
  copy_launcher "torbrowser.desktop"
}

install_transmission()
{
  apt-get install -y transmission
  copy_launcher "transmission-gtk.desktop"
  create_links_in_path "$(which transmission-gtk)" transmission
}

install_uget()
{
  # Dependencies
  apt-get install -y aria2
  apt-get install -y uget
  copy_launcher uget-gtk.desktop
}

install_vlc()
{
  apt-get -y install vlc
  copy_launcher "vlc.desktop"
}

install_virtualbox()
{
  # Dependencies
  apt-get install -y libqt5opengl5
  
  download_and_install_package ${virtualbox_downloader}
  copy_launcher "virtualbox.desktop"
}

install_wireshark()
{
  echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
  DEBIAN_FRONTEND=noninteractive
  apt-get install -y wireshark
  copy_launcher "wireshark.desktop"
  sed -i 's-Icon=.*-Icon=/usr/share/icons/hicolor/scalable/apps/wireshark.svg-' ${XDG_DESKTOP_DIR}/wireshark.desktop
}



#####################################
###### USER SOFTWARE FUNCTIONS ######
#####################################

install_ant()
{
  download_and_decompress ${ant_downloader} "apache_ant" "z" "bin/ant" "ant"
}

install_libgtkglext1()
{
  apt-get install -y libgtkglext1
}

install_anydesk()
{
  download_and_decompress ${anydesk_downloader} "anydesk" "z" "anydesk" "anydesk"
  create_manual_launcher "${anydesk_launcher}" "anydesk"
}

install_studio()
{
  download_and_decompress ${android_studio_downloader} "android-studio" "z" "bin/studio.sh" "studio"

  create_manual_launcher "${android_studio_launcher}" "Android_Studio"

  add_bash_function "${android_studio_alias}" "studio_alias.sh"
}

install_clion()
{
  download_and_decompress ${clion_downloader} "clion" "z" "bin/clion.sh" "clion"

  create_manual_launcher "${clion_launcher}" "clion"

  register_file_associations "text/x-c++hdr" "clion.desktop"
  register_file_associations "text/x-c++src" "clion.desktop"
  register_file_associations "text/x-chdr" "clion.desktop"
  register_file_associations "text/x-csrc" "clion.desktop"

  add_bash_function "${clion_alias}" "clion_alias.sh"
}

# Does not work because the root directory of the compressed is called ".". Wait until the developers change it
install_codium()
{
  download_and_decompress ${codium_downloader} "codium" "z" "bin/codium" "codium"
  create_manual_launcher "${codium_launcher}" "codium"
}

# discord desktop client
# Permissions: user
install_discord()
{
  download_and_decompress ${discord_downloader} "discord" "z" "Discord" "discord"

  create_manual_launcher "${discord_launcher}" "discord"
}

install_docker()
{
  download_and_decompress ${docker_downloader} "docker" "z" "docker" "docker" "containerd" "containerd" "containerd-shim" "containerd-shim" "containerd-shim-runc-v2" "containerd-shim-runc-v2" "ctr" "ctr" "docker" "docker" "dockerd" "dockerd" "docker-init" "docker-init" "docker-proxy" "docker-proxy" "runc" "runc"
}

# Install Eclipse IDE
install_eclipse()
{
  download_and_decompress ${eclipse_downloader} "eclipse" "z" "eclipse" "eclipse"

  create_manual_launcher "${eclipse_launcher}" "eclipse"
}

install_geogebra()
{

  download_and_decompress ${geogebra_downloader} "geogebra" "zip" "GeoGebra" "geogebra"
  wget ${geogebra_icon} -q --show-progress -O ${USR_BIN_FOLDER}/geogebra/GeoGebra.svg
  create_manual_launcher "${geogebra_desktop}" "geogebra"
}


# Install IntelliJ Community
install_ideac()
{
  download_and_decompress ${intellij_community_downloader} "idea-ic" "z" "bin/idea.sh" "ideac"

  create_manual_launcher "${intellij_community_launcher}" "ideac"

  register_file_associations "text/x-java" "ideac.desktop"

  add_bash_function "${ideac_alias}" "ideac_alias.sh"
}

# Install IntelliJ Ultimate
install_ideau()
{
  download_and_decompress ${intellij_ultimate_downloader} "idea-iu" "z" "bin/idea.sh" "ideau"

  create_manual_launcher "${intellij_ultimate_launcher}" "ideau"

  register_file_associations "text/x-java" "ideau.desktop"

  add_bash_function "${ideau_alias}" "ideau_alias.sh"
}

install_java()
{
  download_and_decompress ${java_downloader} "jdk8" "z" "bin/java" "java"
  add_bash_function "${java_globalvar}" "java_javahome.sh"
}

install_mvn()
{
  download_and_decompress ${maven_downloader} "maven" "z" "bin/mvn" "mvn"
}

# Manual install, creating launcher in the launcher and in desktop. Modifies .desktop file provided by the software
install_mendeley()
{
  download_and_decompress ${mendeley_downloader} "mendeley" "j" "bin/mendeleydesktop" "mendeley"

  # Create Desktop launcher
  cp ${USR_BIN_FOLDER}/mendeley/share/applications/mendeleydesktop.desktop ${XDG_DESKTOP_DIR}
  chmod 775 ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
  # Modify Icon line
  sed -i s-Icon=.*-Icon=${HOME}/.bin/mendeley/share/icons/hicolor/128x128/apps/mendeleydesktop.png- ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
  # Modify exec line
  sed -i 's-Exec=.*-Exec=mendeley %f-' ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
  # Copy to desktop  launchers of the current user
  cp -p ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop ${PERSONAL_LAUNCHERS_DIR}
}

# Installs pycharm, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharm()
{
  download_and_decompress ${pycharm_downloader} "pycharm-community" "z" "bin/pycharm.sh" "pycharm"

  create_manual_launcher "$pycharm_launcher" "pycharm"

  register_file_associations "text/x-python" "pycharm.desktop"
  register_file_associations "text/x-python3" "pycharm.desktop"
  register_file_associations "text/x-sh" "pycharm.desktop"

  add_bash_function "${pycharm_alias}" "pycharm_alias.sh"
}

# Installs pycharm professional, links it to the PATH and creates a launcher for it in the desktop and in the apps folder
install_pycharmpro()
{
  download_and_decompress ${pycharm_professional_downloader} "pycharm-professional" "z" "bin/pycharm.sh" "pycharmpro"

  create_manual_launcher "$pycharm_professional_launcher" "pycharm-pro"

  register_file_associations "text/x-sh" "pycharm-pro.desktop"
  register_file_associations "text/x-python" "pycharm-pro.desktop"
  register_file_associations "text/x-python3" "pycharm-pro.desktop"

  add_bash_function "${pycharmpro_alias}" "pycharmpro_alias.sh"
}

# Installs pypy3 dependencies, pypy3 and basic modules (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
# Links it to the path
install_pypy3()
{
  download_and_decompress ${pypy3_downloader} "pypy3" "J"

  # Install modules using pip
  ${USR_BIN_FOLDER}/pypy3/bin/pypy3 -m ensurepip

  # Forces download of pip and of modules
  ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 --no-cache-dir -q install --upgrade pip
  ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 --no-cache-dir install cython numpy
  # Currently not supported
  # ${USR_BIN_FOLDER}/${pypy3_version}/bin/pip3.6 --no-cache-dir install matplotlib

  create_links_in_path "${USR_BIN_FOLDER}/pypy3/bin/pypy3" "pypy3" ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 pypy3-pip
}

# Install Sublime text 3
install_sublime()
{
  download_and_decompress ${sublime_text_downloader} "sublime-text" "j" "sublime_text" "sublime"

  create_manual_launcher "${sublime_text_launcher}" "sublime"

  # register file associations
  register_file_associations "text/x-sh" "sublime-text.desktop"
  register_file_associations "text/x-c++hdr" "sublime-text.desktop"
  register_file_associations "text/x-c++src" "sublime-text.desktop"
  register_file_associations "text/x-chdr" "sublime-text.desktop"
  register_file_associations "text/x-csrc" "sublime-text.desktop"
  register_file_associations "text/x-python" "sublime-text.desktop"
  register_file_associations "text/x-python3" "sublime-text.desktop"

  add_bash_function "${sublime_alias}" "sublime_alias.sh"
}

install_telegram()
{
  download_and_decompress ${telegram_downloader} "telegram" "J" "Telegram" "telegram"

  wget ${telegram_icon} -q --show-progress -O ${USR_BIN_FOLDER}/telegram/telegram.svg

  create_manual_launcher "${telegram_launcher}" "telegram"
}

# Microsoft Visual Studio Code
install_code()
{
  download_and_decompress ${visualstudiocode_downloader} "visual-studio" "z" "code" "code"

  create_manual_launcher "${visualstudiocode_launcher}" "code"

  add_bash_function "${code_alias}" "code_alias.sh"
}

install_youtube-dl()
{
  wget ${youtubedl_downloader} -q --show-progress -O ${USR_BIN_FOLDER}/youtube-dl
  chmod a+rx ${USR_BIN_FOLDER}/youtube-dl
  create_links_in_path ${USR_BIN_FOLDER}/youtube-dl youtube-dl
  add_bash_function "${youtubewav_alias}" youtube-wav_alias.sh

  hash -r
}

install_zoom()
{
  download_and_decompress ${zoom_downloader} "zoom" "J" "zoom" "zoom" "ZoomLauncher" "ZoomLauncher"

  create_manual_launcher "${zoom_launcher}" "zoom"

  wget ${zoom_icon_downloader} -q --show-progress -O ${USR_BIN_FOLDER}/zoom/zoom_icon.ico
}

#######################################
###### USER-ENVIRONMENT FEATURES ######
#######################################
# Most (all) of them just use user permissions

install_alert()
{
  add_bash_function "${alert_alias}" alert.sh
}

install_cheat()
{
  # Rf
  rm -f ${USR_BIN_FOLDER}/cheat.sh
  (cd ${USR_BIN_FOLDER}; wget -q --show-progress -O cheat.sh ${cheat_downloader})
  chmod 755 ${USR_BIN_FOLDER}/cheat.sh
  create_links_in_path ${USR_BIN_FOLDER}/cheat.sh cheat

}

install_converters()
{
  rm -Rf ${USR_BIN_FOLDER}/converters
  mkdir -p ${USR_BIN_FOLDER}/converters
  git clone ${converters_downloader} ${USR_BIN_FOLDER}/converters

  for converter in $(ls ${USR_BIN_FOLDER}/converters/converters); do
    create_links_in_path ${USR_BIN_FOLDER}/converters/converters/${converter} "$(echo ${converter} | cut -d "." -f1)"
  done

  add_bash_function "${converters_functions}" converters.sh
}

# Install templates (available files in the right click --> new --> ...)
install_templates()
{
  echo -e "${bash_file_template}" > ${XDG_TEMPLATES_DIR}/shell_script.sh
  echo -e "${python_file_template}" > ${XDG_TEMPLATES_DIR}/python3_script.py
  echo -e "${latex_file_template}" > ${XDG_TEMPLATES_DIR}/latex_document.tex
  echo -e "${makefile_file_template}" > ${XDG_TEMPLATES_DIR}/makefile
  echo "${c_file_template}" > ${XDG_TEMPLATES_DIR}/c_script.c
  echo "${c_header_file_template}" > ${XDG_TEMPLATES_DIR}/c_script_header.h
  > ${XDG_TEMPLATES_DIR}/empty_text_file.txt
  chmod 775 ${XDG_TEMPLATES_DIR}/*
}

install_l()
{
  add_bash_function "${l_function}" l.sh
}

install_extract()
{
  add_bash_function "${extract_function}" extract.sh
}

install_history_optimization()
{
  add_bash_function "${shell_history_optimization_function}" history.sh
}

install_git_aliases()
{
  add_bash_function "${git_aliases_function}" git_aliases.sh
  rm -Rf ${USR_BIN_FOLDER}/.bash-git-prompt
  git clone https://github.com/magicmonty/bash-git-prompt.git ${USR_BIN_FOLDER}/.bash-git-prompt --depth=1
}

install_s()
{
  add_bash_function "${s_function}" s.sh
}

install_shortcuts()
{
  add_bash_function "${shortcut_aliases}" shortcuts.sh
}

install_prompt()
{
  add_bash_function "${prompt_function}" prompt.sh
}


install_terminal_background()
{
  local -r profile_terminal=$(dconf list /org/gnome/terminal/legacy/profiles:/)
  if [[ ! -z "${profile_terminal}" ]]; then
    dconf write /org/gnome/terminal/legacy/profiles:/${profile}/background-color "'rgb(0,0,0)'"
  fi
}

install_chwlppr()
{
  # Install script changer to be executed manually or with crontab automatically
  echo "${wallpapers_changer_script}" > ${USR_BIN_FOLDER}/wallpaper_changer.sh
  chmod 775 ${USR_BIN_FOLDER}/wallpaper_changer.sh
  ln -sf ${USR_BIN_FOLDER}/wallpaper_changer.sh ${DIR_IN_PATH}/chwlppr

  echo "${wallpapers_cronjob}" > ${BASH_FUNCTIONS_FOLDER}/wallpapers_cronjob
  crontab ${BASH_FUNCTIONS_FOLDER}/wallpapers_cronjob


  # Download and install wallpaper
  rm -Rf ${XDG_PICTURES_DIR}/wallpapers
  mkdir -p ${XDG_PICTURES_DIR}/wallpapers
  git clone ${wallpapers_downloader} ${XDG_PICTURES_DIR}/wallpapers
  #cp ${XDG_PICTURES_DIR}/wallpapers/*.tar.gz ${XDG_PICTURES_DIR}
  #rm -Rf ${XDG_PICTURES_DIR}/wallpapers
  $(cd ${XDG_PICTURES_DIR}/wallpapers; tar -xzf *.tar.gz)
  rm -f ${XDG_PICTURES_DIR}/wallpapers/*.tar.gz

  for filename in $(ls); do
    if [[ -f "${XDG_PICTURES_DIR}/wallpapers/${filename}" ]]; then
      cp "/usr/share/backgrounds/${filename}" ${XDG_PICTURES_DIR}/wallpapers
    fi
  done
}


################################
###### AUXILIAR FUNCTIONS ######
################################

# Common piece of code in the execute_installation function
# Argument 1: forceness_bit
# Argument 2: quietness_bit
# Argument 3: program_function
execute_installation_install_feature()
{
  feature_name=$( echo "$3" | cut -d "_" -f2- )
  if [[ $1 == 1 ]]; then
    set +e
  else
    set -e
  fi
  output_proxy_executioner "echo INFO: Attemptying to install ${feature_name}." $2
  output_proxy_executioner $3 $2
  output_proxy_executioner "echo INFO: ${feature_name} installed." $2
  set +e
}

execute_installation_wrapper_install_feature()
{
  if [[ $1 == 1 ]]; then
    execute_installation_install_feature $2 $3 $4
  else
    type "${program_name}" &>/dev/null
    if [[ $? != 0 ]]; then
      execute_installation_install_feature $2 $3 $4
    else
      output_proxy_executioner "echo WARNING: $5 is already installed. Skipping..." $3
    fi
  fi
}

execute_installation()
{
  space=" "
  for (( i = 1 ; i != ${NUM_INSTALLATION} ; i++ )); do
    for program in ${installation_data[@]}; do
      # Installation bit processing
      installation_bit=$( echo ${program} | cut -d ";" -f1 )
      if [[ ${installation_bit} == ${i} ]]; then
        forceness_bit=$( echo ${program} | cut -d ";" -f2 )
        quietness_bit=$( echo ${program} | cut -d ";" -f3 )
        overwrite_bit=$( echo ${program} | cut -d ";" -f4 )
        program_function=$( echo ${program} | cut -d ";" -f6 )
        program_privileges=$( echo ${program} | cut -d ";" -f5 )

        program_name=$( echo ${program_function} | cut -d "_" -f2- )
        if [[ ${program_privileges} == 1 ]]; then
          if [[ ${EUID} -ne 0 ]]; then
            output_proxy_executioner "echo WARNING: ${program_name} needs root permissions to be installed. Skipping." ${quietness_bit}
          else
            execute_installation_wrapper_install_feature ${overwrite_bit} ${forceness_bit} ${quietness_bit} ${program_function} ${program_name}
          fi
        elif [[ ${program_privileges} == 0 ]]; then
          if [[ ${EUID} -ne 0 ]]; then
            execute_installation_wrapper_install_feature ${overwrite_bit} ${forceness_bit} ${quietness_bit} ${program_function} ${program_name}
          else
            output_proxy_executioner "echo WARNING: ${program_name} needs user permissions to be installed. Skipping." ${quietness_bit}
          fi
        fi
      fi
    done
  done
}

# Receives a list of feature function name (install_pycharm, install_vlc...) and applies the current flags to it,
# modifying the corresponding line of installation_data
add_program()
{
  while [[ $# -gt 0 ]]; do
    total=${#installation_data[*]}
    for (( i=0; i<$(( ${total} )); i++ )); do
      program_name=$(echo "${installation_data[$i]}" | rev | cut -d ";" -f1 | rev )

      if [[ "$1" == "${program_name}" ]]; then
        # Cut static bits
        rest=$(echo "${installation_data[$i]}" | cut -d ";" -f5- )
        # Append static bits to the state of the flags
        new="${FLAG_INSTALL};${FLAG_IGNORE_ERRORS};${FLAG_QUIETNESS};${FLAG_OVERWRITE};${rest}"
        installation_data[$i]=${new}
        # Update flags and program counter
        if [[ ${FLAG_INSTALL} -gt 0 ]]; then
          NUM_INSTALLATION=$(( ${NUM_INSTALLATION} + 1 ))
          FLAG_INSTALL=${NUM_INSTALLATION}
        fi
      fi
    done
    shift
  done
}

add_programs()
{
  while [[ $# -gt 0 ]]; do
    add_program "install_$1"
    shift
  done
}

##################
###### MAIN ######
##################
main()
{
  if [[ ${EUID} == 0 ]]; then  # root
    create_folder_as_root ${USR_BIN_FOLDER}
    create_folder_as_root ${BASH_FUNCTIONS_FOLDER}
    create_folder_as_root ${DIR_IN_PATH}
    create_folder_as_root ${PERSONAL_LAUNCHERS_DIR}

    if [[ ! -f ${BASH_FUNCTIONS_PATH} ]]; then
      echo "${bash_functions_init}" > "${BASH_FUNCTIONS_PATH}"
      chgrp ${SUDO_USER} ${BASH_FUNCTIONS_PATH}
      chown ${SUDO_USER} ${BASH_FUNCTIONS_PATH}
      chmod 775 ${BASH_FUNCTIONS_PATH}
      # Make sure that PATH is pointing to ${DIR_IN_PATH} (where we will put our soft links to the software)
      if [[ -z "$(echo "${PATH}" | grep -Eo "(.*:.*)*${DIR_IN_PATH}")" ]]; then  # If it is not in PATH, add to bash functions
        echo "export PATH=$PATH:${DIR_IN_PATH}" >> ${BASH_FUNCTIONS_PATH}
      fi
    fi
  else  # user
    mkdir -p ${USR_BIN_FOLDER}
    mkdir -p ${DIR_IN_PATH}
    mkdir -p ${PERSONAL_LAUNCHERS_DIR}
    mkdir -p ${BASH_FUNCTIONS_FOLDER}

    # If $BASH_FUNCTION_PATH does not exist, create the exit point when running not interactively.
    if [[ ! -f ${BASH_FUNCTIONS_PATH} ]]; then
      echo "${bash_functions_init}" > "${BASH_FUNCTIONS_PATH}"
    else
      # Import bash functions to know which functions are installed (used for detecting installed alias or functions)
      source ${BASH_FUNCTIONS_PATH}
    fi

    # Make sure that PATH is pointing to ${DIR_IN_PATH} (where we will put our soft links to the software)
    if [[ -z "$(echo "${PATH}" | grep -Eo "(.*:.*)*${DIR_IN_PATH}")" ]]; then  # If it is not in PATH, add to bash functions
      echo "export PATH=$PATH:${DIR_IN_PATH}" >> ${BASH_FUNCTIONS_PATH}
    fi
  fi

  # Make sure .bash_functions and its structure is present
  if [[ -z "$(cat ${BASHRC_PATH} | grep -Fo "source ${BASH_FUNCTIONS_PATH}" )" ]]; then  # .bash_functions not added
    echo -e "${bash_functions_import}" >> ${BASHRC_PATH}
  fi


  ###### ARGUMENT PROCESSING ######

  while [[ $# -gt 0 ]]; do
    key="$1"

    case ${key} in
      ### BEHAVIOURAL ARGUMENTS ###
      -v|--verbose)
        FLAG_QUIETNESS=0
        SILENT=0
      ;;
      -q|--quiet)
        FLAG_QUIETNESS=1
        SILENT=1
      ;;
      -Q|--Quiet)
        FLAG_QUIETNESS=2
        SILENT=2
      ;;

      -o|--overwrite|--overwrite-if-present)
        FLAG_OVERWRITE=1
      ;;
      -s|--skip|--skip-if-installed)
        FLAG_OVERWRITE=0
      ;;

      -i|--ignore|--ignore-errors)
        FLAG_IGNORE_ERRORS=1
      ;;
      -e|--exit|--exit-on-error)
        FLAG_IGNORE_ERRORS=0
      ;;

      # Force is the two previous active behaviours in one
      -f|--force)
        FLAG_IGNORE_ERRORS=1
        FLAG_OVERWRITE=1
      ;;

      -d|--dirty|--no-autoclean)
        AUTOCLEAN=0
      ;;
      -c|--clean)
        AUTOCLEAN=1
      ;;
      -C|--Clean)
        AUTOCLEAN=2
      ;;

      -U|--upgrade|--Upgrade)
        UPGRADE=2
      ;;
      -u|--update)
        UPGRADE=1
      ;;
      -k|--keep-system-outdated)
        UPGRADE=0
      ;;

      -n|--not|-!)
        FLAG_INSTALL=0
      ;;
      -y|--yes)
        FLAG_INSTALL=${NUM_INSTALLATION}
      ;;

      -h)
        output_proxy_executioner "echo ${help_common}${help_simple}" ${SILENT}
        exit 0
      ;;

      -H|--help)
        output_proxy_executioner "echo ${help_common}${help_arguments}" ${SILENT}
        exit 0
      ;;

      ### WRAPPERS ###
      --custom1)
        add_programs "${custom1[@]}"
      ;;
      --iochem)
        add_programs "${iochem[@]}"
      ;;

      ### INDIVIDUAL ARGUMENTS ###
      # Sorted alphabetically by function name:
      --alert|--alert-alias|--alias-alert)
        add_program install_alert
      ;;
      --android|--AndroidStudio|--androidstudio|--studio|--android-studio|--android_studio|--Androidstudio)
        add_program install_studio
      ;;
      --ant|--apache_ant|--apache-ant)
        add_program install_ant
      ;;
      --anydesk)
        add_program install_anydesk
      ;;
      --audacity|--Audacity)
        add_program install_audacity
      ;;
      --autofirma)
        add_program install_AutoFirma
      ;;
      --atom|--Atom)
        add_program install_atom
      ;;
      --curl|--Curl)
        add_program install_curl
      ;;
      --discord|--Discord|--disc)
        add_program install_discord
      ;;
      --docker|--Docker)
        add_program install_docker
      ;;
      --dropbox|--Dropbox|--DropBox|--Drop-box|--drop-box|--Drop-Box)
        add_program install_dropbox
      ;;
      --gcc|--GCC)
        add_program install_gcc
      ;;
      --caffeine|--Caffeine|--cafe|--coffee)
        add_program install_caffeine
      ;;
      --calibre|--Calibre|--cali)
        add_program install_calibre
      ;;
      --cheat|--cheat.sh|--Cheat.sh|--che)
        add_program install_cheat
      ;;
      --cheese|--Cheese)
        add_program install_cheese
      ;;
      --clementine|--Clementine)
        add_program install_clementine
      ;;
      --clion|--Clion|--CLion)
        add_program install_clion
      ;;
      --cmatrix|--Cmatrix)
        add_program install_cmatrix
      ;;
      --converters|--Converters)
        add_program install_converters
      ;;
      --clonezilla|--CloneZilla|--cloneZilla)
        add_program install_clonezilla
      ;;
      --codium|--vscodium)
        add_program install_codium
      ;;
      --copyq|--copy-q|--copy_q|--copqQ|--Copyq|--copy-Q)
        add_program install_copyq
      ;;
      --eclipse)
        add_program install_eclipse
      ;;
      --extract-function|-extract_function)
        add_program install_extract
      ;;
      --f-irc|--firc|--Firc|--irc)
        add_program install_f-irc
      ;;
      --firefox|--Firefox)
        add_program install_firefox
      ;;
      --freecad|--FreeCAD|--freeCAD)
        add_program install_freecad
      ;;
      --ffmpeg|--youtube-dl-dependencies)
        add_program install_ffmpeg
      ;;
      #--google-play-music|--musicmanager|--music-manager|--MusicManager|--playmusic|--GooglePlayMusic|--play-music|--google-playmusic|--Playmusic|--google-music)
      #  add_program install_musicmanager
      #;;
      --gpaint|--paint|--Gpaint)
        add_program install_gpaint
      ;;
      --geany|--Geany)
        add_program install_geany
      ;;
      --geogebra|--geogebra-classic-6|--Geogebra-6|--geogebra-6|--Geogebra-Classic-6|--geogebra-classic)
        add_program install_geogebra
      ;;
      --git)
        add_program install_git
      ;;
      --git-aliases|--git_aliases|--git-prompt)
        add_program install_git_aliases
      ;;
      --GIMP|--gimp|--Gimp)
        add_program install_gimp
      ;;
      --GNOME_Chess|--gnome_Chess|--gnomechess|--chess)
        add_program install_gnome-chess
      ;;
      --GParted|--gparted|--GPARTED|--Gparted)
        add_program install_gparted
      ;;
      --gvim|--vim-gtk3|--Gvim|--GVim)
        add_program install_gvim
      ;;
      --history-optimization)
        add_program install_history_optimization
      ;;
      --parallel|--gnu_parallel|--GNUparallel|--GNUParallel|--gnu-parallel)
        add_program install_parallel
      ;;
      --chrome|--Chrome|--google-chrome|--Google-Chrome)
        add_program install_google-chrome
      ;;
      --iqmol|--IQmol)
        add_program install_iqmol
      ;;
      --inkscape|--ink-scape|--Inkscape|--InkScape)
        add_program install_inkscape
      ;;
      --intellijcommunity|--intelliJCommunity|--intelliJ-Community|--intellij-community|--ideac)
        add_program install_ideac
      ;;
      --intellijultimate|--intelliJUltimate|--intelliJ-Ultimate|--intellij-ultimate|--ideau)
        add_program install_ideau
      ;;
      --java|--javadevelopmentkit|--java-development-kit|--java-development-kit-11|--java-development-kit11|--jdk|--JDK|--jdk11|--JDK11|--javadevelopmentkit-11)
        add_program install_java
      ;;
      --latex|--LaTeX|--tex|--TeX)
        add_program install_latex
      ;;
      --libgtkglext1)
        add_program install_libgtkglext1
      ;;
      --alias-l|--alias-ls|--l-alias|--ls-alias|--l)
        add_program install_l
      ;;
      --libxcb-xtest0)
        add_program install_libxcb-xtest0
      ;;
      --maven|--mvn)
        add_program install_mvn
      ;;
      --mahjongg|--Mahjongg|--gnome-mahjongg)
        add_program install_gnome-mahjongg
      ;;
      --mega|--Mega|--MEGA|--MegaSync|--MEGAsync|--MEGA-sync|--megasync)
        add_program install_megasync
      ;;
      --Mendeley|--mendeley|--mendeleyDesktop|--mendeley-desktop|--Mendeley-Desktop)
        add_program install_mendeley
      ;;
      --MendeleyDependencies|--mendeleydependencies|--mendeleydesktopdependencies|--mendeley-desktop-dependencies|--Mendeley-Desktop-Dependencies)
        add_program install_mendeley_dependencies
      ;;
      --mines|--Mines|--GNU-mines|--gnome-mines|--gnomemines)
        add_program install_gnome-mines
      ;;
      --nemo|--nemo-desktop|--Nemo-Desktop|--Nemodesktop|--nemodesktop|--Nemo|--Nemodesk|--NemoDesktop)
        add_program install_nemo
      ;;
      --net-tools|--nettools)
        add_program install_net-tools
      ;;
      --notepadqq|--Notepadqq|--notepadQQ|--NotepadQQ|--notepadQq|--notepadQq|--NotepadQq|--NotepadqQ)
        add_program install_notepadqq
      ;;
      --openoffice|--office|--Openoffice|--OpenOffice|--openOfice|--open_office|--Office)
        add_program install_openoffice
      ;;
      --OBS|--obs|--obs-studio|--obs_studio|--obs_Studio|--OBS_studio|--obs-Studio|--OBS_Studio|--OBS-Studio)
        add_program install_obs
      ;;
      --okular|--Okular|--okularpdf)
        add_program install_okular
      ;;
      --pacman|--pac-man)
        add_program install_pacman
      ;;
      --pdfgrep|--findpdf|--pdf)
        add_program install_pdfgrep
      ;;
      --pluma)
        add_program install_pluma
      ;;
      --postgreSQL|--PostGreSQL|--postgresql|--postgre-sql|--postgre-SQL|--psql|--pSQL|--p-SQL|--p-sql)
        add_program install_psql
      ;;
      --prompt)
        add_program install_prompt
      ;;
      --pycharmcommunity|--pycharmCommunity|--pycharm_community|--pycharm|--pycharm-community)
        add_program install_pycharm
      ;;
      --pycharmpro|--pycharmPro|--pycharm_pro|--pycharm-pro|--Pycharm-Pro|--PyCharm-pro)
        add_program install_pycharmpro
      ;;
      -p|--python|--python3|--Python3|--Python)
        add_program install_python3
      ;;
      --pypy|--pypy3|--PyPy3|--PyPy)
        add_program install_pypy3
      ;;
      --dependencies|--pypy3_dependencies|--pypy3Dependencies|--PyPy3Dependencies|--pypy3dependencies|--pypy3-dependencies)
        add_program install_pypy3_dependencies
      ;;
      --s|--s-function)
        add_program install_s
      ;;
      --shotcut|--ShotCut|--Shotcut|--shot-cut|--shot_cut)
        add_program install_shotcut
      ;;
      --shortcuts)
        add_program install_shortcuts
      ;;
      --slack|--Slack)
        add_program install_slack
      ;;
      --sudoku|--Sudoku|--gnome-sudoku)
        add_program install_gnome-sudoku
      ;;
      --solitaire|--Solitaire|--gnome-solitaire|--aisleriot)
        add_program install_aisleriot
      ;;
      --sublime|--sublimeText|--sublime_text|--Sublime|--sublime-Text|--sublime-text)
        add_program install_sublime
      ;;
      --sudoku|--Sudoku|--GNU-sudoku|--gnome-sudoku|--gnomesudoku)
        add_program install_sudoku
      ;;
      --steam|--Steam|--STEAM)
        add_program install_steam
      ;;
      --Telegram|--telegram)
        add_program install_telegram
      ;;
      --templates)
        add_program install_templates
      ;;
      --terminal-background|--terminal_background)
        add_program install_terminal_background
      ;;
      --Terminator|--terminator)
        add_program install_terminator
      ;;
      --Tilix|--tilix)
        add_program install_tilix
      ;;
      --tmux|--Tmux)
        add_program install_tmux
      ;;
      --thunderbird|--mozillathunderbird|--mozilla-thunderbird|--Thunderbird|--thunder-bird)
        add_program install_thunderbird
      ;;
      --tor|--torbrowser|--tor_browser|--TOR|--TOR-browser|--TOR-BROSWER|--TORBROWSER|--TOR_BROWSER|--TOR_browser)
        add_program install_tor
      ;;
      --transmission|--transmission-gtk|--Transmission)
        add_program install_transmission
      ;;
      --uget)
        add_program install_uget
      ;;
      --virtualbox|--virtual-box|--VirtualBox|--virtualBox|--Virtual-Box|--Virtualbox)
        add_program install_virtualbox
      ;;
      --visualstudiocode|--visual-studio-code|--code|--Code|--visualstudio|--visual-studio)
        add_program install_code
      ;;
      --vlc|--VLC|--Vlc)
        add_program install_vlc
      ;;
      --Wallpapers|--wallpapers|--chwlppr)
        add_program install_chwlppr
      ;;
      --wireshark|--Wireshark)
        add_program install_wireshark
      ;;
      --youtube-dl)
        add_program install_youtube-dl
      ;;
      --Zoom| --zoom)
        add_program install_zoom
      ;;

      ### WRAPPER ARGUMENTS ###
      --user|--regular|--normal)
        add_user_programs
      ;;
      --root|--superuser|--su)
        add_root_programs
      ;;
      --ALL|--all|--All)
        add_all_programs
      ;;
      *)    # unknown option
        output_proxy_executioner "echo ERROR: ${key} is not a recognized command. Skipping this argument." ${SILENT}
      ;;
    esac
    shift
  done

  # If we don't receive arguments we try to install everything that we can given our permissions
  if [[ ${NUM_INSTALLATION} == 0 ]]; then
    output_proxy_executioner "echo ERROR: No arguments provided to install feature. Displaying help and finishing..." ${SILENT}
    output_proxy_executioner "echo ${help_message}" ${SILENT}
    exit 0
  fi

  ####### EXECUTION #######

  ### PRE-INSTALLATION UPDATE ###

  if [[ ${EUID} == 0 ]]; then
    if [[ ${UPGRADE} -gt 0 ]]; then
      output_proxy_executioner "echo INFO: Attempting to update system via apt-get." ${SILENT}
      output_proxy_executioner "apt-get -y update" ${SILENT}
      output_proxy_executioner "echo INFO: System updated." ${SILENT}
    fi
    if [[ ${UPGRADE} == 2 ]]; then
      output_proxy_executioner "echo INFO: Attempting to upgrade system via apt-get." ${SILENT}
      output_proxy_executioner "apt-get -y upgrade" ${SILENT}
      output_proxy_executioner "echo INFO: System upgraded." ${SILENT}
    fi
  fi


  ### INSTALLATION ###

  execute_installation


  ### POST-INSTALLATION CLEAN ###

  if [[ ${EUID} == 0 ]]; then
    if [[ ${AUTOCLEAN} -gt 0 ]]; then
      output_proxy_executioner "echo INFO: Attempting to clean orphaned dependencies via apt-get autoremove." ${SILENT}
      output_proxy_executioner "apt-get -y autoremove" ${SILENT}
      output_proxy_executioner "echo INFO: Finished." ${SILENT}
    fi
    if [[ ${AUTOCLEAN} == 2 ]]; then
      output_proxy_executioner "echo INFO: Attempting to delete useless files in cache via apt-get autoremove." ${SILENT}
      output_proxy_executioner "apt-get -y autoclean" ${SILENT}
      output_proxy_executioner "echo INFO: Finished." ${SILENT}
    fi
  fi
}


# Import file of common variables in a relative way to themselves so they alw
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then
  DIR="${PWD}"
fi
source "${DIR}/common_data.sh"

# Call main function
main "$@"

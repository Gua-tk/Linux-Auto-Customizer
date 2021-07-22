#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer installation of features.                                                              #
# - Description: A set of programs, functions, aliases, templates, environment variables, wallpapers, desktop          #
# features... collected in a simple portable shell script to customize a Linux working environment.                    #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 19/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernández Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when   #
# logged as root) to install some of the features.                                                                     #
# - Arguments: Accepts behavioural arguments with one hyphen (-f, -o, etc.) and feature selection with two hyphens     #
# (--pycharm, --gcc).                                                                                                  #
# - Usage: Installs the features selected by argument, modifying its behaviour depending on the specified flags.       #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


########################################################################################################################
############################################# ROOT FUNCTIONS ###########################################################
########################################################################################################################

install_google-chrome()
{
  generic_install google-chrome

  add_keybinding "google-chrome" "<Primary><Alt><Super>O" "Google Chrome"
}

install_iqmol()
{
  download_and_install_package ${iqmol_downloader}
  create_folder ${USR_BIN_FOLDER}/iqmol
  # Obtain icon for iqmol
  (cd ${USR_BIN_FOLDER}/iqmol; wget -q -O iqmol_icon.png ${iqmol_icon})
  create_manual_launcher "${iqmol_launcher}" iqmol
  add_bash_function "${iqmol_alias}" "iqmol_alias.sh"
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

install_openoffice()
{
  # Delete old versions of openoffice to avoid conflicts
  apt-get remove -y libreoffice-base-core libreoffice-impress libreoffice-calc libreoffice-math libreoffice-common libreoffice-ogltrans libreoffice-core libreoffice-pdfimport libreoffice-draw libreoffice-style-breeze libreoffice-gnome libreoffice-style-colibre libreoffice-gtk3 libreoffice-style-elementary libreoffice-help-common libreoffice-style-tango libreoffice-help-en-us libreoffice-writer

  rm -f ${USR_BIN_FOLDER}/office*
  (cd ${USR_BIN_FOLDER}; wget -q --show-progress -O office ${openoffice_downloader})

  rm -Rf ${USR_BIN_FOLDER}/en-US
  (cd ${USR_BIN_FOLDER}; tar -xzf -) < ${USR_BIN_FOLDER}/office
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

install_R()
{
  generic_install R
  R -e "${R_jupyter_lab_function}"
}

install_sonic-pi()
{
  DEBIAN_FRONTEND=noninteractive
  generic_install sonic-pi
}

install_tmux()
{
  generic_install tmux
  autostart_program tmux
}

install_wireshark()
{
  # Used to install wireshark without prompt
  echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
  DEBIAN_FRONTEND=noninteractive

apt-get install -y wireshark
  copy_launcher "wireshark.desktop"
  sed -i 's-Icon=.*-Icon=/usr/share/icons/hicolor/scalable/apps/wireshark.svg-' ${XDG_DESKTOP_DIR}/wireshark.desktop
}

########################################################################################################################
######################################### USER SOFTWARE FUNCTIONS ######################################################
########################################################################################################################

install_branch()
{
  generic_install branch
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

install_code()
{
  download_and_decompress ${visualstudiocode_downloader} "visual-studio" "z" "code" "code"

  create_manual_launcher "${visualstudiocode_launcher}" "code"

  add_bash_function "${code_alias}" "code_alias.sh"
}

install_discord()
{
  download_and_decompress ${discord_downloader} "discord" "z" "Discord" "discord"
  create_manual_launcher "${discord_launcher}" "discord"
}

install_docker()
{
    download_and_decompress ${docker_downloader} "docker" "z" "docker" "docker" "containerd" "containerd" "containerd-shim" "containerd-shim" "containerd-shim-runc-v2" "containerd-shim-runc-v2" "ctr" "ctr" "dockerd" "dockerd" "docker-init" "docker-init" "docker-proxy" "docker-proxy" "runc" "runc"
}

install_eclipse()
{
  download "${eclipse_downloader}" "eclipse_downloading"
  decompress "z" "eclipse_downloading" "eclipse"
  create_manual_launcher "${eclipse_launcher}" "eclipse"
  create_links_in_path "eclipse" "Eclipse"
}

install_geogebra()
{

  download_and_decompress ${geogebra_downloader} "geogebra" "zip" "GeoGebra" "geogebra"

  wget "${geogebra_icon}" -q --show-progress -O ${USR_BIN_FOLDER}/geogebra/GeoGebra.svg

  create_manual_launcher "${geogebra_desktop}" "geogebra"
}

install_ideac()
{
  download_and_decompress ${ideac_downloader} "idea-ic" "z" "bin/idea.sh" "ideac"

  create_manual_launcher "${ideac_launcher}" "ideac"

  register_file_associations "text/x-java" "ideac.desktop"

  add_bash_function "${ideac_alias}" "ideac_alias.sh"
}

install_ideau()
{
  download_and_decompress ${ideau_downloader} "idea-iu" "z" "bin/idea.sh" "ideau"

  create_manual_launcher "${ideau_launcher}" "ideau"

  register_file_associations "text/x-java" "ideau.desktop"

  add_bash_function "${ideau_alias}" "ideau_alias.sh"
}

install_ijs()
{
  "${USR_BIN_FOLDER}/node/bin/npm" config set prefix "${HOME_FOLDER}/.local"
  "${USR_BIN_FOLDER}/node/bin/npm" install -g ijavascript
  "${DIR_IN_PATH}/ijsinstall"
}

install_java()
{
  download_and_decompress ${java_downloader} "jdk8" "z" "bin/java" "java"
  add_bash_function "${java_globalvar}" "java_javahome.sh"
}

install_julia()
{
  download "${julia_packageurls}" "${USR_BIN_FOLDER}/julia_downloading"
  decompress "z" "${USR_BIN_FOLDER}/julia_downloading" "julia"
  create_links_in_path "${USR_BIN_FOLDER}/julia/bin/julia" julia
  create_manual_launcher "${julia_launchercontents}" "julia"

  # install jupyter-lab dependencies
  julia -e '#!/.local/bin/julia
  using Pkg
  Pkg.add("IJulia")
  Pkg.build("IJulia")'
}

install_jupyter-lab()
{
  # Avoid collision with previous installations
  rm -Rf "${USR_BIN_FOLDER}/jupyter-lab"
  python3 -m venv "${USR_BIN_FOLDER}/jupyter-lab"

  # Install necessary pip and python packages
  "${USR_BIN_FOLDER}/jupyter-lab/bin/python3" -m pip install -U pip

  "${USR_BIN_FOLDER}/jupyter-lab/bin/pip" install wheel jupyter jupyterlab jupyterlab-git jupyterlab_markup

  "${USR_BIN_FOLDER}/jupyter-lab/bin/pip" install bash_kernel
  "${USR_BIN_FOLDER}/jupyter-lab/bin/python3" -m bash_kernel.install

  "${USR_BIN_FOLDER}/jupyter-lab/bin/pip" install pykerberos pywinrm[kerberos]
  "${USR_BIN_FOLDER}/jupyter-lab/bin/pip" install powershell_kernel
  "${USR_BIN_FOLDER}/jupyter-lab/bin/python3" -m powershell_kernel.install --powershell-command powershell

  "${USR_BIN_FOLDER}/jupyter-lab/bin/pip" install iarm
  "${USR_BIN_FOLDER}/jupyter-lab/bin/python3" -m iarm_kernel.install

  "${USR_BIN_FOLDER}/jupyter-lab/bin/pip" install ansible-kernel
  "${USR_BIN_FOLDER}/jupyter-lab/bin/python3" -m ansible_kernel.install

  "${USR_BIN_FOLDER}/jupyter-lab/bin/pip" install kotlin-jupyter-kernel
  "${USR_BIN_FOLDER}/jupyter-lab/bin/python3" -m kotlin_kernel fix-kernelspec-location

  "${USR_BIN_FOLDER}/jupyter-lab/bin/pip" install vim-kernel
  "${USR_BIN_FOLDER}/jupyter-lab/bin/python3" -m vim_kernel.install

  # Enable dark scrollbars by clicking on Settings -> JupyterLab Theme -> Theme Scrollbars in the JupyterLab menus.
  "${USR_BIN_FOLDER}/jupyter-lab/bin/pip" install theme-darcula
  "${USR_BIN_FOLDER}/jupyter-lab/bin/jupyter" labextension install @telamonian/theme-darcula
  "${USR_BIN_FOLDER}/jupyter-lab/bin/jupyter" labextension enable @telamonian/theme-darcula
  "${USR_BIN_FOLDER}/jupyter-lab/bin/jupyter" lab build

  create_links_in_path "${USR_BIN_FOLDER}/jupyter-lab/bin/jupyter-lab" jupyter-lab "${USR_BIN_FOLDER}/jupyter-lab/bin/jupyter" jupyter "${USR_BIN_FOLDER}/jupyter-lab/bin/ipython" ipython "${USR_BIN_FOLDER}/jupyter-lab/bin/ipython3" ipython3
  create_manual_launcher "${jupyter_lab_launchercontents}" "jupyter-lab"
  add_bash_function "${jupyter_lab_bashfunctions[0]}" "jupyter_lab.sh"pga
}

install_mendeley()
{
  download_and_decompress ${mendeley_downloader} "mendeley" "j" "bin/mendeleydesktop" "mendeley"

  # Create Desktop launcher
  cp ${USR_BIN_FOLDER}/mendeley/share/applications/mendeleydesktop.desktop ${XDG_DESKTOP_DIR}
  chmod 775 ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
  # Modify Icon line
  sed -i 's-Icon=.*-Icon=${HOME}/.bin/mendeley/share/icons/hicolor/128x128/apps/mendeleydesktop.png-' ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
  # Modify exec line
  sed -i 's-Exec=.*-Exec=mendeley %f-' ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop
  # Copy to desktop  launchers of the current user
  cp -p ${XDG_DESKTOP_DIR}/mendeleydesktop.desktop ${PERSONAL_LAUNCHERS_DIR}
}

install_mvn()
{
  download_and_decompress ${maven_downloader} "maven" "z" "bin/mvn" "mvn"
}

install_studio()
{
  download_and_decompress ${android_studio_downloader} "android-studio" "z" "bin/studio.sh" "studio"

  create_manual_launcher "${android_studio_launcher}" "Android_Studio"

  add_bash_function "${android_studio_alias}" "studio_alias.sh"
}

install_pgadmin()
{
  # Avoid collision and create venv for pgadmin in USR_BIN_FOLDER
  rm -Rf "${USR_BIN_FOLDER}/pgadmin"
  python3 -m venv "${USR_BIN_FOLDER}/pgadmin"

  # Source activate to activate the venv, so the venv python interpreter is the one actually used.
  source "${USR_BIN_FOLDER}/pgadmin/bin/activate"

  # Update pip and install git dependencies (wheel) and the program itself in the venv
  python -m pip install -U pip
  pip install wheel pgadmin4

  echo "${pgadmin_datafiles[0]}" > "${pgadmin_basefolder}/config_local.py"

  # deactivate virtual environment
  deactivate

  # Create a valid binary in the path. In this case if we want the same schema as other programs we need to set a
  # shebang that points to the virtual environment that we just created, so the python script of pgadmin has all the
  # information on how to call the script

  # Prepend shebang line to python3 interpreter of the venv
  echo "#!${USR_BIN_FOLDER}/pgadmin/bin/python3" | cat - "${USR_BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py" > "${USR_BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py.tmp" && mv "${USR_BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py.tmp" "${USR_BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py"
  chmod +x "${USR_BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py"
  create_links_in_path "${USR_BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py" pgadmin

  # Create launcher and structures to be able to launch pgadmin and access it using the browser
  create_manual_launcher "${pgadmin_launchercontents[0]}" pgadmin
  echo "${pgadmin_execscript}" > "${USR_BIN_FOLDER}/pgadmin/pgadmin_exec.sh"
  apply_permissions "${USR_BIN_FOLDER}/pgadmin/pgadmin_exec.sh"
}

install_postman()
{
  download_and_decompress "${postman_url}" "postman" "z" "Postman" "postman"
  #download "${postman_url}" "Postman"
  #decompress "z" "${USR_BIN_FOLDER}/Postman" "postman"
  #create_links_in_path "Postman/Postman" "postman"
  create_manual_launcher "${postman_launchercontents[0]}" "Postman"
}

# Installs pypy3 dependencies, pypy3 and basic modules (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
install_pypy3()
{
  download_and_decompress ${pypy3_downloader} "pypy3" "j"

  # Install modules using pip
  ${USR_BIN_FOLDER}/pypy3/bin/pypy3 -m ensurepip

  # Forces download of pip and of modules
  ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 --no-cache-dir -q install --upgrade pip
  ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 --no-cache-dir install cython numpy
  # Currently not supported
  # ${USR_BIN_FOLDER}/${pypy3_version}/bin/pip3.6 --no-cache-dir install matplotlib

  create_links_in_path "${USR_BIN_FOLDER}/pypy3/bin/pypy3" "pypy3" ${USR_BIN_FOLDER}/pypy3/bin/pip3.6 pypy3-pip
}

install_sysmontask()
{
  rm -Rf ${USR_BIN_FOLDER}/SysMonTask
  create_folder ${USR_BIN_FOLDER}/SysMonTask
  git clone ${sysmontask_downloader} ${USR_BIN_FOLDER}/SysMonTask
  #chgrp -R ${SUDO_USER} ${USR_BIN_FOLDER}/SysMonTask
  #chown -R ${SUDO_USER} ${USR_BIN_FOLDER}/SysMonTask
  #chmod -R 755 ${USR_BIN_FOLDER}/SysMonTask
  $(cd ${USR_BIN_FOLDER}/SysMonTask && python3 setup.py install &>/dev/null)
  #python3 ${USR_BIN_FOLDER}/SysMonTask/setup.py install
  copy_launcher "SysMonTask.desktop"
}

install_telegram()
{
  download_and_decompress ${telegram_downloader} "telegram" "J" "Telegram" "telegram"

  wget ${telegram_icon} -q --show-progress -O ${USR_BIN_FOLDER}/telegram/telegram.svg

  create_manual_launcher "${telegram_launcher}" "telegram"
}

install_tomcat()
{
  download "${tomcat_inheritedcompressedfileurl}" "tomcat_downloading"
  decompress "${tomcat_inheritedcompressedfiletype}" "${USR_BIN_FOLDER}/tomcat_downloading" tomcat
}

install_youtube-dl()
{
  wget ${youtubedl_downloader} -q --show-progress -O ${USR_BIN_FOLDER}/youtube-dl
  chmod a+rx ${USR_BIN_FOLDER}/youtube-dl
  create_links_in_path ${USR_BIN_FOLDER}/youtube-dl youtube-dl
  add_bash_function "${youtubewav_alias}" youtube-wav_alias.sh
}

install_zoom()
{
  download_and_decompress ${zoom_downloader} "zoom" "J" "zoom" "zoom" "ZoomLauncher" "ZoomLauncher"

  create_manual_launcher "${zoom_launcher}" "zoom"

  wget ${zoom_icon_downloader} -q --show-progress -O ${USR_BIN_FOLDER}/zoom/zoom_icon.ico
}


########################################################################################################################
######################################### USER-ENVIRONMENT FUNCTIONS ###################################################
########################################################################################################################


install_bashcolors()
{
  add_bash_function "${bashcolors_function}" bashcolors.sh
}

install_bi()
{
  generic_install bi
}

install_c()
{
  add_bash_function "${c_function}" c.sh
}

install_change-bg()
{
  # Install script changer to be executed manually or with crontab automatically
  echo "${wallpapers_changer_script}" > ${USR_BIN_FOLDER}/wallpaper_changer.sh
  chmod 775 ${USR_BIN_FOLDER}/wallpaper_changer.sh
  ln -sf ${USR_BIN_FOLDER}/wallpaper_changer.sh ${DIR_IN_PATH}/change-bg

  echo "${wallpapers_cronjob}" > ${BASH_FUNCTIONS_FOLDER}/wallpapers_cronjob
  crontab ${BASH_FUNCTIONS_FOLDER}/wallpapers_cronjob

  # Download and install wallpaper
  rm -Rf ${XDG_PICTURES_DIR}/wallpapers
  mkdir -p ${XDG_PICTURES_DIR}/wallpapers
  git clone ${wallpapers_downloader} ${XDG_PICTURES_DIR}/wallpapers

  $(cd ${XDG_PICTURES_DIR}/wallpapers; tar -xzf *.tar.gz)
  rm -f ${XDG_PICTURES_DIR}/wallpapers/*.tar.gz

  for filename in $(ls /usr/share/backgrounds); do
    if [ -f "/usr/share/backgrounds/${filename}" ]; then
      cp "/usr/share/backgrounds/${filename}" "${XDG_PICTURES_DIR}/wallpapers"
    fi
  done
}

install_checkout()
{
  generic_install checkout
}

install_commit()
{
  generic_install commit
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

install_document()
{
  add_internet_shortcut document
}

install_drive()
{
  add_internet_shortcut drive
}

install_duckduckgo()
{
  add_internet_shortcut duckduckgo
}

install_dummycommit()
{
  generic_install dummycommit
}

install_e()
{
  add_bash_function "${e_function}" e.sh
}

install_extract()
{
  add_bash_function "${extract_function}" extract.sh
}

install_facebook()
{
  add_internet_shortcut facebook
}

install_fonts-alegreya-sans()
{
  add_font ${fonts_alegreya_sans_compressedfileurls} zip alegreya_sans
}

install_fonts-oxygen()
{
  add_font ${fonts_oxygen_compressedfileurls} zip oxygen
}

install_fonts-lato()
{
  add_font ${fonts_lato_compressedfileurls} zip lato
}

install_fonts-oswald()
{
  add_font ${fonts_oswald_compressedfileurls} zip oswald
}

install_fonts-noto-sans()
{
  add_font ${fonts_noto_sans_compressedfileurls} zip noto_sans
}

install_fetch()
{
  generic_install fetch
}

install_forms()
{
  add_internet_shortcut forms
}

install_g()
{
  generic_install g
}

install_gitprompt()
{
  add_bash_function "${gitprompt_bashfunctions[0]}" git_prompt.sh
  rm -Rf ${USR_BIN_FOLDER}/.bash-git-prompt
  git clone https://github.com/magicmonty/bash-git-prompt.git ${USR_BIN_FOLDER}/.bash-git-prompt --depth=1
}

install_gitlab()
{
  add_internet_shortcut gitlab
}

install_gmail()
{
  add_internet_shortcut gmail
}

install_googlecalendar()
{
  add_internet_shortcut googlecalendar
}

install_h()
{
  generic_install h
}

install_hard()
{
  generic_install hard
}

install_history-optimization()
{
  add_bash_function "${shell_history_optimization_function}" history.sh
}

install_ipe()
{
  add_bash_function "${ipe_function}" ipe.sh
}

install_ipi()
{
  add_bash_function "${ipi_function}" ipi.sh
}

install_instagram()
{
  add_internet_shortcut instagram
}

install_j()
{
  generic_install j
}

install_keep()
{
  add_internet_shortcut keep
  add_to_favorites "keep.desktop"
}

install_L()
{
  add_bash_function "${L_function}" L.sh
}

install_l()
{
  add_bash_function "${l_function}" l.sh
}

install_lab()
{
  generic_install lab
}

install_netflix()
{
  add_internet_shortcut netflix
  add_to_favorites "netflix.desktop"
}

install_node()
{
  download "${node_packageurls}" "${USR_BIN_FOLDER}/node_downloading"
  decompress "J" "${USR_BIN_FOLDER}/node_downloading" "node"
  create_links_in_path "${USR_BIN_FOLDER}/node/bin/node" node "${USR_BIN_FOLDER}/node/bin/npm" npm "${USR_BIN_FOLDER}/node/bin/npx" npx
}

install_notebook()
{
  generic_install notebook
}

install_o()
{
  add_bash_function "${o_function}" o.sh
}

install_onedrive()
{
  add_internet_shortcut onedrive
}

install_openssl102()
{
  generic_install "openssl102"
}

install_outlook()
{
  add_internet_shortcut outlook
}

install_overleaf()
{
  add_internet_shortcut overleaf
}

install_push()
{
  generic_install push
}

install_presentation()
{
  add_internet_shortcut presentation
}

install_prompt()
{
  add_bash_function "${prompt_functions[0]}" prompt.sh
}

install_reddit()
{
  add_internet_shortcut reddit
}

install_rstudio()
{
  download "${rstudio_packageurls}" "rstudio_downloading"
  decompress "z" "${USR_BIN_FOLDER}/rstudio_downloading" "rstudio"
  create_links_in_path "${USR_BIN_FOLDER}/rstudio/bin/rstudio" rstudio
  create_manual_launcher "${rstudio_launcher}" "rstudio"
  register_file_associations "text/plain" "rstudio.desktop"

}

install_s()
{
  add_bash_function "${s_function}" s.sh
}

install_screenshots()
{
  mkdir -p ${XDG_PICTURES_DIR}/screenshots
  add_bash_function "${screenshots_function}" "screenshots.sh"
}

install_shortcuts()
{
  add_bash_function "${shortcut_aliases}" shortcuts.sh
}

install_spreadsheets()
{
  add_internet_shortcut spreadsheets
}

install_status()
{
  generic_install status
}

install_system-fonts()
{
  # Interface text
  gsettings set org.gnome.desktop.interface font-name 'Roboto Medium 11'
  # Document text //RF
  gsettings set org.gnome.desktop.interface document-font-name 'Fira Code weight=453 10'
  # Monospaced text
  gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Regular 12'
  # Inherited window titles
  gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Hermit Bold 9'
}

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

install_terminal-background()
{
  local -r profile_uuid="$(gsettings get org.gnome.Terminal.ProfilesList default | cut -d "'" -f2)"
  #2E3436
  if [ -n "${profile_uuid}" ]; then
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"${profile_uuid}"/ use-theme-colors false
    # soft grey terminal background
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"${profile_uuid}"/ background-color 'rgb(43,54,60)'
    # green text terminal
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"${profile_uuid}"/ foreground-color 'rgb(28,135,39)'
    # Cursor like in a text editor

    gsettings set org.gnome.Terminal.Legacy.Profile:/:"${profile_uuid}"/ cursor-shape 'ibeam'
  fi
}

install_trello()
{
  add_internet_shortcut trello
}

install_tumblr()
{
  add_internet_shortcut tumblr
}

install_twitch()
{
  add_internet_shortcut twitch
}

install_twitter()
{
  add_internet_shortcut twitter
}

install_u()
{
  generic_install u
}

install_whatsapp()
{
  add_internet_shortcut whatsapp
}

install_wikipedia()
{
  add_internet_shortcut wikipedia
}

install_youtube()
{
  add_internet_shortcut youtube
}

install_youtubemusic()
{
  add_internet_shortcut youtubemusic
}



##################
###### MAIN ######
##################
main()
{
  data_and_file_structures_initialization
  argument_processing "$@"
  pre_install_update
  execute_installation
  post_install_clean
  bell_sound
}


# Import file of common variables in a relative way, so customizer can be called system-wide
# RF, necessary duplication in uninstall. Common extraction in the future in the common endpoint customizer.sh
DIR="${BASH_SOURCE%/*}"
if [ ! -d "${DIR}" ]; then
  DIR="${PWD}"
fi

if [ -f "${DIR}/functions_install.sh" ]; then
  source "${DIR}/functions_install.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data yet
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_install.sh not found. Aborting..."
  exit 1
fi

# Call main function
main "$@"

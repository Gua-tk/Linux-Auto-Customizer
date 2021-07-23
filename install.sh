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

install_R()
{
  generic_install R
  R -e "${R_jupyter_lab_function}"
}

install_wireshark()
{
  echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
  generic_install wireshark
}

########################################################################################################################
######################################### USER SOFTWARE FUNCTIONS ######################################################
########################################################################################################################

install_ijs()
{
  "${USR_BIN_FOLDER}/node/bin/npm" config set prefix "${HOME_FOLDER}/.local"
  "${USR_BIN_FOLDER}/node/bin/npm" install -g ijavascript
  "${DIR_IN_PATH}/ijsinstall"
}

install_julia()
{
  generic_install julia
  # install jupyter-lab dependencies down Rf
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
  git clone ${sysmontask_repositoryurl} ${USR_BIN_FOLDER}/SysMonTask
  #chgrp -R ${SUDO_USER} ${USR_BIN_FOLDER}/SysMonTask
  #chown -R ${SUDO_USER} ${USR_BIN_FOLDER}/SysMonTask
  #chmod -R 755 ${USR_BIN_FOLDER}/SysMonTask
  $(cd ${USR_BIN_FOLDER}/SysMonTask && python3 setup.py install &>/dev/null)
  #python3 ${USR_BIN_FOLDER}/SysMonTask/setup.py install
  copy_launcher "SysMonTask.desktop"
}

########################################################################################################################
######################################### USER-ENVIRONMENT FUNCTIONS ###################################################
########################################################################################################################

install_change-bg()
{
  # Install script changer to be executed manually or with crontab automatically
  mkdir -p "${USR_BIN_FOLDER}/change-bg"
  echo "${wallpapers_changer_script}" > "${USR_BIN_FOLDER}/change-bg/wallpaper_changer.sh"
  chmod 775 ${USR_BIN_FOLDER}/change-bg/wallpaper_changer.sh
  ln -sf ${USR_BIN_FOLDER}/change-bg/wallpaper_changer.sh ${DIR_IN_PATH}/change-bg

  echo "${wallpapers_cronjob}" > ${BASH_FUNCTIONS_FOLDER}/change-bg/wallpapers_cronjob
  crontab ${BASH_FUNCTIONS_FOLDER}/change-bg/wallpapers_cronjob

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

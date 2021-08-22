#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer installation of features.                                                              #
# - Description: A set of programs, functions, aliases, templates, environment variables, wallpapers, desktop          #
# features... collected in a simple portable shell script to customize a Linux working environment.                    #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 19/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernandez Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when   #
# logged as root) to install some of the features.                                                                     #
# - Arguments: Accepts behavioural arguments with one hyphen (-f, -o, etc.) and feature selection with two hyphens     #
# (--pycharm, --gcc).                                                                                                  #
# - Usage: Installs the features selected by argument, modifying its behaviour depending on the specified flags.       #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################

########################################################################################################################
######################################### USER SOFTWARE FUNCTIONS ######################################################
########################################################################################################################

install_codium()
{
  download_and_decompress ${codium_downloader} "codium" "z" "bin/codium" "codium"
  create_manual_launcher "${codium_launcher}" "codium"
}

install_caffeine_pre()
{
  apt-get purge -y caffeine
}

install_caffeine_post()
{
  wget -O - https://gist.githubusercontent.com/syneart/aa8f2f27a103a7f1e1812329fa192e65/raw/caffeine-indicator.patch | patch /usr/bin/caffeine-indicator
}

install_customizer_post()
{
  ln -sf "${DIR}/install.sh" /usr/bin/customizer-install
  if ! grep -Fo "source \"${BASH_FUNCTIONS_PATH}\"" "${BASHRC_ALL_USERS_PATH}"; then
    echo "source \"${BASH_FUNCTIONS_PATH}\"" >> "${BASHRC_ALL_USERS_PATH}"
  fi
}

install_gitcm_post()
{
  git config --global credential.credentialStore plaintext
}

install_jupyter_lab_pre() {
  local -r dependencies=("npm" "R" "julia")
  for dependency in "${dependencies[@]}"; do

    if ! which "${dependency}" &>/dev/null; then
      output_proxy_executioner "echo ERROR: ${dependency} is not installed. You can installing using bash install.sh --npm --R --julia" "${FLAG_QUIETNESS}"
      exit 1
    fi
  done
}

install_jupyter_lab_mid() {
  # Enable dark scrollbars by clicking on Settings -> JupyterLab Theme -> Theme Scrollbars in the JupyterLab menus.
  "${USR_BIN_FOLDER}/jupyter_lab/bin/jupyter" labextension install @telamonian/theme-darcula
  "${USR_BIN_FOLDER}/jupyter_lab/bin/jupyter" labextension enable @telamonian/theme-darcula

  "${USR_BIN_FOLDER}/jupyter_lab/bin/jupyter" lab build

  # ijs legacy install
  npm config set prefix "${HOME_FOLDER}/.local"
  npm install -g ijavascript
  ijsinstall

  # Set up IRKernel for R-jupyter
  # R -e "install.packages('IRkernel')
  # install.packages(c('rzmq', 'repr', 'uuid','IRdisplay'),
  #                repos = c('http://irkernel.github.io/',
  #                getOption('repos')),
  #                type = 'source')
  # IRkernel::installspec()"

  # install jupyter-lab dependencies down
  julia -e '#!/.local/bin/julia
  using Pkg
  Pkg.add("IJulia")
  Pkg.build("IJulia")'
}

install_pgadmin_mid() {
  # Create a valid binary in the path. In this case if we want the same schema as other programs we need to set a
  # shebang that points to the virtual environment that we just created, so the python script of pgadmin has all the
  # information on how to call the script

  # Prepend shebang line to python3 interpreter of the venv
  echo "#!${USR_BIN_FOLDER}/pgadmin/bin/python3" | cat - "${USR_BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py" >"${USR_BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py.tmp" && mv "${USR_BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py.tmp" "${USR_BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py"
  chmod +x "${USR_BIN_FOLDER}/pgadmin/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py"
}

# Installs pypy3 dependencies, pypy3 and basic modules (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
install_pypy3_mid() {
  # Install modules using pip
  "${USR_BIN_FOLDER}/pypy3/bin/pypy3" -m ensurepip

  # Forces download of pip and of modules
  "${USR_BIN_FOLDER}/pypy3/bin/pip3.6" --no-cache-dir -q install --upgrade pip
  "${USR_BIN_FOLDER}/pypy3/bin/pip3.6" --no-cache-dir install cython numpy
  # Currently not supported
  # ${USR_BIN_FOLDER}/${pypy3_version}/bin/pip3.6 --no-cache-dir install matplotlib
}

install_sysmontask_mid() {
  (
    cd "${USR_BIN_FOLDER}/sysmontask" || exit
    python3 setup.py install
  )
}

install_changebg_post() {
  crontab "${USR_BIN_FOLDER}/changebg/.cronjob"
}

install_system_fonts_mid() {
  # Interface text
  gsettings set org.gnome.desktop.interface font-name 'Roboto Medium 11'
  # Document text //RF
  gsettings set org.gnome.desktop.interface document-font-name 'Fira Code weight=453 10'
  # Monospaced text
  gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Regular 12'
  # Inherited window titles
  gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Hermit Bold 9'
}

##################
###### MAIN ######
##################
main() {
  FLAG_MODE=install  # Install mode
  argument_processing "$@"
  data_and_file_structures_initialization
  pre_install_update
  execute_installation
  post_install_clean
  #update_environment
  bell_sound
}

DIR=$(dirname "$(realpath "$0")")

if [ -f "${DIR}/functions_install.sh" ]; then
  source "${DIR}/functions_install.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data yet
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_install.sh not found. Aborting..."
  exit 1
fi

# Call main function
main "$@"

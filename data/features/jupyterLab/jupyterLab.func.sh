#!/usr/bin/env bash

install_jupyterLab_pre() {
  local -r dependencies=("npm" "R" "julia")
  for dependency in "${dependencies[@]}"; do

    if ! which "${dependency}" &>/dev/null; then
      output_proxy_executioner "The dependency ${dependency} is not installed. You can installing using bash install.sh npm R julia" "ERROR"
    fi
  done
}
install_jupyterLab_mid() {
  # Enable dark scrollbars by clicking on Settings -> JupyterLab Theme -> Theme Scrollbars in the JupyterLab menus.
  "${BIN_FOLDER}/jupyterLab/bin/jupyter" labextension install @telamonian/theme-darcula
  "${BIN_FOLDER}/jupyterLab/bin/jupyter" labextension enable @telamonian/theme-darcula

  "${BIN_FOLDER}/jupyterLab/bin/jupyter" lab build

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
uninstall_jupyterLab_pre() {
  :
}
uninstall_jupyterLab_mid() {

  # install jupyter-lab dependencies down
  #julia -e '#!/.local/bin/julia
  #using Pkg
  #Pkg.add("IJulia")
  #Pkg.build("IJulia")'
  :
}

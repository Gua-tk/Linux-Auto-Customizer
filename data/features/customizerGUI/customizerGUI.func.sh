#!/usr/bin/env bash

install_customizer_post()
{
  ln -sf "${DIR}/uninstall.sh" /usr/bin/customizer-uninstall
  ln -sf "${DIR}/install.sh" /usr/bin/customizer-install
}
uninstall_customizer_post()
{
  remove_file /usr/bin/customizer-install
  remove_file /usr/bin/customizer-uninstall
}

install_customizerGUI_post()
{
  # Create a valid binary in the path. In this case if we want the same schema as other programs we need to set a
  # shebang that points to the virtual environment that we just created, so the python script of pgadmin has all the
  # information on how to call the script using the correct python interpreter, which is the one in the virtual
  # environment an not the python system interpreter.

  # Prepend shebang line to python3 interpreter of the venv
  echo "#!${CURRENT_INSTALLATION_FOLDER}/bin/python3" | cat - "${CURRENT_INSTALLATION_FOLDER}/launcher.py" > "${CURRENT_INSTALLATION_FOLDER}/launcher.py.tmp" && mv "${CURRENT_INSTALLATION_FOLDER}/launcher.py.tmp" "${CURRENT_INSTALLATION_FOLDER}/launcher.py"
  chmod +x "${CURRENT_INSTALLATION_FOLDER}/launcher.py"
}
uninstall_customizerGUI_post()
{
  :
}
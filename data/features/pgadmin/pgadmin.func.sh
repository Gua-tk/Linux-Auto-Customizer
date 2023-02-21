#!/usr/bin/env bash

install_pgadmin_pre()
{
  if isRoot; then
    create_folder "/var/lib/pgadmin"
  fi
}

uninstall_pgadmin_pre()
{
  remove_folder "/var/lib/pgadmin"
}

install_pgadmin_mid() {
  # Create a valid binary in the path. In this case if we want the same schema as other programs we need to set a
  # shebang that points to the virtual environment that we just created, so the python script of pgadmin has all the
  # information on how to call the script using the correct python interpreter, which is the one in the virtual
  # environment an not the python system interpreter.

  # Prepend shebang line to python3 interpreter of the venv
  echo "#!${BIN_FOLDER}/pgadmin/bin/python3" | cat - "${BIN_FOLDER}/pgadmin/lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgAdmin4.py" > "${BIN_FOLDER}/pgadmin/lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgAdmin4.py.tmp" && mv "${BIN_FOLDER}/pgadmin/lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgAdmin4.py.tmp" "${BIN_FOLDER}/pgadmin/lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgAdmin4.py"
  chmod +x "${BIN_FOLDER}/pgadmin/lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgAdmin4.py"
}
uninstall_pgadmin_mid() {
  :
}

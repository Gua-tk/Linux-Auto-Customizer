#!/usr/bin/env bash
pgadmin_name="pgAdmin 4"
pgadmin_description="PostgreSQL Tools"
pgadmin_version="Python dependent"
pgadmin_tags=("pgadmin")
pgadmin_systemcategories=("Network")
pgadmin_commentary="CLI utility that makes it possible to search for text in a PDF file without opening the file"

pgadmin_binariesinstalledpaths=("lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgAdmin4.py;pgadmin")
pgadmin_confoverride_path="lib/${PYTHON_VERSION}/site-packages/pgadmin4/config_local.py"
pgadmin_confoverride_content="config_local.py"
pgadmin_executionscript_path="pgadmin.sh"
pgadmin_executionscript_content="pgadmin.sh"
pgadmin_filekeys=("confoverride" "executionscript")
pgadmin_launcherkeynames=("defaultLauncher")
pgadmin_defaultLauncher_windowclass="pgadmin"
pgadmin_defaultLauncher_exec="bash ${CURRENT_INSTALLATION_FOLDER}/pgadmin.sh"
pgadmin_manualcontentavailable="1;1;0"
pgadmin_pipinstallations=("pgadmin4")
pgadmin_packagedependencies=("libgmp3-dev" "libpq-dev" "libapache2-mod-wsgi-py3")
pgadmin_bashfunctions=("silentFunction")

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

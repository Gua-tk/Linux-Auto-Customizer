#!/usr/bin/env bash
pgadmin_name="pgAdmin 4"
pgadmin_description="PostgreSQL Tools"
pgadmin_version="Python dependent"
pgadmin_tags=("")
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
pgadmin_packagedependencies=("libgmp3-dev" "libpq-dev" "libapache2-mod-wsgi-py3" "python3.8" "python3.8-venv")
pgadmin_bashfunctions=("silentFunction")

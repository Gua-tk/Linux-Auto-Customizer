#!/usr/bin/env bash

# https://github.com/bugy/script-server/wiki/Installing-on-virtualenv-(linux)
# http://localhost:5000
customizerGUI_name="Linux Auto Customizer Graphical Interface"
customizerGUI_description="Graphical interface for the customizer"
customizerGUI_version="1.17.1"
customizerGUI_tags=("development" "GNU" "environment" "customDesktop")
customizerGUI_systemcategories=("Development" "Utility" "System" "Programming" "PackageManager" "Settings")
customizerGUI_commentary="Access customizer with a Web Interface"
customizerGUI_dependencies=("python3" "python3-dev" "python3-venv")
customizerGUI_downloadKeys=("bundleSource")
customizerGUI_bundleSource_URL="https://github.com/bugy/script-server/releases/download/1.17.1/script-server.zip"
customizerGUI_pipinstallations=("-r ${CURRENT_INSTALLATION_FOLDER}/requirements.txt")  # TODO: when extract files allow CURRENT_INSTALLATION_FOLDER to be available
customizerGUI_binariesinstalledpaths=("launcher.py;customizerGUI")
customizerGUI_manualcontentavailable="0;0;1"
customizerGUI_filekeys=("multinstall" "multiuninstall" "debug")
customizerGUI_multinstall_path="${CURRENT_INSTALLATION_FOLDER}/conf/runners/multinstall.json"
customizerGUI_multinstall_content="multinstall.json"
customizerGUI_multiuninstall_path="${CURRENT_INSTALLATION_FOLDER}/conf/runners/multiuninstall.json"
customizerGUI_multiuninstall_content="multiuninstall.json"
customizerGUI_debug_path="${CURRENT_INSTALLATION_FOLDER}/conf/runners/debug.json"
customizerGUI_debug_content="debug.json"
customizerGUI_launcherkeynames=("defaultLauncher")  # TODO: pgadmin launcher style, with xdg-open to https://localhost:5000
customizerGUI_bashfunctions=("customizerGUI.sh")
#!/usr/bin/env bash
customizer_name="Linux Auto Customizer"
customizer_description="Custom local installation manager"
customizer_version="developer dependent"
customizer_tags=("environment" "customDesktop")
customizer_systemcategories=("Development" "PackageManager" "Settings" "System" "Utility")

customizer_manualcontentavailable="0;0;1"
customizer_flagsoverride="0;;;;;"  # Install always as root
customizer_bashfunctions=("customizer.sh" "shortcuts.sh")
customizer_packagedependencies=("python3" "python-venv" "wget" "git" "git-lfs" "bash-completion" "file" "python3.8" "python3.8-venv")  # python3.8-venv is now needed to create venv in Ubuntu/Debian
customizer_binariesinstalledpaths=("${CUSTOMIZER_PROJECT_FOLDER}/src/core/uninstall.sh;customizer-uninstall" "${CUSTOMIZER_PROJECT_FOLDER}/src/core/install.sh;customizer-install" "${CUSTOMIZER_PROJECT_FOLDER}/src/customizer.sh;customizer")

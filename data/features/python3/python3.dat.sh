#!/usr/bin/env bash

python3_name="Python3"
python3_description="Interpreted, high-level and general-purpose programming language"
python3_version="System dependent"
python3_tags=("language")
python3_systemcategories=("Languages")

python3_bashfunctions=("v.sh")
python3_packagenames=("python-dev" "python3-dev" "python3-pip" "python3-venv" "python3-wheel" "python3.8-venv")  # "python3-pyqt5" "python3-pyqt4" "python-qt4"
python3_filekeys=("template")
python3_template_path="${XDG_TEMPLATES_DIR}"
python3_template_content="python3_script.py"
python3_launcherkeynames=("languageLauncher")
python3_languageLauncher_terminal="true"
python3_languageLauncher_exec="gnome-terminal -- python3"

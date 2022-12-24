install_sherlock_post() {
  python3 -m pip install -r "${BIN_FOLDER}/sherlock/requirements.txt"
}
uninstall_sherlock_post() {
  :
}

sherlock_name="Sherlock"
sherlock_description="Tool to obtain linked social media accounts using user name"
sherlock_version="1.0"
sherlock_tags=("bashfunctions")
sherlock_systemcategories=("System" "Utility" "ConsoleOnly")
sherlock_bashfunctions=("sherlock.sh")
sherlock_repositoryurl="https://github.com/sherlock-project/sherlock.git"
sherlock_manualcontentavailable="0;0;1"

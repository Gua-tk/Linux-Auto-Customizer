install_customizer_post()
{
  ln -sf "${CUSTOMIZER_PROJECT_FOLDER}/src/core/uninstall.sh" "${ALL_USERS_PATH_POINTED_FOLDER}/customizer-uninstall"
  ln -sf "${CUSTOMIZER_PROJECT_FOLDER}/src/core/install.sh" "${ALL_USERS_PATH_POINTED_FOLDER}/customizer-install"
}
uninstall_customizer_post()
{
  remove_file /usr/bin/customizer-uninstall
  remove_file /usr/bin/customizer-install
}
customizer_name="Linux Auto Customizer"
customizer_description="Custom local installation manager"
customizer_version="developer dependent"
customizer_tags=("development" "GNU" "environment")
customizer_systemcategories=("Development" "Utility" "System" "PackageManager" "Settings")
customizer_manualcontentavailable="0;0;1"
customizer_flagsoverride="0;;;;;"  # Install always as root
customizer_bashfunctions=("customizer.sh")
customizer_packagedependencies=("python3" "python-venv" "wget" "git" "git-lfs")
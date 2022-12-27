install_customizer_post()
{
  (
    cd "${CUSTOMIZER_PROJECT_FOLDER}" || return
    git-lfs pull
  )
}
uninstall_customizer_post()
{
  :
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
customizer_binariesinstalledpaths=("${CUSTOMIZER_PROJECT_FOLDER}/src/core/uninstall.sh;customizer-uninstall" "${CUSTOMIZER_PROJECT_FOLDER}/src/core/install.sh;customizer-install")
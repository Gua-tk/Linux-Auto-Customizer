install_sysmontask_mid() {
  (
    cd "${BIN_FOLDER}/sysmontask" || exit
    python3 setup.py install
  )
}
uninstall_sysmontask_mid() {
  :
}
sysmontask_name="Sysmontask"
sysmontask_description="Control panel for linux"
sysmontask_version="System dependent"
sysmontask_tags=("controlPanel")
sysmontask_systemcategories=("Settings")
sysmontask_flagsoverride="0;;;;;"  # To install the cloned software it has to be run as root
sysmontask_bashfunctions=("silentFunction")
sysmontask_manualcontentavailable="0;1;0"
sysmontask_repositoryurl="https://github.com/KrispyCamel4u/SysMonTask.git"

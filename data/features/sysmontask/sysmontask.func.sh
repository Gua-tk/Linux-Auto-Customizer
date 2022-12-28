install_sysmontask_mid() {
  (
    cd "${BIN_FOLDER}/sysmontask" || exit
    python3 setup.py install
  )
}
uninstall_sysmontask_mid() {
  :
}
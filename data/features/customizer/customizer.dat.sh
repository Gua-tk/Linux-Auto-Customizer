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
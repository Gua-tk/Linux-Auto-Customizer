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
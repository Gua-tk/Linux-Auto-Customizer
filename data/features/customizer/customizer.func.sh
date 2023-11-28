#!/usr/bin/env bash
install_customizer_post()
{
  (
    cd "${CUSTOMIZER_PROJECT_FOLDER}" || return
    git-lfs pull

    if isRoot; then
      apply_permissions_recursively "${CUSTOMIZER_PROJECT_FOLDER}"  # /data/features
    fi
  )
}
uninstall_customizer_post()
{
  :
}

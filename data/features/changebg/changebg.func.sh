install_changebg_post() {
  # TODO: Do not append to crontab if an exact job already exists
  if [ -n "${SUDO_USER}" ]; then
    (crontab -u "${SUDO_USER}" -l ; cat "${BIN_FOLDER}/changebg/cronjob") | crontab -u "${SUDO_USER}" -
  else
    (crontab -l ; cat "${BIN_FOLDER}/changebg/cronjob") | crontab -
  fi
}
uninstall_changebg_post() {
  :
  #crontab "${USR_BIN_FOLDER}/changebg/cronjob"
}

#!/usr/bin/env bash
changebg_name="Change Background"
changebg_description="Function that changes the wallpaper using one random image from user images folder. It also downloads wallpapers and installs a cronjob to change the wallpaper every 5 minutes"
changebg_version="1.0"
changebg_tags=("terminal" "utility" "customDesktop" "bashFunctions")
changebg_systemcategories=("Settings" "System" "Utility")

changebg_movefiles=("*.jpg;${XDG_PICTURES_DIR}/wallpapers" "*.png;${XDG_PICTURES_DIR}/wallpapers" "*.jpeg;${XDG_PICTURES_DIR}/wallpapers" )
changebg_binariesinstalledpaths=("cronscript.sh;changebg")
changebg_cronscript_content="cronscript.sh"
changebg_cronscript_path="cronscript.sh"
changebg_cronjob_content="cronjob"
changebg_cronjob_path="cronjob"
changebg_filekeys=("cronscript" "cronjob")
changebg_manualcontentavailable="0;0;1"
changebg_repositoryurl="https://github.com/AleixMT/wallpapers"
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

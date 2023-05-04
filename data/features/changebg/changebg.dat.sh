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
changebg_filekeys=("cronscript")
changebg_repositoryurl="https://github.com/AleixMT/wallpapers"
changebg_cronjobs=("cronjob")

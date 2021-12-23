
E() {
  declare -Arl EDITABLEFILES=(
    [aliases]="€{HOME_FOLDER}/.bash_aliases"
    [allbashrc]="€{BASHRC_ALL_USERS_PATH}"
    [bashfunctions]="€{FUNCTIONS_PATH}"
    [bashrc]="€{BASHRC_PATH}"
    [favorites]="€{PROGRAM_FAVORITES_PATH}"
    [initializations]="€{INITIALIZATIONS_PATH}"
    [keybindings]="€{PROGRAM_KEYBINDINGS_PATH}"
    [mime]="€{MIME_ASSOCIATION_PATH}"
    [profile]="€{PROFILE_PATH}"
    [sshconf]="€{HOME_FOLDER}/.ssh/config"
    [tmuxconf]="€{HOME_FOLDER}/.tmux.conf"
    )
  if [ $# -eq 0 ]; then
    echo "Recognised arguments to edit:"
    for i in "${!EDITABLEFILES[@]}"; do
      echo "${i}:${EDITABLEFILES[${i}]}"
    done
  else
    while [ -n "$1" ]; do
      local path_editable="${EDITABLEFILES["$1"]}"
      if [ -z "${path_editable}" ]; then
        if [ -f "$1" ]; then
          nohup editor "$1" &>/dev/null &
        else
          echo "$1 is not a valid file or option."
        fi
      else
        nohup editor "${path_editable}" &>/dev/null &
      fi
      shift
    done
  fi
}

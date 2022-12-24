install_tmux_post() {
  if [ -n "${SUDO_USER}" ]; then
    (crontab -u "${SUDO_USER}" -l ; cat "${BIN_FOLDER}/tmux/cronjob") | crontab -u "${SUDO_USER}" -
  else
    (crontab -l ; cat "${BIN_FOLDER}/tmux/cronjob") | crontab -
  fi
}
uninstall_tmux_post() {
  cp "${CUSTOMIZER_PROJECT_FOLDER}/src/features/tmux/cronjob" "${CUSTOMIZER_PROJECT_FOLDER}/src/features/tmux/cronjob.tmp"
  translate_variables "${CUSTOMIZER_PROJECT_FOLDER}/src/features/tmux/cronjob.tmp"
  if [ -n "${SUDO_USER}" ]; then
    crontab -u "${SUDO_USER}" -l | sed "s;$(cat "${CUSTOMIZER_PROJECT_FOLDER}/src/features/tmux/cronjob.tmp");;g" | crontab -u "${SUDO_USER}" -
  else
    crontab -l | sed "s;$(cat "${CUSTOMIZER_PROJECT_FOLDER}/src/features/tmux/cronjob.tmp");;g" | crontab -
  fi
  rm -f "${CUSTOMIZER_PROJECT_FOLDER}/src/features/tmux/cronjob.tmp"
}

tmux_name="Terminal multiplexor"
tmux_description="Terminal multiplexor"
tmux_version="System dependent"
tmux_tags=("terminal" "sessions")
tmux_systemcategories=("System" "Utility")
tmux_launcherkeynames=("defaultLauncher")
tmux_defaultLauncher_exec="tmux"
tmux_defaultLauncher_terminal="true"
tmux_packagenames=("tmux")
tmux_packagedependencies=("xdotool" "xclip" "tmuxp" "bash-completion")
tmux_bashfunctions=("tmux_functions.sh")
tmux_filekeys=("tmuxconf" "clockmoji" "cronjob")
tmux_clockmoji_content="tmux_clockmoji.sh"
tmux_clockmoji_path="clockmoji.sh"
tmux_tmuxconf_content="tmux.conf"
tmux_tmuxconf_path="${HOME_FOLDER}/.tmux.conf"
tmux_cronjob_content="cronjob"
tmux_cronjob_path="cronjob"
tmux_manualcontentavailable="0;0;1"

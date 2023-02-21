#!/usr/bin/env bash
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

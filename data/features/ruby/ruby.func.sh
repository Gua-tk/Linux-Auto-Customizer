#!/usr/bin/env bash

install_ruby_post() {
  (
    cd "${CURRENT_INSTALLATION_FOLDER}"
    sudo make install
  )
}

uninstall_ruby_post() {
  :
}

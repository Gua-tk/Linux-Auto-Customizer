#!/usr/bin/env bash

install_jekyll_post() {
  if [ ! -d "${CURRENT_INSTALLATION_FOLDER}/gems}" ]; then
    mkdir -p "${CURRENT_INSTALLATION_FOLDER}/gems}"
  fi
  export GEM_HOME="${CURRENT_INSTALLATION_FOLDER}/gems}"
  gem install jekyll bundler
}

uninstall_jekyll_post() {
  :
}

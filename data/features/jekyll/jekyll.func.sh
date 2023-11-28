#!/usr/bin/env bash

install_jekyll_post() {
  if [ ! -d "${CURRENT_INSTALLATION_FOLDER}/gems}" ]; then
    mkdir -p "${CURRENT_INSTALLATION_FOLDER}/gems"
  fi
  export GEM_HOME="${CURRENT_INSTALLATION_FOLDER}/gems"
  export PATH="${CURRENT_INSTALLATION_FOLDER}/gems/bin:$PATH"
  gem install jekyll bundler
}

uninstall_jekyll_post() {
  :
}
#!/usr/bin/env bash

# TODO: make the clean rfunction parametric by using the variables to specify action over the package manager
clean()
{
  if [ ${EUID} -eq 0 ]; then
    apt-get -y --fix-broken install
    apt-get update -y --fix-missing
    apt-get -y autoclean
    apt-get -y autoremove
  fi
  rm -rf "${HOME_FOLDER}/.local/share/Trash/*" 2>/dev/null
  echo "The recycle bin has been emptied"
}

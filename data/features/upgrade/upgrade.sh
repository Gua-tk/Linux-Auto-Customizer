#!/usr/bin/env bash

upgrade()
{
  if [ ${EUID} -eq 0 ]; then
    apt-get update -y && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y
  else
    sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get autoremove -y && sudo apt-get autoclean -y
  fi
}



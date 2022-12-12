#!/usr/bin/env bash

alias rip="sudo shutdown -h now"
alias up="sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt --fix-broken install && sudo apt-get -y autoclean && sudo apt-get -y autoremove"
alias services="sudo systemctl --type=service"
alias cls="clear"
alias services="sudo systemctl --type=service"
alias q="exit"

del-key()
{
  if [ "${EUID}" == 0 ]; then
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$1"
  else
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$1"
  fi
}

del-branches()
{
  local -r branches="$(git branch | tr -s " " | cut -d " " -f2-)"
  local -r currentBranch="$(git branch --show-current)"

  for b in ${branches[@]}; do
    if [ "${b}" != "${currentBranch}" ]; then
      git branch -d "${b}"
    fi
  done
}

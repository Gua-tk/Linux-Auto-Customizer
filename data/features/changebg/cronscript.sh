#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer change background script.                                                              #
# - Description: Script to change the background. Can be called periodically from cron to change the background        #
#   continuously.                                                                                                      #
# - Creation Date: 8/2/21                                                                                              #
# - Last Modified: 8/2/21                                                                                              #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: aleix.marine@estudiants.urv.cat                                                                             #
# - Permissions: Needs to read from the folder where we have stored our wallpapers. Needs permission to write into     #
#   dconf registry.                                                                                                    #
# - Arguments: No arguments                                                                                            #
# - Usage: Changes the background using the pictures in DIR                                                                    #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################

# First check if we have dconf available. If not, we exit the script because there is nothing to do.
if ! which dconf &>/dev/null; then
  exit
fi
# If we are root, we need to say that the user is the SUDO_USER
if [ "${EUID}" -eq 0 ]; then
  user="${SUDO_USER}"
else
  user="$(whoami)"
fi

# Finds the DBUS ADDRESS for the current user if it is not present.
if [ -z ${DBUS_SESSION_BUS_ADDRESS+x} ]; then
  # List processes
  fl=$(find /proc -maxdepth 2 -user "${user}" -name environ -print -quit)
  # Loop while we do not capture bus address
  while [ -z "$(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2- | tr -d '\000' )" ]
  do
    fl=$(find /proc -maxdepth 2 -user "${user}" -name environ -newer "$fl" -print -quit)
  done

  # At this point we have found something so we assign in
  DBUS_SESSION_BUS_ADDRESS="$(grep -z DBUS_SESSION_BUS_ADDRESS "${fl}" | cut -d= -f2-)"
  # If we did not find it just exit this script
  if [ -z "${DBUS_SESSION_BUS_ADDRESS}" ]; then
    unset user
    unset fl
    exit
  fi
  # Export the variable, will be used transparently when calling dconf write
  export DBUS_SESSION_BUS_ADDRESS

  # Delete temporal variables from environment
  unset user
  unset fl
fi

DIR="€{XDG_PICTURES_DIR}/wallpapers"
PIC=""
while [ -z "${PIC}" ]; do
  PIC="$(find "${DIR}" -maxdepth 1 -type f | rev | cut -d "/" -f1 | rev | shuf -n1)"
  if [ "${PIC}" == ".git" ] || [ "${PIC}" == ".gitattributes" ] || [ "${PIC}" == ".cronscript.sh" ] || [ "${PIC}" == ".cronjob" ]; then
    PIC=""
  fi
done

echo "${DIR}/${PIC}"
dconf write "/org/gnome/desktop/background/picture-uri" "'file://${DIR}/${PIC}'"

unset DIR
unset PIC
unset user
unset fl


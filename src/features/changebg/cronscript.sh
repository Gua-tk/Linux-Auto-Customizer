#!/bin/bash
if [ -z ${DBUS_SESSION_BUS_ADDRESS+x} ]; then
  user=$(whoami)
  fl=$(find /proc -maxdepth 2 -user $user -name environ -print -quit)
  while [ -z $(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2- | tr -d '\000' ) ]
  do
    fl=$(find /proc -maxdepth 2 -user ${user} -name environ -newer "$fl" -print -quit)
  done
  export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d= -f2-)
fi
DIR="€{XDG_PICTURES_DIR}/wallpapers"
PIC=""
while [ -z "${PIC}" ]; do
  PIC="$(ls "${DIR}" | shuf -n1)"
  if [ "${PIC}" == ".git" ] || [ "${PIC}" == ".gitattributes" ] || [ "${PIC}" == ".cronscript.sh" ] || [ "${PIC}" == ".cronjob" ]; then
    PIC=""
  fi
done

dconf write "/org/gnome/desktop/background/picture-uri" "'file://${DIR}/${PIC}'"


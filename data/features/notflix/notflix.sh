#!/usr/bin/env bash

notflix() {
  if ! which peerflix; then
    if ! which npm; then
      if [ ${EUID} -eq 0 ]; then
        €{PACKAGE_MANAGER_INSTALL} npm
      else
        sudo €{PACKAGE_MANAGER_INSTALL} npm
      fi
    fi

    if [ ${EUID} -eq 0 ]; then
      npm install -g peerflix
    else
      sudo npm install -g peerflix
    fi
  fi


  query=$(printf '%s' "$*" | tr ' ' '+' )
  movie=$(curl -s https://1337x.wtf/search/$query/1/ | grep -Eo "torrent\/[0-9]{7}\/[a-zA-Z0-9?%-]*/" | head -n 1)
  magnet=$(curl -s https://1337x.wtf/$movie | grep -Po "magnet:\?xt=urn:btih:[a-zA-Z0-9]*" | head -n 1)
  peerflix -l "${magnet}" --vlc --subtitles="/mnt/d/Descargas/lifeofbrian.srt"
}
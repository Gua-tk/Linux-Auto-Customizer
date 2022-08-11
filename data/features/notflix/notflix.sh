#!/usr/bin/env bash

notflix_dependencies() {
  if [ ${EUID} -eq 0 ]; then
    echo "peerflix is not installed and are not root"
    exit 1
  else
    npm install --verbose peerflix
    # Create link to the path for peerflix in ~/.customizer/bin/nodejs/bin/peerflix
    ln -s "€{BIN_FOLDER}/nodejs/bin/peerflix" "€{PATH_POINTED_FOLDER}/peerflix"
  fi
}

notflix() {
  if ! which peerflix; then
    notflix_dependencies
  fi

  query=$(printf '%s' "$*" | tr ' ' '+' )
  movie=$(curl -s "https://1337x.wtf/search/${query}/1/" | grep -Eo "torrent\/[0-9]{7}\/[a-zA-Z0-9?%-]*/" | head -n 1)
  magnet=$(curl -s "https://1337x.wtf/${movie}" | grep -Po "magnet:\?xt=urn:btih:[a-zA-Z0-9]*" | head -n 1)
  #movie=$(curl -s "https://rarbg.to/torrents.php?search=${query}&order=seeders&by=DESC")

  firstWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f1)"
  secondWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f2)"
  thirdWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f3)"
  fourthWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f4)"
  fifthWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f5)"
  sixthWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f6)"
  seventhWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f7)"
  eigthWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f8)"
  ninethWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f9)"
  tenthWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f10)"
  eleventhWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f11)"
  twelvethWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f12)"
  thirteenthWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f13)"
  fourteenthWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f14)"
  fifteenthWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f15)"
  sixteenthWordMovieName="$(echo $movie | cut -d "/" -f3 | cut -d "-" -f16)"
  echo "LAUNCHING PEERFLIX"
  peerflix -l "${magnet}" -t "/tmp/torrent-stream/"*"/"*"/"*"${firstWordMovieName}"*"${secondWordMovieName}"*"${thirdWordMovieName}"*"${fourthWordMovieName}"*"${fifthWordMovieName}"*"${sixthWordMovieName}"*"${seventhWordMovieName}"*"${eigthWordMovieName}"*"${ninethWordMovieName}"*"${tenthWordMovieName}"*"${eleventhWordMovieName}"*"${twelvethWordMovieName}"*"${thirteenthWordMovieName}"*"${fourteenthWordMovieName}"*"${fifteenthWordMovieName}"*"${sixteenthWordMovieName}"*".srt" --vlc --fullscreen
  echo "EXIT PEERFLIX"
}
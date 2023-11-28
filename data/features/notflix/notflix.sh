#!/usr/bin/env bash

# - Description: Receives a query string as first argument, expected to be a video name such as a movie title or a
#   magnet link. If it is a video name, it searches in a hardcoded torrent server a magnet link. It plays the magnet in
#   vlc using peerflix, which streams the magnet link supplied or found depending on the first argument type.
# - Permission: Can be only called as user.
# - Argument 1: String of the name of a movie or a magnet string
notflix() {
  # We check if peerflix is not installed
  if ! which peerflix &> /dev/null; then
    if [ ${EUID} -eq 0 ]; then
      echo "peerflix is not installed and you are root. Re run as user and try again. Aborting..."
      return 1
    else
      # If we are not root, we install peerflix using npm
      if which npm &> /dev/null; then
        npm install --verbose peerflix
        # Create link to the path for peerflix in ~/.customizer/bin/nodejs/bin/peerflix
        ln -s "€{BIN_FOLDER}/nodejs/bin/peerflix" "€{PATH_POINTED_FOLDER}/peerflix"
      else
        echo "npm is not installed. Install it and try again. Aborting..."
        return 1
      fi
    fi
  fi

  # We check if the first argument is a valid magnet url
  if echo "${1}" | grep -Po "magnet:\?xt=urn:btih:[a-zA-Z0-9]*" &> /dev/null; then
    peerflix -l "${1}" --vlc
    return 0
  fi

  # If we do not receive a magnet link as 1st argument we assume it is a movie name
  # Torrent page where we make search queries
  torrent_page="https://purple-dream-6314.a-i.workers.dev/srch?search="
  # Torrent page to retrieve magnet from a movie url
  torrent_redirection_page="https://gateway.a-r.workers.dev"

  # Obtain string with spaces replaced with '+' format for valid url
  query_string=$(printf '%s' "$*" | tr ' ' '+' )
  # Obtain html of the search and look for the first torrent url
  movie_url="$(curl -s "${torrent_page}${query_string}" | grep -Eo "torrent\/[0-9]{7}\/[a-zA-Z0-9?%-]*/" | head -n 1)"
  # Obtain the first valid magnet link
  magnet_link="$(curl -s "${torrent_redirection_page}/${movie_url}" | grep -Po "magnet:\?xt=urn:btih:[a-zA-Z0-9]*" | head -n 1)"

  echo "Magnet torrent link: ${magnet_link}"
  peerflix -l "${magnet_link}" --vlc
}

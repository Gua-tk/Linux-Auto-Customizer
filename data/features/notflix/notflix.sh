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
# TODO: BUG Add the year of the film to the search of the subtitle to avoid collisions with remakes,
# TODO: in some cases it seems to download an .html page instead the .srt, in other cases it downloads a random .srt
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

  local -r tmp_srt="/tmp/torrent-stream/"*"/"*"/"*"${firstWordMovieName}"*"${secondWordMovieName}"*"${thirdWordMovieName}"*"${fourthWordMovieName}"*"${fifthWordMovieName}"*"${sixthWordMovieName}"*"${seventhWordMovieName}"*"${eigthWordMovieName}"*"${ninethWordMovieName}"*"${tenthWordMovieName}"*"${eleventhWordMovieName}"*"${twelvethWordMovieName}"*"${thirteenthWordMovieName}"*"${fourteenthWordMovieName}"*"${fifteenthWordMovieName}"*"${sixteenthWordMovieName}"*".srt"
  echo "LAUNCHING PEERFLIX"

  if [[ -f ${tmp_srt} ]]; then
    # TODO: The code seems to ignore this condition when peerflix has downloaded the .srt file
    # When .srt file has been downloaded by peerflix
    peerflix -l "${magnet}" -t ${tmp_srt} --vlc --fullscreen
  else
    # Downloading .srt file from opensubtitles manually
      echo ".srt file not downloaded via peerflix, performing manual downloaof .srt file from opensubtitles.org"
      movieSubtitlesSearchPage=$(curl -s "https://www.opensubtitles.org/es/search2/sublanguageid-spa,spl/moviename-${query}" | grep -Eo '"(http|https)://www.opensubtitles.org/es/[a-zA-Z0-9#~.*,/!?=+&_%:-]*"' | head -1 | tr -d '"')
      movieSubtitlesLink=$(curl -s "${movieSubtitlesSearchPage}" | grep -Eo "https?://www.opensubtitles.org/es/\S+?\"" | head -1 | tr -d '"')
      movieLink=$(curl -s "${movieSubtitlesLink}" | grep -Eo 'href="https://www.opensubtitles.org/es/[a-zA-Z0-9#~.*,/!?=+&_%:-]*' | head -1 | cut -d '=' -f2 | tr -d '"')
      movieURL="$(curl -s "${movieLink}" | grep -Eo '/es/search/sublanguageid-spa,spl/idmovie-[0-9]*' | head -1)"
      movieURL="https://www.opensubtitles.org${movieURL}"
      subtitleURL="$(curl -s "${movieURL}" | grep -Eo '[a-zA-Z0-9#~.*,/!?=+&_%:-]*-es' | head -1)"
      subtitleURL="https://www.opensubtitles.org${subtitleURL}"
      subtitleDownloadURL="$(curl -s "${subtitleURL}" | grep -Eo '/es/subtitleserve/sub/[0-9]*' | head -1)"
      subtitleDownloadURL="https://www.opensubtitles.org${subtitleDownloadURL}"
      subtitleNum="$(echo $subtitleDownloadURL | rev | cut -d '/' -f1 | rev)"
      # Download the .srt file to ~/Documents/subtitles
      mkdir -p ~/Documents/subtitles
      wget -P ~/Documents/subtitles "${subtitleDownloadURL}"
      unzip ~/Documents/subtitles/${subtitleNum} -d ~/Documents/subtitles
      rm ~/Documents/subtitles/${subtitleNum}
      rm ~/Documents/subtitles/*.nfo
      local -r subtitlePath="$HOME/Documents/subtitles/"*".srt"
      peerflix -l "${magnet}" -t ${subtitlePath} --vlc --fullscreen
  fi
  echo "EXIT PEERFLIX"
  rm -rf ~/Documents/subtitles
}
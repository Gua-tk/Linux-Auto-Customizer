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
# TODO: in some cases it seems to download an .html page instead the .srt, in other cases it downloads a random .srt.
# TODO: P. example 'The Godfather' loads 'The Godfather II' .srt...
# TODO: peerflix has to be run twice when .srt file is found within its search and again to load the .srt
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
  tmp_srt="/tmp/torrent-stream/"*"/"*"/"*".srt"
  echo "LAUNCHING PEERFLIX"
  if [[ -f ${tmp_srt} ]]; then
    # TODO: The code seems to ignore this condition when peerflix has downloaded the .srt file (Test with 'Life of Brian')
    # When .srt file has been downloaded by peerflix
    local -r tmp_srt="/tmp/torrent-stream/"*"/"*"/"*"${firstWordMovieName}"*"${secondWordMovieName}"*"${thirdWordMovieName}"*"${fourthWordMovieName}"*"${fifthWordMovieName}"*"${sixthWordMovieName}"*"${seventhWordMovieName}"*"${eigthWordMovieName}"*"${ninethWordMovieName}"*"${tenthWordMovieName}"*"${eleventhWordMovieName}"*"${twelvethWordMovieName}"*"${thirteenthWordMovieName}"*"${fourteenthWordMovieName}"*"${fifteenthWordMovieName}"*"${sixteenthWordMovieName}"*".srt"

    echo "LOADING torrent-stream .srt subtitles file"
    peerflix -l "${magnet}" -t ${tmp_srt} --vlc
  else
      rm -rf /tmp/torrent-stream/*
    # Downloading .srt file from opensubtitles manually
    # Some movies might not find the .srt in opensubtitles.org...
      echo ".srt file not downloaded via peerflix, performing manual download .srt file from opensubtitles.org"
      movieSubtitlesSearchPage=$(curl -s "https://www.opensubtitles.org/es/search/sublanguageid-spa,spl/moviename-${query}" | grep -Eo '(http|https)://www.opensubtitles.org/es/[a-zA-Z0-9#~.*,/!?=+&_%:-]*' | head -1 | tr -d '"')
      movieLink=$(curl -s "${movieSubtitlesSearchPage}" | grep -Eo 'href="https://www.opensubtitles.org/es/[a-zA-Z0-9#~.*,/!?=+&_%:-]*' | head -1 | cut -d '=' -f2 | tr -d '"')
      movieURL="$(curl -s "${movieLink}" | grep -Eo '/es/subtitles/[0-9]*/[a-zA-Z0-9#~.*,/!?=+&_%:-]*' | head -1)"
      movieURL="https://www.opensubtitles.org${movieURL}"
      subtitleURL="$(curl -s "${movieURL}" | grep -Eo '/es/subtitles/[a-zA-Z0-9#~.*,/!?=+&_%:-]*-es' | head -1)"
      subtitleURL="https://www.opensubtitles.org${subtitleURL}"
      subtitleDownloadURL="$(curl -s "${subtitleURL}" | grep -Eo '/es/subtitleserve/sub/[0-9]*' | head -1)"
      subtitleDownloadURL="https://www.opensubtitles.org${subtitleDownloadURL}"
      subtitleNum="$(echo $subtitleDownloadURL | rev | cut -d '/' -f1 | rev)"
      subtitleName="$(echo $movie | cut -d '/' -f3)"
      mkdir -p /tmp/torrent-stream/notflix-subtitles
      mkdir -p /tmp/torrent-stream/notflix-subtitles/movie
      wget -P /tmp/torrent-stream/notflix-subtitles/movie "${subtitleDownloadURL}"
      unzip /tmp/torrent-stream/notflix-subtitles/movie/${subtitleNum} -d /tmp/torrent-stream/notflix-subtitles/movie
      rm /tmp/torrent-stream/notflix-subtitles/movie/${subtitleNum}
      rm /tmp/torrent-stream/notflix-subtitles/movie/*.nfo

      # Here we operate if we have more than one .srt file in the downloaded zip
      if [[ $(ls /tmp/torrent-stream/notflix-subtitles/movie//tmp/torrent-stream/notflix-subtitles/movie | wc -1) -gt 1 ]]; then
        # We have to add jumpline between the possibles (cd1, cd2, cd2) .srt values and glue them onto one .srt
        subtitles="$'\\n'"
        for subtitlefile in $(ls /tmp/torrent-stream/notflix-subtitles/movie); do
          subtitles=$subtitles$(cat /tmp/torrent-stream/notflix-subtitles/movie//tmp/torrent-stream/notflix-subtitles/movie/$subtitlefile)$'\\n'
        done

        # TODO: echo "append subtitles"
        # TODO: echo "remove cd1, cd2, cd2 files and keep the /tmp/torrent-stream/notflix-subtitles/movie/${subtitleName}.srt"
      fi
      # CHANGE NAME OF SUBTITLES FILE TO THE MOVIE FILE NAME # "$(echo $movie | cut -d '/' -f3)" so peerflix. It always need to have one .srt in the /tmp/torrent-stream/notflix-subtitles/movie/ to open.
      local -r subtitlePath="/tmp/torrent-stream/notflix-subtitles/movie/"*".srt"
      peerflix -l "${magnet}" -t ${subtitlePath} --vlc --fullscreen
  fi
  echo "EXIT PEERFLIX"
  #rm -rf /tmp/torrent-stream/*
}


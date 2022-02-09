#!/usr/bin/env bash

colors() {
  if [ -z "$(echo "${COLORS[@]}")" ]; then
    declare -Ar COLORS=(
      [BLACK]='\e[0;30m'
      [RED]='\e[0;31m'
      [GREEN]='\e[0;32m'
      [YELLOW]='\e[0;33m'
      [BLUE]='\e[0;34m'
      [PURPLE]='\e[0;35m'
      [CYAN]='\e[0;36m'
      [WHITE]='\e[0;37m'

      [BOLD_BLACK]='\e[1;30m'
      [BOLD_RED]='\e[1;31m'
      [BOLD_GREEN]='\e[1;32m'
      [BOLD_YELLOW]='\e[1;33m'
      [BOLD_BLUE]='\e[1;34m'
      [BOLD_PURPLE]='\e[1;35m'
      [BOLD_CYAN]='\e[1;36m'
      [BOLD_WHITE]='\e[1;37m'

      [UNDERLINE_BLACK]='\e[4;30m'
      [UNDERLINE_RED]='\e[4;31m'
      [UNDERLINE_GREEN]='\e[4;32m'
      [UNDERLINE_YELLOW]='\e[4;33m'
      [UNDERLINE_BLUE]='\e[4;34m'
      [UNDERLINE_PURPLE]='\e[4;35m'
      [UNDERLINE_CYAN]='\e[4;36m'
      [UNDERLINE_WHITE]='\e[4;37m'

      [BACKGROUND_BLACK]='\e[40m'
      [BACKGROUND_RED]='\e[41m'
      [BACKGROUND_GREEN]='\e[42m'
      [BACKGROUND_YELLOW]='\e[43m'
      [BACKGROUND_BLUE]='\e[44m'
      [BACKGROUND_PURPLE]='\e[45m'
      [BACKGROUND_CYAN]='\e[46m'
      [BACKGROUND_WHITE]='\e[47m'

      [CLEAR]='\e[0m'
    )
  fi

  if [ -n "$1" ]; then
    local return_color="${COLORS[$(echo "$1" | tr '[:lower:]' '[:upper:]')]}"
    if [ -z "$(echo "${return_color}")" ]; then  # Not a color keyname
      for i in "${!COLORS[@]}"; do  # Search for color and return its keyname
        if [ "${COLORS[${i}]}" == "$1" ]; then
          return_color="${i}"
          echo "${return_color}"
          return
        fi
      done
      # At this point $1 is not a keyname or color
      if [ "$1" == "random" ]; then  # Check for random color
        COLORS_arr=(${COLORS[@]})
        echo -e "${COLORS_arr[$RANDOM % ${#COLORS_arr[@]}]}"
      elif [ "$1" == "randomkey" ]; then
        COLORS_arr=(${!COLORS[@]})
        echo "${COLORS_arr[$RANDOM % ${#COLORS_arr[@]}]}"
      elif [ "$1" -ge 0 ]; then  # If a natural number passed return a color indexing by number
        COLORS_arr=(${COLORS[@]})
        echo -e "${COLORS_arr[$1 % ${#COLORS_arr[@]}]}"
      else
        echo "ERROR Not recognised option"
      fi
    else  # Return color from indexing with dict
      echo -e "${return_color}"
    fi
  else
    # Not an argument, show all colors with dictionary structure
    for i in "${!COLORS[@]}"; do
      echo "${i}:${COLORS[${i}]}"
    done
  fi
}

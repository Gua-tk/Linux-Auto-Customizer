#!/usr/bin/env bash

F() {
  if [ $# -eq 0 ]; then  # No arguments given
    find / 2>/dev/null
  else
    if [[ "$1" =~ -i=.+ ]]; then
    echo "$1olssssssssssssssssssssssssssssssssss"
      ignored_paths="$(echo "${1}" | cut -d "=" -f2 | tr ',' ' ')"
      find_args_ignored_paths=""
      IFS=' '
      for path in ${ignored_paths}; do
        echo "$path entra en el for"
        find_args_ignored_paths+=" -not -path '${path}' "
      done
      shift
    fi
    if [ -d "$1" ]; then
      first_argument="$1"
      shift
    else
      first_argument="."
    fi
    IFS=$'\n'
    while [ -n "$1" ]; do
      echo "FIND IGNORED PATHS: ${find_args_ignored_paths}FidnBBBBBBBBBBBBBBBBBBBBBBB"
      for filename in $(find "${first_argument}" -type f -not -path '*/\.git/*' ${find_args_ignored_paths} 2>/dev/null); do
        local result="$(grep "$1" < "${filename}" 2>/dev/null)"
        if [ -n "$(echo "${result}")" ]; then
          echo
          echo -e "\e[0;33m${filename}\e[0m"
           grep -hnI -B 5 -A 5 --color='auto' "$1" < "${filename}" 2>/dev/null
         fi
      done
      shift
    done
  fi
}

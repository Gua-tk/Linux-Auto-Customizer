#!/usr/bin/env bash

F() {
  previous_lines=5
  following_lines=5

  # Process arguments
  while [ -n "$1" ]; do
    case "$1" in
      "-A")
        if [ $# -eq 1 ]; then
          echo "ERROR: the \"$1\" option needs to be followed by another argument"
          exit 3
        fi
        shift
        previous_lines=$1
      ;;
      "-B")
        if [ $# -eq 1 ]; then
          echo "ERROR: the \"$1\" option needs to be followed by another argument"
          exit 3
        fi
        shift
        following_lines=$1
      ;;
      *)  # Error
        echo "ERROR: \"$1\" not recognized argument. Aborting..."
        exit 1
      ;;
    esac
    shift
  done

  # Process stdin
  while IFS= read -r line; do
    echo -e "\e[0;33m${line}\e[0m"
    grep -hnI -B ${following_lines} -A ${previous_lines} --color='auto' "$1" < "${line}" 2>/dev/null
  done
}

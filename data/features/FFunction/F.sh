#!/usr/bin/env bash

F() {
  previous_lines=5
  following_lines=5
  grep_query_string=""
  read_from_stdin=""

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
      "-")
        read_from_stdin="true"
      ;;
      *)  # Error
        if [ $# -eq 1 ]; then  # If only one argument this is the last argument and means that is the search dir
          grep_query_string="$1"
        else
          echo "ERROR: \"$1\" not recognized argument. Aborting..."
          exit 1
        fi
      ;;
    esac
    shift
  done

  if [ "${read_from_stdin}" = "true" ]; then
    # Process stdin
    while IFS= read -r line; do
      grep -hnI -B ${following_lines} -A ${previous_lines} --color='auto' "${grep_query_string}" < "${line}" 2>/dev/null
    done
  else
    while IFS= read -r line; do
      grep -hnI -B ${following_lines} -A ${previous_lines} --color='auto' "${grep_query_string}" < "${line}" 2>/dev/null
    done
  fi
}

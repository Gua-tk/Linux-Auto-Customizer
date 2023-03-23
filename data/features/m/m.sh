#!/usr/bin/env bash

m() {
  if command -v man >/dev/null; then
    if [[ $# -eq 1 ]]; then
      man_output=$(man "$@" | grep -E '^ +-[a-zA-Z], --[a-zA-Z-]+')
      echo "$man_output"
    elif [[ $# -eq 2 ]]; then
      man "$1" | grep -E "^ +$2\b" -A1 | sed 's/^\s\+//'
    else
      echo "Error: Invalid arguments." >&2
      return 1
    fi
  else
    echo "Error: 'man' command not found." >&2
    return 1
  fi
}
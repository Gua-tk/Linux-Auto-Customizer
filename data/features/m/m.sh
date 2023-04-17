#!/usr/bin/env bash

# Description: Function to search text in the manual of a command. It expects at least one argument, which should
# contain the name of a system command. The rest of the arguments are the therms searched in the manual.
# Argument 1: String representing a system binary (example: ls)
# Argument 2 (optional): String representing argument option of the binary (example: -A)
m() {
  if ! command -v man &>/dev/null; then
    echo "Error: 'man' command not found."
    return 1
  fi

  if [ $# -eq 0 ]; then  # No arguments given
    echo "Error: Invalid arguments."
    return 1
  fi

  if [ $# -eq 1 ]; then
    man "$1"
    return 0
  fi

  for arg in "${@:2}"; do
    # Search the manual page for the command specified by the first argument ($1)
    # using the 'man' command, and pipe the output to 'grep' for searching the arguments of the command.
    man "$1" | grep -hnI -E "+${arg}" -B 5 -A 5 --color='auto'
  done
}
#!/usr/bin/env bash

# Description: Function to search arguments in the manual of a command, with more than two arguments looks for all
# arguments from the first to the command manual for their definition
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
  else
    for arg in "${@:2}"; do
      # search for lines that start with the second argument ($2) preceded by one or more spaces (^ +)
      # The -A5 option tells grep to also output five lines of context after each match.
      man "$1" | grep -hnI -E "+${arg}" -B 5 -A 5 --color='auto'
    done
  fi
}
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
    # Matches any line that starts with one or more spaces followed by a dash (-), one letter (lowercase or uppercase),
    # a comma, a space, two hyphens (--), and one or more letters (lowercase or uppercase) or dashes (-).
    # This pattern is used to match the short and long options that are documented in the manual page.
    man "$1"
  else
    for arg in "${@:2}"; do
      # search for lines that start with the second argument ($2) preceded by one or more spaces (^ +) and followed by
      # a word boundary (\b). The -A5 option tells grep to also output five lines of context after each match.
      # Remove the leading whitespace from the lines that were matched in the previous step.
      man "$1" | grep -hnI -E "^ +${arg}\\b" -B 5 -A 5 --color='auto'
    done
  fi
}
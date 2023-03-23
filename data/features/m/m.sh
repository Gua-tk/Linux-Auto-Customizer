#!/usr/bin/env bash

# Description:
# Argument 1: String representing a system binary (example: ls)
# Argument 2 (optional): String representing argument option of the binary
m() {
  if ! command -v man &>/dev/null; then
    echo "Error: 'man' command not found."
    return 1
  fi

  if [ $# -lt 1 ]; then
    echo "Error: Invalid arguments."
    return 1
  fi

  if [ $# -eq 1 ]; then
    # Matches any line that starts with one or more spaces followed by a dash (-), one letter (lowercase or uppercase),
    # a comma, a space, two hyphens (--), and one or more letters (lowercase or uppercase) or dashes (-).
    # This pattern is used to match the short and long options that are documented in the manual page.
    man_output="$(man "$@" | grep -E '^ +-[a-zA-Z], --[a-zA-Z-]+')"
    echo "${man_output}"
  else
    for arg in "${@:2}"; do
      # search for lines that start with the second argument ($2) preceded by one or more spaces (^ +) and followed by
      # a word boundary (\b). The -A5 option tells grep to also output one line of context after each match.
      # Remove the leading whitespace from the lines that were matched in the previous step.
      man "${1}" | grep -E "^ +${arg}\\b" -A5 | sed 's/^\s\+//'
    done
  fi
}
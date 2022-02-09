#!/usr/bin/env bash
f()
{
  if  [ $# -eq 0 ]; then  # No arguments given
    find . 2>/dev/null
  elif [ $# -eq 1 ]; then
    if [ -f "$1" ]; then  # Searches therm in a file
      cat "$1"
    elif [ -d "$1" ]; then  # Searches files in directory
      find "$1"
    else
      more * | grep "$1"  # Searches therm in all files
    fi
  elif [ $# -gt 1 ]; then
    local temp="$1"
    while [ $# -gt 1 ]; do
      if [ -f "$temp" ]; then  # Searches therm in a file
        more "$temp" | grep "$2"
      elif [ -d "$temp" ]; then  # Searches file in directory
        if [ -n "$(find "$temp" -name "$2")" ]; then  # Show files matching argument
          more $(find "$temp" -name "$2")
        else
          ls -lah "$temp" | grep "$2"  # Show list of other matching files in elements of directory
        fi
      else  # Literal search in therm
        echo "$temp" | grep "$2"
      fi
      shift
    done
  fi
}

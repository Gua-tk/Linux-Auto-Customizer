#!/usr/bin/env bash

i()
{
  if [ $# -eq 0 ]; then
    tree -d "$(pwd)"
  else
    while [ -n "$1" ]; do
      if [ -d "$1" ]; then
        echo
        tree -d "$1"
        echo
      else
        echo "ERROR: A valid path to a folder is expected, skipping argument"
      fi
      shift
    done
  fi
}

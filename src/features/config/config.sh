#!/usr/bin/env bash

config()
{
  if [ -z "$1" ]; then
    echo "ERROR: config needs two arguments"
    return 1
  fi
  if [ -z "$2" ]; then
    echo "ERROR: config needs two arguments"
    return 1
  fi
  if ! echo "$2" | grep -Eo "@" &>/dev/null; then
    echo "ERROR: config needs an email as the second arguments"
    return 1
  fi
  git config user.name "$1"
  git config user.email "$2"
}

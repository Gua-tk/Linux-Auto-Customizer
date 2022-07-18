#!/usr/bin/env bash

clone()
{
  if [ $# -eq 0 ]; then
    echo "ERROR: You need to provide at least one argument"
    return
  else
    if [ -n "$(echo "$1" | grep -Eo "^http.?://.+$")" ]; then
      git clone "$1"
    else
      git clone "https://$1"
    fi
  fi
}
if [ -f "€{BASH_COMPLETIONS_PATH}" ]; then
  source "€{BASH_COMPLETIONS_PATH}"
  __git_complete clone _git_clone
fi

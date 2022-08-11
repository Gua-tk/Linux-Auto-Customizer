#!/usr/bin/env bash

u()
{
  if [ $# -eq 0 ]; then
    echo "ERROR: You need to provide at least one argument"
    return
  else
    for url_address in "$@"; do
      if [ -n "$(echo "${url_address}" | grep -Eo "^[a-z]+://.+$")" ]; then
        xdg-open "${url_address}" &>/dev/null
      else
        xdg-open "https://${url_address}" &>/dev/null
      fi
    done
  fi
}

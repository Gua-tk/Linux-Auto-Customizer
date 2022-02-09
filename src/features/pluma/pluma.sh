#!/usr/bin/env bash

pluma()
{
  if [ $# -eq 0 ]; then
    nohup pluma &>/dev/null &
  else
    while [ -n "$1" ]; do
      nohup pluma "$1" &>/dev/null &
      shift
    done
  fi
}

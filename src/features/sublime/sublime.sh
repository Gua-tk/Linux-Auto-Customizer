#!/usr/bin/env bash

sublime() {
  if [ $# -eq 0 ]; then
    args="."
  else
    args="$@"
  fi
  nohup sublime ${args} &>/dev/null &
}

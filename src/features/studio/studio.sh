#!/usr/bin/env bash

studio() {
  if [ $# -eq 0 ]; then
    args="."
  else
    args="$@"
  fi
  nohup studio ${args} &>/dev/null &
}

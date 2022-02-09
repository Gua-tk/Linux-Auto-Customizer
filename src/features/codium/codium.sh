#!/usr/bin/env bash

codium() {
  if [ $# -eq 0 ]; then
    args="."
  else
    args="$@"
  fi
  nohup codium ${args} &>/dev/null &
}

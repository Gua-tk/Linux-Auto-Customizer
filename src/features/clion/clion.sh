#!/usr/bin/env bash

clion() {
  if [ $# -eq 0 ]; then
    args="."
  else
    args="$@"
  fi
  nohup clion "${args}" &>/dev/null &
}

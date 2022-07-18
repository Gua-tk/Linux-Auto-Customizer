#!/usr/bin/env bash

pycharm() {
  if [ $# -eq 0 ]; then
    args="."
  else
    args="$@"
  fi
  nohup pycharm "${args}" &>/dev/null &
}

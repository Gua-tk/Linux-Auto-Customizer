#!/usr/bin/env bash

carbon() {
  if [ $# -eq 0 ]; then
    args="."
  else
    args="$@"
  fi
  bazel run //explorer --  "${args}"
}
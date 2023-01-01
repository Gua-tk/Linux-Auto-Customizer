#!/usr/bin/env bash

d()
{ # d, a git diff and color grep dif
  if [ $# -eq 2 ]; then
    if [ -d ".git" ]; then
      git diff --color-words "$1" "$2"
    else
      git diff --color-words --no-index "$1" "$2"
    fi
  elif [ $# -eq 1 ]; then
    if [ -d ".git" ]; then
      git diff --color-words "$1"
    else
      echo "ERROR: If this is not a git directory you need at least two arguments to see any differences."
    fi
  elif [ $# -eq 0 ]; then
    if [ -d ".git" ]; then
      git diff --color-words
    else
      echo "ERROR: If this is not a git directory you need at least two arguments to see any differences."
    fi
  else
    if [ -d ".git" ]; then
      while [ -n "$1" ]; do
        git diff --color-words "$1"
        shift
      done
    else
      echo "ERROR: If this is not a git directory you need at least two arguments to see any differences."
    fi
  fi
}
if [ -f "€{BASH_COMPLETIONS_PATH}" ]; then
  source "€{BASH_COMPLETIONS_PATH}"
  __git_complete d _git_diff
fi

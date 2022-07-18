#!/usr/bin/env bash
alias add="git add"
if [ -f "€{BASH_COMPLETIONS_PATH}" ]; then
  source "€{BASH_COMPLETIONS_PATH}"
  __git_complete add _git_add
fi

#!/usr/bin/env bash
alias checkout="git checkout"
if [ -f "€{BASH_COMPLETIONS_PATH}" ]; then
  source "€{BASH_COMPLETIONS_PATH}"
  __git_complete checkout _git_checkout
fi

#!/usr/bin/env bash

merge()
{
  if [ -z "$1" ]; then
	  git merge
	else
	  git merge origin --no-ff "$@"
	fi
}
if [ -f "€{BASH_COMPLETIONS_PATH}" ]; then
  source "€{BASH_COMPLETIONS_PATH}"
  __git_complete merge _git_merge
fi

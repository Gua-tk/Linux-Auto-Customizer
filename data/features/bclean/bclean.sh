#!/usr/bin/env bash

bclean()
{
  if [ "$1" == "--interactive" ]; then
    git branch --merged >/tmp/merged-branches && \ vi /tmp/merged-branches && xargs git branch -d </tmp/merged-branches
  else
    git fetch -p && for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'); do git branch -D "${branch}"; done
  fi
}

alias git-branch-clean="bclean"

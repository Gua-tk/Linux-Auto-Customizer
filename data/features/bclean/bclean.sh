#!/usr/bin/env bash

bclean()
{
  if [ "$1" == "--interactive" ] || [ "$1" == "-i" ]; then
    current="$(git branch --show-current)"
    git branch --merged \
    | sed '/^\** *develop$/d' \
    | sed '/^\** *master$/d' \
    | sed "/^\** *${current}/d" >/tmp/merged-branches \
    && grep -q '[^[:space:]]' < "/tmp/merged-branches" \
    && nano /tmp/merged-branches \
    && grep -q '[^[:space:]]' < "/tmp/merged-branches" \
    && xargs git branch -d </tmp/merged-branchesS
    unset current
  else
    git fetch -p \
    && for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'); do
      git branch -D "${branch}"
    done
  fi
}

alias git-branch-clean="bclean"

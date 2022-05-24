#!/usr/bin/env bash

pristine()
{
  local delete_ignored_files="no"
  local branch
  for arg in "$@"; do
    if [ "${arg}" == "--ignored" ]; then
      delete_ignored_files="yes"
    fi
  done

  # Check if in git repository and obtain current branch
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch="$(git rev-parse --abbrev-ref HEAD)"
  else
    echo "ERROR: Current directory is not under git version control"
    exit 1
  fi

  # Obtain pristine last version of the project in the currently active branch
  git fetch origin "${branch}"
  git checkout --force -B "${branch}" "origin/${branch}"
  git reset --hard
  if [ "${delete_ignored_files}" == "yes" ]; then
    git clean -fdx
  else
    git clean -fd
  fi
  git submodule update --init --recursive --force
  git submodule foreach git fetch
  git submodule foreach git checkout --force -B "${branch}" "origin/${branch}"
  git submodule foreach git reset --hard
  if [ "${delete_ignored_files}" == "yes" ]; then
    git submodule foreach git clean -fdx
  else
    git submodule foreach git clean -fd
  fi
}

alias git-pristine="pristine"
#!/usr/bin/env bash

commit()
{
  messag="$@"
  while [ -z "${messag}" ]; do
    read -p "Add message: " messag
  done

  trimmedArgs=
  for word in ${messag}; do
    if ! echo "${word}" | grep -qE "-am|-ma|-m|-a"; then
      trimmedArgs+=${word}
    fi
  done

  git commit -am "${trimmedArgs}"
}
if [ -f "€{BASH_COMPLETIONS_PATH}" ]; then
  source "€{BASH_COMPLETIONS_PATH}"
  __git_complete commit _git_commit
fi

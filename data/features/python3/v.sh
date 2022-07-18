#!/usr/bin/env bash
# Create and source a venv with the given name passed as parameter.
# If already exists, only sources activate
# If already activated, do deactivate
v()
{
  if [ $# -eq 0 ]; then
    if [ -n "${VIRTUAL_ENV}" ]; then
      deactivate
    else
      if [ -f activate ]; then
        source activate
        return
      elif [ -f bin/activate ]; then
        source bin/activate
        return
      else
        for i in $(ls); do
          if [ -d "${i}" ]; then
            if [ -f "${i}/bin/activate" ]; then
              source "${i}/bin/activate"
              return
            fi
          fi
        done
      fi
      python3 -m venv venv
    fi
  else
    if [ -n "${VIRTUAL_ENV}" ]; then
      deactivate
    else
      python3 -m venv "$1"
    fi
  fi
}

#!/usr/bin/env bash

f()
{
  default_ignored_dirs=("node_modules" ".git")
  find_ignored_dirs_shell_command=""
  skip_defaults="false"
  ignore_all_levels="true"
  find_dir=""
  custom_command=""

  # Process arguments
  while [ -n "$1" ]; do
    case "$1" in
      "--skip-defaults" | "-s")
        skip_defaults="true"
      ;;
      "--ignore-all" | "-i")
        ignore_all_levels="true"
      ;;
      "--literal" | "-l")  # TODO: Unluckily, I didn't make it work...
        ignore_all_levels="false"
      ;;
      "--dir" | "-d" | "--dir-exclude")
        if [ $# -eq 1 ]; then
          echo "ERROR: the \"$1\" option needs to be followed by another argument"
          exit 3
        fi
        shift
        if [ "${ignore_all_levels}" = "true" ]; then
          find_ignored_dirs_shell_command+=" -o -path */$1/*"
        else
          find_ignored_dirs_shell_command+=" -o -path ./$1/'*'"
        fi
      ;;
      "--custom" | "-c" | "--custom-command")
        if [ $# -eq 1 ]; then
          echo "ERROR: the \"$1\" option needs to be followed by another argument"
          exit 4
        fi
        shift
        custom_command="$1"
      ;;
      *)  # Error
        if [ $# -eq 1 ]; then  # If only one argument this is the last argument and means that is the search dir
          find_dir="$1"
        else
          echo "ERROR: \"$1\" not recognized argument. Aborting..."
          exit 1
        fi
      ;;
    esac
    shift
  done

  # Add the default ignored paths depending on the state of the flag
  if [ "${skip_defaults}" = "false" ]; then
    for dir in "${default_ignored_dirs[@]}"; do
      if [ "${ignore_all_levels}" = "true" ]; then
        find_ignored_dirs_shell_command+=" -o -path */${dir}/*"
      else
        find_ignored_dirs_shell_command+=" -o -path ./${dir}/'*'"
      fi
    done
  fi

  # Set current directory if query directory not present
  if [ -z "${find_dir}" ]; then
    # Since we expect f to be called as a binary in the PATH, we can expect the working directory to be the same that
    # we are using f against
    find_dir="."
  else
    if [ ! -d "${find_dir}" ]; then
      echo "ERROR: \"${find_dir}\" is not a valid directory. Aborting..."
      exit 2
    fi
  fi

  find "${find_dir}" -type f -not \( -type d ${find_ignored_dirs_shell_command} \) 2> /dev/null
}

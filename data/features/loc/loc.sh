#!/usr/bin/env bash

loc() {
  local total_lines=0
  local -r NEW_LINE=$'\n'
  local loc_table=""

  if [ -z "$1" ]; then
    local total_lines_in_directory=0
    for file_route in $(find "$1" -type f -name "*" 2>/dev/null); do
      loc_table+="${file_route};"
      local lines_file="$(sed '/^$/d' < "${file_route}" 2>/dev/null | wc -l)"
      total_lines_in_directory=$(( total_lines_in_directory + lines_file ))
      loc_table+="${lines_file}"
      loc_table+="${NEW_LINE}"
    done
    loc_table+="${1};"
    loc_table+="${total_lines_in_directory}"
    total_lines=$(( total_lines + total_lines_in_directory ))
    loc_table+="${NEW_LINE}"
  else
    local counter_args=1
    while [ -n "$1" ]; do
      if [ -f "$1" ]; then
        loc_table+="${1};"
        local_lines_in_file="$( sed '/^$/d' < "$1"  2>/dev/null | wc -l)"
        loc_table+="${local_lines_in_file}"
        total_lines=$(( total_lines + local_lines_in_file ))
        loc_table+="${NEW_LINE}"     
      elif [ -d "$1" ]; then
        local total_lines_in_directory=0

        for file_route in $(find "$1" -type f -name "*" 2>/dev/null); do
          loc_table+="${file_route};"
          local lines_file="$( sed '/^$/d' < "${file_route}" 2>/dev/null | wc -l)"
          total_lines_in_directory=$(( total_lines_in_directory + lines_file ))
          loc_table+="${lines_file}"
          loc_table+="${NEW_LINE}"
        done
        loc_table+="${1};"
        loc_table+="${total_lines_in_directory}"
        total_lines=$(( total_lines + total_lines_in_directory ))
        loc_table+="${NEW_LINE}"
      else
        loc_table+="argument ${counter_args};"
        local_lines_in_string="$(echo "$1" | sed '/^$/d' | wc -l)"
        loc_table+="${local_lines_in_string}"
        total_lines=$(( total_lines + local_lines_in_string ))
        loc_table+="${NEW_LINE}"
      fi
      counter_args=$(( 1 + counter_args ))
      shift
    done
    loc_table+="${NEW_LINE}"
    loc_table+="TOTAL;"
    loc_table+="${total_lines}"
    echo "${loc_table}" | column -ts ";"
  fi
}

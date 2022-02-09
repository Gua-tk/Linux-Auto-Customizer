#!/usr/bin/env bash

L()
{
  # Work around because du options are hard to parametrize for a different directory that the current one for showing size of hiddent directories
  if [ -n "$1" ]; then
    local -r current_path="$(pwd)"
    cd "$1"
  fi
  local -r NEW_LINE=$'\n'
  local -r lsdisplay="$(ls -lhA | tr -s " " | tail -n+2)"  # Obtain ls data in list format
  local -r numfiles="$(echo "${lsdisplay}" | wc -l)"  # Obtain number of elements in the folder
  local -r dudisplay="$(du -shxc .[!.]* * 2>/dev/null | sort -h | tr -s "\\t" " " | head -n -1)"  # Obtain du data for the real size of the directories, deleting the line of the total size
  local -r totaldu="$(echo "${dudisplay}" | tail -1 | rev | cut -d " " -f2 | rev)"  # Obtain the total size of the folder
  local finaldisplay=""
  # Iterate over every line in ls and check if it is a directory in order to change the size shown in ls (4 KB) for the real size of directory from the output of du
  local IFS=$'\n'
  for linels in ${lsdisplay}; do
    element_name="$(echo "${linels}" | cut -d ' ' -f9-)"  # Obtain full name of the element that we are goind to add
    if [[ "${linels}" =~ ^d.* ]]; then  # If a directory, perform substitution of size
      for linedu in ${dudisplay}; do  # Search for matching du line using name from both ls and du
        if [[ "$(echo ${linedu} | cut -d ' ' -f2-)" = "${element_name}" ]]; then  # Search for match using directory name
          currentline=$(echo ${linels} | cut -d " " -f-4)  # Obtain prefix of line (before the column of the size in ls)
          currentline="${currentline} $(echo "${linedu}" | cut -d ' ' -f1)"  # Obtain size from du and append
          currentline="${currentline} $(echo "${linels}" | cut -d ' ' -f6-)"  # Obtain rest of the line
          # Now add the semicolons in between columns in order to work with column command

          finaldisplay="$finaldisplay$NEW_LINE$(echo "${currentline}" | cut -d ' ' -f-8 | tr " " ";");${element_name}"
          break
        fi
      done
    else
      finaldisplay="${finaldisplay}${NEW_LINE}$(echo "${linels}" | cut -d ' ' -f-8 | tr " " ";");${element_name}"  # Change spaces for semicolons for using column
    fi
  done
  finaldisplay="$(echo "${finaldisplay}"  | column -ts ";")"  # Construct table by using column
  finaldisplay="${totaldu} in ${numfiles} files and directories${NEW_LINE}${finaldisplay}"  # Prepend first line of output with general summary
  echo "${finaldisplay}"
  if [ -n "${current_path}" ]; then
    cd "${current_path}"
  fi
}

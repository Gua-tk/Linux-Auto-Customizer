#!/usr/bin/env bash

x() {
  local first_compressed_file_arg_pos=
  if [ -d "$1" ]; then
    local -r decompression_folder="$1"
    mkdir -p "${decompression_folder}"
    local old_folder="$(pwd)"
    shift  # With this we expect files in $1 and the following positions.
  fi

  while [ -n "$1" ]; do
    local absolute_first_arg=
    if [ -n "${decompression_folder}" ]; then
      if [ -n "$(echo "$1" | grep -Eo "^/")" ]; then  # Absolute path
        absolute_first_arg="$1"
      else  # relative path
        absolute_first_arg="$(pwd)/$1"
      fi
      cd "${decompression_folder}"
    else
      absolute_first_arg="$1"
    fi
    if [ -f "${absolute_first_arg}" ] ; then
      local mime_type="$(mimetype "${absolute_first_arg}" | cut -d ":" -f2 | tr -d " ")"
      case "${mime_type}" in
        application/x-bzip-compressed-tar)
          tar xjf "${absolute_first_arg}"
        ;;
        application/x-compressed-tar)
          tar xzf "${absolute_first_arg}"
        ;;
        application/x-bzip)
          if ! which bunzip2 2>/dev/null; then
            sudo €{PACKAGE_MANAGER_INSTALL} bunzip2
          fi
          bunzip2 "${absolute_first_arg}"
        ;;
        application/vnd.rar)
          if ! which rar 2>/dev/null; then
            sudo €{PACKAGE_MANAGER_INSTALL} rar
          fi
          rar x "${absolute_first_arg}"
        ;;
        application/gzip)
          if ! which gzip 2>/dev/null; then
            sudo €{PACKAGE_MANAGER_INSTALL} gzip
          fi
          gzip -dk "${absolute_first_arg}"
        ;;
        application/x-xz-compressed-tar)
          tar xf "${absolute_first_arg}"
        ;;
        application/x-tar)
          tar xf "${absolute_first_arg}"
        ;;
        application/x-bzip-compressed-tar)
          tar xjf "${absolute_first_arg}"
        ;;
        application/zip)
          if ! which unzip 2>/dev/null; then
            sudo €{PACKAGE_MANAGER_INSTALL} unzip
          fi
          unzip "${absolute_first_arg}"
        ;;
        application/x-compress)
          if ! which uncompress 2>/dev/null; then
            sudo €{PACKAGE_MANAGER_INSTALL} uncompress
          fi
          uncompress "${absolute_first_arg}"
        ;;
        application/x-7z-compressed)
          if ! which 7z 2>/dev/null; then
            sudo €{PACKAGE_MANAGER_INSTALL} 7z
          fi
          7z x "${absolute_first_arg}"
        ;;
        *)
          echo "${absolute_first_arg} cannot be extracted via x"
        ;;
      esac
    else
      echo "'${absolute_first_arg}' is not a valid file for x"
    fi
    if [ -n "${decompression_folder}" ]; then
      cd "${old_folder}"
    fi

    shift
  done
  if [ ! -n "$(echo "${absolute_first_arg}")" ]; then
    echo "ERROR: x needs at least an argument. The first arg can be a file or directory where compressed files will be extracted. The rest o arguments are paths to different compressed files."
  fi

}

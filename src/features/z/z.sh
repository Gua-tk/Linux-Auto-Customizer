
z() {
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

    local compression_type="$1"
    shift
    if [ -f "${absolute_first_arg}" ]; then
      local first_arg_name="$(echo "$1" | rev | cut -d "/" -f1 | rev)"
      case "${compression_type}" in
        tar.bz2)
          tar cvjf "${first_arg_name}.tar.bz2" "${absolute_first_arg}"
        ;;
        tar.gz)
          tar cvzf "${first_arg_name}.tar.gz" "${absolute_first_arg}"
        ;;
        bz2)
          bzip2 "${first_arg_name}.bz2" "${absolute_first_arg}"
        ;;
        rar)
          rar a "${first_arg_name}.rar" "${absolute_first_arg}"
        ;;
        gz)
          gzip -c "${absolute_first_arg}.gz" > "${first_arg_name}"
        ;;
        tar)
          tar cf "${first_arg_name}.tar" "${absolute_first_arg}"
        ;;
        tbz2)
          tar cvjf "${first_arg_name}.tbz2" "${absolute_first_arg}"
        ;;
        tgz)
          tar cvzf "${first_arg_name}.tgz" "${absolute_first_arg}"
        ;;
        zip)
          zip "${first_arg_name}.zip" "${absolute_first_arg}"
        ;;
        Z)
          compress "${first_arg_name}.Z" "${absolute_first_arg}"
        ;;
        7z)
          7z a "${first_arg_name}.7z" "${absolute_first_arg}"
        ;;
        *)
          echo "${absolute_first_arg} cannot be extracted via x"
        ;;
      esac
    else
      echo "'${absolute_first_arg}' is not a valid file for z"
    fi
    if [ -n "${decompression_folder}" ]; then
      cd "${old_folder}"
    fi

    shift
  done
  if [ ! -n "$(echo "${absolute_first_arg}")" ]; then
    echo "ERROR: z needs at least an argument. The first arg can be a file or directory where compressed files will be created. The rest o arguments are paths to different files that have to be compressed."
  fi
}

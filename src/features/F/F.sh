
F() {
  if [ $# -eq 0 ]; then  # No arguments given
    find / 2>/dev/null
  else
    if [ -d "$1" ]; then
      first_argument="$1"
      shift
    else
      first_argument="."
    fi
    IFS=$'\n'
    while [ -n "$1" ]; do
      for filename in $(find "${first_argument}" -type f 2>/dev/null); do
        local result="$(cat "${filename}" 2>/dev/null | grep "$1")"
        if [ -n "$(echo "${result}")" ]; then
          echo
          echo -e "\e[0;33m${filename}\e[0m"
          cat "${filename}" 2>/dev/null | grep -hnI -B 3 -A 3 --color='auto' "$1"
         fi
      done
      shift
    done
  fi
}

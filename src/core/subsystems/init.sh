# Shellcheck thinks you are comparing two strings, but we expand using the euro.
# shellcheck disable=SC2050
if [ "€{OS_NAME}" != "WSL2" ]; then
  # If not running interactively, don't do anything
  case $- in
      *i*) ;;
        *) return;;
  esac
fi

# Make sure that PATH is pointing to €{PATH_POINTED_FOLDER} (where we will put our soft links to the software)
if ! echo "${PATH}" | grep -Eq "€{PATH_POINTED_FOLDER}"; then
  export PATH="${PATH}:€{PATH_POINTED_FOLDER}"
fi
if [ "€{OS_NAME}" != "WSL2" ]; then
  # If not running interactively, don't do anything
  case $- in
      *i*) ;;
        *) return;;
  esac
fi

# Make sure that PATH is pointing to €{PATH_POINTED_FOLDER} (where we will put our soft links to the software)
if [ -z "$(echo $PATH | grep -Eo "€{PATH_POINTED_FOLDER}")" ]; then
  export PATH="${PATH}:€{PATH_POINTED_FOLDER}"
fi
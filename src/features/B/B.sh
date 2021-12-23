
B() {
  clear
  source "€{BASHRC_PATH}"
  source "€{PROFILE_PATH}"
  while [ -n "$1" ]; do
    case "$1" in 
      fonts)
        fc-cache -f
      ;;
      path)
        hash -r
      ;;
      *) 
        echo "ERROR: Not recognized argument. Exiting..."
        exit 1
      ;;
    esac
    shift
  done
}

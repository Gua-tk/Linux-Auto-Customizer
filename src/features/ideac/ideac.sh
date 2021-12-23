
ideac() {
  if [ $# -eq 0 ]; then
    args="."
  else
    args="$@"
  fi
  nohup ideac ${args} &>/dev/null &
}

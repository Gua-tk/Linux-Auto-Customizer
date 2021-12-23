
ideau() {
  if [ $# -eq 0 ]; then
    args="."
  else
    args="$@"
  fi
  nohup ideau ${args} &>/dev/null &
}

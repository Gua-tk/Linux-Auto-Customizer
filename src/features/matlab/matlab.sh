matlab() {
  if [ $# -eq 0 ]; then
    args="."
  else
    args="$@"
  fi
  nohup matlab ${args} &>/dev/null &
}
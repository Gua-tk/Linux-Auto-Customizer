
pycharmpro() {
  if [ $# -eq 0 ]; then
    args="."
  else
    args="$@"
  fi
  nohup pycharmpro ${args} &>/dev/null &
}

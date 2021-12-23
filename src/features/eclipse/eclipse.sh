
eclipse() {
  if [ $# -eq 0 ]; then
    args="."
  else
    args="$@"
  fi
  nohup eclipse ${args} &>/dev/null &
}

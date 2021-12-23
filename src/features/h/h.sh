
h()
{
  if [ $# -eq 0 ]; then
    history
  else
    if [ $# -eq 1 ]; then
      history | grep --color=always "$1"
    else
      echo "ERROR: Too many arguments"
      return
    fi
  fi
}

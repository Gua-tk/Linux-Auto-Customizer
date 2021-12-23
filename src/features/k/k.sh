
k() {    #sudo kill `lsof -i:3000 -t` "$1"  # kill by port
  [ "$1" -eq "$1" ] 2>/dev/null
  if [ $? -eq 0 ]; then
    sudo kill -9 "$1"
  else
    if [ -n "$1" ]; then
      pkill "$1"
    else
      # Introduce port to be killed
      echo "Kill port nº:"
      read portkillnumber
      for pid_program in $(sudo lsof -i:"${portkillnumber}" | tail -n+2 | tr -s " "  | cut -d " " -f2 | sort | uniq); do
        sudo kill ${pid_program}
      done
    fi
  fi
}

#!/usr/bin/env bash
customizerGUI()
{

  GUI_process_id="$(netstat -ltnup 2>/dev/null | tr -s " " | grep -Eo "5000.*\$" | cut -d "/" -f1 | rev | cut -d " " -f1 | rev)"
  if [ -n "${GUI_process_id}" ]; then
    kill -9 "${GUI_process_id}"
  fi

  local direction="$(which customizerGUI)"
  "${direction}" &>/dev/null &


  echo "open browser in https://localhost:5000"
  xdg-open http://127.0.0.1:5000/index.html#/ &>/dev/null
}

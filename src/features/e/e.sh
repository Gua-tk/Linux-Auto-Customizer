
e()
{
  if [ -z "$1" ]; then
    editor new_text_file &
  else
    if [ -f "$1" ]; then
      if [ ! -z $(echo "$1" | grep -Fo "/") ]; then
  			local -r dir_name="$(echo "$1" | rev | cut -d '/' -f2- | rev)"
  			mkdir -p "${dir_name}"
				cd "${dir_name}"
      fi
      case "$1" in
        *)
          nohup pluma "$1" &>/dev/null &
        ;;
        *.py)
          nohup pycharm "$1" &>/dev/null &
        ;;
        *.tex)
          nohup texmaker "$1" &>/dev/null &
        ;;
        *.pdf)
          nohup okular "$1" &>/dev/null &
        ;;
        *.rtf)
          nohup gedit "$1" &>/dev/null &
        ;;
      esac
		else
			if [ -d "$1" ]; then
				cd "$1"
				if [ -d ".git" ]; then
				  git fetch
          nohup gitk --all --date-order &>/dev/null &
          nohup pycharm &>/dev/null &
				else
          nohup nemo "$1" &>/dev/null &
				fi
			else
        #Inexistent route or new file
        if [ ! -z $(echo "$1" | grep -Fo "/") ]; then
          local -r dir_name="$(echo "$1" | rev | cut -d '/' -f2- | rev)"
          if [ -d "${dir_name}" ]; then
            cd "${dir_name}"
          else
            mkdir -p "${dir_name}"
            cd "${dir_name}"
          fi
          editor "$(echo "$1" | rev | cut -d '/' -f1 | rev)" &
        else
          case "$1" in
            *.py)
              nohup pycharm "$1" &>/dev/null &
            ;;
            *.tex)
              nohup texmaker "$1" &>/dev/null &
            ;;
            *)
              nohup pluma "$1" &>/dev/null &
            ;;
         esac
        fi
			fi
		fi
	fi
}

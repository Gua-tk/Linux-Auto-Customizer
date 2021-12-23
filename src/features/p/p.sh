
p()
{
  if [ -n "$1" ]; then
    sudo lsof -i:"$1" | tail -n+2 | tr -s " "  | cut -d " " -f-2 | sort | uniq | column -ts " "
  else
    sudo lsof -Pan -i tcp -i udp
  fi
}

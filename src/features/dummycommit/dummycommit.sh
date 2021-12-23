
dummycommit()
{
  git add -A
  messag="$@"
  while [ -z "$messag" ]; do
    read -p "Add message: " messag
  done
  git commit -am "$messag"
  git push
}

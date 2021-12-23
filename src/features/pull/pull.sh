
pull()
{
  if [ -z "$1" ]; then
	  git pull
	else
	  git pull origin --no-ff "$@"
	fi
}
if [ -f "€{BASH_COMPLETIONS_PATH}" ]; then
  source "€{BASH_COMPLETIONS_PATH}"
  __git_complete pull _git_branch  # Using git branch completions since _git_pull completions only give incorreclty "origin origin" as completion
fi

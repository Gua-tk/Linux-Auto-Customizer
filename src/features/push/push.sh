
push()
{
  git fetch &>/dev/null
  if [ -z "$1" ]; then
    if git rev-parse --symbolic-full-name $(git branch --show-current)@{upstream} &>/dev/null; then
      git push
    else
	    git push --set-upstream origin "$(git branch --show-current)"
    fi
	else
	  if git rev-parse --symbolic-full-name $(git branch --show-current)@{upstream} &>/dev/null; then
	    git push origin "$@"
    else
	    git push --set-upstream origin "$@"
    fi
	fi
	unset returnerror
}
if [ -f "€{BASH_COMPLETIONS_PATH}" ]; then
  source "€{BASH_COMPLETIONS_PATH}"
  __git_complete push _git_branch  # Using git branch completions since _git_push completions only give incorreclty "origin origin" as completion
fi

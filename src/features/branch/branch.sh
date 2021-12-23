alias branch="git branch"
if [ -f "€{BASH_COMPLETIONS_PATH}" ]; then
  source "€{BASH_COMPLETIONS_PATH}"
  __git_complete branch _git_branch
fi

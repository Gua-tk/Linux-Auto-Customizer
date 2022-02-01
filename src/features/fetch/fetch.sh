alias fetch="git fetch -f --prune"
if [ -f "€{BASH_COMPLETIONS_PATH}" ]; then
  source "€{BASH_COMPLETIONS_PATH}"
  __git_complete fetch _git_fetch
fi

#!/usr/bin/env bash
# Save and reload from history before prompt appears to be sure the prompt is being charged correctly because it conflicts with gitprompt.
if [ -z "$(echo "${PROMPT_COMMAND}" | grep -Fo " [ ! -d .git ] && source "€{FUNCTIONS_FOLDER}/prompt.sh"")" ]; then
  # Check if there is something inside PROMPT_COMMAND, so we put semicolon to separate or not
  if [ -z "${PROMPT_COMMAND}" ]; then
    export PROMPT_COMMAND=" [ ! -d .git ] && source "€{FUNCTIONS_FOLDER}/prompt.sh""
  else
    export PROMPT_COMMAND="${PROMPT_COMMAND}; [ ! -d .git ] && source "€{FUNCTIONS_FOLDER}/prompt.sh""
  fi
fi

#!/usr/bin/env bash

if [ -f "€{BIN_FOLDER}/gitprompt/gitprompt.sh" ]; then
    GIT_PROMPT_THEME=Default_Ubuntu
    GIT_PROMPT_ONLY_IN_REPO=1
    source "€{BIN_FOLDER}/gitprompt/gitprompt.sh"
fi


# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=100000
export HISTFILESIZE=10000000
# append to the history file, don't overwrite it
shopt -s histappend
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoredups
# Ignore simple commands in history
HISTIGNORE="ls:ps:history:l:pwd:top:gitk"
# The cmdhist shell option, if enabled, causes the shell to attempt to save each line of a multi-line command in the
# same history entry, adding semicolons where necessary to preserve syntactic correctness.
shopt -s cmdhist
# Store multiline commands with newlines when possible, rather that using semicolons
#shopt -s lithist
# To retrieve the commands correctly
HISTTIMEFORMAT='%F %T '
# Check the windows size on every prompt and reset the number of columns and rows if necessary
shopt -s checkwinsize  # Kinda buggy

# Save and reload from history before prompt appears
if [ -z "$(echo "${PROMPT_COMMAND}" | grep -Fo "history -a; history -r")" ]; then
  # Check if there is something inside PROMPT_COMMAND, so we put semicolon to separate or not
  if [ -z "${PROMPT_COMMAND}" ]; then
    export PROMPT_COMMAND="history -a; history -r"
  else
    export PROMPT_COMMAND="${PROMPT_COMMAND}; history -a; history -r"
  fi
fi

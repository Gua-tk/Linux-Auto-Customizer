########################################################################################################################
# - Name: tmux_functions.sh                                                                                            #
# - Description: Miscellaneous configuration (functions and aliases) of tmux using bash. Functions include completions #
# - Creation Date: 15/12/21                                                                                            #
# - Last Modified: 15/12/21                                                                                            #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: aleix.marine@estudiants.urv.cat                                                                             #
# - Permissions: This script can not be executed directly, only sourced to import its functions and process its own    #
# imports. See the header of each function to see its privilege requirements.                                          #
# - Arguments: No arguments                                                                                            #
# - Usage: Not executed directly, sourced from functions.sh                                                            #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


alias t="tmux"
alias tls="echo -e '\e[0;33m'; echo \"Name | Attached(1/0) | Windows name\"; echo -en '\e[0m'; tmux ls -F '#S      #{session_attached}              #{W}'"
alias thelp="tmux list-commands"
alias tks="tmux kill-server"
alias trefresh="tmux refresh-client -S"


# - Description: Generates a completion using the active tmux sessions.
# - Permissions: Needs access to tmux server.
_tsession_complete()
{
  COMPREPLY=($(compgen -W "$(tmux ls -F '#S' | xargs)" -- "${COMP_WORDS[COMP_CWORD]}"))
}


# - Description: Generates a completion using the name of the files in €{CURRENT_INSTALLATION_FOLDER}
# - Permissions: Needs access to the tmux installation folder.
_tload()
{
  COMPREPLY=($(compgen -W "$(ls -ca "€{CURRENT_INSTALLATION_FOLDER}" | grep -Eo ".*\.(json|yaml)")" -- "${COMP_WORDS[COMP_CWORD]}"))
}


# - Description: Create the new sessions supplied by argument.
# - Permissions: Needs access to tmux server.
# - Arguments:
#   * Argument N: Name of the new session.
tns()
{
  while [ $# -ne 0 ]; do
		tmux new-session -d -s "$1"
    shift
  done
}


# - Description: Invoke a new terminal that does not load tmux.
# - Permissions: No special permissions needed.
# - Arguments: No arguments.
told()
{
  gnome-terminal
}

# - Description: Saves configuration of the current session to a file.
# - Permissions: Needs access to tmux server and be inside a tmux session.
# - Arguments:
#   * Argument 1: Targeted tmux session file name in €{CURRENT_INSTALLATION_FOLDER}
tsave()
{
	tmuxp freeze "$1"
}
complete -F _tsession_complete tsave


# - Description: Load configuration from the installation folder of tmux
# - Permissions: Needs access to tmux server and be inside a tmux session.
# - Arguments:
#   * Argument 1: Targeted tmux session file name in €{CURRENT_INSTALLATION_FOLDER}
tload()
{
	tmuxp load "€{CURRENT_INSTALLATION_FOLDER}/$1"
}
complete -F _tload tload


# - Description: From outside tmux attaches the current client to an existing tmux session or creates a new one. From
#   inside tmux perform a `tmux switch` to the desired session.
# - Permissions: Needs access to tmux server.
# - Arguments:
#   * Argument 1: Targeted tmux session using name.
ta()
{
  if [ -z "$1" ]; then
    tmux attach-session
  else
    tmux attach-session -t "$1"
  fi
}
complete -F _tsession_complete ta


# - Description: Detaches from the current tmux session, returning to the original bash shell that called tmux.
# - Permissions: Needs access to tmux server.
# - Arguments:
#   * Argument 1: Targeted tmux session using name.
td()
{
  tmux detach-client -s "$1"
}
complete -F _tsession_complete td


# - Description: Renames the current session to the supplied argument.
# - Permissions: Needs access to tmux server.
# - Arguments:
#   * Argument 1: Targeted tmux session using name.
trs()
{
	tmux rename-session "$1"
}
complete -F _tsession_complete ts


# - Description: Switch the current session to the desired session. This allows you to control another terminal.
# - Permissions: Needs access to tmux server.
# - Arguments:
#   * Argument N: Targeted tmux session using name.
#   * Argument N+1: Command to send to the session.
ts()
{
	tmux switch -t "$1"
}
complete -F _tsession_complete ts


# - Description: Sends commands to the desired sessions.
# - Permissions: Needs access to tmux server.
# - Arguments:
#   * Argument N: Targeted tmux session using name.
#   * Argument N+1: Command to send to the session.
tsend()
{
  while [ $# -ne 0 ]; do
    tmux send -t "$1" "$2" Enter
    shift; shift
  done
}
complete -F _tsession_complete tsend


# - Description: Kills the desired tmux session using its name. This can be consulted using `tmux ls`.
# - Arguments:
#   * Argument N: tmux session name to be killed.
tk()
{
  for session_name in "$@"; do
    tmux kill-session -t "${session_name}"
  done
}
complete -F _tsession_complete tk


# - Description: Inverts the mouse state by adding "set -g mouse on" line into .tmux.conf or deleting the same line.
#   You need to reload tmux afterwards to reload the configuration changes.
# - Permissions: Needs access to €{HOME_FOLDER}/.bashrc to write and read.
# - Arguments: No arguments
tm()
{
  local -r activate_mouse_tmuxconf_line="set -g mouse on"
  if ! grep -qE "^${activate_mouse_tmuxconf_line}\$" "€{HOME_FOLDER}/.tmux.conf" &>/dev/null; then
    echo "${activate_mouse_tmuxconf_line}" >> "€{HOME_FOLDER}/.tmux.conf"
    tmux source-file "€{HOME_FOLDER}/.tmux.conf"
  else
    sed "s/^${activate_mouse_tmuxconf_line}\$//g" -i "€{HOME_FOLDER}/.tmux.conf"
  fi
}



# https://unix.stackexchange.com/questions/43601/how-can-i-set-my-default-shell-to-start-up-tmux
# Make sure that
#  * (1) tmux exists on the system
#  * (2) we're in an interactive shell
#  * (3) tmux doesn't try to run within itself
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  attach_session="$(tmux ls -F '#{session_attached} #{?#{==:#{session_last_attached},},1,#{session_last_attached}} #{session_id}' 2> /dev/null | awk '/^0/ { if ($2 > t) { t = $2; s = $3 } }; END { if (s) printf "%s", s }')"
  if [ -n "$attach_session" ]; then

    # * Putting this into .bashrc can give some problems, since all the functions that are after this file will not be
    #   loaded, since the terminal is blocked executing the tmux line. This means that when bash is loaded when
    #   launching a terminal, if the tmux is not loaded, the .bashrc will be loaded into this "first" bash environment
    #   until this line is found. Then, the .bashrc loading is interrupted by the execution of the tmux command.
    #   - At that point, tmux will launch the default shell which presumably will be bash (another new bash session
    #     hosted in tmux) and will load the same .bashrc, but this time tmux is already loaded so it will not encounter
    #     this "tmux" call because it is protected by the above if. If the tmux call is not protected, we would nest a
    #     session and presumably enter in an infinite recursive loop of tmux sessions; instead we will load all .bashrc
    #     functions into the bash environment that is being hosted by tmux as usual, giving to us a bash session with
    #     all .bashrc loaded into the bash session hosted by tmux.
    # * When we exit tmux, the blocking command "tmux" explained in the first bullet is finished, so the original bash
    #   session that we had in the beginning that was interrupted while was loading its .bashrc will continue
    #   parsing .bashrc contents.
    #   This gives us a problem if we intend to work with bash and with tmux in independent sessions. When exiting tmux
    #   and having the mouse on there is a buffer that is left behind in an inconsistent state, which results in the
    #   mouse movement producing trashy characters on screen. We can disable this buffer by "reset" command or
    #   manually changing the state of these buffers with "echo -en '\e[?1003l'" (or similar).
    #   In this case we are choosing "echo -en '\e[?1003l'" because if we use reset we would lose all the imports that
    #   we loaded into the original bash session until we executed tmux, leaving us into an inconsistent bash session
    #   state created by ourselves regarding all the imports of customizer already installed and its order regarding
    #   tmux imports (after or before).
    #   This solution is not perfect: The bash session where we return when we kill tmux had loaded all the data and
    #   functions in .bashrc before the tmux call the amount of time that we used tmux. After exiting tmux it loads the
    #   rest of the lines after the tmux call. This can cause trouble in functions or variables that are dependent on
    #   time events. Also it means that when we invoke a bash session we will be loading .bashrc one time for tmux and
    #   one incomplete time for the first bash session, which that incompleteness comes from all the .bashrc code after
    #   the tmux call. This means that this call should be the last to load in .bashrc, but because our bashrc features
    #   are independent, we can not make sure that this line will be the last to load (by now).

    # This is a blocking synchronous call. We will continue executing this point of the code when tmux exits, which only
    # happens if we exit or kill its process.
    tmux attach -t "${attach_session}"
    # When we exit tmux, we call reset, so the bug of the mouse does not affect us.
    # https://github.com/tmux/tmux/issues/2116
    echo -en '\e[?1003l'
  else
    # If we are root we will not find any tmux server because they are on different folders, so it does not make sense
    # to load tmux if we are root, since we would be probably nesting sessions.
    if [ ${EUID} -ne 0 ]; then
      # Use the following instruction instead of tmux to make tmux kidnap the session so there is no terminal to fall
      # back after killing the tmux server
      #exec tmux
      # This is a blocking synchronous call. We will continue executing this point of the code when tmux exits, which only happens if we exit or kill its process.
      tmux
      # When we exit tmux, we call reset, so the bug of the mouse does not affect us.
      # https://github.com/tmux/tmux/issues/2116
      echo -en '\e[?1003l'
    fi
  fi
fi


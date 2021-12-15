
alias at="tmux a -t"
alias oldt="tmux new -s default"
alias t="tmux"
alias tls="tmux ls -F '#{session_attached} #{session_name}'"
alias tk="tmux kill-ses"
alias tks="tmux kill-server"
alias tds="tmux a #"
alias trefresh="tmux refresh-client -S"
alias pbcopy="xsel --clipboard --input"
alias pbpaste="xsel --clipboard --output"

att()
{
	tmux attach -t "$1"
}

dt()
{
	local CONTADOR=0
	while [ $# -ne 0 ]; do
		if [ "$1" != "default" ]; then
		  CONTADOR=$((${CONTADOR} + 1))
		  tmux new-session -d -s "$1"
	  fi
	  shift
	done
}


freezesession()
{
	tmuxp freeze "$1"
}


session()
{
	if [ -n "$1" ]; then
		tmuxp load "€{CURRENT_INSTALLATION_FOLDER}/$1.yaml"
	else
		tmuxp load "€{CURRENT_INSTALLATION_FOLDER}/main.yaml"
	fi
}


ta()
{
  if [[ -z $1 ]]; then
    tmux attach
  else
    tmux attach -t "$1"
  fi
}
_ta() {
  TMUX_SESSIONS=$(tmux ls -F '#S' | xargs)
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "$TMUX_SESSIONS" -- $cur) )
}
complete -F _ta ta


td()
{
  tmux detach "$1"
}
_td() {
  TMUX_SESSIONS=$(tmux ls -F '#S' | xargs)
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "$TMUX_SESSIONS" -- $cur) )
}
complete -F _td td


trs()
{
	tmux rename-session "$1"
}


ts()
{
	tmux switch -t "$1"
}
_ts() {
  TMUX_SESSIONS=$(tmux ls -F '#S' | xargs)
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "$TMUX_SESSIONS" -- $cur) )
}
complete -F _ts ts


tsend()
{
  tmux send -t "$1" "$2" Enter
}


tses()
{
	tmuxp load "€{CURRENT_INSTALLATION_FOLDER}/$1.json"
}


tsesconvert()
{
	tmuxp convert -y "$1"
}


tsk()
{
CONTADOR=0
while [ "$*" ]
do
	if [[ "$1" == "default" ]]; then
	  shift
	else
	  let CONTADOR=$CONTADOR+1
	  tmux kill-session -t $1
    shift
  fi
done
}
_tsk() {
    TMUX_SESSIONS=$(tmux ls -F '#S' | xargs)

    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "$TMUX_SESSIONS" -- $cur) )
}
complete -F _tsk tsk

# Inverts the mouse state by adding "set -g mouse on" line into .tmux.conf or deleting the same line.
# You need to reload tmux afterwards to reload the configuration changes.
tm()
{
  local -r activate_mouse_tmuxconf_line="set -g mouse on\$"
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



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

# https://unix.stackexchange.com/questions/43601/how-can-i-set-my-default-shell-to-start-up-tmux
# Make sure that
#  * (1) tmux exists on the system
#  * (2) we're in an interactive shell
#  * (3) tmux doesn't try to run within itself
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  attach_session="$(tmux 2> /dev/null ls -F '#{session_attached} #{?#{==:#{session_last_attached},},1,#{session_last_attached}} #{session_id}' | awk '/^0/ { if ($2 > t) { t = $2; s = $3 } }; END { if (s) printf "%s", s }')"
  if [ -n "$attach_session" ]; then
    tmux attach -t "$attach_session"
  else
    # Use the following instruction instead of tmux to make tmux kidnap the session so there is no terminal to fall back after killing the tmux server
    #exec tmux
    tmux
  fi
fi


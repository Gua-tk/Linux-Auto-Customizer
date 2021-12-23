
o()
{
	if [[ -z "$1" ]]; then
		nemo "$(pwd)" &>/dev/null &
	else
		nemo "$1" &>/dev/null &
	fi
}

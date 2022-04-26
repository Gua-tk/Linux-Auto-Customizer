#!/usr/bin/env bash

nemo()
{
	if [[ -z "$1" ]]; then
		nohup nemo "$(pwd)" &>/dev/null &
	else
		nohup nemo "$1" &>/dev/null &
	fi
}

alias o="nemo"
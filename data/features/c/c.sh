#!/usr/bin/env bash

c()
{
  clear
	if [ -d "$*" ]; then
		cd "$*"
	elif [ -f "$*" ]; then
		cat "$*"
	fi
}

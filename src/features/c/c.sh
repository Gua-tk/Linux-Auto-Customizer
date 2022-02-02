#!/usr/bin/env bash

c()
{
  clear
	if [ -d "$1" ]; then
		cd $1
	elif [ -f "$1" ]; then
		cat $1
	fi
}

#!/usr/bin/env bash

_customizer-install() {
  COMPREPLY=()
  local arguments="$(echo "$(customizer commands)")"
  COMPREPLY=( $(compgen -W "${arguments}" -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F _customizer-install customizer-install

_customizer-uninstall() {
  COMPREPLY=()
  local arguments="$(echo "$(customizer commands)")"
  COMPREPLY=( $(compgen -W "${arguments}" -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F _customizer-uninstall customizer-uninstall

_customizer() {
  COMPREPLY=()
  local arguments="$(echo "$(customizer commands)")"
  COMPREPLY=( $(compgen -W "${arguments}" -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F _customizer customizer
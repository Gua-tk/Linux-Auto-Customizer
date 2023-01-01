#!/usr/bin/env bash

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
  if [ ! -z "${GIT_PROMPT_LAST_COMMAND_STATE}" ]; then
    if [ "${GIT_PROMPT_LAST_COMMAND_STATE}" -gt 0 ]; then  # Red color if error
      color_dollar="\[\e[1;31m\]"
    else  # light green color if last command is ok
      color_dollar="\[\e[1;32m\]"
    fi
  else
    color_dollar="\[\e[2;32m\]"
  fi
    # is root
    if [ "${EUID}" == 0 ]; then
      prompt_last_char="#"
    else
      prompt_last_char="\$"
    fi
    PS1="\[\e[1;33m\]$(date "+%a %d %b %Y") \[\e[0;35m\]\u\[\e[0;0m\]@\[\e[0;36m\]\H \[\e[0;33m\]\w
\[\e[0;37m\]\t ${color_dollar}${prompt_last_char} \[\e[0;0m\]"
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt color_dollar

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    :
    PS1="$PS1\[\\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\\a\]"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then

    if test -r ~/.dircolors; then
      if eval "$(dircolors -b ~/.dircolors)"; then
        :
      else
        eval "$(dircolors -b)"
      fi
    else
      eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

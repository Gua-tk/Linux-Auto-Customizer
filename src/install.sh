#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer installation of features.                                                              #
# - Description: A set of programs, functions, aliases, templates, environment variables, wallpapers, desktop          #
# features... with an automatic installation collected in a simple portable shell script to customize a Linux          #
# environment.                                                                                                         #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 17/9/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: aleix.marine@estudiants.urv.cat                                                                             #
# - Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when   #
# logged as root) to install some of the features.                                                                     #
# - Arguments: Accepts behavioural arguments with one hyphen (-f, -o, etc.) and feature selection with two hyphens     #
# (--pycharm, --gcc).                                                                                                  #
# - Usage: Installs the features selected by argument, modifying its behaviour depending on the specified flags.       #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


main() {
  ################################################
  ### DATA AND FILE STRUCTURES INITIALIZATIONS ###
  ################################################
  FLAG_MODE=install  # Install mode
  argument_processing "$@"
  data_and_file_structures_initialization

  ####################
  ### INSTALLATION ###
  ####################
  pre_install_update
  execute_installation

  ###############################
  ### POST-INSTALLATION CLEAN ###
  ###############################
  post_install_clean
  bell_sound
}

DIR=$(dirname "$(realpath "$0")")

if [ -f "${DIR}/functions_install.sh" ]; then
  source "${DIR}/functions_install.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data yet
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_install.sh not found. Aborting..."
  exit 1
fi

# Call main function
main "$@"

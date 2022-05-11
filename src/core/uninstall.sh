#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer uninstallation of features.                                                            #
# - Description: Portable script to remove all installation features installed by install.sh                           #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 19/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: aleix.marine@estudiants.urv.cat                                                                             #
# - Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when   #
# logged as root) to uninstall some of the features. The features that need to be installed as privileged user also    #
# need to be uninstalled as privileged user.                                                                           #
# - Arguments: Accepts behavioural arguments with one hyphen (-f, -o, etc.) and feature to uninstall with two hyphens  #
# (--pycharm, --gcc).                                                                                                  #
# - Usage: Uninstalls the features given by argument.                                                                  #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


main()
{
  ################################################
  ### DATA AND FILE STRUCTURES INITIALIZATIONS ###
  ################################################
  FLAG_MODE=uninstall  # Uninstall mode
  FLAG_OVERWRITE=1  # Set in uninstall always to true or it skips the program if it is installed
  ensure_and_import_custom_options
  argument_processing "$@"

  ####################
  ### INSTALLATION ###
  ####################
  execute_installation

  #########################
  ### POST-INSTALLATION ###
  #########################
  post_install_clean
  bell_sound
}

DIR=$(dirname "$(realpath "$0")")
export CUSTOMIZER_PROJECT_FOLDER="$(cd "${DIR}/../.." &>/dev/null && pwd)"

# Activate customizer hooks to enforce repository rules
bash "${CUSTOMIZER_PROJECT_FOLDER}/src/core/subsystems/activate_hooks.sh"

if [ -f "${DIR}/functions_uninstall.sh" ]; then
  source "${DIR}/functions_uninstall.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_uninstall.sh does not exist. Aborting..."
  exit 1
fi

# Call main function
main "$@"

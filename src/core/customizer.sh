#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer endpoint wrapper                                                                       #
# - Description: Processes the arguments to call the customizer backend                                                #
# - Creation Date: 13/2/24                                                                                             #
# - Last Modified: 13/2/24                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: aleix.marine@estudiants.urv.cat                                                                             #
# - Permissions: This script has to be executed directly. It can be run either as root or as an unprivileged user. You #
#   will need certain privileges for different installations.                                                          #
# - Arguments: Arguments to modulate the call to the backend and all the arguments that the backends accept            #
# - Usage:                                                                                                             #
#   * customizer ARGUMENTS                                                                                             #
#   * bash customizer.sh ARGUMENTS                                                                                     #
#   * sudo customizer ARGUMENTS                                                                                        #
#   * sudo bash customizer.sh ARGUMENTS                                                                                #
# - License: GPL v3.0                                                                                                  #
########################################################################################################################


# State variables for argument processing
mode_privilege=deduce  # deduce, sudo or user
mode_operation=install  # install or uninstall
mode_call=optimize  # optimize, maximize or minimize.Optimize minimizes  number of calls (respects order),

# - Description: Processes the arguments received from the outside and builds the necessary string for the
#   subsequent calls to the backend.
# - Permission: Can be called as root or user.
# - Argument 1, 2, 3... : Arguments for the whole program.
argument_processing_middle()
{
  :
}


# - Description: Processes the arguments received from the outside and performs immediate actions for the first
#   argument. The rest of the arguments are processed afterwards by another function, which will be passed to the
#   backend on the last steps.
# - Permission: Can be called as root or user.
# - Argument 1, 2, 3... : Arguments for the whole program.
argument_processing()
{
  case "$1" in
    features)
      local all_arguments+=("${feature_keynames[@]}")
      echo "${all_arguments[@]}"
      exit 0
    ;;
    commands)
      local all_arguments+=("${feature_keynames[@]}")
      all_arguments+=("${auxiliary_arguments[@]}")
      all_arguments+=("${WRAPPERS_KEYNAMES[@]}")
      echo "${all_arguments[@]}"
      exit 0
    ;;
    flags)
      local all_arguments+=("${auxiliary_arguments[@]}")
      echo "${all_arguments[@]}"
      exit 0
    ;;
    wrappers)
      generate_wrappers
      display_wrappers
      exit 0
    ;;
    installations)
      cat "${INSTALLED_FEATURES}"
      exit 0
    ;;
    initializations)
      cat "${INITIALIZATIONS_PATH}"
      exit 0
    ;;
    functions)
      cat "${FUNCTIONS_PATH}"
      exit 0
    ;;
    favorites|favourites)
      cat "${PROGRAM_FAVORITES_PATH}"
      exit 0
    ;;
    keybindings)
      cat "${PROGRAM_KEYBINDINGS_PATH}"
      exit 0
    ;;

    # Not a beginning argument. Go to process the rest of arguments
    *)
      argument_processing_middle
    ;;
  esac
}



main() {
  FLAG_MODE=wrapper  # Install mode
  argument_processing "$@"
  bell_sound
}


DIR=$(dirname "$(realpath "$0")")
export CUSTOMIZER_PROJECT_FOLDER="$(cd "${DIR}/../.." &>/dev/null && pwd)"
if [ -f "${DIR}/functions_common.sh" ]; then
  source "${DIR}/functions_common.sh"
else
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_common.sh not found. Aborting..."
  exit 1
fi

# Call main function
main "$@"
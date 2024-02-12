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


# - Description: Processes the arguments received from the outside and activates or deactivates flags and calls
#   add_program to append a keyname to the list of features to install.
# - Permission: Can be called as root or user.
# - Argument 1, 2, 3... : Arguments for the whole program.
argument_processing()
{
  while [ $# -gt 0 ]; do
    key="$1"

    case "${key}" in
      ### INTROSPECTION AND INFORMATION ###
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


      --flush=favorites)
        if [ "${FLAG_MODE}" == "uninstall" ]; then
          remove_all_favorites
        fi
      ;;
      --flush=keybindings)
        if [ "${FLAG_MODE}" == "uninstall" ]; then
          remove_all_keybindings
        fi
      ;;
      --flush=functions)
        if [ "${FLAG_MODE}" == "uninstall" ]; then
          remove_all_functions
        fi
      ;;
      --flush=initializations)
        if [ "${FLAG_MODE}" == "uninstall" ]; then
          remove_all_initializations
        fi
      ;;
      --flush=structures)
        if [ "${FLAG_MODE}" == "uninstall" ]; then
          remove_structures
        fi
      ;;
      --flush=cache)
        if [ "${FLAG_MODE}" == "uninstall" ]; then
          rm -Rf "${CACHE_FOLDER}"
        fi
      ;;

      *)

      ;;
    esac
    shift
  done
}



main() {
  FLAG_MODE=wrapper  # Install mode
  argument_processing "$@"
  bell_sound
}


DIR=$(dirname "$(realpath "$0")")
export CUSTOMIZER_PROJECT_FOLDER="$(cd "${DIR}/../.." &>/dev/null && pwd)"
if [ -f "${DIR}/functions_common.sh" ]; then
  # shellcheck source=./functions_common.sh
  source "${DIR}/functions_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_common.sh not found. Aborting..."
  exit 1
fi

# Call main function
main "$@"
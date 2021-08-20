#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer common functions between install.sh and uninstall.sh.                                  #
# - Description: Set of functions used both in install.sh and uninstall.sh. Most of these functions are used to        #
# manipulate and interpret the common data structures. Others are here to avoid code duplications between install.sh   #
# and uninstall.sh.                                                                                                    #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 16/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernandez Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: This script can not be executed directly, only sourced to import its functions and process its own    #
# imports. See the header of each function to see its privilege requirements                                           #
# - Arguments: No arguments                                                                                            #
# - Usage: Sourced from install.sh                                                                                     #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################

########################################################################################################################
############################################### COMMON API FUNCTIONS ###################################################
########################################################################################################################

# - Description: Execute the command received in the first argument and redirect the standard and error output depending
#   on the quietness level. If the command in the first argument is an echo, adds the date, tries to detect what type
#   of message contains this echo, which can be INFO, WARNING or ERROR. Each message type has an associated colour.
# - Permissions: Can be called as root or as normal user presumably with the same behaviour.
# - Argument 1: Bash command to execute.
# - Argument 2: Quietness level [0, 1, 2]:
#   * 0: Full verbose: Display echoes and output from other commands
#   * 1: Quiet: Display echoes but silences output from other commands
#   * 2: Full quiet: No output from executed commands
output_proxy_executioner() {
  # If the command to execute is an echo, capture echo type and apply format to it depending on the message type
  local -r command_name=$(echo "$1" | head -1 | cut -d " " -f1)
  if [ "${command_name}" == "echo" ]; then
    local echo_processed_command=""
    local echo_command_arguments=
    echo_command_arguments="$(echo "$1" | sed '1 s@^echo @@')"
    local -r echo_message_type="$(echo "${echo_command_arguments}" | head -1 | cut -d ":" -f1)"
    if [ "${echo_message_type}" == "WARNING" ]; then
      echo_processed_command+="\e[33m"  # Activate yellow color
    elif [ "${echo_message_type}" == "INFO" ]; then
      echo_processed_command+="\e[36m"  # Activate cyan color
    elif [ "${echo_message_type}" == "ERROR" ]; then
      echo_processed_command+="\e[91m"  # Activate red color
    fi
    # If we need to process an echo and we are not in full quietness mode print the prefix with date for each echo
    echo_processed_command+="$(date +%Y-%m-%d_%T) -- "
    echo_processed_command+="${echo_command_arguments}"
    echo_processed_command+="\e[0m"  # deactivate colour after the echo
  fi

  # Execute command with verbosity depending on quietness level and if the command_name is an echo or not
  if [ "$2" -eq 0 ]; then
    if [ "${command_name}" == "echo" ]; then
      echo -e "$echo_processed_command"
    else
      $1
    fi
  elif [ "$2" -eq 1 ]; then
    if [ "${command_name}" == "echo" ]; then
      echo -e "$echo_processed_command"
    else
      $1 &>/dev/null
    fi
  elif [ "$2" -eq 2 ]; then
    $1 &>/dev/null
  fi
}

# - Description: Makes a bell sound.
# - Permission: Can be called as root or as user.
bell_sound()
{
  echo -en "\07"
  echo -en "\07"
  echo -en "\07"
}

# - Description: Sets up a prompt in the desired point of customizer, which is used for in-place debugging. You can
#   input your desired bash commands for using variables of call functions.
# - Permission: Can be run as root or user.
customizer_prompt()
{
  while true; do
    read -pr "customizer-prompt $ " cmds
    eval "${cmds}"
  done
}


# - Description: Receives an string, a separator and a position and returns the selected field via stdout
# - Permission: Can be called as root or user.
# - Argument 1: String containing fields
# - Argument 2: Separator of the fields
# - Argument 3: Field position to get
get_field()
{
  echo -n "$1" | cut -d "$2" -f"$3"
}


# - Description: Receives an string, a separator and a position and returns the same string with the selected field
#   changed with the desired value. To do that obtains the value in position and cuts from that position to the
#   beginning and from that position to the end. Them delete the old value from these two substrings and joins them
#   with the desired value in between. Returns the new string via stdout.
# - Permission: Can be called as root or user.
# - Argument 1: String containing fields
# - Argument 2: Separator of the fields
# - Argument 3: Field position to set
# - Argument 4: Value to set
set_field()
{
  local -r value_in_pos="$(get_field "$1" "$2" "$3")"
  echo -n "$(echo "$1" | cut -d "$2" -f-"$3" | sed "s@${value_in_pos}\$@@g")$4$(echo "$1" | cut -d "$2" -f"$3"- | sed "s@^${value_in_pos}@@g")"
}


# - Description: Performs a post-install clean by using cleaning option of package manager
# - Permission: Can be called as root or user.
post_install_clean()
{
  if [ "${EUID}" -eq 0 ]; then
    if [ "${FLAG_AUTOCLEAN}" -gt 0 ]; then
      output_proxy_executioner "echo INFO: Attempting to clean orphaned dependencies via apt-get autoremove." "${FLAG_QUIETNESS}"
      output_proxy_executioner "apt-get -y autoremove" "${FLAG_QUIETNESS}"
      output_proxy_executioner "echo INFO: Finished." "${FLAG_QUIETNESS}"
    fi
    if [ "${FLAG_AUTOCLEAN}" -eq 2 ]; then
      output_proxy_executioner "echo INFO: Attempting to delete useless files in cache via apt-get autoremove." "${FLAG_QUIETNESS}"
      output_proxy_executioner "apt-get -y autoclean" "${FLAG_QUIETNESS}"
      output_proxy_executioner "echo INFO: Finished." "${FLAG_QUIETNESS}"
    fi
  fi
}


# - Description: Updates the system by using the package manager
# - Permission: Can be called as root or as user.
update_environment()
{
  output_proxy_executioner "echo INFO: Rebuilding path cache" "${FLAG_QUIETNESS}"
  output_proxy_executioner "hash -r" "${FLAG_QUIETNESS}"
  output_proxy_executioner "echo INFO: Rebuilding font cache" "${FLAG_QUIETNESS}"
  output_proxy_executioner "fc-cache -f" "${FLAG_QUIETNESS}"
  output_proxy_executioner "echo INFO: Reload .bashrc shell environment" "${FLAG_QUIETNESS}"
  output_proxy_executioner "source ${FUNCTIONS_PATH}" "${FLAG_QUIETNESS}"
}


autogen_help()
{
  local packagemanager_lines=
  local user_lines=
  local root_lines=
  local root_num=0
  local user_num=0
  true > help.md

  for program in "${feature_keynames[@]}"; do
    local readme_line_pointer="${program}_readmeline"
    local installationtype_pointer="${program}_installationtype"
    local arguments_pointer="${program}_arguments[@]"

    local readme_line=
    readme_line="${!readme_line_pointer}"
    local installation_type=
    installation_type="${!installationtype_pointer}"
    local program_argument=
    program_argument="${program}"

    local program_features=
    program_features="$(echo "${readme_line}" | cut -d "|" -f4)"
    local program_commands=
    program_commands="$(echo "${program_features}" | grep -Eo "\`.[a-zA-Z0-9]+\`" | tr "$\n" " " | tr "\`" " " | tr -s " " | sed "s/\.[a-z]*//g" | sed 's/^ *//g')"
    local help_line="${program_argument};${program_commands}"
    case ${installation_type} in
      packagemanager|packageinstall)
        root_lines+=("${help_line}")
        root_num=$(( root_num + 1 ))
      ;;
      repositoryclone|userinherit|environmental|pythonvenv)
        user_lines+=("${help_line}")
        user_num=$(( user_num + 1 ))
      ;;
    esac
  done
  local program_headers="ARGUMENT;COMMANDS"

  local -r newline=$'\n'
  local user_lines_final=
  for line in "${user_lines[@]}"; do
    user_lines_final="${user_lines_final}${line}${newline}"
  done
  user_lines_final="$(echo "${user_lines_final}" | sort)"
  column -ts ";" <<< "${program_headers}${newline}${user_lines_final}"

  echo "${newline}" >> "help.md"

  local root_lines_final=
  for line in "${root_lines[@]}"; do
    root_lines_final="${root_lines_final}${line}${newline}"
  done
  root_lines_final="$(echo "${root_lines_final}" | sort)"
  column -ts ";" <<< "${program_headers}${newline}${root_lines_final}"

  echo "Customizer currently has available $user_num user features and $root_num root features, $(( user_num + root_num)) in total"
}

autogen_readme()
{
  local packagemanager_lines=
  local user_lines=()
  local root_lines=()
  local root_num=0
  local user_num=0
  for program in "${feature_keynames[@]}"; do
    local readme_line_pointer="${program}_readmeline"
    local installationtype_pointer="${program}_installationtype"
    local arguments_pointer="${program}_arguments[@]"

    local readme_line=
    readme_line="${!readme_line_pointer}"
    local installation_type=
    installation_type="${!installationtype_pointer}"
    local program_arguments=
    program_arguments="${!arguments_pointer}"
    local program_name=
    program_name="${program}"

    # Add arguments to readme
    local prefix=
    prefix="$(echo "${readme_line}" | cut -d "|" -f-5)"
    local suffix=
    suffix="$(echo "${readme_line}" | cut -d "|" -f5-)"
    local readme_line="${prefix}${program_arguments}${suffix}"
    case ${installation_type} in
      packagemanager|packageinstall)
        root_lines+=("${readme_line}")
        root_num=$(( root_num + 1 ))
      ;;
      repositoryclone|userinherit|environmental|pythonvenv)
        user_lines+=("${readme_line}")
        user_num=$(( user_num + 1 ))
      ;;
    esac
  done
  local -r newline=$'\n'
  {
    echo "#### User programs";
    echo "| Name | Description | Execution | Arguments | Testing |";
    echo "|-------------|----------------------|------------------------------------------------------|------------|-------------|";
  } >> "table.md"
  local user_lines_final=
  for line in "${user_lines[@]}"; do
    user_lines_final="${user_lines_final}${line}${newline}"
  done
  {
  echo "${user_lines_final}" | sed -r '/^\s*$/d' | sort;
  echo "#### Root Programs";
  echo "| Name | Description | Execution | Arguments | Testing |";
  echo "|-------------|----------------------|------------------------------------------------------|------------|-------------|";
  } >> "table.md"
  local root_lines_final=
  for line in "${root_lines[@]}"; do
    root_lines_final="${root_lines_final}${line}${newline}"
  done
  echo "${root_lines_final[@]}" | sed -r '/^\s*$/d' | sort >> "table.md"

  echo "Customizer currently has available $user_num user features and $root_num root features, $(( user_num + root_num)) in total" >> table.md
}


########################################################################################################################
############################################### COMMON MAIN FUNCTIONS ##################################################
########################################################################################################################

# - Description: Processes the arguments received from the outside and activates or deactivates flags and calls
#   add_program to append a keyname to the list of features to install.
# - Permission: Can be called as root or user.
# - Argument 1, 2, 3... : Arguments for the whole program.
argument_processing()
{
  while [ $# -gt 0 ]; do
    key="$1"

    case ${key} in
      ### BEHAVIOURAL ARGUMENTS ###
      -v|--verbose)
        FLAG_QUIETNESS=0
      ;;
      -q|--quiet)
        FLAG_QUIETNESS=1
      ;;
      -Q|--Quiet)
        FLAG_QUIETNESS=2
      ;;

      -s|--skip|--skip-if-installed)
        FLAG_OVERWRITE=0
      ;;
      -o|--overwrite|--overwrite-if-present)
        FLAG_OVERWRITE=1
      ;;

      -e|--exit|--exit-on-error)
        FLAG_IGNORE_ERRORS=0
      ;;
      -i|--ignore|--ignore-errors)
        FLAG_IGNORE_ERRORS=1
      ;;

      -d|--dirty|--no-autoclean)
        FLAG_AUTOCLEAN=0
      ;;
      -c|--clean)
        FLAG_AUTOCLEAN=1
      ;;
      -C|--Clean)
        FLAG_AUTOCLEAN=2
      ;;

      -k|--keep-system-outdated)
        FLAG_UPGRADE=0
      ;;
      -u|--update)
        FLAG_UPGRADE=1
      ;;
      -U|--upgrade|--Upgrade)
        FLAG_UPGRADE=2
      ;;

      -f|--favorites|--set-favorites)
        FLAG_FAVORITES=1
      ;;
      -z|--no-favorites)
        FLAG_FAVORITES=0
      ;;

      -a|--autostart)
        FLAG_AUTOSTART=1
      ;;
      -r|--regular)
        FLAG_AUTOSTART=0
      ;;

      -n|--not)
        FLAG_INSTALL=0
      ;;
      -y|--yes)
        FLAG_INSTALL=1
      ;;

      -p|--privilege-check)
        FLAG_SKIP_PRIVILEGES_CHECK=0
      ;;
      -P|--skip-privilege-check)
        FLAG_SKIP_PRIVILEGES_CHECK=1
      ;;

      -h|--not-cached)
        FLAG_CACHE=0
      ;;
      -H|--cached|--cache|--use-cache)
        FLAG_CACHE=1
      ;;

      --commands)  # Print list of possible arguments and finish the program
        local all_arguments+=("${feature_keynames[@]}")
        all_arguments+=("${auxiliary_arguments[@]}")
        echo "${all_arguments[@]}"
        exit 0
      ;;

      -h)
        output_proxy_executioner "echo ${help_common}${help_simple}" "${FLAG_QUIETNESS}"
        exit 0
      ;;
      -H|--help)
        autogen_help

        output_proxy_executioner "echo ${help_common}${help_arguments}${help_individual_arguments_header}$(autogen_help)${help_wrappers}" "${FLAG_QUIETNESS}"
        exit 0
      ;;

      --debug)
        customizer_prompt
      ;;

      --user|--normal)
        add_programs_with_x_permissions 1
      ;;
      --root|--superuser|--su)
        add_programs_with_x_permissions 0
      ;;
      --ALL|--all|--All)
        add_programs_with_x_permissions 2
      ;;

      *)  # Individual argument
        local wrapper_key=
        wrapper_key="$(echo "${key}" | tr "-" "_" | tr -d "_")"
        local set_of_features="wrapper_${wrapper_key}[@]"
        if [ -z "$(echo "${!set_of_features}")" ]; then
          add_program "${key}"
        else
          add_programs "${!set_of_features}"
        fi
      ;;
    esac
    shift
  done

  # If we don't receive arguments we try to install everything that we can given our permissions
  if [ ${#added_feature_keynames[@]} -eq 0 ]; then
    output_proxy_executioner "echo ERROR: No arguments provided to install feature. Displaying help and finishing..." "${FLAG_QUIETNESS}"
    output_proxy_executioner "echo INFO: Displaying help ${help_common}" "${FLAG_QUIETNESS}"
    exit 1
  fi
}


add_programs_with_x_permissions()
{
  for keyname in "${feature_keynames[@]}"; do
    local installationtype_pointer="${keyname}_installationtype"
    if [ "$1" -eq 0 ]; then
      case ${!installationtype_pointer} in
        packagemanager)
          add_program "${keyname}"
        ;;
        packageinstall)
          add_program "${keyname}"
        ;;
      esac
    elif [ "$1" -eq 1 ] ; then
      case ${!installationtype_pointer} in
        # Download and decompress a file that contains a folder
        userinherit)
          add_program "${keyname}"
        ;;
        # Clone a repository
        repositoryclone)
          add_program "${keyname}"
        ;;
        # Create a virtual environment to install the feature
        pythonvenv)
          add_program "${keyname}"
        ;;
        # Only uses the common part of the generic installation
        environmental)
          add_program "${keyname}"
        ;;
      esac
    elif [ "$1" -eq 2 ]; then
      add_program "${keyname}"
    else
      output_proxy_executioner "echo ERROR: $1 is not a possible permission level." "${FLAG_QUIETNESS}"
      exit 1
    fi
  done
}


# - Description: Accepts N individual arguments representing feature keynames and adds them to the installation.
#   Useful for adding many arguments at the same time, like with a wrapper.
# - Permission: Can be called as root or as user.
# - Argument 1: Feature keyname to be added.
# - Argument 2, 3, 4... : Feature keyname to be added
add_programs()
{
  while [ $# -gt 0 ]; do
    add_program "$1"
    shift
  done
}


# - Description: Receives an argument and add or remove the corresponding feature for that argument to the installation
#   list. Also, if adding the installation of a program, save the current state of the flags, taking in account the flag
#   states that have to be overwritten.
# - Permission: Can be called indistinctly as root or user with same behaviour.
# - Argument 1: Outside argument that can match a feature keyname (fast match with binary search) or an argument (slow
#   match looping through all the arguments, obtained by indirect expansion using every feature keyname)
add_program()
{
  local matched_keyname=""
  # fast match against keynames
  local processed_argument=
  processed_argument="$(echo "$1" | tr "-" "_")"  # Convert - to _
  for keyname in "${feature_keynames[@]}"; do
    if [ "${processed_argument//^_*/}" == "${keyname}" ]; then
      matched_keyname="${keyname}"
      break
    fi
  done

  if [ -z "${matched_keyname}" ]; then
    # We did not achieve fast match. Loop through elements in all arguments property of all features looking for match
    processed_argument="$(echo "${processed_argument}" | tr '[:upper:]' '[:lower:]')"  # Convert to lowercase
    for keyname in "${feature_keynames[@]}"; do
      local arguments_pointer="${keyname}_arguments[@]"
      for argument in "${!arguments_pointer}"; do  # Expand arguments of each feature using feature_keyname
        if [ "${argument}" == "${processed_argument}" ] || [ "$(echo "${argument}" | tr -d "_")" == "$(echo "${processed_argument}" | tr -d "_")" ] ; then  # Flexible match
          matched_keyname="${keyname}"  # Save the match
          break  # Break the inner loop
        fi
      done
      if [ -n "${matched_keyname}" ]; then  # If we have already matched something  break external loop and continue
        break
      fi
    done
  fi

  # If we do not have a match after checking all args, this arg is not valid
  if [ -z "${matched_keyname}" ]; then
    if [ "${FLAG_IGNORE_ERRORS}" -eq 0 ]; then
      output_proxy_executioner "echo ERROR: $1 is not a recognized command. Installation will abort." "${FLAG_QUIETNESS}"
      exit 1
    else
      output_proxy_executioner "echo WARNING: $1 is not a recognized command. Skipping this argument..." "${FLAG_QUIETNESS}"
      return
    fi
  fi

  # Here matched_keyname matches a valid feature. Process its flagsoverride and add or remove from added_feature_keynames
  if [ "${FLAG_INSTALL}" == 1 ]; then
    # Addition mode, we need to add keyname to added_feature_keynames and build flags
    local -r flags_override_pointer="${matched_keyname}_flagsoverride"
    local flags_override_stringbuild=""
    if [ -n "${!flags_override_pointer}" ]; then  # If flagsoverride property is defined for this feature
      flags_override_stringbuild="${!flags_override_pointer}"
    else  # flagsoverride not defined, load template
      flags_override_stringbuild="${flagsoverride_template}"
    fi

    # The first flag indicates override permissions. Process FLAG_SKIP_PRIVILEGES_CHECK in here
    local flag_privileges=
    flag_privileges="$(get_field "${flags_override_stringbuild}" ";" "1")"
    if [ -z "${flag_privileges}" ]; then
      # If override not present, check installation type
      local -r installationtype_pointer="${matched_keyname}_installationtype"

      case ${!installationtype_pointer} in
        # Using package manager such as apt-get
        packagemanager)
          flag_privileges=0
        ;;
        # Downloading a package and installing it using a package manager such as dpkg
        packageinstall)
          flag_privileges=0
        ;;
        # Download and decompress a file that contains a folder
        userinherit)
          flag_privileges=1
        ;;
        # Clone a repository
        repositoryclone)
          flag_privileges=1
        ;;
        # Create a virtual environment to install the feature
        pythonvenv)
          flag_privileges=1
        ;;
        # Only uses the common part of the generic installation
        environmental)
          flag_privileges=1
        ;;
        # If not recognized put 2, so we do not care
        *)
          flag_privileges=2
        ;;
      esac

    fi
    # Process FLAG_SKIP_PRIVILEGES_CHECK. If 1 skip privilege check
    if [ "${FLAG_SKIP_PRIVILEGES_CHECK}" -eq 0 ] && [ "${flag_privileges}" -ne 2 ]; then
      if [ "${EUID}" -eq 0 ] && [ "${flag_privileges}" -eq 1 ]; then
        output_proxy_executioner "echo ERROR: $1 enforces user permissions to be executed. Rerun without root privileges or use -P to avoid this behaviour. Skipping this program..." "${FLAG_QUIETNESS}"
        exit 1
      fi
      if [ "${EUID}" -ne 0 ] && [ "${flag_privileges}" -eq 0 ]; then
        output_proxy_executioner "echo ERROR: $1 enforces root permissions to be executed. Rerun with root privileges or use -P to avoid this behaviour. Skipping this program..." "${FLAG_QUIETNESS}"
        exit 1
      fi
    fi
    # No need to pass to the execute installation the permissions of each feature, they are already processed here
    # flags_override_stringbuild="$(set_field "${flags_override_stringbuild}" ";" "1" "${flag_privileges}")"

    # Second flag overwrite bit
    local flag_overwrite=
    flag_overwrite="$(get_field "${flags_override_stringbuild}" ";" "2")"
    if [ -z "${flag_overwrite}" ]; then
      flag_overwrite="${FLAG_OVERWRITE}"  # If not present in override, inherit from runtime flags
    fi
    # No need to pass to the execute installation the override, it can be processed here
    # Process flag_overwrite. if installation is already present show error
    if [ "${flag_overwrite}" -eq 0 ]; then
      # Change of _ to - again to allow the matches of commands that have - in its name
      if type "$(echo "${matched_keyname}" | tr "_" "-")" &>/dev/null; then
        output_proxy_executioner "echo WARNING: ${matched_keyname} is already installed. Continuing installation without this program... Use -o to overwrite this program" "${FLAG_QUIETNESS}"
        return 1
      fi
    fi

    # Third flag ignore errors
    local flag_errors=
    flag_errors="$(get_field "${flags_override_stringbuild}" ";" "3")"
    if [ -z "${flag_errors}" ]; then
      flag_errors="${FLAG_IGNORE_ERRORS}"  # If not present in override, inherit from runtime flags
    fi
    flags_override_stringbuild="$(set_field "${flags_override_stringbuild}" ";" "3" "${flag_errors}")"

    # Fourth flag quietness bit
    local flag_quietness=
    flag_quietness="$(get_field "${flags_override_stringbuild}" ";" "4")"
    if [ -z "${flag_quietness}" ]; then
      flag_quietness="${FLAG_QUIETNESS}"  # If not present in override, inherit from runtime flags
    fi
    flags_override_stringbuild="$(set_field "${flags_override_stringbuild}" ";" "4" "${flag_quietness}")"

    # Fifth flag favorites bit
    local flag_favorites=
    flag_favorites="$(get_field "${flags_override_stringbuild}" ";" "5")"
    if [ -z "${flag_favorites}" ]; then
      flag_favorites="${FLAG_FAVORITES}"  # If not present in override, inherit from runtime flags
    fi
    flags_override_stringbuild="$(set_field "${flags_override_stringbuild}" ";" "5" "${flag_favorites}")"

    # Sixth flag autostart
    local flag_autostart=
    flag_autostart="$(get_field "${flags_override_stringbuild}" ";" "6")"
    if [ -z "${flag_autostart}" ]; then
      flag_autostart="${FLAG_AUTOSTART}"  # If not present in override, inherit from runtime flags
    fi
    flags_override_stringbuild="$(set_field "${flags_override_stringbuild}" ";" "6" "${flag_autostart}")"
    # At this point flags_override_stringbuild have all flags merged inside (override and runtime)


    # Declare runtime flags for accession in execute_feature
    declare -g "${matched_keyname}_flagsruntime=${flags_override_stringbuild}"
    # Add this feature in the result list
    added_feature_keynames+=("${matched_keyname}")
  else
    # Deletion mode

    # Delete from the result array
    local i=0
    for keyname in "${added_feature_keynames[@]}"; do
      if [ "${keyname}" == "${matched_keyname}" ]; then
        unset added_feature_keynames[${i}]
      fi
      i=$(( i+1 ))
    done
  fi
}


# - Description: Reads the array added_feature_keynames where are stored the keynames of features that have to be
#   installed, interprets or delegates the flags and runs the generic_(un)install
# - Permission: Can be called indistinctly as root or user but it can skip or show error if the permissions do not
#   coincide with the required ones.
execute_installation()
{
  # flagsruntime ${FLAG_IGNORE_ERRORS};${FLAG_QUIETNESS};${FLAG_FAVORITES};${FLAG_AUTOSTART}
  for keyname in "${added_feature_keynames[@]}"; do
    local flags_pointer="${keyname}_flagsruntime"
    local flag_ignore_errors=
    flag_ignore_errors="$(get_field "${!flags_pointer}" ";" "3")"  # local, processed here
    FLAG_QUIETNESS="$(get_field "${!flags_pointer}" ";" "4")"  # Global, so it can be accessed during installations
    FLAG_FAVORITES="$(get_field "${!flags_pointer}" ";" "5")"  # Global, accessed in generic_install
    FLAG_AUTOSTART="$(get_field "${!flags_pointer}" ";" "6")"  # Global, accessed in generic_install
    # Process flag_ignore_errors
    if [ "${flag_ignore_errors}" -eq 0 ]; then
      set -e
    fi

    output_proxy_executioner "echo INFO: Attemptying to ${FLAG_MODE} ${keyname}." "${FLAG_QUIETNESS}"
    output_proxy_executioner "generic_installation ${keyname}" "${FLAG_QUIETNESS}"
    output_proxy_executioner "echo INFO: ${keyname} ${FLAG_MODE}ed." "${FLAG_QUIETNESS}"

    # Return flag errors to bash defaults (ignore errors)
    set +e
  done
}

########################################################################################################################
################################################## GENERIC INSTALL #####################################################
########################################################################################################################

# - Description: Installs a user program in a generic way relying on variables declared in data_features.sh and the name
#   of a feature. The corresponding data has to be declared following the pattern %FEATURENAME_%PROPERTIES. This is
#   because indirect expansion is used to obtain the data to install each feature of a certain program to install.
#   Depending on the properties set, some subfunctions will be activated to install related features.
#   Also performs the manual execution of paths of the feature and calls generic functions to install the common
#   part of the features such as desktop launchers, sourced .bashrc functions...
# - Permissions: Can be executed as root or user.
# - Argument 1: Name of the feature to install, matching the necessary variables such as $1_installationtype and the
#   name of the first argument in the common_data.sh table
generic_installation() {
  # Substitute dashes for underscores. Dashes are not allowed in variable names
  local -r featurename="${1//-/_}"
  local -r installationtype=${featurename}_installationtype
  local -r manualcontentavailable="$1_manualcontentavailable"
  if [ -n "${!installationtype}" ]; then
    if [ "$(echo "${!manualcontentavailable}" | cut -d ";" -f1)" == "1" ]; then
      "${FLAG_MODE}_$1_pre"
    fi
    case ${!installationtype} in
      # Using package manager such as apt-get
      packagemanager)
        "rootgeneric_${FLAG_MODE}ation_type" "${featurename}" packagemanager
      ;;
      # Downloading a package and installing it using a package manager such as dpkg
      packageinstall)
        "rootgeneric_${FLAG_MODE}ation_type" "${featurename}" packageinstall
      ;;
      # Download and decompress a file that contains a folder
      userinherit)
        "userinherit_${FLAG_MODE}ation_type" "${featurename}"
      ;;
      # Clone a repository
      repositoryclone)
        "repositoryclone_${FLAG_MODE}ation_type" "${featurename}"
      ;;
      # Create a virtual environment to install the feature
      pythonvenv)
        "pythonvenv_${FLAG_MODE}ation_type" "${featurename}"
      ;;
      # Only uses the common part of the generic installation
      environmental)
        : # no-op
      ;;
      *)
        output_proxy_executioner "echo ERROR: ${!installationtype} is not a recognized installation type" "${FLAG_QUIETNESS}"
        exit 1
      ;;
    esac
    if [ "$(echo "${!manualcontentavailable}" | cut -d ";" -f2)" == "1" ]; then
      "${FLAG_MODE}_$1_mid"
    fi

    generic_${FLAG_MODE}_downloads "${featurename}"
    generic_${FLAG_MODE}_files "${featurename}"
    generic_${FLAG_MODE}_manual_launchers "${featurename}"
    generic_${FLAG_MODE}_copy_launcher "${featurename}"
    generic_${FLAG_MODE}_functions "${featurename}"
    generic_${FLAG_MODE}_initializations "${featurename}"
    generic_${FLAG_MODE}_autostart "${featurename}"
    generic_${FLAG_MODE}_favorites "${featurename}"
    generic_${FLAG_MODE}_file_associations "${featurename}"
    generic_${FLAG_MODE}_keybindings "${featurename}"
    generic_${FLAG_MODE}_pathlinks "${featurename}"


    if [ "$(echo "${!manualcontentavailable}" | cut -d ";" -f3)" == "1" ]; then
      "${FLAG_MODE}_$1_post"
    fi
  fi
}


if [ -f "${DIR}/data_features.sh" ]; then
  source "${DIR}/data_features.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: data_features.sh not found. Aborting..."
  exit 1
fi

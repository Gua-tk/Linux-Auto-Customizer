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
    local echo_command_arguments="$(echo "$1" | sed '1 s@^echo @@')"
    local -r echo_message_type="$(echo "${echo_command_arguments}" | head -1 | cut -d ":" -f1)"
    if [ "${echo_message_type}" == "WARNING" ]; then
      echo_processed_command+="\e[33m"  # Activate yellow colour
    elif [ "${echo_message_type}" == "INFO" ]; then
      echo_processed_command+="\e[36m"  # Activate cyan colour
    elif [ "${echo_message_type}" == "ERROR" ]; then
      echo_processed_command+="\e[91m"  # Activate red colour
    fi
    # If we need to process an echo and we are not in full quietness mode print the prefix with date for each echo
    echo_processed_command+="$(date +%Y-%m-%d_%T) -- "
    echo_processed_command+="${echo_command_arguments}"
    echo_processed_command+="\e[0m"  # deactivate colour after the echo
  fi

  # Execute command with verbosity depending on quietness level and if the command_name is an echo or not
  if [ $2 == 0 ]; then
    if [ "${command_name}" == "echo" ]; then
      echo -e "$echo_processed_command"
    else
      $1
    fi
  elif [ $2 == 1 ]; then
    if [ "${command_name}" == "echo" ]; then
      echo -e "$echo_processed_command"
    else
      $1 &>/dev/null
    fi
  elif [ $2 == 2 ]; then
    $1 &>/dev/null
  fi
}

# Sets up custom prompt when entering debug mode in customizer
customizer_prompt()
{
  while [ true ]; do
    read -p "customizer-prompt $ " cmds
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

# Add program
# Try to expand the argument directly as the keyname
#   - remove first dashes in the args
#  - change - for _
#  - try indirect expansion pointer=${processed_argument}_installationtype ; ${!pointer}

#If not match go through all args using vars in the common list of krynames with indirect expansion against all args
# For keyname in keynamescommon:
#  pointer=${keyname}_arguments
#  If $1 in ${!pointer}
    # save this keyname outside of for scope
#    Matchedkeyname=$keyname
#    Break


#If $flag_install:
#  declare -a ${matchedkeyname}_flagsstate=fillwithemptyvalues()
#  if ${!${matchedkeyname}_flagsstateoverride} defined
#    Trim ${!${matchedkeyname}_flagsstateoverride} and put each flag on the positions of flagstate

#  For each bit in ${matchedkeyname}_flagsstates with IFS=;  or for each bitpos in range(${numbitsstate_common})
    # here we need to satisfy the new bit of forcing installation even with wrong permissions.
    # if the bit of skip permissions is not set (default) check the bit of permissions of the feature. If it is 2, continue.
    # else if is 0 it has to coincide with the EUID (then continue installation if not warning and skip) else if it is 1,
    # then the EUID has to be different from 0

#    If $bit == ""
#      ${matchedkeyname}_flagsstates.put(bitpos, FLAG_WHATEVER). # THIS IS NOT PARAMETRIZABLE AND THE FOR NEEDS TO BE ROLLED OUT
#    else
#      ${matchedkeyname}_flagsstates.put(bitpos, flagsstateoverride.get(bitpos))
#else
#  If $matchedkeyname in $resulttable
#     $resulttable-=matchedkeyname
#  Else
#    Show warning that it was not added

#added_feature_keynames

# - Description: Receives an argument and add or remove the corresponding feature for that argument to the installation
#   list. Also, if adding the installation of a program, save the current state of the flags, taking in account the flag
#   states that have to be overwritten.
# - Permission: Can be called indistinctly as root or user with same behaviour.
# - Argument 1: Outside argument that can match a feature keyname (fast match with binary search) or an argument (slow
#   match looping through all the arguments, obtained by indirect expansion using every feature keyname)
add_programx()
{
  local matched_keyname=""
  # fast match against keynames
  local processed_argument="$(echo "$1" | tr "-" "_")"  # Convert - to _
  for keyname in "${feature_keynames[@]}"; do
    if [ "${processed_argument}" == "${keyname}" ]; then
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
        if [ "${argument}" == "$1" ]; then  # Literal match
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
    output_proxy_executioner "echo WARNING: $1 is not a recognized command. Skipping this argument..." ${FLAG_QUIETNESS}
    return 1
  fi

  # Here matched_keyname matches a valid feature. Process its flagsoverride and add or remove from added_feature_keynames
  if [ ${FLAG_INSTALL} == 1 ]; then
    # Addition mode, we need to add keyname to added_feature_keynames and build flags
    local -r flags_override_pointer="${matched_keyname}_flagsoverride"
    local flags_override_stringbuild=""
    if [ ! -z "${!flagsoverride_pointer}" ]; then  # If flagsoverride property is defined for this feature
      flags_override_stringbuild="${!flagsoverride_pointer}"
    else  # flagsoverride not defined, load template
      flags_override_stringbuild="${flags_overrides_template}"
    fi

    # The first flag indicates override permissions. Process FLAG_SKIP_PRIVILEGES_CHECK in here
    local flag_privileges="$(get_field "${flags_override_stringbuild}" ";" "1")"
    if [ -z "${flag_privileges}" ]; then
      flag_privileges=2  # If not present in override, set to 2 (indifferent)
    fi
    # Process FLAG_SKIP_PRIVILEGES_CHECK. If 1 skip privilege check
    if [ ${FLAG_SKIP_PRIVILEGES_CHECK} -eq 0 ] && [ ${flag_privileges} -ne 2 ]; then
      if [ ${EUID} -eq 0 ] && [ ${flag_privileges} -eq 1 ]; then
        output_proxy_executioner "echo WARNING: $1 enforces user permissions to be executed. Rerun without root privileges or use -P to avoid this behaviour. Skipping this program..." ${FLAG_QUIETNESS}
        return 1
      fi
      if [ ${EUID} -ne 0 ] && [ ${flag_privileges} -eq 0 ]; then
        output_proxy_executioner "echo WARNING: $1 enforces root permissions to be executed. Rerun with root privileges or use -P to avoid this behaviour. Skipping this program..." ${FLAG_QUIETNESS}
        return 1
      fi
    fi
    flags_override_stringbuild="$(set_field "${flags_override_stringbuild}" ";" "1" "${flag_privileges}")"

    # Second flag ignore errors
    local flag_errors="$(get_field "${flags_override_stringbuild}" ";" "2")"
    if [ -z "${flag_errors}" ]; then
      flag_errors=${FLAG_IGNORE_ERRORS}  # If not present in override, inherit from runtime flags
    fi
    flags_override_stringbuild="$(set_field "${flags_override_stringbuild}" ";" "2" "${flag_errors}")"

    # Third flag overwrite bit
    local flag_overwrite="$(get_field "${flags_override_stringbuild}" ";" "3")"
    if [ -z "${flag_overwrite}" ]; then
      flag_overwrite=${FLAG_OVERWRITE}  # If not present in override, inherit from runtime flags
    fi
    flags_override_stringbuild="$(set_field "${flags_override_stringbuild}" ";" "3" "${flag_overwrite}")"

    # Fourth flag quietness bit
    local flag_quietness="$(get_field "${flags_override_stringbuild}" ";" "4")"
    if [ -z "${flag_quietness}" ]; then
      flag_quietness=${FLAG_QUIETNESS}  # If not present in override, inherit from runtime flags
    fi
    flags_override_stringbuild="$(set_field "${flags_override_stringbuild}" ";" "4" "${flag_quietness}")"

    # Fifth flag favorites bit
    local flag_favorites="$(get_field "${flags_override_stringbuild}" ";" "5")"
    if [ -z "${flag_favorites}" ]; then
      flag_favorites=${FLAG_FAVORITES}  # If not present in override, inherit from runtime flags
    fi
    flags_override_stringbuild="$(set_field "${flags_override_stringbuild}" ";" "5" "${flag_favorites}")"

    # Sixth flag autostart
    local flag_autostart="$(get_field "${flags_override_stringbuild}" ";" "6")"
    if [ -z "${flag_autostart}" ]; then
      flag_autostart=${FLAG_AUTOSTART}  # If not present in override, inherit from runtime flags
    fi
    flags_override_stringbuild="$(set_field "${flags_override_stringbuild}" ";" "6" "${flag_autostart}")"

    # At this point flags_override_stringbuild have all flags merged inside (override and runtime)

    # Declare runtime flags for accession in execute_feature
    declare "${matched_keyname}_flagsruntime"="${flags_override_stringbuild}"
    # Add this feature in the result list
    added_feature_keynames+="${matched_keyname}"

  else
    # Deletion mode

    # Delete from the result array
    local i=0
    for keyname in "${added_feature_keynames[@]}"; do
      if [ "${keyname}" == "${matched_keyname}" ]; then
        unset added_feature_keynames[${i}]
      fi
      i=$(( ${i}+1 ))
    done

  fi


}




add_program()
{
  # Process all arguments
  while [ $# -gt 0 ]; do
    found=0  # To check for a valid argument
    # Process each argument to write down the flags for each installation in feature_keynames
    total=${#feature_keynames[*]}
    for (( i=0; i<$(( ${total} )); i++ )); do  # Check all the entries in feature_keynames
      # Cut first program name argument (with two -- at the beginning) from the first argument
      # We will generate the program function name with it
      program_arguments="$(echo "${feature_keynames[$i]}" | cut -d ";" -f1 | tr "|" " ")"
      # Set IFS, variable used to determine the default separator on foreach loops in bash. Set space as separator
      IFS=" "
      for argument in ${program_arguments}; do
        if [ "$1" == "${argument}" ]; then
          # Set that the argument is valid
          found=1
          # Cut static bit of permission
          flag_permissions=$(echo "${feature_keynames[$i]}" | cut -d ";" -f2)
          # Generate name of the function depending on the mode from the first argument
          program_name="${FLAG_MODE}_$(echo ${program_arguments} | cut -d " " -f1 | cut -d "-" -f3-)"
          # Append static bits to the state of the flags
          new="${program_name};${flag_permissions};${FLAG_INSTALL};${FLAG_IGNORE_ERRORS};${FLAG_QUIETNESS};${FLAG_OVERWRITE};${FLAG_FAVORITES};${FLAG_AUTOSTART}"
          feature_keynames[$i]=${new}
          # Update flags and program counter if we are installing
          if [ ${FLAG_INSTALL} -gt 0 ]; then
            NUM_INSTALLATION=$(( ${NUM_INSTALLATION} + 1 ))
            FLAG_INSTALL=${NUM_INSTALLATION}
          fi
          break  # Argument matched, so we can stop searching
        fi
      done
      # Propagate the inner break, and continue to next argument
      if [ ${found} == 1 ]; then
        break
      fi

    done
    if [ ${found} == 0 ]; then
        output_proxy_executioner "echo WARNING: $1 is not a recognized command. Skipping this argument." ${FLAG_QUIETNESS}
    fi
    shift
  done
}


# Common piece of code in the execute_installation function
# Argument 1: forceness_bit
# Argument 2: quietness_bit
# Argument 3: program_function
execute_installation_install_feature()
{
  local -r feature_name=$( echo "$3" | cut -d "_" -f2- )
  if [[ $1 == 1 ]]; then
    set +e
  else
    set -e
  fi
  output_proxy_executioner "echo INFO: Attemptying to ${FLAG_MODE} ${feature_name}." $2

  local -r installationtype="$(echo "${feature_name}" | sed "s/-/_/g")_installationtype"
  # A generified install
  if [ -n "${!installationtype}" ]; then
    output_proxy_executioner "generic_${FLAG_MODE} $(echo "${feature_name}" | sed "s/-/_/g")" $2
  else  # A hardcoded install
    output_proxy_executioner $3 $2
  fi
  output_proxy_executioner "echo INFO: ${feature_name} ${FLAG_MODE}ed." $2
  set +e
}

execute_installation_wrapper_install_feature()
{
  if [[ $1 == 1 ]]; then
    execute_installation_install_feature $2 $3 $4
  else
    type "${program_name}" &>/dev/null
    if [[ $? != 0 ]]; then
      execute_installation_install_feature $2 $3 $4
    else
      output_proxy_executioner "echo WARNING: $5 is already installed. Skipping... Use -o to overwrite this program" $3
    fi
  fi
}

execute_installation()
{
  # Double for to perform the installation in same order as the arguments
  for (( i = 1 ; i != ${NUM_INSTALLATION} ; i++ )); do
    # Loop through all the elements in the common data table
    for program in "${feature_keynames[@]}"; do
      # Check the number of elements, if there are less than 3 do not process, that program has not been added
      num_elements=$(echo "${program}" | tr ";" " " | wc -w)
      if [ "${num_elements}" -lt 8 ]; then
        continue
      fi

      # Installation bit processing
      installation_bit=$(echo ${program} | cut -d ";" -f3 )
      if [ "${installation_bit}" == ${i} ]; then
        program_function=$(echo ${program} | cut -d ";" -f1)
        program_privileges=$(echo ${program} | cut -d ";" -f2)
        forceness_bit=$(echo ${program} | cut -d ";" -f4)
        quietness_bit=$(echo ${program} | cut -d ";" -f5)
        overwrite_bit=$(echo ${program} | cut -d ";" -f6)
        favorite_bit=$(echo ${program} | cut -d ";" -f7)
        autostart_bit=$(echo ${program} | cut -d ";" -f8)
        program_name=$(echo ${program_function} | cut -d "_" -f2- )
        if [[ ${program_privileges} == 1 ]]; then
          if [[ ${EUID} -ne 0 ]]; then
            output_proxy_executioner "echo WARNING: ${program_name} needs root permissions to be installed. Skipping." ${quietness_bit}
          else  # When called from uninstall it will take always this branch
            execute_installation_wrapper_install_feature ${overwrite_bit} ${forceness_bit} ${quietness_bit} ${program_function} ${program_name}
          fi
        elif [ "${program_privileges}" == 0 ]; then
          if [ ${EUID} -ne 0 ]; then
            execute_installation_wrapper_install_feature ${overwrite_bit} ${forceness_bit} ${quietness_bit} ${program_function} ${program_name}
          else
            output_proxy_executioner "echo WARNING: ${program_name} needs user permissions to be installed. Skipping." ${quietness_bit}
          fi
        else  # This feature does not care about permissions, ${program_privileges} == 2
          execute_installation_wrapper_install_feature ${overwrite_bit} ${forceness_bit} ${quietness_bit} ${program_function} ${program_name}
        fi
        break
      fi
    done
  done
}


add_wrapper()
{
  while [[ $# -gt 0 ]]; do
    add_program "--$1"
    shift
  done
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
    local readme_line="$(echo "${program}" | cut -d ";" -f3-)"
    local installation_type="$(echo "${program}" | cut -d ";" -f2)"
    local program_arguments="$(echo "${program}" | cut -d ";" -f1)"
    local program_argument="$(echo "${program_arguments}" | cut -d "|" -f1)"
    local program_name="$(echo "${readme_line}" | cut -d "|" -f2 | sed 's/^ *//g')"
    local program_features="$(echo "${readme_line}" | cut -d "|" -f4)"
    local program_commands="$(echo "${program_features}" | grep -Eo "\`.[a-zA-Z0-9]+\`" | tr "$\n" " " | tr "\`" " " | tr -s " " | sed "s/\.[a-z]*//g" | sed 's/^ *//g')"
    local help_line="${program_argument};${program_name};${program_commands}"
    case ${installation_type} in
      0)
        user_lines+=("${help_line}")
        root_num=$(( root_num + 1 ))
      ;;
      1)
        root_lines+=("${help_line}")
        user_num=$(( user_num + 1 ))
      ;;
      packagemanager)
        packagemanager_lines+=("${help_line}")
      ;;
    esac
  done
  local program_headers=("ARGUMENT;FEATURE_NAME;COMMANDS")

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
  local user_lines=
  local root_lines=
  local root_num=0
  local user_num=0
  for program in "${feature_keynames[@]}"; do
    local readme_line="$(echo "${program}" | cut -d ";" -f3-)"
    local installation_type="$(echo "${program}" | cut -d ";" -f2)"
    local program_arguments="$(echo "${program}" | cut -d ";" -f1 | tr "|" " ")"
    local program_name="$(echo "${program_arguments}" | cut -d "|" -f1 | cut -d "-" -f3-)"

    # Add arguments to readme
    local prefix="$(echo "${readme_line}" | cut -d "|" -f-5)"
    local suffix="$(echo "${readme_line}" | cut -d "|" -f5-)"
    local readme_line="${prefix}${program_arguments}${suffix}"
    case ${installation_type} in
      0)
        user_lines+=("${readme_line}")
        root_num=$(( root_num + 1 ))
      ;;
      1)
        root_lines+=("${readme_line}")
        user_num=$(( user_num + 1 ))
      ;;
      packagemanager)
        packagemanager_lines+=("${readme_line}")
      ;;
    esac
  done
  local -r newline=$'\n'
  true > "table.md"
  echo "#### User programs" >> "table.md"
  echo "| Name | Description | Execution | Arguments | Testing |" >> "table.md"
  echo "|-------------|----------------------|------------------------------------------------------|------------|-------------|" >> "table.md"
  local user_lines_final=
  for line in "${user_lines[@]}"; do
    user_lines_final="${user_lines_final}${line}${newline}"
  done
  echo "${user_lines_final}" | sed -r '/^\s*$/d' | sort >> "table.md"
  echo "#### Root Programs" >> "table.md"
  echo "| Name | Description | Execution | Arguments | Testing |" >> "table.md"
  echo "|-------------|----------------------|------------------------------------------------------|------------|-------------|" >> "table.md"
  local root_lines_final=
  for line in "${root_lines[@]}"; do
    root_lines_final="${root_lines_final}${line}${newline}"
  done
  echo "${root_lines_final[@]}" | sed -r '/^\s*$/d' | sort >> "table.md"

  echo "Customizer currently has available $user_num user features and $root_num root features, $(( user_num + root_num)) in total" >> table.md
}


# - Description: Adds all the programs with specific privileges to the installation data
# - Permissions: This function can be called as root or as user with same behaviour.
# - Argument 1: Type of permissions of the selected program: 0 for user, 1 for root, 2 for everything
add_programs_with_x_permissions()
{
  for program in "${feature_keynames[@]}"; do
    permissions=$(echo ${program} | cut -d ";" -f2)
    name=$(echo ${program} | cut -d ";" -f1 | cut -d "|" -f1)
    if [[ 2 == $1 ]]; then
      add_program ${name}
      continue
    fi
    if [[ ${permissions} == $1 ]]; then
      add_program ${name}
    fi
  done
}

argument_processing()
{
  output_proxy_executioner "echo INFO: Processing arguments" "${FLAG_QUIETNESS}"
  while [[ $# -gt 0 ]]; do
    key="$1"

    case ${key} in
      ### BEHAVIOURAL ARGUMENTS ###
      -v|-verbose)
        FLAG_QUIETNESS=0
      ;;
      -q|-quiet)
        FLAG_QUIETNESS=1
      ;;
      -Q|-Quiet)
        FLAG_QUIETNESS=2
      ;;

      -s|-skip|-skip-if-installed)
        FLAG_OVERWRITE=0
      ;;
      -o|-overwrite|-overwrite-if-present)
        FLAG_OVERWRITE=1
      ;;

      -e|-exit|-exit-on-error)
        FLAG_IGNORE_ERRORS=0
      ;;
      -i|-ignore|-ignore-errors)
        FLAG_IGNORE_ERRORS=1
      ;;

      -d|-dirty|-no-autoclean)
        FLAG_AUTOCLEAN=0
      ;;
      -c|-clean)
        FLAG_AUTOCLEAN=1
      ;;
      -C|-Clean)
        FLAG_AUTOCLEAN=2
      ;;

      -k|-keep-system-outdated)
        FLAG_UPGRADE=0
      ;;
      -u|-update)
        FLAG_UPGRADE=1
      ;;
      -U|-upgrade|-Upgrade)
        FLAG_UPGRADE=2
      ;;

      -f|-favorites|-set-favorites)
        FLAG_FAVORITES=1
      ;;
      -z|-no-favorites)
        FLAG_FAVORITES=0
      ;;

      -a|-autostart)
        FLAG_AUTOSTART=1
      ;;
      -r|-regular)
        FLAG_AUTOSTART=0
      ;;

      -n|-not)
        FLAG_INSTALL=0
      ;;
      -y|-yes)
        FLAG_INSTALL=${NUM_INSTALLATION}
      ;;

      -h)
        output_proxy_executioner "echo ${help_common}${help_simple}" ${FLAG_QUIETNESS}
        exit 0
      ;;

      -H|-help)
        autogen_help

        output_proxy_executioner "echo ${help_common}${help_arguments}${help_individual_arguments_header}$(autogen_help)${help_wrappers}" ${FLAG_QUIETNESS}
        exit 0
      ;;

      -debug)
        customizer_prompt
      ;;

      ### WRAPPER ARGUMENTS ###
      --custom1)
        add_wrapper "${custom1[@]}"
      ;;
      --iochem)
        add_wrapper "${iochem[@]}"
      ;;
      --user|--regular|--normal)
        add_programs_with_x_permissions 0
      ;;
      --root|--superuser|--su)
        add_programs_with_x_permissions 1
      ;;
      --ALL|--all|--All)
        add_programs_with_x_permissions 2
      ;;

      *)  # Individual argument
        add_program ${key}
      ;;
    esac
    shift
  done

  # If we don't receive arguments we try to install everything that we can given our permissions
  if [ ${NUM_INSTALLATION} == 1 ]; then
    output_proxy_executioner "echo ERROR: No arguments provided to install feature. Displaying help and finishing..." ${FLAG_QUIETNESS}
    output_proxy_executioner "echo INFO: Displaying help ${help_common}" ${FLAG_QUIETNESS}
    exit 0
  fi
}

post_install_clean()
{
  if [[ ${EUID} == 0 ]]; then
    if [[ ${FLAG_AUTOCLEAN} -gt 0 ]]; then
      output_proxy_executioner "echo INFO: Attempting to clean orphaned dependencies via apt-get autoremove." ${FLAG_QUIETNESS}
      output_proxy_executioner "apt-get -y autoremove" ${FLAG_QUIETNESS}
      output_proxy_executioner "echo INFO: Finished." ${FLAG_QUIETNESS}
    fi
    if [[ ${FLAG_AUTOCLEAN} == 2 ]]; then
      output_proxy_executioner "echo INFO: Attempting to delete useless files in cache via apt-get autoremove." ${FLAG_QUIETNESS}
      output_proxy_executioner "apt-get -y autoclean" ${FLAG_QUIETNESS}
      output_proxy_executioner "echo INFO: Finished." ${FLAG_QUIETNESS}
    fi
  fi
}

# Make the bell sound at the end
bell_sound()
{
  echo -en "\07"
  echo -en "\07"
  echo -en "\07"
}

update_environment()
{
  output_proxy_executioner "echo INFO: Rebuilding path cache" "${quietness_bit}"
  output_proxy_executioner "hash -r" "${quietness_bit}"
  output_proxy_executioner "echo INFO: Rebuilding font cache" "${quietness_bit}"
  output_proxy_executioner "fc-cache -f -v" "${quietness_bit}"
  output_proxy_executioner "echo INFO: Reload .bashrc shell environment" "${quietness_bit}"
  output_proxy_executioner "source ${BASH_FUNCTIONS_PATH}" "${quietness_bit}"
}


if [[ -f "${DIR}/data_features.sh" ]]; then
  source "${DIR}/data_features.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: data_features.sh not found. Aborting..."
  exit 1
fi

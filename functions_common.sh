########################################################################################################################
# - Name: Linux Auto-Customizer common functions between install.sh and uninstall.sh.                                  #
# - Description: Set of functions used both in install.sh and uninstall.sh. Most of these functions are used to        #
# manipulate and interpret the common data structures. Others are here to avoid code duplications between install.sh   #
# and uninstall.sh.                                                                                                    #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 16/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernández Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: This script can not be executed directly, only sourced to import its functions and process its own    #
# imports. See the header of each function to see its privilege requirements                                           #
# - Arguments: No arguments                                                                                            #
# - Usage: Sourced from install.sh                                                                                     #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


# Execute the command received in the first argument and redirect the output depending on the quietness level
# Argument 1: Bash command to execute.
# Argument 2: Quietness level [0, 1, 2].
output_proxy_executioner() {
  comm=$(echo "$1" | head -1 | cut -d " " -f1)
  if [[ "${comm}" == "echo" ]]; then
    rest=$(echo "$1" | sed '1 s@^echo @@')
    message_type="$(echo "${rest}" | cut -d ":" -f1)"
    if [[ ${message_type} == "WARNING" ]]; then
      echo -en "\e[33m" # Activate yellow colour
    elif [[ ${message_type} == "INFO" ]]; then
      echo -en "\e[36m" # Activate cyan colour
    elif [[ ${message_type} == "ERROR" ]]; then
      echo -en "\e[91m" # Activate red colour
    fi
    echo -n "$(date +%Y-%m-%d_%T) -- "
  fi

  if [[ $2 == 0 ]]; then
    $1
  elif [[ $2 == 1 ]]; then
    if [[ "${comm}" == "echo" ]]; then
      # If it is a echo command, delete trailing echo and echo formatting
      rest=$(echo "$1" | sed '1 s@^echo @@') # Delete echo at the beggining of the line
      echo "${rest}"
    else
      $1 &>/dev/null
    fi
  else
    $1 &>/dev/null
  fi
  if [[ "${comm}" == "echo" ]]; then
    echo -en "\e[0m" # DeActivate colour
  fi
}

# Receives a list of arguments selecting features (--pycharm, --vlc...) and applies the current flags to it,
# modifying the corresponding line of installation_data
add_program()
{
  # Process all arguments
  while [[ $# -gt 0 ]]; do

    found=0  # To check for a valid argument
    # Process each argument to write down the flags for each installation in installation_data
    total=${#installation_data[*]}
    for (( i=0; i<$(( ${total} )); i++ )); do  # Check all the entries in installation_data
      # Cut first program name argument (with two -- at the beginning) from the first argument
      # We will generate the program function name with it
      program_arguments=$(echo "${installation_data[$i]}" | cut -d ";" -f1)
      for argument in $(echo ${program_arguments} | tr "|" " "); do

        if [[ "$1" == "${argument}" ]]; then

          # Set that the argument is valid
          found=1
          # Cut static bit of permission
          flag_permissions=$(echo "${installation_data[$i]}" | cut -d ";" -f2)
          # Generate name of the function depending on the mode from the first argument
          program_name="${FLAG_MODE}_$(echo ${program_arguments} | cut -d "|" -f1 | cut -d "-" -f3-)"
          # Append static bits to the state of the flags
          new="${program_arguments};${flag_permissions};${FLAG_INSTALL};${FLAG_IGNORE_ERRORS};${FLAG_QUIETNESS};${FLAG_OVERWRITE};${program_name}"
          installation_data[$i]=${new}
          # Update flags and program counter if we are installing
          if [[ ${FLAG_INSTALL} -gt 0 ]]; then
            NUM_INSTALLATION=$(( ${NUM_INSTALLATION} + 1 ))
            FLAG_INSTALL=${NUM_INSTALLATION}
          fi
          break  # Argument matched, so we can stop searching
        fi
      done
      # Propagate the inner break, and continue to next argument
      if [[ ${found} == 1 ]]; then
        break
      fi

    done
    if [[ ${found} == 0 ]]; then
        output_proxy_executioner "echo WARNING: $1 is not a recognized command. Skipping this argument." ${FLAG_QUIETNESS}
    fi
    shift
  done
}

add_wrapper()
{
  while [[ $# -gt 0 ]]; do
    add_program "--$1"
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
  local -r action_name=$( echo "$3" | cut -d "_" -f1 )
  if [[ $1 == 1 ]]; then
    set +e
  else
    set -e
  fi
  output_proxy_executioner "echo INFO: Attemptying to ${action_name} ${feature_name}." $2
  output_proxy_executioner $3 $2
  output_proxy_executioner "echo INFO: ${feature_name} ${action_name}ed." $2
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
    for program in "${installation_data[@]}"; do
      # Check the number of elements, if there are less than 3 do not process, that program has not been added
      num_elements=$(echo ${program} | tr ";" " " | wc -w)
      if [[ ${num_elements} -lt 3 ]]; then
        continue
      fi
      # Installation bit processing
      installation_bit=$( echo ${program} | cut -d ";" -f3 )
      if [[ ${installation_bit} == ${i} ]]; then
        program_privileges=$( echo ${program} | cut -d ";" -f2 )
        forceness_bit=$( echo ${program} | cut -d ";" -f4 )
        quietness_bit=$( echo ${program} | cut -d ";" -f5 )
        overwrite_bit=$( echo ${program} | cut -d ";" -f6 )
        program_function=$( echo ${program} | cut -d ";" -f7 )
        program_name=$( echo ${program_function} | cut -d "_" -f2- )
        if [[ ${program_privileges} == 1 ]]; then
          if [[ ${EUID} -ne 0 ]]; then
            output_proxy_executioner "echo WARNING: ${program_name} needs root permissions to be installed. Skipping." ${quietness_bit}
          else  # When called from uninstall it will take always this branch
            execute_installation_wrapper_install_feature ${overwrite_bit} ${forceness_bit} ${quietness_bit} ${program_function} ${program_name}
          fi
        elif [[ ${program_privileges} == 0 ]]; then
          if [[ ${EUID} -ne 0 ]]; then
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

# - Description: Adds all the programs with specific privileges to the installation data
# - Permissions: This function can be called as root or as user with same behaviour.
# - Argument 1: Type of permissions of the selected program: 0 for user, 1 for root, 2 for everything
add_programs_with_x_permissions()
{
  for program in "${installation_data[@]}"; do
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

if [[ -f "${DIR}/data_features.sh" ]]; then
  source "${DIR}/data_features.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: data_features.sh not found. Aborting..."
  exit 1
fi

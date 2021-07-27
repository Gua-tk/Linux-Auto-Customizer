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
    if [ "$2" != "2" ]; then
      echo -n "$(date +%Y-%m-%d_%T) -- "
    fi
  fi

  if [[ $2 == 0 ]]; then
    $1
  elif [[ $2 == 1 ]]; then
    if [[ "${comm}" == "echo" ]]; then
      # If it is a echo command, delete trailing echo and echo formatting
      rest=$(echo "$1" | sed '1 s@^echo @@') # Delete echo at the beggining of the line
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
  while [ $# -gt 0 ]; do
    found=0  # To check for a valid argument
    # Process each argument to write down the flags for each installation in installation_data
    total=${#installation_data[*]}
    for (( i=0; i<$(( ${total} )); i++ )); do  # Check all the entries in installation_data
      # Cut first program name argument (with two -- at the beginning) from the first argument
      # We will generate the program function name with it
      program_arguments="$(echo "${installation_data[$i]}" | cut -d ";" -f1 | tr "|" " ")"
      # Set IFS, variable used to determine the default separator on foreach loops in bash. Set space as separator
      IFS=" "
      for argument in ${program_arguments}; do
        if [ "$1" == "${argument}" ]; then
          # Set that the argument is valid
          found=1
          # Cut static bit of permission
          flag_permissions=$(echo "${installation_data[$i]}" | cut -d ";" -f2)
          # Generate name of the function depending on the mode from the first argument
          program_name="${FLAG_MODE}_$(echo ${program_arguments} | cut -d " " -f1 | cut -d "-" -f3-)"
          # Append static bits to the state of the flags
          new="${program_name};${flag_permissions};${FLAG_INSTALL};${FLAG_IGNORE_ERRORS};${FLAG_QUIETNESS};${FLAG_OVERWRITE};${FLAG_FAVORITES};${FLAG_AUTOSTART}"
          installation_data[$i]=${new}
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
    for program in "${installation_data[@]}"; do
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

  for program in "${installation_data[@]}"; do
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
  for program in "${installation_data[@]}"; do
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

# Sets up custom prompt when entering debug mode in customizer
customizer_prompt()
{
  while [ true ]; do
    read -p "customizer-prompt $ " cmds
    eval "${cmds}"
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

argument_processing()
{
  output_proxy_executioner "echo \"INFO: Processing arguments\"" "${FLAG_QUIETNESS}"
  while [[ $# -gt 0 ]]; do
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
        FLAG_INSTALL=${NUM_INSTALLATION}
      ;;

      -h)
        output_proxy_executioner "echo ${help_common}${help_simple}" ${FLAG_QUIETNESS}
        exit 0
      ;;

      -H|--help)
        autogen_help

        output_proxy_executioner "echo ${help_common}${help_arguments}${help_individual_arguments_header}$(autogen_help)${help_wrappers}" ${FLAG_QUIETNESS}
        exit 0
      ;;

      --debug)
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
  if [[ ${NUM_INSTALLATION} == 0 ]]; then
    output_proxy_executioner "echo ERROR: No arguments provided to install feature. Displaying help and finishing..." ${quietness_bit}
    output_proxy_executioner "echo ${help_message}" ${quietness_bit}
    exit 0
  fi
}

post_install_clean()
{
  if [[ ${EUID} == 0 ]]; then
    if [[ ${FLAG_AUTOCLEAN} -gt 0 ]]; then
      output_proxy_executioner "echo INFO: Attempting to clean orphaned dependencies via apt-get autoremove." ${quietness_bit}
      output_proxy_executioner "apt-get -y autoremove" ${quietness_bit}
      output_proxy_executioner "echo INFO: Finished." ${quietness_bit}
    fi
    if [[ ${FLAG_AUTOCLEAN} == 2 ]]; then
      output_proxy_executioner "echo INFO: Attempting to delete useless files in cache via apt-get autoremove." ${quietness_bit}
      output_proxy_executioner "apt-get -y autoclean" ${quietness_bit}
      output_proxy_executioner "echo INFO: Finished." ${quietness_bit}
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

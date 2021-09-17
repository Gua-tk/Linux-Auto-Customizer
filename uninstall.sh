#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer uninstallation of features.                                                            #
# - Description: Portable script to remove all installation features installed by install.sh                           #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 19/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when   #
# logged as root) to uninstall some of the features. The features that need to be installed as privileged user also    #
# need to be uninstalled as privileged user.                                                                           #
# - Arguments: Accepts behavioural arguments with one hyphen (-f, -o, etc.) and feature to uninstall with two hyphens  #
# (--pycharm, --gcc).                                                                                                  #
# - Usage: Uninstalls the features given by argument.                                                                  #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


########################################################################################################################
######################################### USER SOFTWARE FUNCTIONS ######################################################
########################################################################################################################

uninstall_caffeine_pre()
{
 :
}

uninstall_caffeine_post()
{
 :
}

uninstall_customizer_post()
{
  remove_file /usr/bin/customizer-uninstall
  remove_line "source \"${BASH_FUNCTIONS_PATH}\"" "${BASHRC_ALL_USERS_PATH}"
}

uninstall_gitcm_post()
{
  :
  #git config --global credential.credentialStore plaintext
}

uninstall_jupyter_lab_pre() {
  :
}

uninstall_jupyter_lab_mid() {

  # install jupyter-lab dependencies down
  #julia -e '#!/.local/bin/julia
  #using Pkg
  #Pkg.add("IJulia")
  #Pkg.build("IJulia")'
  :
}

uninstall_pgadmin_mid() {
  :
}

# Installs pypy3 dependencies, pypy3 and basic modules (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
uninstall_pypy3_mid() {
  :
}

uninstall_sherlock_post() {
  :
}

uninstall_sysmontask_mid() {
  :
}

install_changebg_post() {
  :
  #crontab "${USR_BIN_FOLDER}/changebg/.cronjob"
}

uninstall_wikit_mid() {
  npm remove wikit -g
}


##################
###### MAIN ######
##################
main()
{
  ################################
  ### DATA AND FILE STRUCTURES ###
  ################################

  FLAG_MODE=uninstall  # Uninstall mode
  FLAG_OVERWRITE=1  # Set in uninstall always to true or it skips the program if it is installed


  #################################
  ###### ARGUMENT PROCESSING ######
  #################################
  argument_processing "$@"

  ####################
  ### INSTALLATION ###
  ####################
  execute_installation

  ###############################
  ### POST-INSTALLATION CLEAN ###
  ###############################
  post_install_clean

  bell_sound
}

DIR=$(dirname "$(realpath "$0")")

if [ -f "${DIR}/functions_uninstall.sh" ]; then
  source "${DIR}/functions_uninstall.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: functions_uninstall.sh does not exist. Aborting..."
  exit 1
fi

# Call main function
main "$@"

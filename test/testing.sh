#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer installation of features.                                                              #
# - Description: Performs a batch install of all the features using two terminals, one for the root features and the   #
#   other for the user features. It also accepts an argument to shutdown or reboot afterwards.                         #
# - Creation Date: 28/8/21                                                                                             #
# - Last Modified: 11/12/21                                                                                            #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: aleix.marine@estudiants.urv.cat                                                                             #
# - Permissions: It is run with normal permissions and the script will ask for superuser permissions to the user by    #
#   using sudo.                                                                                                        #
# - Arguments: The first argument can be set optionally to "reboot" to reboot after the test and to "shutdown" to      #
#   shutdown.                                                                                                          #
# - Usage: bash testing.sh [shutdown|reboot|]  # it will ask for permissions after                                     #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################

# Install all programs, show output and save it to a file, ignore errors, overwrite already existent features
sudo bash ../src/install.sh -v -o -i --root | tee customizersudoall.outerr.txt &
PID_ROOT=$!
# wait 10 seconds to write the password with nothing on the screen
sleep 10
bash ../src/install.sh -v -o -i --user &>customizeruserall.outerr.txt &
PID_USER=$!

gnome-terminal -- less +F -f -r customizeruserall.outerr.txt
gnome-terminal -- less +F -f -r customizersudoall.outerr.txt
wait $PID_ROOT
wait $PID_USER
if [ "$1" == "shutdown" ]; then
  shutdown -h now
elif [ "$1" == "reboot" ]; then
  reboot
fi



#!/usr/bin/env bash
# Install all programs, show output and save it to a file, ignore errors, overwrite already existent features
sudo bash install.sh -v -o -i --root | tee customizersudoall.outerr.txt &
PID_ROOT=$!
# wait 10 seconds to write the password with nothing on the screen
sleep 10
bash install.sh -v -o -i --user &>customizeruserall.outerr.txt &
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



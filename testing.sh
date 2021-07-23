#!/usr/bin/env bash
# Install all programs, show output and save it to a file, ignore errors, overwrite already existent features
sudo bash install.sh -v -o -i --root 2>&1 | tee customizersudoall.outerr.txt &
PID_ROOT=$!
bash install.sh -v -o -i --user 2>&1 | tee customizeruserall.outerr.txt &
PID_USER=$!
wait $PID_ROOT
wait $PID_USER
if [ "$1" == "shutdown" ]; then
  shutdown -h now
else if [ "$1" == "reboot" ]; then
  reboot
fi



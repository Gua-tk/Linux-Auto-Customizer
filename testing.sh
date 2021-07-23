#!/usr/bin/env bash
# Install all programs, show output and save it to a file, ignore errors, overwrite already existent features
sudo bash install.sh -v -o -i --all 2>&1 | tee customizersudoall.outerr && bash install.sh -v -o -i --all 2>&1 | tee customizeruserall.outerr

#!/usr/bin/env bash
install_matlab_mid()
{
  "${TEMP_FOLDER}/matlab/install"  # Execute installer
  rm -Rf "${TEMP_FOLDER}/matlab"
}
uninstall_matlab_mid()
{
  :
}

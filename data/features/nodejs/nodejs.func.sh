#!/usr/bin/env bash
install_nodejs_post()
{
  if ! isRoot; then
    output_proxy_executioner "Updating npm to latest version" "INFO"
    npm install npm@latest -g
  else
    output_proxy_executioner "Can't update npm because you are root, re-run 'npm install npm@latest -g' if you want to update npm" "WARNING"
  fi
}

uninstall_nodejs_post()
{
  :
}

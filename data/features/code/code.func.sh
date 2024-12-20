#!/usr/bin/env bash

uninstall_code_pre()
{
  remove_folder "/var/lib/pgadmin"
}

install_code_post()
{
  code --install-extension ${CURRENT_INSTALLATION_FOLDER}/arm-syntax-vscode-extension.vsix

}




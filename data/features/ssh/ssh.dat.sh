#!/usr/bin/env bash

ssh_name="SSH"
ssh_description="Secure Shell"
ssh_version="System dependent"
ssh_tags=("client" "remote" "shell")
ssh_systemcategories=("Network" "RemoteAccess" "ConsoleOnly" "Shell")
ssh_packagenames=("ssh-client")
ssh_bashfunctions=("ssh.sh")
ssh_packagedependencies=("openssh-sftp-server" "openssh-client")
ssh_launcherkeynames=("defaultLauncher")
ssh_defaultLauncher_exec="ssh"
ssh_defaultLauncher_terminal="true"

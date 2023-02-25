#!/usr/bin/env bash

opensshServer_name="openssh-server"
opensshServer_description="SSH server"
opensshServer_version="System dependent"
opensshServer_tags=("server" "customDesktop")
opensshServer_systemcategories=("Network" "Settings" "ConsoleOnly")

opensshServer_packagenames=("openssh-server")
opensshServer_bashfunctions=("openssh_server.sh")
opensshServer_manualcontentavailable="0;0;1"

opensshServer_filekeys=("banner" "motdScript")
opensshServer_banner_path="banner.ans"
opensshServer_banner_content="banner.ans"

opensshServer_motdScript_path="/etc/update-motd.d/96-custom-message"
opensshServer_motdScript_content="96-custom-message.sh"

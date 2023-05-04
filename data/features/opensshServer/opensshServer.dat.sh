#!/usr/bin/env bash

opensshServer_name="openssh-server"
opensshServer_description="SSH server"
opensshServer_version="System dependent"
opensshServer_tags=("server" "customDesktop")
opensshServer_systemcategories=("ConsoleOnly" "Network" "Settings")

opensshServer_packagenames=("openssh-server")
opensshServer_bashfunctions=("openssh_server.sh")
opensshServer_manualcontentavailable="0;0;1"

opensshServer_filekeys=("logoImage" "banner" "motdScript" "profileScript")

# Banner is ANSI text that when displayed in a capable terminal shows the an alien and a warning message. It is
# displayed before ssh login
opensshServer_banner_path="banner.ans"
opensshServer_banner_content="banner.ans"

# This includes a small script that displays the customizer logo from the ANSI text file in the MOTD for SSH with bottom
# priority. It does not work most of the time because basically MOTD is old and weird, but it should work.
# The expected results can be seen with `run-parts /etc/update-motd.d`. I will leave this configuration here because it
# could be useful for other distros
opensshServer_motdScript_path="/etc/update-motd.d/96-custom-message"
opensshServer_motdScript_content="96-custom-message.sh"

# We copy the logo to the installation folder
opensshServer_logoImage_path="logo.png"
opensshServer_logoImage_content="${CUSTOMIZER_PROJECT_FOLDER}/.github/logo.png"

# This could be used in a bash initialization, but that will make it only visible when we log in as the current user.
# This makes much more sense as a global configuration that everyone sees
opensshServer_profileScript_path="/etc/profile.d/neofetch_customizer.sh"
opensshServer_profileScript_content="neofetch_customizer.sh"


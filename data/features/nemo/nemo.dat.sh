#!/usr/bin/env bash

nemo_name="Nemo Desktop"
nemo_description="Access and organize files"
nemo_version="System dependent"
nemo_tags=("customDesktop")
nemo_systemcategories=("Core" "GTK" "Utility")
nemo_bashfunctions=("nemo.sh")
nemo_bashinitializations=("nemo_config.sh")
nemo_packagenames=("nemo")
nemo_packagedependencies=("dconf-editor")
nemo_description="File and desktop manager, usually with better options and less bugs than nautilus. *We recommend this explorer to view correctly the launchers*"
nemo_launcherkeynames=("defaultLauncher" "autostartLauncher")
nemo_defaultLauncher_exec="nemo %U"

nemo_defaultLauncher_name="Files"
nemo_defaultLauncher_ubuntuGetText="nemo"
nemo_defaultLauncher_OnlyShowIn=("GNOME" "Unity" "KDE" "Cinnamon")
nemo_defaultLauncher_actions=("openhome" "opencomputer" "opentrash" "openserver")

nemo_defaultLauncher_openhome_name="Home"
nemo_defaultLauncher_openhome_exec="nemo %U"

nemo_defaultLauncher_opencomputer_name="Computer"
nemo_defaultLauncher_opencomputer_exec="nemo computer:///"

nemo_defaultLauncher_opentrash_name="Trash"
nemo_defaultLauncher_opentrash_exec="nemo trash:///"

nemo_defaultLauncher_openserver_name="Server Connect"
nemo_defaultLauncher_openserver_exec="nemo-connect-server"
nemo_associatedfiletypes=("inode/directory" "application/x-gnome-saved-search")

nemo_autostartLauncher_name="Nemo"
nemo_autostartLauncher_comment="Start Nemo desktop at log in"
nemo_autostartLauncher_exec="nemo-desktop"
nemo_autostartLauncher_nodisplay="false"
nemo_autostartLauncher_autostartcondition="GSettings org.nemo.desktop show-desktop-icons"
nemo_autostartLauncher_autorestart="true"
nemo_autostartLauncher_autorestartdelay="2"
nemo_autostartLauncher_ubuntuGetText="nemo"
nemo_autostartLauncher_autostart="yes"
nemo_keybindings=("nemo;<Super>e;Nemo File Explorer")

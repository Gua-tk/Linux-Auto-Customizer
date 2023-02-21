#!/usr/bin/env bash

rsync_name="Grsync"
rsync_description="Software for file/folders synchronization"
rsync_version="System dependent"
rsync_tags=("rsync" "sync")
rsync_systemcategories=("Filesystem" "Utility")
rsync_packagedependencies=("libcanberra-gtk-module" "libcanberra-gtk3-module" "libcanberra-gtk-module:i386")
rsync_packagenames=("rsync" "grsync")
rsync_bashfunctions=("rsync.sh")
rsync_launcherkeynames=("grsyncLauncher")
rsync_grsyncLauncher_exec="grsync"

#!/usr/bin/env bash

onedrive_name="OneDrive client"
onedrive_description="A free Microsoft OneDrive Client"
onedrive_version="2.4.13-1build1_amd64"
onedrive_tags=("iochem" "customDesktop")
onedrive_systemcategories=("System" "Utility")
onedrive_downloadKeys=("debPackage")
onedrive_debPackage_installedPackages=("onedrive")
onedrive_debPackage_URL="http://es.archive.ubuntu.com/ubuntu/pool/universe/o/onedrive/onedrive_2.4.13-1build1_amd64.deb"
onedrive_launcherkeynames=("defaultLauncher")
onedrive_defaultLauncher_exec="onedrive --monitor --verbose ; sleep 5"
onedrive_defaultLauncher_terminal="true"
onedrive_defaultLauncher_actionkeynames=("sync" "reauthorize")

onedrive_defaultLauncher_sync_name="Sync files"
onedrive_defaultLauncher_sync_exec="onedrive --monitor --verbose ; sleep 5"

onedrive_defaultLauncher_reauthorize_name="Reauthorize"
onedrive_defaultLauncher_reauthorize_exec="onedrive --monitor --verbose --logout re-authorize ; sleep 5"

#!/usr/bin/env bash

dropbox_name="Dropbox"
dropbox_description="File Synchronizer"
dropbox_version="2020.03.04_amd64"
dropbox_tags=("backup" "cloud" "customDesktop")
dropbox_systemcategories=("FileTransfer" "Network")
dropbox_packagenames=("dropbox")
dropbox_packagedependencies=("python3-gpg")
dropbox_downloadKeys=("bundle")
dropbox_bundle_URL="https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb"
dropbox_package_manager_override="apt-get"
dropbox_launcherkeynames=("defaultLauncher")
dropbox_defaultLauncher_exec="dropbox start -i"
dropbox_defaultLauncher_notify="false"

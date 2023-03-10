#!/usr/bin/env bash

uget_name="uGet"
uget_description="Download Manager"
uget_version="System dependent"
uget_tags=("downloadManager" "filetransfer" "download files" "download manager" "customDesktop")
uget_systemcategories=("FileTransfer" "Network")
uget_launchernames=("uget-gtk")
uget_packagedependencies=("aria2")
uget_packagenames=("uget")
uget_launcherkeynames=("defaultLauncher")
uget_defaultLauncher_exec="env GDK_BACKEND=x11 uget-gtk %u"

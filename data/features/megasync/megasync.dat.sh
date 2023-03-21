#!/usr/bin/env bash

megasync_name="MegaSync"
megasync_description="Synchronises folders between your computer and your MEGA Cloud Drive"
megasync_version="4.6.1-2.1_amd64"
megasync_tags=("cloud" "customDesktop")
megasync_packagedependencies=("nemo" "libc-ares2" "libmediainfo0v5" "libqt5x11extras5" "libzen0v5")
megasync_downloadKeys=("packageDefault" "packageDesktop")
megasync_packageDefault_URL="https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/megasync_4.6.1-2.1_amd64.deb"
megasync_packageDefault_installedPackages="megasync"
megasync_packageDesktop_URL="https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/nemo-megasync_4.0.2_amd64.deb"
megasync_packageDesktop_installedPackages="nemo-megasync"
megasync_package_manager_override="apt-get"
megasync_launcherkeynames=("default")
megasync_default_exec="megasync"

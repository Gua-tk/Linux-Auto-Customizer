#!/usr/bin/env bash

virtualbox_name="VirtualBox"
virtualbox_description="Hosted hypervisor for x86 virtualization"
virtualbox_version="System dependent"
virtualbox_tags=("customDesktop")
virtualbox_systemcategories=("System" "")
virtualbox_bashfunctions=("silentFunction")
virtualbox_launchernames=("virtualbox")
virtualbox_packagedependencies=("make" "gcc" "perl" "python" "build-essential" "dkms" "libsdl1.2debian" "virtualbox-guest-utils" "libqt5printsupport5" "libqt5x11extras5" "libcurl4" "virtualbox-guest-dkms" "linux-headers-$(uname -r)" "libqt5opengl5" "linux-headers-generic" "linux-source" "linux-generic" "linux-signed-generic")
virtualbox_packagenames=("virtualbox-6.1")
virtualbox_downloadKeys=("bundle")
virtualbox_bundle_URL="https://download.virtualbox.org/virtualbox/6.1.28/virtualbox-6.1_6.1.28-147628~Ubuntu~eoan_amd64.deb"
virtualbox_package_manager_override="apt-get"
virtualbox_launcherkeynames=("defaultLauncher")
virtualbox_defaultLauncher_exec="virtualbox"

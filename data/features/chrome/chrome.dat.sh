#!/usr/bin/env bash

chrome_name="Google Chrome"
chrome_description="Web Browser"
chrome_version="Google dependent"
chrome_tags=("browser" "network")
chrome_systemcategories=("Network" "WebBrowser")
chrome_bashfunctions=("silentFunction")
chrome_flagsoverride=";;;;1;"
chrome_launcherkeynames=("default")
chrome_default_exec="google-chrome"
chrome_packagedependencies=("libxss1" "libappindicator1" "libindicator7" "fonts-liberation")
chrome_downloadKeys=("debianPackage")
chrome_debianPackage_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
chrome_debianPackage_installedPackages="google-chrome-stable"
chrome_package_manager_override="apt-get"
chrome_launcherkeys=("default")
chrome_keybindings=("google-chrome;<Primary><Alt><Super>c;Google Chrome")

#!/usr/bin/env bash

skype_name="Skype"
skype_description="Skype Internet Telephony"
skype_version="System dependent"
skype_tags=("calls" "customDesktop")
skype_systemcategories=("InstantMessaging" "Chat" "Network" "Application")
skype_packagenames=("skype")
skype_launcherkeynames=("defaultLauncher")
skype_defaultLauncher_exec="skypeforlinux %U"
skype_defaultLauncher_windowclass="Skype"
skype_defaultLauncher_actions=("QuitSkype")

skype_defaultLauncher_QuitSkype_name="Quit Skype"
skype_defaultLauncher_QuitSkype_exec="skypeforlinux --shutdown"
skype_defaultLauncher_QuitSkype_onlyShowIn="Unity;"
skype_downloadKeys=("bundle")
skype_bundle_URL="https://go.skype.com/skypeforlinux-64.deb"
skype_package_manager_override="apt-get"

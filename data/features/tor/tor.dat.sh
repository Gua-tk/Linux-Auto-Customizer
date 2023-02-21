#!/usr/bin/env bash

tor_name="Tor Browser"
tor_description="Browser focused on security and privacy. Can browse through the onion protocol"
tor_version="System dependent"
tor_tags=("security" "web" "browser")
tor_systemcategories=("Network" "WebBrowser")
tor_packagenames=("torbrowser-launcher")
tor_launcherkeynames=("defaultLauncher")
tor_defaultLauncher_exec="torbrowser-launcher %u"
tor_defaultLauncher_windowclass="Tor Browser"

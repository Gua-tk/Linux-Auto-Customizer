#!/usr/bin/env bash

steam_name="Steam"
steam_description="Application for managing and playing games on Steam"
steam_version="System dependent"
steam_tags=("customDesktop")
steam_systemcategories=("FileTransfer" "Game" "Network")
steam_launcherkeynames=("defaultLauncher")
steam_defaultLauncher_exec="steam %U"
steam_defaultLauncher_actions=("Store" "Community" "Library" "Servers" "Screenshots" "News" "Settings" "BigPicture" "Friends")

steam_defaultLauncher_Store_name="Store"
steam_defaultLauncher_Store_exec="steam steam://store"

steam_defaultLauncher_Community_name="Community"
steam_defaultLauncher_Community_exec="steam steam://url/SteamIDControlPage"

steam_defaultLauncher_Library_name="Library"
steam_defaultLauncher_Library_exec="steam steam://open/games"

steam_defaultLauncher_Servers_name="Servers"
steam_defaultLauncher_Servers_exec="steam steam://open/servers"

steam_defaultLauncher_Screenshots_name="Screenshots"
steam_defaultLauncher_Screenshots_exec="steam steam://open/screenshots"

steam_defaultLauncher_News_name="News"
steam_defaultLauncher_News_exec="steam steam://open/news"

steam_defaultLauncher_Settings_name="Settings"
steam_defaultLauncher_Settings_exec="steam steam://open/settings"

steam_defaultLauncher_BigPicture_name="Big Picture"
steam_defaultLauncher_BigPicture_exec="steam steam://open/bigpicture"

steam_defaultLauncher_Friends_name="Friends"
steam_defaultLauncher_Friends_exec="steam steam://open/friends"
steam_packagenames=("steam-launcher")
steam_associatedfiletypes=("x-scheme-handler/steam" "x-scheme-handler/steamlink")
steam_packagedependencies=("curl")
steam_downloadKeys=("bundle")
steam_bundle_URL="https://steamcdn-a.akamaihd.net/client/installer/steam.deb"
steam_package_manager_override="apt-get"

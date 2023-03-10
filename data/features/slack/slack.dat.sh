#!/usr/bin/env bash

slack_name="Slack"
slack_description="Slack Client for Linux"
slack_version="4.29.149-amd64"
slack_tags=("team" "customDesktop")
slack_systemcategories=("GNOME" "GTK" "Network" "InstantMessaging")

slack_packagenames=("slack-desktop")
slack_downloadKeys=("bundle")
slack_bundle_URL="https://downloads.slack-edge.com/releases/linux/4.29.149/prod/x64/slack-desktop-4.29.149-amd64.deb"
slack_package_manager_override="apt-get"
slack_associatedfiletypes=("x-scheme-handler/slack")
slack_launcherkeynames=("defaultLauncher")
slack_defaultLauncher_exec="slack %U"
slack_defaultLauncher_windowclass="Slack"
slack_bashfunctions=("silentFunction")
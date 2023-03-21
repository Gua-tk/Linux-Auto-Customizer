#!/usr/bin/env bash

teams_name="Microsoft Teams - Preview"
teams_description="Microsoft Teams for Linux is your chat-centered workspace in Office 365."
teams_version="System dependent"
teams_tags=("customDesktop")
teams_systemcategories=("Office" "Network" "ProjectManagement" "Chat")
teams_associatedfiletypes=("x-scheme-handler/msteams")
teams_launchernames=("teams")
teams_packagenames=("teams")
teams_downloadKeys=("bundle")
teams_bundle_URL="https://go.microsoft.com/fwlink/p/?LinkID=2112886&clcid=0x40a&culture=es-es&country=ES"
teams_launcherkeynames=("defaultLauncher")
teams_defaultLauncher_exec="teams %U"
teams_defaultLauncher_windowclass="Microsoft Teams - Preview"
teams_defaultLauncher_usesNotifications="true"
teams_defaultLauncher_protocols="teams"
teams_defaultLauncher_actions=("QuitTeams")

teams_defaultLauncher_QuitTeams_name="Quit Teams"
teams_defaultLauncher_QuitTeams_exec="/usr/bin/teams --quit"
teams_defaultLauncher_QuitTeams_onlyShowIn="Unity;"

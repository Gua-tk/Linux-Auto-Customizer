#!/usr/bin/env bash

thunderbird_name="Thunderbird Mail"
thunderbird_description="Send and receive mail with Thunderbird"
thunderbird_version="System dependent"
thunderbird_tags=("mail" "email" "Email" "E-mail" "Newsgroup" "Feed" "RSS")
thunderbird_systemcategories=("Application" "Network" "Email")
thunderbird_packagenames=("thunderbird")
thunderbird_associatedfiletypes=("x-scheme-handler/mailto" "application/x-xpinstall" "x-scheme-handler/webcal" "x-scheme-handler/mid" "message/rfc822")
thunderbird_bashfunctions=("silentFunction")
thunderbird_launcherkeynames=("defaultLauncher")
thunderbird_defaultLauncher_exec="thunderbird %u"
thunderbird_defaultLauncher_XMultipleArgs="false"
thunderbird_defaultLauncher_actions=("Compose" "Contacts")

thunderbird_defaultLauncher_Compose_name="Compose New Message"
thunderbird_defaultLauncher_Compose_exec="thunderbird -compose"
thunderbird_defaultLauncher_Compose_onlyShowIn="Messaging Menu;Unity;"

thunderbird_defaultLauncher_Contacts_name="Contacts"
thunderbird_defaultLauncher_Contacts_exec="thunderbird -addressbook"
thunderbird_defaultLauncher_Contacts_onlyShowIn="Messaging Menu;Unity;"

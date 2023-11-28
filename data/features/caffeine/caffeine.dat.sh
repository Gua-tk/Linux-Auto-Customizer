#!/usr/bin/env bash
caffeine_name="Caffeine"
caffeine_description="Customization application"
caffeine_version="System dependent"
caffeine_tags=("customDesktop")
caffeine_systemcategories=("Settings" "System" "TrayIcon" "Utility")

caffeine_launcherkeynames=("defaultLauncher" "caffeineIndicator")
caffeine_defaultLauncher_StartupNotify="false"
caffeine_defaultLauncher_exec="caffeine-indicator"

caffeine_caffeineIndicator_name="Caffeine Indicator"
caffeine_caffeineIndicator_exec="caffeine-indicator"
caffeine_caffeineIndicator_StartupNotify="false"
caffeine_caffeineIndicator_autostart="yes"
caffeine_caffeineIndicator_OnlyShowIn=("GNOME" "KDE" "LXDE" "LXQt" "MATE" "Razor" "ROX" "TDE" "Unity" "XFCE" "EDE" "Cinnamon" "Pantheon")

caffeine_packagenames=("caffeine")
caffeine_manualcontentavailable="1;0;1"

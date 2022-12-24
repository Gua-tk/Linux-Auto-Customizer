
copyq_name="CopyQ"
copyq_description="Clipboard Manager"
copyq_version="1.0"
copyq_tags=("history" "clipboard")
copyq_systemcategories=("Qt" "KDE" "Utility")
copyq_packagenames=("copyq")
copyq_flagsoverride=";;;;;1"  # Always autostart
copyq_launcherkeynames=("defaultLauncher" "autostartLauncher")
copyq_defaultLauncher_exec="copyq --start-server show"
copyq_defaultLauncher__autorestartdelay="3"
copyq_autostartLauncher_exec="copyq --start-server show"

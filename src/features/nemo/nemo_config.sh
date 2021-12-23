
# Check if gsettings command is available
if ! command -v gsettings &> /dev/null
then
  return
fi

xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
gsettings set org.gnome.desktop.background show-desktop-icons false
gsettings set org.nemo.desktop show-desktop-icons true

# Other tweaks
# Do not ask for password after locking
gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false
# Allow forcing the volume
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true
# Set the time zone automatically
gsettings set org.gnome.desktop.datetime automatic-timezone true
# Set the dark theme
gsettings set org.gnome.desktop.interface gtk-theme Yaru-dark
gsettings set org.gnome.desktop.interface cursor-theme Yaru-dark
# Show battery percentage on bar
gsettings set org.gnome.desktop.interface show-battery-percentage true
# Show seconds in the time
gsettings set org.gnome.desktop.interface clock-show-seconds true
# Show weekday in the date of the calendar
gsettings set org.gnome.desktop.interface clock-show-weekday true
# Enable that the left corner acts as the show apps menu (not working)
gsettings set org.gnome.desktop.interface enable-hot-corners true
# Enable keyboard shortcuts
gsettings set org.gnome.Terminal.Legacy.Settings mnemonics-enabled true
# Put dock in the bottom of the screen
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position "'BOTTOM'"
# Change the image in the lockscreen
# gsettings set org.gnome.login-screen fallback-logo "'CUSTOMIZER LOGO'"
# Show icon of the home folder
gsettings set org.nemo.desktop home-icon-visible true
# Show different captions for the icon view in the file explorer
gsettings set org.nemo.icon-view captions "['size', 'type', 'date_accessed', 'date_modified']"
# Try to hide the identity given to third party softwares
gsettings set org.gnome.desktop.privacy hide-identity true
# Show thousands separators in the calculator
gsettings set org.gnome.calculator show-thousands true
# Also show files in the side panel of the file explorer
gsettings set org.nemo.sidebar-panels.tree show-only-directories false

# Gedit options
gsettings set org.gnome.gedit.preferences.editor auto-save true
gsettings set org.gnome.gedit.preferences.editor display-line-numbers true
gsettings set org.gnome.gedit.preferences.editor display-right-margin true
gsettings set org.gnome.gedit.preferences.editor tabs-size 4
gsettings set org.gnome.gedit.preferences.ui bottom-panel-visible true
gsettings set org.gnome.gedit.preferences.ui side-panel-visible true
gsettings set org.gnome.gedit.plugins.spell highlight-misspelled true

# keyboard configurations 0 for spanish 1 for us keyboard
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'es'), ('xkb', 'us')]"
gsettings set org.gnome.desktop.input-sources current 0

# Category launcher containers in dashboard
gsettings set org.gnome.desktop.app-folders folder-children "['accessories', 'chrome-apps', 'games', 'graphics', 'internet', 'office', 'programming', 'science', 'sound---video', 'system-tools', 'universal-access', 'wine']"

gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/accessories/ name "Accessories"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/accessories/ categories "['Utility']"

gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/chrome-apps/ name "Chrome Apps"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/chrome-apps/ categories "['chrome-apps']"

gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/games/ name "Games"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/games/ categories "['Game']"

gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/graphics/ name "Graphics"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/graphics/ categories "['Graphics']"

gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/internet/ name "Internet"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/internet/ categories "['Network', 'WebBrowser', 'Email']"

gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/office/ name "Office"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/office/ categories "['Office']"

gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/programming/ name "Programming"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/programming/ categories "['Development']"

gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/science/ name "Science"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/science/ categories "['Science']"

gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/sound---video/ name "Sound & Video"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/sound---video/ categories "['AudioVideo', 'Audio', 'Video']"

gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/system-tools/ name "System Tools"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/system-tools/ categories "['System', 'Settings']"

gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/universal-access/ name "Universal Access"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/universal-access/ categories "['Accessibility']"

gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/wine/ name "Wine"
gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/wine/ categories "['Wine', 'X-Wine', 'Wine-Programs-Accessories']"

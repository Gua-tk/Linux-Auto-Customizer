#!/usr/bin/env bash
# Set a key into gsettings safely, even if it does not exists
# Argument 1: Key path
# Argument 2: Property
# Argument 3: New value
set_key_safely()
{
  if gsettings get "$1" "$2" &> /dev/null; then
    gsettings set "$1" "$2" "$3"
  fi
}

# Check if xdg-mime command is available
if ! command -v xdg-mime &> /dev/null
then
  return
fi

xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

# Check if gsettings command is available
if ! command -v gsettings &> /dev/null
then
  return
fi


set_key_safely org.gnome.desktop.background show-desktop-icons false
set_key_safely org.nemo.desktop show-desktop-icons true

# Other tweaks

# Show thumbnails of files until 128 GB which is 137.438.953.472 B
# Maximum value in the IU: 32 GB which is shown as 34.359.738.368 B
# Default value in dconf editor 1 MB
# Value that comes with the installation 1 GB
set_key_safely org.nemo.preferences thumbnail-limit 137438953472
# Do not ask for password after locking
set_key_safely org.gnome.desktop.screensaver ubuntu-lock-on-suspend false
# Allow forcing the volume
set_key_safely org.gnome.desktop.sound allow-volume-above-100-percent true
# Set the time zone automatically
set_key_safely org.gnome.desktop.datetime automatic-timezone true
# Set the dark theme
set_key_safely org.gnome.desktop.interface gtk-theme Yaru-dark
set_key_safely org.gnome.desktop.interface cursor-theme Yaru-dark
# Show battery percentage on bar
set_key_safely org.gnome.desktop.interface show-battery-percentage true
# Show seconds in the time
set_key_safely org.gnome.desktop.interface clock-show-seconds true
# Show weekday in the date of the calendar
set_key_safely org.gnome.desktop.interface clock-show-weekday true
# Enable that the left corner acts as the show apps menu (not working)
set_key_safely org.gnome.desktop.interface enable-hot-corners true
# Enable keyboard shortcuts
set_key_safely org.gnome.Terminal.Legacy.Settings mnemonics-enabled true
# Put dock in the bottom of the screen
set_key_safely org.gnome.shell.extensions.dash-to-dock dock-position "'BOTTOM'"
# Change the image in the lockscreen
set_key_safely org.gnome.login-screen fallback-logo "'€{CUSTOMIZER_PROJECT_FOLDER}/.github/logo.png'"
# Change the image in the user profile
set_key_safely org.gnome.login-screen logo "'€{CUSTOMIZER_PROJECT_FOLDER}/.github/logo.png'"
# Show icon of the home folder
set_key_safely org.nemo.desktop home-icon-visible true
# Show different captions for the icon view in the file explorer
set_key_safely org.nemo.icon-view captions "['size', 'type', 'date_accessed', 'date_modified']"
# Try to hide the identity given to third party softwares
set_key_safely org.gnome.desktop.privacy hide-identity true
# Show thousands separators in the calculator
set_key_safely org.gnome.calculator show-thousands true
# Also show files in the side panel of the file explorer
set_key_safely org.nemo.sidebar-panels.tree show-only-directories false

# Gedit options
set_key_safely org.gnome.gedit.preferences.editor auto-save true
set_key_safely org.gnome.gedit.preferences.editor display-line-numbers true
set_key_safely org.gnome.gedit.preferences.editor display-right-margin true
set_key_safely org.gnome.gedit.preferences.editor tabs-size 4
set_key_safely org.gnome.gedit.preferences.ui bottom-panel-visible true
set_key_safely org.gnome.gedit.preferences.ui side-panel-visible true
set_key_safely org.gnome.gedit.plugins.spell highlight-misspelled true
set_key_safely org.gnome.gedit.preferences.editor insert-spaces true
set_key_safely org.gnome.gedit.preferences.editor highlight-current-line false
set_key_safely org.gnome.gedit.preferences.editor wrap-mode none  # Do not wrap lines


# keyboard configurations 0 for spanish 1 for us keyboard
set_key_safely org.gnome.desktop.input-sources sources "[('xkb', 'es'), ('xkb', 'us')]"
set_key_safely org.gnome.desktop.input-sources current 0

# Category launcher containers in dashboard
set_key_safely org.gnome.desktop.app-folders folder-children "['accessories', 'chrome-apps', 'games', 'graphics', 'internet', 'office', 'programming', 'science', 'sound---video', 'system-tools', 'universal-access', 'wine']"

set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/accessories/ name "Accessories"
set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/accessories/ categories "['Utility']"

set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/chrome-apps/ name "Chrome Apps"
set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/chrome-apps/ categories "['chrome-apps']"

set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/games/ name "Games"
set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/games/ categories "['Game']"

set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/graphics/ name "Graphics"
set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/graphics/ categories "['Graphics']"

set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/internet/ name "Internet"
set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/internet/ categories "['Network', 'WebBrowser', 'Email']"

set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/office/ name "Office"
set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/office/ categories "['Office']"

set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/programming/ name "Programming"
set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/programming/ categories "['Development']"

set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/science/ name "Science"
set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/science/ categories "['Science']"

set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/sound---video/ name "Sound & Video"
set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/sound---video/ categories "['AudioVideo', 'Audio', 'Video']"

set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/system-tools/ name "System Tools"
set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/system-tools/ categories "['System', 'Settings']"

set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/universal-access/ name "Universal Access"
set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/universal-access/ categories "['Accessibility']"

set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/wine/ name "Wine"
set_key_safely org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/wine/ categories "['Wine', 'X-Wine', 'Wine-Programs-Accessories']"

#!/usr/bin/env bash

screenshots_name="Screenshots"
screenshots_description="Takes a screenshot and saves it to custom ~/Images/screenshots folder and save it to the clipboard for pasting"
screenshots_version="System dependent"
screenshots_tags=("gnome" "customDesktop")
screenshots_systemcategories=("Utility")

screenshots_filekeys=("screenshotwindow" "screenshotarea" "screenshotfull")
screenshots_keybindings=("screenshot-area;<Primary><Alt><Super>a;Screenshot Area" "screenshot-full;<Primary><Alt><Super>s;Screenshot Full" "screenshot-window;<Primary><Alt><Super>w;Screenshot Window")
screenshots_screenshotwindow_path="screenshot_window.sh"
screenshots_screenshotwindow_content="screenshot_window.sh"
screenshots_screenshotarea_path="screenshot_area.sh"
screenshots_screenshotarea_content="screenshot_area.sh"
screenshots_screenshotfull_path="screenshot_full.sh"
screenshots_screenshotfull_content="screenshot_full.sh"
screenshots_binariesinstalledpaths=("screenshot_area.sh;screenshot-area" "screenshot_window.sh;screenshot-window" "screenshot_full.sh;screenshot-full")
screenshots_packagedependencies=("gnome-screenshot" "xclip")

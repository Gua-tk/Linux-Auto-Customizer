#!/usr/bin/env bash
keyboardFix_name="Fix Fn key Keychron K8 ISO UK"
keyboardFix_description="Fixes the Fn key in combination with the Function keys F1, F2, etc. which happens to not work in some keyboards"
keyboardFix_version="System dependent"
keyboardFix_tags=("customDesktop")
keyboardFix_systemcategories=("Utility")

keyboardFix_filekeys=("keyboardconf")
keyboardFix_keyboardconf_path="/etc/modprobe.d/hid_apple.conf"
keyboardFix_keyboardconf_content="keyboard.conf"
keyboardFix_manualcontentavailable="0;0;1"
keyboardFix_flagsoverride="0;;;;;"  # Root mode

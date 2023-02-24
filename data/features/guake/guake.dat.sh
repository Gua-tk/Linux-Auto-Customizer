#!/usr/bin/env bash

guake_name="Guake Terminal"
guake_description="Use the command line in a Quake-like terminal"
guake_version="System dependent"
guake_tags=("terminal" "utility" "customDesktop")
guake_systemcategories=("System" "Utility" "TerminalEmulator" "GNOME" "GTK")
guake_bashfunctions=("silentFunction")
guake_packagenames=("guake")
guake_launcherkeynames=("default")
guake_default_exec="guake"
guake_flagsoverride=";;;;;1"  # Always autostart

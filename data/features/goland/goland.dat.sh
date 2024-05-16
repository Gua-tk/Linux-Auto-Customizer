#!/usr/bin/env bash

goland_name="GoLand"
goland_description="Integrated development environment for the Go programming language"
goland_version="2024.1.1"
goland_tags=("editor" "IDE" "programming" "text" "customDesktop")
goland_systemcategories=("ComputerScience" "Debugger" "Development" "IDE" "WebDevelopment")
goland_icon="goland.svg"

goland_associatedfiletypes=("text/x-go")
goland_bashfunctions=("silentFunctionInWd")
goland_binariesinstalledpaths=("bin/goland.sh;goland")
goland_downloadKeys=("bundle")
goland_bundle_URL="https://download.jetbrains.com/go/goland-2024.1.1.tar.gz"
goland_keybindings=("goland;<Primary><Alt><Super>g;GoLand")
goland_launcherkeynames=("launcher")
goland_launcher_exec="goland %F"
goland_launcher_windowclass="jetbrains-goland"
goland_launcher_actionkeynames=("newwindow")

goland_launcher_newwindow_name="GoLand New Window"
goland_launcher_newwindow_exec="GoLand"

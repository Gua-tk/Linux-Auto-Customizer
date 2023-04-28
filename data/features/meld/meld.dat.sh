#!/usr/bin/env bash

meld_name="Meld"
meld_description="Diff viewer to compare and merge your files"
meld_version="2021.3"
meld_tags=("programming" "customDesktop")
meld_systemcategories=("Development" "GTK")
meld_packagedependencies=("libgtksourceview-4-dev" "libgtksourceview-3.0-1")
meld_bashfunctions=("silentFunction")
meld_associatedfiletypes=("application/x-meld-comparison")
meld_binariesinstalledpaths=("bin/meld;meld")
meld_downloadKeys=("bundle")
meld_bundle_URL="https://download.gnome.org/sources/meld/3.21/meld-3.21.0.tar.xz"
meld_launcherkeynames=("default")
meld_default_exec="meld %F"

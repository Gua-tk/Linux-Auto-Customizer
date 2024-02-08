#!/usr/bin/env bash
nodejs_name="NodeJS"
nodejs_description="JavaScript language for the developers."
nodejs_version="v20.11.0-linux-x64"
nodejs_tags=("language" "customDesktop")
nodejs_systemcategories=("Development" "Languages")
nodejs_downloadKeys=("bundle")
nodejs_bundle_URL="https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz"
nodejs_binariesinstalledpaths=("bin/node;node" "bin/npm;npm" "bin/npx;npx")
nodejs_launcherkeynames=("languageLauncher")
nodejs_languageLauncher_exec="gnome-terminal -- nodejs"
nodejs_manualcontentavailable="0;0;1"

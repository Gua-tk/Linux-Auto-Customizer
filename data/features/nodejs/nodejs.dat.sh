#!/usr/bin/env bash
nodejs_name="NodeJS"
nodejs_description="JavaScript language for the developers."
nodejs_version=""
nodejs_tags=("javascript" "language" "packageManager" "npm")
nodejs_systemcategories=("Languages" "Development")
nodejs_downloadKeys=("bundle")
nodejs_bundle_URL="https://nodejs.org/dist/v14.17.0/node-v14.17.0-linux-x64.tar.xz"
nodejs_binariesinstalledpaths=("bin/node;node" "bin/npm;npm" "bin/npx;npx")
nodejs_launcherkeynames=("languageLauncher")
nodejs_languageLauncher_terminal="true"
nodejs_languageLauncher_exec="gnome-terminal -e nodejs"
nodejs_manualcontentavailable="0;0;1"

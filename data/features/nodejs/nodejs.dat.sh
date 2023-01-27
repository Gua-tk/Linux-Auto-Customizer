#!/usr/bin/env bash
nodejs_name="NodeJS"
nodejs_description="JavaScript language for the developers."
nodejs_version="v16.19.0-linux-x64"
nodejs_tags=("javascript" "language" "packageManager" "npm")
nodejs_systemcategories=("Languages" "Development")
nodejs_downloadKeys=("bundle")
nodejs_bundle_URL="https://nodejs.org/download/release/v16.19.0/node-v16.19.0-linux-x64.tar.gz"
nodejs_binariesinstalledpaths=("bin/node;node" "bin/npm;npm" "bin/npx;npx")
nodejs_launcherkeynames=("languageLauncher")
nodejs_languageLauncher_terminal="false"
nodejs_languageLauncher_exec="gnome-terminal -- nodejs"
nodejs_manualcontentavailable="0;0;1"

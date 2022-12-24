install_nodejs_post()
{
  if ! isRoot; then
    output_proxy_executioner "Updating npm to latest version" "INFO"
    npm install npm@latest -g
  else
    output_proxy_executioner "Can't update npm because you are root, re-run 'npm install npm@latest -g' if you want to update npm" "WARNING"
  fi
}
uninstall_nodejs_post()
{
  :
}
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

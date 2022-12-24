install_wikit_mid() {
  npm install wikit -g
}
uninstall_wikit_mid() {
  npm remove wikit -g
}
wikit_name="Wikit"
wikit_description="Wikipedia search inside terminal"
wikit_version="System dependent"
wikit_tags=("wikipedia")
wikit_systemcategories=("Education")
wikit_manualcontentavailable=";1;"
wikit_flagsoverride="1;;;;;"  # Install always as user

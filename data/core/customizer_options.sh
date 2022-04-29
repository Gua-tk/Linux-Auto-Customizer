# The following options are the default options of the customizer. Uncomment and change the declaration of the variables
# to change the default behaviour of the customizer

# Installation behaviour flags
#FLAG_OVERWRITE=0
#FLAG_INSTALL=1
#FLAG_QUIETNESS=1
#FLAG_IGNORE_ERRORS=0
#FLAG_FAVORITES=0
#FLAG_AUTOSTART=0
#FLAG_SKIP_PRIVILEGES_CHECK=0
#FLAG_PACKAGE_MANAGER_ALLOW_OVERRIDES=0

# Common behaviour flags
#FLAG_UPGRADE=1
#FLAG_AUTOCLEAN=2
#FLAG_CACHE=1

# You can declare properties and add them into the accepted features to insert custom features
donut_name="donut feature"
donut_version="1.0"
donut_description="A certain custom feature with many uses"
donut_commentary="Amazing example feature"
donut_tags=("customizer", "custom", "example")
donut_arguments=("custom_feature" "feature")
donut_packagedependencies=("gcc")
donut_launcherkeynames=("defaultLauncher")
donut_defaultLauncher_terminal="true"
donut_defaultLauncher_exec="${BIN_FOLDER}/donut/donut"
donut_downloadKeys=("donutFile")
donut_donutFile_URL="https://gist.githubusercontent.com/AleixMT/44a499f2a1b73811c76d0520bb15e8e0/raw/247818ab59d0b65548e28237c04f074b048ee755/donut.c"
donut_donutFile_downloadPath="${BIN_FOLDER}/donut/donut.c"
donut_manualcontentavailable="0;0;1"
install_donut_post()
{
  gcc "${BIN_FOLDER}/donut/donut.c" -lm -o "${BIN_FOLDER}/donut/donut"
}
uninstall_donut_post()
{
  rm -Rf "${BIN_FOLDER}/donut"
}

feature_keynames+=("donut")

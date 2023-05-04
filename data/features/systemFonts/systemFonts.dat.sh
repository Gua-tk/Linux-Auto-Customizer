#!/usr/bin/env bash

systemFonts_name="Change default fonts"
systemFonts_description="Sets pre-defined fonts to desktop environment."
systemFonts_version="System dependent"
systemFonts_tags=("customDesktop")
systemFonts_systemcategories=("System" "Utility")
systemFonts_bashinitializations=("fonts_initializations.sh")
systemFonts_packagenames=("fonts-hack" "fonts-firacode" "fonts-hermit" "fonts-roboto" "msttcorefonts" )
systemFonts_downloadKeys=("alegreyaSans" "lato" "noto" "oswald" "oxygen")
systemFonts_alegreyaSans_downloadPath="${FONTS_FOLDER}"
systemFonts_alegreyaSans_URL="https://fonts.google.com/download?family=Alegreya%20Sans"
systemFonts_alegreyaSans_doNotInherit="yes"
systemFonts_lato_downloadPath="${FONTS_FOLDER}"
systemFonts_lato_URL="https://fonts.google.com/download?family=Lato"
systemFonts_lato_doNotInherit="yes"
systemFonts_noto_downloadPath="${FONTS_FOLDER}"
systemFonts_noto_URL="https://fonts.google.com/download?family=Noto%20Sans"
systemFonts_noto_doNotInherit="yes"
systemFonts_oswald_downloadPath="${FONTS_FOLDER}"
systemFonts_oswald_URL="https://fonts.google.com/download?family=Oswald"
systemFonts_oswald_doNotInherit="yes"
systemFonts_oxygen_downloadPath="${FONTS_FOLDER}"
systemFonts_oxygen_URL="https://fonts.google.com/download?family=Oxygen"
systemFonts_oxygen_doNotInherit="yes"

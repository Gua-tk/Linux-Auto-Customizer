#!/usr/bin/env bash

# The display variable makes possible the printing of images. if not declared fallback to neofetch default logo
if [ -z "${DISPLAY}" ]; then
  export DISPLAY=":0"
fi

neofetch --jp2a "€{CURRENT_INSTALLATION_FOLDER}/logo.png"  # Display banner

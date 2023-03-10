#!/usr/bin/env bash

zoom_name="Zoom"
zoom_description="Live video streaming for meetings and productivity"
zoom_version="Vendor dependent"
zoom_tags=("social" "videoCalls" "communication" "customDesktop")
zoom_systemcategories=("AudioVideo" "Network" "Education")

zoom_packagedependencies=("libglib2.0-0" "libxcb-shape0" "libxcb-shm0" "libxcb-xfixes0" "libxcb-randr0" "libxcb-image0" "libfontconfig1" "libgl1-mesa-glx" "libxi6" "libsm6" "libxrender1" "libpulse0" "libxcomposite1" "libxslt1.1" "libsqlite3-0" "libxcb-keysyms1" "ibus" "libxcb-xtest0" "libqt5quickwidgets5")
zoom_binariesinstalledpaths=("ZoomLauncher;ZoomLauncher" "zoom;zoom")
zoom_downloadKeys=("bundle")
zoom_bundle_URL="https://zoom.us/client/latest/zoom_x86_64.tar.xz"
zoom_launcherkeynames=("defaultLauncher")

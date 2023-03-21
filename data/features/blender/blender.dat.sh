#!/usr/bin/env bash
blender_name="Blender"
blender_description="2D and 3D image modeling and animation, fx, video edit..."
blender_version="1.0"
blender_tags=("editing" "video" "3D")
blender_systemcategories=("Art" "Graphics" "ImageProcessing" "Video" "2DGraphics")

blender_downloadKeys=("bundle")
blender_bundle_URL="https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.93/blender-2.93.3-linux-x64.tar.xz"
blender_binariesinstalledpaths=("blender;blender")
blender_launcherkeynames=("defaultLauncher")
blender_defaultLauncher_exec="blender %f"
blender_defaultLauncher_mimetypes=("application/x-blender")

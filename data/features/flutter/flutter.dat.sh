flutter_install_post()
{
   flutter config --enable-linux-desktop
}
flutter_uninstall_post()
{
  :
}
flutter_name="Flutter"
flutter_description="Tool to create responsive GUIs"
flutter_version="2.10.5-stable"
flutter_tags=("programming" "development" "webProgramming")
flutter_systemcategories=("WebDevelopment" "Development")
flutter_packagedependencies=("bash" "curl" "file" "git" "mkdir" "rm" "unzip" "which" "xz-utils" "zip" "clang" "cmake" "ninja-build" "pkg-config" "libgtk-3-dev" "liblzma-dev")
flutter_downloadKeys=("bundleCompressed")
flutter_bundleCompressed_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_2.10.5-stable.tar.xz"
flutter_binariesinstalledpaths=("bin/dart;dart" "bin/flutter;flutter" "bin/dart.bat;dart.bat" "bin/flutter.bat;flutter.bat")
flutter_manualcontentavailable="0;0;1"

install_nano_post()
{
  # Set nano as the default git editor
  if which git &>/dev/null; then
    git config --global core.editor "nano"
  fi

  # Set editor to nano using the entry displayed in update-alternatives --list editor
  if isRoot; then
    nano_default_path="$(update-alternatives --list editor | grep -Eo "^.*nano.*$" | head -1)"
    if [ -n "${nano_default_path}" ]; then
      update-alternatives --set editor "${nano_default_path}"
    fi
  fi
}
uninstall_nano_post()
{
  # Restore editor to the default one (usually vim)
  if isRoot; then
    update-alternatives --auto editor
  fi

  # Restore default editor to git if we have it installed
  if which git &>/dev/null; then
    git config --global core.editor "editor"
  fi

}
nano_name="nano"
nano_description=""
nano_version="System dependent"
nano_systemcategories=("TextEditor" "Utility" "ConsoleOnly")
nano_packagenames=("nano")
nano_filekeys=("conf")
nano_conf_path="${HOME_FOLDER}/.nanorc"
nano_conf_content=("nanorc")
nano_manualcontentavailable="0;0;1"

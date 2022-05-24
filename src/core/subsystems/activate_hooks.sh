# Activate customizer hooks to enforce repository rules
# Use hooks in the repo if git is installed
if which git &>/dev/null; then
  if git merge HEAD >/dev/null 2>&1; then
    if [ "$(git rev-parse --show-toplevel | rev | cut -d '/' -f1 | rev )" == "Linux-Auto-Customizer" ]; then
      echo "Activating git hooks"
      git config --local core.hooksPath "${CUSTOMIZER_PROJECT_FOLDER}/.githooks/"
    fi
  fi
fi


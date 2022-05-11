# Activate customizer hooks to enforce repository rules
# Use hooks in the repo if git is installed
if which git &>/dev/null; then
  git config --local core.hooksPath "${CUSTOMIZER_PROJECT_FOLDER}/.githooks/"
fi

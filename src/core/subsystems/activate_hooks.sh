# Activate customizer hooks to enforce repository rules
# Use hooks in the repo if git is installed
if which git &>/dev/null; then
  # Subshell with no re-interpretation of output
  (
    cd "${CUSTOMIZER_PROJECT_FOLDER}" || exit 1
    git config --local core.hooksPath "${CUSTOMIZER_PROJECT_FOLDER}/.githooks/"
  )
fi

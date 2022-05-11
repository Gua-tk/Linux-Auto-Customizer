# Activate customizer hooks to enforce repository rules
# Check if git is installed
if which git &>/dev/null; then
  # Check that we are in a git repository
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    # Check that this repository is the Customizer
    if [ "$(git rev-parse --show-toplevel | rev | cut -d "/" -f1 | rev)" = "Linux-Auto-Customizer" ]; then
      git config --local core.hooksPath "${CUSTOMIZER_PROJECT_FOLDER}/.githooks/"
    fi
  fi
fi


#!/usr/bin/env bash

########################################################################################################################
# -Name:
# -Description:
# -Creation Date:
# -Last Modified:
# -Author:
# -Email:
# -Permissions:
# -Args:
# -Usage:
# -License:
########################################################################################################################

main()
{
  CUSTOMIZER_PROJECT_FOLDER="$(cd "$(dirname "$(realpath "$0")")/../.." &>/dev/null && pwd)"
  DIR="${CUSTOMIZER_PROJECT_FOLDER}/src/core"
  source "${CUSTOMIZER_PROJECT_FOLDER}/src/core/data_features.sh"

  for key_name in "${feature_keynames[@]}"; do
    num=1
    launchers_pointer="${key_name}_launchernames[@]"
    if [ -z "$(echo "${!launchers_pointer}")" ]; then
      continue
    fi
    mkdir -p "${CUSTOMIZER_PROJECT_FOLDER}/data/static/${key_name}"
    for launcher_pointer in ${!launchers_pointer}; do
      if [ ! -f "${XDG_DESKTOP_DIR}/${launcher_pointer}.desktop" ]; then
        echo "${XDG_DESKTOP_DIR}/${launcher_pointer}.desktop does not exist"
        continue
      fi
      icon_name="$(cat "${XDG_DESKTOP_DIR}/${launcher_pointer}.desktop" | grep -Eo "^Icon=.*\$" | cut -d "=" -f2)"
      for icon_path_system in $(find /usr/share/icons | grep "${icon_name}"); do
        echo "${icon_path_system}"
        echo "${icon_name}"
        cp "${icon_path_system}" "${CUSTOMIZER_PROJECT_FOLDER}/data/static/${key_name}/${key_name}_${num}.$(echo "${icon_path_system}" | rev | cut -d "." -f1 | rev)"
        num=$((num + 1))
      done
    done
  done

}

set -e
main "$@"


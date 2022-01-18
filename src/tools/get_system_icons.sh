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

  programs_with_copy_launcher=()
  programs_trimmed=()
  programs_not_trimmed=()
  for key_name in "${feature_keynames[@]}"; do
    num=1
    launchers_pointer="${key_name}_launchernames[@]"
    if [ -z "$(echo "${!launchers_pointer}")" ]; then
      continue
    fi

    programs_with_copy_launcher+=(${key_name})
    mkdir -p "${CUSTOMIZER_PROJECT_FOLDER}/data/static/${key_name}"
    for launcher_pointer in ${!launchers_pointer}; do
      if [ ! -f "${XDG_DESKTOP_DIR}/${launcher_pointer}.desktop" ]; then
        echo "${XDG_DESKTOP_DIR}/${launcher_pointer}.desktop does not exist"
        programs_not_trimmed+=(${key_name})
        continue
      fi
      programs_trimmed+=(${key_name})
      icon_name="$(cat "${XDG_DESKTOP_DIR}/${launcher_pointer}.desktop" | grep -Eo "^Icon=.*\$" | cut -d "=" -f2)"
      for icon_path_system in $(find /usr/share/icons -type f | grep -E "^.*/${icon_name}"); do
        echo "ICON PATH: ${icon_path_system}"
        echo "ICON NAME: ${icon_name}"
        file_extension="$(echo "${icon_path_system}" | rev | cut -d "." -f1 | rev)"
        file_name="$(echo "${icon_path_system}" | tr "/" "_" )"
        if [ "${file_extension}" == "svg" ] || [ "${file_extension}" == "png" ]; then
          cp "${icon_path_system}" "${CUSTOMIZER_PROJECT_FOLDER}/data/static/${key_name}/${key_name}_${num}_${file_name}.${file_extension}"
        else
          cp "${icon_path_system}" "${CUSTOMIZER_PROJECT_FOLDER}/data/static/${key_name}/${key_name}_${num}_${file_name}"
        fi
        num=$((num + 1))
      done
    done
  done


  echo
  echo
  echo "Programs with copy launcher:"
  echo "${programs_with_copy_launcher[@]}"

  echo
  echo
  echo "Programs trimmed:"
  echo "${programs_trimmed[@]}"

  echo
  echo
  echo "Programs not trimmed:"
  echo "${programs_not_trimmed[@]}"
}



set -e
main "$@"


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

  programs_with_launcher_contents=()
  programs_trimmed=()
  programs_not_trimmed=()
  for key_name in "${feature_keynames[@]}"; do
    num=1
    echo "Program: ${key_name}"
    launchers_pointer="${key_name}_launchercontents[@]"
    if [ -z "$(echo "${!launchers_pointer}")" ]; then
      echo "${key_name} has no launcher names property"
      continue
    fi

    programs_with_launcher_contents+=(${key_name})
    mkdir -p "${CUSTOMIZER_PROJECT_FOLDER}/data/static/${key_name}"
    if [[ $(ls -A "${CUSTOMIZER_PROJECT_FOLDER}/data/static/${key_name}") ]]; then
      echo "${key_name} static folder already has files"
      programs_trimmed+=(${key_name})
      continue
    fi

    echo "launcher name: ${key_name}.desktop"
    if [ ! -f "${XDG_DESKTOP_DIR}/${key_name}.desktop" ]; then
      echo "${XDG_DESKTOP_DIR}/${key_name}.desktop does not exist"
      programs_not_trimmed+=(${key_name})
      continue
    fi
    icon_path="$(grep -Eo "^Icon=.*\$" < "${XDG_DESKTOP_DIR}/${key_name}.desktop" | cut -d "=" -f2-)"
    if [ -z "${icon_path}" ]; then
      continue
    fi
    echo "Icon name is ${icon_path}"
    if [ -f "${icon_path}" ]; then
      cp "${icon_path}" "${CUSTOMIZER_PROJECT_FOLDER}/data/static/${key_name}"
      programs_trimmed+=(${key_name})
    else
      echo "Icon in path ${icon_path}"
      programs_not_trimmed+=(${key_name})
    fi
  done


  echo
  echo
  echo "Programs with copy launcher:"
  echo "${programs_with_launcher_contents[@]}"

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


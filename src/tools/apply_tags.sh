#!/usr/bin/env bash

########################################################################################################################
# -Name: apply_tags.sh
# -Description: Inserts in the last position of the field tags o fhte supplied features
# -Creation Date: 02/02/2022
# -Last Modified: 02/02/2002
# -Author: Aleix Mariné-Tena
# -Email: aleixaretra@gmail.com
# -Permissions: It is run with normal permissions.
# -Args: No arguments
# -Usage: Go to Linux-Auto-Customizer/src/features and run 'bash ../tools/add_functions_shebang.sh'
# -License: GPL v2.0
########################################################################################################################

main()
{
  CUSTOMIZER_PROJECT_FOLDER="$(cd "$(dirname "$(realpath "$0")")/../.." &>/dev/null && pwd)"

  if [ $# -gt 1 ]; then
    echo "You need to supply at least 2 argument. First the tag and the other following the feature keyname to apply the tag"
    exit 1
  fi

  # Obtain the tag to apply
  local -r tagName="$1"
  shift

  for featureName in "$@"; do
    local tagsContent="$(grep -Eo "${featureName}_tags=(.*)" < "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${featureName}.dat.sh")"
    local tagsSplit="$(echo "${tagsContent}" | cut -d ")" -f1)"
    local newTagContent="$(echo "${tagsSplit} ${tagName})")"
    sed "s/${tagsContent}/${newTagContent}/g" "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${featureName}.dat.sh"
  done

}




set -e
main "$@"

#!/usr/bin/env bash

########################################################################################################################
# - Name: apply_tags.sh
# - Description: Inserts in the last position of the tags field of the supplied feature the supplied tag name to apply.
# - Creation Date: 24/02/2023
# - Last Modified: 24/02/2023
# - Author: Aleix Mariné-Tena
# - Email: aleixaretra@gmail.com
# - Permissions: It is run with normal permissions. Modification access to the .dat.sh files of the selected feature.
# - Arguments:
#   * Argument 1: Name of the tag to apply.
#   * Argument 2, 3, 4... : Feature key names to apply the tag selection.
# - Usage: Go to Linux-Auto-Customizer/src/tools and run 'bash apply_tags.sh'
# - License: GPL v2.0
########################################################################################################################

main()
{
  CUSTOMIZER_PROJECT_FOLDER="$(cd "$(dirname "$(realpath "$0")")/../.." &>/dev/null && pwd)"

  if [ ! $# -gt 1 ]; then
    echo "You need to supply at least 2 argument. First the tag and the other following the feature keyname to apply the tag"
    exit 1
  fi

  # Obtain the tag to apply
  local -r tagName="$1"
  shift

  for featureName in "$@"; do
    printf '\nApplying tag to feature %s\n' "${featureName}"

    if [ ! -f "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${featureName}/${featureName}.dat.sh" ]; then
      echo "ERROR ${CUSTOMIZER_PROJECT_FOLDER}/data/features/${featureName}/${featureName}.dat.sh file not detected, skipping ${featureName}"
    fi
    local tagsContent="$(grep -Eo "${featureName}_tags=(.*)" < "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${featureName}/${featureName}.dat.sh")"
    local tagsSplit="$(echo "${tagsContent}" | cut -d ")" -f1)"
    local newTagContent="${tagsSplit} \"${tagName}\")"

    sed -i "s/${tagsContent}/${newTagContent}/g" "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${featureName}/${featureName}.dat.sh"
  done
}

set -e
main "$@"

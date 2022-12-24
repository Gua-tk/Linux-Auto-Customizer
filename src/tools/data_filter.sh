DIR=$(dirname "$(realpath "$0")")
export CUSTOMIZER_PROJECT_FOLDER="$(cd "${DIR}/../.." &>/dev/null && pwd)"
cat "${CUSTOMIZER_PROJECT_FOLDER}/data/core/feature_data.sh" | while read line; do

  if echo "${line}" | grep -Eq "^ *#"; then
    continue
  fi

  feature_name="$(echo "${line}" | cut -d "_" -f1)"
   if echo "${line}" | grep -Eq "^.*_name="; then
    echo >> "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${feature_name}/${feature_name}.dat.sh"
  fi

  if echo "${line}" | grep -Eq "^.*_arguments="; then
     mkdir -p "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${feature_name}"
     echo "${line}" >> "${CUSTOMIZER_PROJECT_FOLDER}/data/core/feature_arguments.sh"
     continue
  fi

  if echo "${line}" | grep -Eq "^.*_commentary="; then
    mkdir -p "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${feature_name}"
    comm="$(echo "${line}" | cut -d "=" -f2- | cut -d '"' -f2- | rev | cut -d '"' -f2- | rev )"
    echo "${comm}" >> "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${feature_name}/${feature_name}.md"
    continue
  fi

  echo "${line}" >> "${CUSTOMIZER_PROJECT_FOLDER}/data/features/${feature_name}/${feature_name}.dat.sh"

done
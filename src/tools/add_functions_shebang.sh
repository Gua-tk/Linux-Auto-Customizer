#!/usr/bin/env bash

########################################################################################################################
# -Name: add_functions_shebang.sh
# -Defile_pathion: Add shebangs in bash functions to avoid codacy error 'Add a shebang or a 'shell' directive.'
# -Creation Date: 02/02/2022
# -Last Modified: 02/02/2002
# -Author: Axel
# -Email: axelfernandezcurros@gmail.com
# -Permissions: It is run with normal permissions.
# -Args: No arguments
# -Usage: Go to Linux-Auto-Customizer/src/features and run 'bash ../tools/add_functions_shebang.sh'
# -License: GPL v2.0
########################################################################################################################

main()
{
  CUSTOMIZER_PROJECT_FOLDER="$(cd "$(dirname "$(realpath "$0")")/../.." &>/dev/null && pwd)"

  DIR="${CUSTOMIZER_PROJECT_FOLDER}/src/core"
  source "${DIR}/data_features.sh"
  SHE_BANG='#!/usr/bin/env bash'

  for key_name in ${feature_keynames[@]}; do

    if [ ! -d "${CUSTOMIZER_PROJECT_FOLDER}/src/features/${key_name}" ]; then
      continue
    fi
    for file_path in "${CUSTOMIZER_PROJECT_FOLDER}/src/features/${key_name}/"*; do

      if [ ! "$(echo "${file_path}" | rev | cut -d '.' -f1 | rev )" == "sh" ]; then
        continue
      fi
      # Match for .sh extension
      if [ "$(head -1 "${file_path}")" == "${SHE_BANG}" ]; then
        continue
      fi
      # Write the shebang if we have not already
      ex "${file_path}" <<eof
1 insert
#!/usr/bin/env bash
.
xit
eof

      echo "Added shebang to file ${file_path}"
    done
  done
}


set -e
main "$@"


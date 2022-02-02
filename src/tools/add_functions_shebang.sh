#!/usr/bin/env bash

########################################################################################################################
# -Name: add_functions_shebang.sh
# -Description: Add shebangs in bash functions to avoid codacy error 'Add a shebang or a 'shell' directive.'
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
  source "${CUSTOMIZER_PROJECT_FOLDER}/src/core/data_features.sh"


  for key_name in *; do
    cd ${key_name}
    pwd
    if [ -f ${key_name}.sh ]; then
      ex ${key_name}.sh <<eof
1 insert
#!/usr/bin/env bash
.
xit
eof
    fi
    cd ..
  done
}


set -e
main "$@"


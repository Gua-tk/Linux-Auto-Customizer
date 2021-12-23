#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto-Customizer installation of features.                                                              #
# - Description: Shows all the colors that can be used with tmux in the format "colourN".                              #
# - Creation Date: 28/8/21                                                                                             #
# - Last Modified: 12/12/21                                                                                            #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: aleix.marine@estudiants.urv.cat                                                                             #
# - Permissions: It is run with normal permissions.                                                                    #
# - Arguments: No arguments                                                                                            #
# - Usage: bash tmux_colors.sh | less -r                                                                                #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################

#!/usr/bin/env bash
for i in {0..255} ; do
    printf "\x1b[38;5;${i}mcolour${i}\n"
done
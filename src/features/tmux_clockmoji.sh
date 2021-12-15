########################################################################################################################
# - Name: tmux_clockmoji.sh                                                                                            #
# - Description: Displays the corresponding emoji of a clock regarding the current time. Used in the right status bar  #
#   of tmux.                                                                                                           #
# - Creation Date: 15/12/21                                                                                            #
# - Last Modified: 15/12/21                                                                                            #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: aleix.marine@estudiants.urv.cat                                                                             #
# - Permissions: This script can not be executed directly, only sourced to import its functions and process its own    #
# imports. See the header of each function to see its privilege requirements.                                          #
# - Arguments: No arguments                                                                                            #
# - Usage: Not executed directly, sourced from functions.sh                                                            #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


index=$(( ($(date +%H%M) % 1200 % 100 + 15 + $(date +%H%M) % 1200 / 100 * 60) / 30 ))
clocks=(🕛 🕧 🕐 🕜 🕑 🕝 🕒 🕞 🕓 🕟 🕔 🕠 🕕 🕡 🕖 🕢 🕗 🕣 🕘 🕤 🕙 🕥 🕚 🕦 🕛)

echo "${clocks[${index}]}"

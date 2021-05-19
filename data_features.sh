########################################################################################################################
# - Name: Linux Auto-Customizer exclusive functions of install.sh.                                                     #
# - Description: Contains the different pieces of data used to install and uninstall all features that can be generic.
# Here we have all the data relating to each feature: desktop launchers, icon URLs, aliases, bash_functions, paths to
# the binaries of each program, etc
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 16/5/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Tester: Axel Fernández Curros                                                                                      #
# - Email: aleix.marine@estudiants.urv.cat, amarine@iciq.es                                                            #
# - Permissions: This script can not be executed directly, only sourced to import its functions and process its own    #
# imports. See the header of each function to see its privilege requirements                                           #
# - Arguments: No arguments                                                                                            #
# - Usage: Sourced from install.sh                                                                                     #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################

# Here are the definition of most long strings, that are used in installation
# functions. All the variables follow the same name convention:
# 1 .- the first word is the name in the path, variable, function of the software
# to be installed.
# 2.- This is followed by a underscore _
# 3.- Then the second word is the type of variable:
#   * launcher: contains the contents of a desktop launcher file
#   * icon: Contains a URL that points to a valid icon for that feature
#   * url: Variables that contain an URL that is expected to be in the feature as-is
#   * downloader: Variables that contains an URL that points to a file resource
#   * alias: Contains code that will be integrated into the user environment. This
#     code will be parsed by bash only when run manually by the user, that means that
#     the variable with this suffix contains potentially harmless code such as alias or
#     variable definitions...
#   * function: Contains code that will be integrated into the user environment, but in
#   this case, the code is parsed every time the user reloads its environment indirectly,
#   that means that the variable with this suffix contains potentially harmful code, such
#   as bash functions or code that does some tweaking to the environment
#


#######################################
######## install.sh VARIABLES #########
#######################################

if [[ -f "${DIR}/data_common.sh" ]]; then
  source "${DIR}/data_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: data_common.sh not found. Aborting..."
  exit 1
fi

bash_functions_import="
source ${BASH_FUNCTIONS_PATH}
"
bash_functions_init="
# If not running interactively, don't do anything
case \$- in
    *i*) ;;
      *) return;;
esac
"


###########################################
##### INSTALLATION SPECIFIC VARIABLES #####
###########################################
aisleriot_mode=packagemanager
aisleriot_dependencies=
aisleriot_packages="aisleriot"
aisleriot_launchernames="sol"

alert_alias="
# Add an alert alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i \"\$([ \$? = 0 ] && echo terminal || echo error)\" \"\$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\\'')\"'
"
# Variables used exclusively in the corresponding installation function. Alphabetically sorted.
#Name, GenericName, Type, Comment, Version, StartupWMClass, Icon, Exec, Terminal, Categories=IDE;Programming;, StartupNotify, MimeType=x-scheme-handler/tg;, Encoding=UTF-8
android_studio_downloader=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.1.2.0/android-studio-ide-201.7042882-linux.tar.gz
android_studio_alias="alias studio=\"studio . &>/dev/null &\""
android_studio_launcher="[Desktop Entry]
Categories=Development;IDE;
Comment=IDE for developing android applications
Encoding=UTF-8
Exec=studio %F
GenericName=studio
Icon=${USR_BIN_FOLDER}/android-studio/bin/studio.svg
Keywords=IDE;programming;android;studio;dev;
MimeType=
Name=Android Studio
StartupNotify=true
StartupWMClass=jetbrains-android-studio
Terminal=false
TryExec=studio
Type=Application
Version=1.0
"

ant_downloader="https://ftp.cixug.es/apache//ant/binaries/apache-ant-1.10.9-bin.tar.gz"

anydesk_downloader="https://download.anydesk.com/linux/anydesk-6.1.1-amd64.tar.gz"
anydesk_launcher="[Desktop Entry]
Categories=Remote;control;other;
Comment=Remote control other PCs
Encoding=UTF-8
Exec=anydesk
GenericName=Remote computer control
Icon=${USR_BIN_FOLDER}/anydesk/icons/hicolor/scalable/apps/anydesk.svg
Keywords=IDE;programming;android;studio;dev;
MimeType=
Name=AnyDesk
StartupNotify=true
StartupWMClass=anydesk
Terminal=false
TryExec=anydesk
Type=Application
Version=1.0"

atom_installationtype="packageinstall"
atom_packageurl=("https://atom.io/download/deb")
atom_launchernames=("atom")

audacity_installationtype="packagemanager"
audacity_launchernames=("audacity")
audacity_packagenames=("audacity")

autofirma_downloader=https://estaticos.redsara.es/comunes/autofirma/currentversion/AutoFirma_Linux.zip

caffeine_installationtype="packagemanager"
caffeine_launchernames=("caffeine-indicator")
caffeine_packagenames=("caffeine")

calibre_installationtype="packagemanager"
calibre_launchernames=("calibre-gui")
calibre_packagenames=("calibre")

cheat_downloader=https://cht.sh/:cht.sh

cheese_installationtype="packagemanager"
cheese_launchernames=("org.gnome.Cheese")
cheese_packagenames=("cheese")

clementine_installationtype="packagemanager"
clementine_launchernames=("clementine")
clementine_packagenames=("clementine")

clion_downloader=https://download.jetbrains.com/cpp/CLion-2020.1.tar.gz
clion_launcher="[Desktop Entry]
Categories=Development;IDE;
Comment=C and C++ IDE for Professional Developers
Encoding=UTF-8
Exec=clion %F
GenericName=C Programing IDE
Icon=${USR_BIN_FOLDER}/clion/bin/clion.png
Keywords=IDE;programming;android;studio;dev;
MimeType=
Name=CLion
StartupNotify=true
StartupWMClass=jetbrains-clion
Terminal=false
TryExec=clion
Type=Application
Version=1.0"
clion_alias="alias clion=\"clion . &>/dev/null &\""

clonezilla_launcher="[Desktop Entry]
Categories=backup;images;restoration;boot;
Comment=Create bootable clonezilla images
Encoding=UTF-8
Exec=sudo clonezilla
GenericName=Disk image utility
Icon=/usr/share/gdm/themes/drbl-gdm/clonezilla/ocslogo-1.png
Keywords=clonezilla;CloneZilla;iso
MimeType=
Name=CloneZilla
StartupNotify=true
StartupWMClass=CloneZilla
Terminal=true
TryExec=clonezilla
Type=Application
Version=1.0"

cmatrix_launcher="[Desktop Entry]
Categories=matrix;
Comment=Matrix
Encoding=UTF-8
Exec=cmatrix
GenericName=cmatrix
Icon=/var/lib/app-info/icons/ubuntu-focal-universe/64x64/bless_bless-48x48.png
Keywords=cmatrix;matrix;
MimeType=
Name=CMatrix
StartupNotify=true
StartupWMClass=cmatrix
Terminal=true
TryExec=cmatrix
Type=Application
Version=1.0"

copyq_installationtype="packagemanager"
copyq_packagenames=("copyq")
copyq_launchernames=("com.github.hluk.copyq")

curl_installationtype="packagemanager"
curl_packagenames=("curl")

dropbox_downloader=https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb

discord_downloader="https://discord.com/api/download?platform=linux&format=tar.gz"
discord_launcher="[Desktop Entry]
Categories=Network;InstantMessaging;
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
Encoding=UTF-8
Exec=discord
GenericName=Internet Messenger
Icon=${USR_BIN_FOLDER}/discord/discord.png
Keywords=VoiceChat;Messaging;Social;
MimeType=
Name=Discord
StartupNotify=true
StartupWMClass=discord
Terminal=false
TryExec=discord
Type=Application
Version=1.0"

docker_downloader=https://download.docker.com/linux/static/stable/x86_64/docker-20.10.6.tgz

eclipse_downloader=http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.2.2-201302041200/eclipse-SDK-4.2.2-linux-gtk-x86_64.tar.gz
eclipse_launcher="[Desktop Entry]
Categories=Development;IDE;
Comment=Capable Multi-purpose IDE
Encoding=UTF-8
Exec=eclipse
GenericName=IDE
Icon=${USR_BIN_FOLDER}/eclipse/icon.xpm
Keywords=IDE;programming;
MimeType=
Name=Eclipse IDE
StartupNotify=true
StartupWMClass=Eclipse
Terminal=false
TryExec=eclipse
Type=Application
Version=4.2.2"

firc_launcher="[Desktop Entry]
Categories=InstantMessaging;Communication;
Comment=irc relay chat for terminal (easy to use)
Encoding=UTF-8
Exec=f-irc
GenericName=IRC client
Icon=/var/lib/app-info/icons/ubuntu-focal-universe/64x64/flightgear_flightgear.png
Keywords=InstantMessaging;irc;
MimeType=
Name=F-irc
StartupNotify=true
StartupWMClass=f-irc
Terminal=true
TryExec=f-irc
Type=Application
Version=1.0"

ffmpeg_installationtype="packagemanager"
ffmpeg_packagenames=("ffmpeg")

firefox_installationtype="packagemanager"
firefox_packagenames=("firefox")
firefox_launchernames=("firefox")

freecad_installationtype="packagemanager"
freecad_packagenames=("freecad")
freecad_launchernames=("freecad")

gcc_function="# colored GCC warnings and errors
export GCC_COLORS=\"error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01\"
"

geany_installationtype="packagemanager"
geany_packagenames=("geany")
geany_launchernames=("geany")

geogebra_downloader=https://download.geogebra.org/package/linux-port6
geogebra_icon=https://upload.wikimedia.org/wikipedia/commons/5/57/Geogebra.svg

geogebra_desktop="[Desktop Entry]
Categories=geometry;
Comment=GeoGebra
Encoding=UTF-8
Exec=geogebra
GenericName=Geometry visualization plotter
Icon=${USR_BIN_FOLDER}/geogebra/GeoGebra.svg
Keywords=GeoGebra;geogebra;
MimeType=
Name=GeoGebra
StartupNotify=true
StartupWMClass=geogebra
Terminal=false
TryExec=geogebra
Type=Application
Version=4.2.2"

gimp_installationtype="packagemanager"
gimp_packagenames=("gimp")
gimp_launchernames=("gimp")

git_aliases_function="
commit()
{
    message=\$*
    if [ -z \"\$message\" ]; then
      echo \"Add a message\"
      read message
    fi
    git commit -am \"\$message\"
}
dummycommit()
{
  git add -A
  git commit -am \"\$1\"
  git push
}

alias gitk=\"gitk --all --date-order &\"
if [ -f ${USR_BIN_FOLDER}/.bash-git-prompt/gitprompt.sh ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source ${USR_BIN_FOLDER}/.bash-git-prompt/gitprompt.sh
fi
alias status=\"git status\"
alias fetch=\"git fetch\"

"

github_installationtype="packageinstall"
github_packageurl="https://github.com/shiftkey/desktop/releases/download/release-2.6.3-linux1/GitHubDesktop-linux-2.6.3-linux1.deb"
github_packagenames=("github")
github_launchernames=("github-desktop.desktop")

#The following triggers errors in data_features.sh invalid variable name
gnome_calculator_installationtype="packagemanager"
gnome_calculator_packagenames=("gnome-calculator")
gnome_calculator_launchernames=("org.gnome.Calculator")

gnome_chess_installationtype="packagemanager"
gnome_chess_packagenames=("gnome-chess")
gnome_chess_launchernames=("org.gnome.Chess")

gnome_mahjongg_installationtype="packagemanager"
gnome_mahjongg_packagenames=("gnome-mahjongg")
gnome_mahjongg_launchernames=("org.gnome.Mahjongg")

gnome_mines_installationtype="packagemanager"
gnome_mines_packagenames=("gnome-mines")
gnome_mines_launchernames=("org.gnome.Mines")

gnome_sudoku_installationtype="packagemanager"
gnome_sudoku_packagenames=("gnome-sudoku")
gnome_sudoku_launchernames=("org.gnome.Sudoku")

gparted_installationtype="packagemanager"
gparted_packagenames=("gparted")
gparted_launchernames=("gparted")

forms_url=https://docs.google.com/forms/
forms_icon="https://upload.wikimedia.org/wikipedia/commons/5/5b/Google_Forms_2020_Logo.svg"
forms_alias="alias forms=\"xdg-open ${forms_url} &>/dev/null &\""
forms_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Google Forms from Chrome
Encoding=UTF-8
GenericName=Document
Keywords=forms;
MimeType=ç
Name=Google Forms
StartupNotify=true
StartupWMClass=Google Forms
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

github_icon="https://upload.wikimedia.org/wikipedia/commons/9/91/Octicons-mark-github.svg"
github_url=https://github.com/
github_alias="alias github=\"xdg-open ${github_url} &>/dev/null &\""
github_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Github from Chrome
Encoding=UTF-8
GenericName=GitHub
Keywords=github;
MimeType=ç
Name=GitHub
StartupNotify=true
StartupWMClass=GitHub
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

gitlab_downloader="https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/focal/gitlab-ce_13.11.4-ce.0_amd64.deb/download.deb"
gitlab_url=https://gitlab.com/
gitlab_icon="https://upload.wikimedia.org/wikipedia/commons/1/18/GitLab_Logo.svg"
gitlab_alias="alias gitlab=\"xdg-open ${gitlab_url} &>/dev/null &\""
gitlab_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Gitlab from Chrome
Encoding=UTF-8
GenericName=Code repository online
Keywords=forms;
Mimeç
Name=GitLab Desktop
StartupNotify=true
StartupWMClass=GitLab
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

presentation_url=https://docs.google.com/presentation/
presentation_icon="https://upload.wikimedia.org/wikipedia/commons/1/16/Google_Slides_2020_Logo.svg"
presentation_alias="alias presentation=\"xdg-open ${presentation_url} &>/dev/null &\""
presentation_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Google Presentation from Chrome
Encoding=UTF-8
GenericName=Document
Keywords=presentations;
MimeType=
Name=Google Presentation
StartupNotify=true
StartupWMClass=Google Presentation
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

document_url=https://docs.google.com/document/
document_icon="https://upload.wikimedia.org/wikipedia/commons/6/66/Google_Docs_2020_Logo.svg"
document_alias="alias document=\"xdg-open ${document_url} &>/dev/null &\""
document_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Google Documents from Chrome
Encoding=UTF-8
GenericName=Document
Keywords=documents;
MimeType=x-
Name=Google Document
StartupNotify=true
StartupWMClass=Google Document
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

spreadsheets_url=https://docs.google.com/spreadsheets/
spreadsheets_icon="https://upload.wikimedia.org/wikipedia/commons/a/ae/Google_Sheets_2020_Logo.svg"
spreadsheets_alias="alias spreadsheets=\"xdg-open ${spreadsheets_url} &>/dev/null &\""
spreadsheets_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Google Spreadsheets from Chrome
Encoding=UTF-8
GenericName=Spreadsheets
Keywords=spreadsheets;
MimeType=
Name=Google Spreadsheets
StartupNotify=true
StartupWMClass=Google Spreadsheets
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

google_chrome_downloader=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
gmail_url=https://mail.google.com/
gmail_icon=https://upload.wikimedia.org/wikipedia/commons/7/7e/Gmail_icon_%282020%29.svg
gmail_alias="alias gmail=\"xdg-open ${gmail_url} &>/dev/null &\""
gmail_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to instant e-mail messaging from Chrome
Encoding=UTF-8
GenericName=Gmail
Keywords=gmail;
MimeType=x-scheme-handler/tg;
Name=Gmail
StartupNotify=true
StartupWMClass=Gmail
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

drive_url=https://drive.google.com/
drive_icon=https://upload.wikimedia.org/wikipedia/commons/1/12/Google_Drive_icon_%282020%29.svg
drive_alias="alias drive=\"xdg-open ${drive_url} &>/dev/null &\""
drive_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to instant e-mail messaging from Chrome
Encoding=UTF-8
GenericName=Gmail
Keywords=drive;
MimeType=
Name=Google Drive
StartupNotify=true
StartupWMClass=Google Drive
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

drive_url=https://drive.google.com/
drive_icon=https://upload.wikimedia.org/wikipedia/commons/1/12/Google_Drive_icon_%282020%29.svg
drive_alias="alias drive=\"xdg-open ${drive_url} &>/dev/null &\""
drive_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to instant e-mail messaging from Chrome
Encoding=UTF-8
GenericName=Gmail
Keywords=drive;
MimeType=x-
Name=Google Drive
StartupNotify=true
StartupWMClass=Google Drive
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

overleaf_icon="https://images.ctfassets.net/nrgyaltdicpt/h9dpHuVys19B1sOAWvbP6/5f8d4c6d051f63e4ba450befd56f9189/ologo_square_colour_light_bg.svg"
overleaf_url=https://www.overleaf.com/
overleaf_alias="alias overleaf=\"xdg-open ${overleaf_url} &>/dev/null &\""
overleaf_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Overleaf online LaTeX editor from Chrome
Encoding=UTF-8
GenericName=Overleaf
Keywords=overleaf;
MimeType=x-
Name=Overleaf
StartupNotify=true
StartupWMClass=Overleaf
#Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

outlook_icon="https://upload.wikimedia.org/wikipedia/commons/d/df/Microsoft_Office_Outlook_%282018%E2%80%93present%29.svg"
outlook_url=https://outlook.live.com
outlook_alias="alias outlook=\"xdg-open ${outlook_url} &>/dev/null &\""
outlook_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to Microsoft Outlook from Chrome
Encoding=UTF-8
GenericName=Outlook
Keywords=outlook;
MimeType=
Name=Outlook
StartupNotify=true
StartupWMClass=Outlook
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"


onedrive_icon="https://upload.wikimedia.org/wikipedia/commons/3/3c/Microsoft_Office_OneDrive_%282019%E2%80%93present%29.svg"
onedrive_url=https://onedrive.live.com/
onedrive_alias="alias onedrive=\"xdg-open${onedrive_url} &>/dev/null &\""
onedrive_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to Microsoft OneDrive from Chrome
Encoding=UTF-8
GenericName=OneDrive
Keywords=onedrive;
MimeType=
Name=OneDrive
StartupNotify=true
StartupWMClass=OneDrive
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

googlecalendar_url=https://calendar.google.com/
googlecalendar_icon="https://upload.wikimedia.org/wikipedia/commons/a/a5/Google_Calendar_icon_%282020%29.svg"
googlecalendar_alias="alias googlecalendar=\"xdg-open ${google-calendar_url} &>/dev/null &\""
googlecalendar_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to Google Calendar from Chrome
Encoding=UTF-8
GenericName=Google Calendar
Keywords=google-calendar;
MimeType=
Name=Google Calendar
StartupNotify=true
StartupWMClass=Google Calendar
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

trello_url="https://trello.com"
trello_icon="https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Antu_trello.svg/512px-Antu_trello.svg.png"
trello_alias="alias trello=\"gxdg-open ${trello_url} &>/dev/null &\""
trello_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to Trello from Chrome
Encoding=UTF-8
GenericName=Google Calendar
Keywords=trello;
MimeType=
Name=Trello
StartupNotify=true
StartupWMClass=Trello
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

twitch_url="https://twitch.tv/"
twitch_icon="http://img1.wikia.nocookie.net/__cb20140727180700/logopedia/images/thumb/8/83/Twitch_icon.svg/500px-Twitch_icon.svg.png"
twitch_alias="alias twitch=\"xdg-open ${twitch_url} &>/dev/null &\""
twitch_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to Twitch from Chrome
Encoding=UTF-8
GenericName=Twitch.tv
Keywords=twitch;Twitch;
MimeType=
Name=Twitch
StartupNotify=true
StartupWMClass=Twitch
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

facebook_url="https://facebook.com/"
facebook_icon="https://upload.wikimedia.org/wikipedia/commons/5/51/Facebook_f_logo_%282019%29.svg"
facebook_alias="alias facebook=\"xdg-open ${facebook_url} &>/dev/null &\""
facebook_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to facebook from Chrome
Encoding=UTF-8
GenericName=Facebook
Keywords=facebook;
MimeType=
Name=Facebook
StartupNotify=true
StartupWMClass=Facebook
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

twitter_url="https://twitter.com/"
twitter_icon="https://upload.wikimedia.org/wikipedia/commons/1/19/Twitter_icon.svg"
twitter_alias="alias twitter=\"xdg-open ${twitter_url} &>/dev/null &\""
twitter_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Twitter from Chrome
Encoding=UTF-8
GenericName=Twitter
Keywords=twitter
Name=Twitter
StartupNotify=true
StartupWMClass=Twitter
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"


instagram_url="https://instagram.com"
instagram_icon="https://upload.wikimedia.org/wikipedia/commons/e/e7/Instagram_logo_2016.svg"
instagram_alias="alias instagram=\"xdg-open ${instagram_url} &>/dev/null &\""
instagram_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Twitter from Chrome
Encoding=UTF-8
GenericName=instagram
Keywords=instagram
MimeType=
Name=Instagram
StartupNotify=true
StartupWMClass=Instagram
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

reddit_url="https://www.reddit.com/"
reddit_icon="https://duckduckgo.com/i/b6b8ccc2.png"
reddit_alias="alias reddit=\"xdg-open ${reddit_url} &>/dev/null &\""
reddit_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Reddit from Chrome
Encoding=UTF-8
GenericName=reddit
Keywords=reddit
Name=Reddit
StartupNotify=true
StartupWMClass=Reddit
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

tumblr_url="https://www.tumblr.com/"
tumblr_icon="https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Tumblr.svg/1200px-Tumblr.svg.png"
tumblr_alias="alias tumblr=\"xdg-open ${tumblr_url} &>/dev/null &\""
tumblr_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Tumblr from Chrome
Encoding=UTF-8
GenericName=tumblr
Keywords=tumblr
Name=Tumblr
StartupNotify=true
StartupWMClass=Tumblr
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

wikipedia_url="https://www.wikipedia.org/"
wikipedia_icon="https://upload.wikimedia.org/wikipedia/commons/2/20/Wikipedia-logo-simple.svg"
wikipedia_alias="alias wikipedia=\"xdg-open ${wikipedia_url} &>/dev/null &\""
wikipedia_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Reddit from Chrome
Encoding=UTF-8
GenericName=reddit
Keywords=wikipedia
Name=Wikipedia
StartupNotify=true
StartupWMClass=Wikipedia
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

duckduckgo_url="https://duckduckgo.com/"
duckduckgo_icon="https://iconape.com/wp-content/png_logo_vector/cib-duckduckgo.png"
duckduckgo_alias="alias duckduckgo=\"xdg-open ${duckduckgo_url} &>/dev/null &\""
duckduckgo_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open DuckDuckGo from Chrome
Encoding=UTF-8
GenericName=DuckDuckGo
Keywords=duckduckgo
Name=DuckDuckGo
StartupNotify=true
StartupWMClass=DuckDuckGo
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

keep_url="https://keep.google.com/"
keep_icon="https://upload.wikimedia.org/wikipedia/commons/b/bd/Google_Keep_icon_%282015-2020%29.svg"
keep_alias="alias keep=\"xdg-open ${keep_url} &>/dev/null &\""
keep_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to Google Keep from Chrome
Encoding=UTF-8
GenericName=Google Calendar
Keywords=google-keep;keep;
MimeType=
Name=Google Keep
StartupNotify=true
StartupWMClass=Google Keep
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

netflix_url=https://www.netflix.com
netflix_icon="https://upload.wikimedia.org/wikipedia/commons/7/75/Netflix_icon.svg"
netflix_alias="alias netflix=\"xdg-open ${netflix_url} &>/dev/null &\""
netflix_launcher="[Desktop Entry]
Categories=Network;VideoStreaming;Film;
Comment=Desktop app to reproduce Netflix from Chrome
Encoding=UTF-8
GenericName=Netflix
Keywords=netflix;
MimeType=
Name=Netflix
StartupNotify=true
StartupWMClass=Netflix
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

gpaint_icon_path=/usr/share/icons/hicolor/scalable/apps/gpaint.svg

ideau_downloader="https://download.jetbrains.com/idea/ideaIU-2020.3.1.tar.gz"
ideau_launcher="[Desktop Entry]
Categories=Development;IDE;
Comment=Capable and Ergonomic IDE for JVM
Encoding=UTF-8
Exec=ideau %f
GenericName=Java programing IDE
Icon=${HOME_FOLDER}/.bin/idea-iu/bin/idea.png
Keywords=IDE;programming;java;dev;
MimeType=
Name=IntelliJ IDEA Ultimate Edition
StartupNotify=true
StartupWMClass=jetbrains-idea
Terminal=false
TryExec=ideau
Type=Application
Version=1.0"
ideau_alias="alias ideau=\"ideau . &>/dev/null &\""

ideac_downloader="https://download.jetbrains.com/idea/ideaIC-2020.3.1.tar.gz"
ideac_launcher="[Desktop Entry]
Categories=Development;IDE;
Comment=Capable and Ergonomic IDE for JVM
Encoding=UTF-8
Exec=ideac %f
GenericName=Java programming IDE
Icon=${HOME_FOLDER}/.bin/idea-ic/bin/idea.png
Keywords=IDE;programming;java;dev;
MimeType=
Name=IntelliJ IDEA Community Edition
StartupNotify=true
StartupWMClass=jetbrains-idea
Terminal=false
TryExec=ideac
Type=Application
Version=13.0"
ideac_alias="alias ideac=\"ideac . &>/dev/null &\""

inkscape_installationtype="packagemanager"
inkscape_packagenames=("inkscape")
inkscape_launchernames=("inkscape")

iqmol_downloader=http://www.iqmol.org/download.php?get=iqmol_2.14.deb
iqmol_icon=http://www.iqmol.org/images/icon.png
iqmol_launcher="[Desktop Entry]
Categories=Visualization;
Comment=Molecule Visualizer
Encoding=UTF-8
Exec=iqmol
GenericName=Molecule visualizer
Icon=${USR_BIN_FOLDER}/iqmol/iqmol_icon.png
Keywords=molecules;chemistry;3d;
MimeType=
Name=IQmol
StartupNotify=true
StartupWMClass=IQmol
Terminal=false
TryExec=iqmol
Type=Application
Version=1.0"
iqmol_alias="alias iqmol=\"iqmol . &>/dev/null &\""

java_downloader="https://javadl.oracle.com/webapps/download/GetFile/1.8.0_281-b09/89d678f2be164786b292527658ca1605/linux-i586/jdk-8u281-linux-x64.tar.gz"
java_globalvar="export JAVA_HOME=\"${USR_BIN_FOLDER}/jdk8\""

l_function="alias l=\"ls -lAh --color=auto\""

libgtkglext1_installationtype="packagemanager"
libgtkglext1_packagenames=("libgtkglext1")

#libxcb-xtest0_installationtype="packagemanager"
#libxcb-xtest0_packagenames=("libxcb-xtest0")

maven_downloader="https://ftp.cixug.es/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz"

megasync_downloader=https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/megasync_4.4.0-1.1_amd64.deb
megasync_integrator_downloader=https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/nemo-megasync_4.0.2_amd64.deb

mendeley_downloader=https://www.mendeley.com/autoupdates/installer/Linux-x64/stable-incoming

music_manager_downloader=https://dl.google.com/linux/direct/google-musicmanager-beta_current_amd64.deb

nautilus_conf=("xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search"
  "gsettings set org.gnome.desktop.background show-desktop-icons true"
  "xdg-mime default org.gnome.Nautilus.desktop inode/directory"
)

nemo_conf=("xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search"
  "gsettings set org.gnome.desktop.background show-desktop-icons false"
  "gsettings set org.nemo.desktop show-desktop-icons true"
)

nemo_desktop_launcher="[Desktop Entry]
Type=Application
Name=Files
Exec=nemo-desktop
OnlyShowIn=GNOME;Unity;
X-Ubuntu-Gettext-Domain=nemo"

#net-tools_installationtype="packagemanager"
#net-tools_packagenames=("net-tools")

notepadqq_installationtype="packagemanager"
notepadqq_packagenames=("notepadqq")
notepadqq_launchernames=("notepadqq")

#obs-studio_installationtype="packagemanager"
#obs-studio_packagenames=("obs-studio")
#obs-studio_launchernames=("com.obsproject.Studio")

okular_installationtype="packagemanager"
okular_packagenames=("okular")
okular_launchernames=("org.kde.okular")

openoffice_downloader="https://downloads.sourceforge.net/project/openofficeorg.mirror/4.1.9/binaries/en-US/Apache_OpenOffice_4.1.9_Linux_x86-64_install-deb_en-US.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fopenofficeorg.mirror%2Ffiles%2F4.1.9%2Fbinaries%2Fen-US%2FApache_OpenOffice_4.1.9_Linux_x86-64_install-deb_en-US.tar.gz%2Fdownload&ts=1614201028"

pacman_installationtype="packagemanager"
pacman_packagenames=("pacman")
pacman_launchernames=("pacman")

parallel_instalationtype="packagemanager"
parallel_packagenames=("parallel")

pdfgrep_installationtype="packagemanager"
pdfgrep_packagenames=("pdfgrep")

pluma_installationtype="packagemanager"
pluma_packagenames=("pluma")
pluma_launchernames=("pluma")

prompt_function="
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z \"\${debian_chroot:-}\" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=\$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we \"want\" color)
case \"\$TERM\" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n \"\$force_color_prompt\" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ \"\$color_prompt\" = yes ]; then
    # Colorful custom PS1
    PS1=\"\\[\\\e[1;37m\\]\\\\\\d \\\\\\\t \\[\\\e[0;32m\\]\\\\\u\[\\\e[4;35m\\]@\\[\\\e[0;36m\\]\\\\\\H\\[\\\e[0;33m\\] \\\\\\w\\[\\\e[0;32m\\] \\\\\\\$ \"
else
    PS1='\${debian_chroot:+(\$debian_chroot)}\u@\h:\w\\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case \"\$TERM\" in
xterm*|rxvt*)
    PS1=\"\$PS1\\[\\\e]0;\${debian_chroot:+(\$debian_chroot)}\u@\h: \w\\\a\]\"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval \"\$(dircolors -b ~/.dircolors)\" || eval \"\$(dircolors -b)\"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


"

pycharm_downloader=https://download.jetbrains.com/python/pycharm-community-2021.1.1.tar.gz
pycharm_launcher="[Desktop Entry]
Actions=NewWindow;
Categories=programming;dev;
Comment=Python IDE Community
Encoding=UTF-8
Exec=pycharm %F
GenericName=Pycharm
Icon=${HOME_FOLDER}/.bin/pycharm-community/bin/pycharm.png
Keywords=dev;programming;python;
MimeType=
Name=PyCharm
StartupNotify=true
StartupWMClass=jetbrains-pycharm
Terminal=false
TryExec=pycharm
Type=Application
Version=1.0

[Desktop Action NewWindow]
Name=Pycharm New Window
Exec=pycharm
Icon=${HOME_FOLDER}/.bin/pycharm-community/bin/pycharm.png"

pycharm_alias="alias pycharm=\"pycharm . &>/dev/null &\""

pycharm_professional_downloader=https://download.jetbrains.com/python/pycharm-professional-2020.3.2.tar.gz

pycharm_professional_launcher="[Desktop Entry]
Categories=programming;dev;
Comment=Python IDE for Professional Developers
Encoding=UTF-8
Exec=pycharm-pro %F
GenericName=Pycharm
Icon=${HOME_FOLDER}/.bin/pycharm-professional/bin/pycharm.png
Keywords=dev;programming;python;
MimeType=
Name=PyCharm Professional
StartupNotify=true
StartupWMClass=jetbrains-pycharm
Terminal=false
TryExec=pycharm-pro
Type=Application
Version=1.0"

pypy3_downloader=https://downloads.python.org/pypy/pypy3.6-v7.3.1-linux64.tar.bz2

s_function="
s()
{
  \"\$@\" &>/dev/null &
}
"

screenshots_function="
alias screenshot-full=\"gnome-screenshot -f ${XDG_PICTURES_DIR}/screenshots/Screenshot-\$(date +%Y-%m-%d-%H:%M:%S).png && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga\"
alias screenshot-window=\"gnome-screenshot -w -f ${XDG_PICTURES_DIR}/screenshots/Screenshot-\$(date +%Y-%m-%d-%H:%M:%S).png && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga\"
alias screenshot-area=\"gnome-screenshot -a -f ${XDG_PICTURES_DIR}/screenshots/Screenshot-\$(date +%Y-%m-%d-%H:%M:%S).png && paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga\"
"

shell_history_optimization_function="
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=100000
export HISTFILESIZE=1000000
# append to the history file, don't overwrite it
shopt -s histappend
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoredups
# Ignore simple commands in history
HISTIGNORE=\"ls:ps:history:l:pwd:top:gitk\"
# The cmdhist shell option, if enabled, causes the shell to attempt to save each line of a multi-line command in the
# same history entry, adding semicolons where necessary to preserve syntactic correctness.
shopt -s cmdhist
# Save and reload from history before prompt appears
export PROMPT_COMMAND=\"history -a; history -r; \${PROMPT_COMMAND}\"
"

shortcut_aliases="export DESK=${XDG_DESKTOP_DIR}
export USR_BIN_FOLDER=${USR_BIN_FOLDER}
"

shotcut_desktop_launcher="[Desktop Entry]
Categories=video;
Comment= Open Source, cross-platform video editor
Encoding=UTF-8
Exec=shotcut
GenericName=shotcut
Icon=/usr/share/icons/hicolor/64x64/apps/org.shotcut.Shotcut.png
Keywords=video;editing;editor;VideoEdit;
MimeType=
Name=Shotcut
StartupNotify=true
StartupWMClass=ShotCut
Terminal=false
TryExec=shotcut
Type=Application
Version=1.0"

skype_installationtype="packageinstall"
skype_packageurl=("https://go.skype.com/skypeforlinux-64.deb")
skype_launchernames=("skypeforlinux")

slack_installationtype="packageinstall"
slack_repository=("https://downloads.slack-edge.com/linux_releases/slack-desktop-4.11.1-amd64.deb")
slack_launchernames=("slack")

spotify_installationtype="packageinstall"
spotify_packageurl=("http://repository.spotify.com/pool/non-free/s/spotify-client/spotify-client_1.1.56.595.g2d2da0de_amd64.deb")
spotify_launchernames=("spotify")

steam_installationtype="packageinstall"
steam_packageurl=("https://steamcdn-a.akamaihd.net/client/installer/steam.deb")
steam_launchernames=("steam")

sublime_text_downloader=https://download.sublimetext.com/sublime_text_3_build_3211_x64.tar.bz2
sublime_alias="alias sublime=\"sublime . &>/dev/null &\""
sublime_text_launcher="[Desktop Entry]
Categories=;
Comment=General Purpose Programming Text Editor
Encoding=UTF-8
Exec=sublime %F
GenericName=Text Editor, programming...
Icon=$HOME/.bin/sublime-text/Icon/256x256/sublime-text.png
Keywords=subl;sublime;
MimeType=
Name=Sublime Text
StartupNotify=true
StartupWMClass=Sublime
Terminal=false
TryExec=sublime
Type=Application
Version=1.0"

sysmontask_downloader="https://github.com/KrispyCamel4u/SysMonTask.git"

teams_installationtype="packageinstall"
teams_packageurl=("https://go.microsoft.com/fwlink/p/?LinkID=2112886&clcid=0x40a&culture=es-es&country=ES")
teams_launchernames=("teams")

telegram_icon=https://telegram.org/img/t_logo.svg?1
telegram_downloader=https://telegram.org/dl/desktop/linux
telegram_launcher="[Desktop Entry]
Categories=Network;
Comment=Instant messaging cross platform
Encoding=UTF-8
Exec=telegram -- %u
GenericName=Telegram
Icon=${USR_BIN_FOLDER}/telegram/telegram.svg
Keywords=telegram;
MimeType=x-scheme-handler/tg;
Name=Telegram
StartupNotify=true
StartupWMClass=Telegram
Terminal=false
TryExec=telegram
Type=Application
Version=1.0"

terminator_installationtype="packagemanager"
terminator_packagenames=("terminator")
terminator_launchernames=("terminator")

thunderbird_installationtype="packagemanager"
thunderbird_packagenames=("thunderbird")
thunderbird_launchernames=("thunderbird")

tilix_installationtype="packagemanager"
tilix_packagenames=("tilix")
tilix_launchernames=("com.gexperts.Tilix")

tmux_launcher="[Desktop Entry]
Categories=Network;
Comment=Terminal Multiplexer
Encoding=UTF-8
Exec=tmux
GenericName=Terminal multiplexor with special mnemo-rules 'Ctrl+a'
Icon=/var/lib/app-info/icons/ubuntu-focal-universe/64x64/carla_carla.png
Keywords=tmux;
MimeType=
Name=tmux
StartupNotify=true
StartupWMClass=tmux
Terminal=true
TryExec=tmux
Type=Application
Version=1.0"

#torbrowser-launcher_installationtype="packagemanager"
#torbrowser-launcher_packagenames=("torbrowser-launcher")
#torbrowser-launcher_launchernames=("torbrowser")

transmission_installationtype="packagemanager"
transmission_packagenames=("transmission")
transmission_launchernames=("transmission-gtk")

virtualbox_downloader=https://download.virtualbox.org/virtualbox/6.1.22/virtualbox-6.1_6.1.22-144080~Ubuntu~eoan_amd64.deb

visualstudiocode_downloader="https://go.microsoft.com/fwlink/?LinkID=620884"
code_alias="alias code=\"code . &>/dev/null &\""
visualstudiocode_launcher="[Desktop Entry]
Categories=Development;IDE;
Comment=Develop with pleasure!
Encoding=UTF-8
Exec=code %f
GenericName=IDE for programming
Icon=${HOME}/.bin/visual-studio/resources/app/resources/linux/code.png
Keywords=code;
MimeType=
Name=Visual Studio Code
StartupNotify=true
StartupWMClass=visual-studio-code
Terminal=false
TryExec=code
Type=Application
Version=1.0"

vlc_installationtype="packagemanager"
vlc_packagenames=("vlc")
vlc_launchernames=("vlc")

wallpapers_downloader=https://github.com/AleixMT/wallpapers
wallpapers_changer_script="#!/bin/bash
if [ -z \${DBUS_SESSION_BUS_ADDRESS+x} ]; then
  user=\$(whoami)
  fl=\$(find /proc -maxdepth 2 -user \$user -name environ -print -quit)
  while [ -z \$(grep -z DBUS_SESSION_BUS_ADDRESS \"\$fl\" | cut -d= -f2- | tr -d '\000' ) ]
  do
    fl=\$(find /proc -maxdepth 2 -user \$user -name environ -newer \"\$fl\" -print -quit)
  done
  export DBUS_SESSION_BUS_ADDRESS=\$(grep -z DBUS_SESSION_BUS_ADDRESS \"\$fl\" | cut -d= -f2-)
fi
DIR=\"${XDG_PICTURES_DIR}/wallpapers\"
PIC=\$(ls \${DIR} | shuf -n1)
dconf write \"/org/gnome/desktop/background/picture-uri\" \"'file://\${DIR}/\${PIC}'\"

#gsettings set org.gnome.desktop.background picture-uri \"'file://\${DIR}/\${PIC}'\"
"
wallpapers_cronjob="*/5 * * * * ${USR_BIN_FOLDER}/wallpaper_changer.sh"

whatsapp_url=https://web.whatsapp.com/
whatsapp_icon="https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg"
whatsapp_alias="alias whatsapp=\"google-chrome ${whatsapp_url} &>/dev/null &\""
whatsapp_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open Whatsapp Web from Chrome
Encoding=UTF-8
Exec=google-chrome ${whatsapp_url}
GenericName=WhatsApp Web
Icon=${USR_BIN_FOLDER}/google-chrome/whatsapp_icon.svg
Keywords=forms;
MimeType=x-scheme-handler/tg;
Name=WhatsApp Web
StartupNotify=true
StartupWMClass=WhatsApp
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

youtube_url=https://youtube.com/
youtube_icon="https://upload.wikimedia.org/wikipedia/commons/4/4f/YouTube_social_white_squircle.svg"
youtube_alias="alias youtube=\"google-chrome ${youtube_url} &>/dev/null &\""
youtube_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open YouTube from Chrome
Encoding=UTF-8
Exec=google-chrome ${youtube_url}
GenericName=YouTube
Icon=${USR_BIN_FOLDER}/google-chrome/youtube_icon.svg
Keywords=forms;
MimeType=x-scheme-handler/tg;
Name=YouTube
StartupNotify=true
StartupWMClass=YouTube
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

youtubemusic_url=https://music.youtube.com
youtubemusic_icon="https://upload.wikimedia.org/wikipedia/commons/6/6a/Youtube_Music_icon.svg"
youtubemusic_alias="alias youtubemusic=\"google-chrome ${youtubemusic_url} &>/dev/null &\""
youtubemusic_launcher="[Desktop Entry]
Categories=Network;
Comment=Desktop app to open YouTube Music from Chrome
Encoding=UTF-8
Exec=google-chrome ${youtubemusic_url}
GenericName=YouTube Music
Icon=${USR_BIN_FOLDER}/google-chrome/youtubemusic_icon.svg
Keywords=forms;
MimeType=x-scheme-handler/tg;
Name=YouTube Music
StartupNotify=true
StartupWMClass=YouTube Music
Terminal=false
TryExec=google-chrome
Type=Application
Version=1.0"

youtubedl_downloader=https://yt-dl.org/downloads/latest/youtube-dl

youtubewav_alias="alias youtubewav=\"youtube-dl --extract-audio --audio-format wav\""

zoom_downloader=https://zoom.us/client/latest/zoom_x86_64.tar.xz
zoom_icon_downloader="https://play-lh.googleusercontent.com/JgU6AIREDMsGLmrFSJ8OwLb-JJVw_jwqdwEZWUHemAj0V5Dl7i7GOpmranv2GsCKobM"
zoom_launcher="[Desktop Entry]
Categories=Social;Communication;
Comment=Live Video Streaming for Meetings
Encoding=UTF-8
GenericName=Video multiple calls
Icon=${USR_BIN_FOLDER}/zoom/zoom_icon.ico
Keywords=Social;VideoCalls;
MimeType=
Name=Zoom
StartupNotify=true
StartupWMClass=zoom
Terminal=false
TryExec=ZoomLauncher
Type=Application
Version=1.0"


###########################
##### SYSTEM FEATURES #####
###########################

### SYSTEM FEATURE RELATED VARIABLES ###

converters_downloader="https://github.com/Axlfc/converters"
converters_functions="bintooct()
{
  to \$1 2 3
}
bintoocto()
{
  to \$1 2 8
}
bintodec()
{
  to \$1 2 10
}
bintohex()
{
  to \$1 2 16
}

octtobin()
{
  to \$1 3 2
}
octtoocto()
{
  to \$1 3 8
}
octtodec()
{
  to \$1 3 10
}
octohex()
{
  to \$1 3 16
}

octotobin()
{
  to \$1 8 2
}
octotooct()
{
  to \$1 8 3
}
octotodec()
{
  to \$1 8 10
}
octotohex()
{
  to \$1 8 16
}

dectobin()
{
  to \$1 10 2
}
dectooct()
{
  to \$1 10 3
}
dectoocto()
{
  to \$1 10 8
}
dectohex()
{
  to \$1 10 16
}

hextobin()
{
  to \$1 16 2
}
hextooct()
{
  to \$1 16 3
}
hextoocto()
{
  to \$1 16 8
}
hextodec()
{
  to \$1 16 10
}"

ipe_function="
ipe()
{
  dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'\"' '{ print \$2 }';
}
"

extract_function="

  # Function that allows to extract any type of compressed files
  extract () {
    if [ -f \$1 ] ; then
      case \$1 in
        *.tar.bz2)   tar xjf \$1        ;;
        *.tar.gz)    tar xzf \$1     ;;
        *.bz2)       bunzip2 \$1       ;;
        *.rar)       rar x \$1     ;;
        *.gz)        gunzip \$1     ;;
        *.tar)       tar xf \$1        ;;
        *.tbz2)      tar xjf \$1      ;;
        *.tgz)       tar xzf \$1       ;;
        *.zip)       unzip \$1     ;;
        *.Z)         uncompress \$1  ;;
        *.7z)        7z x \$1    ;;
        *)           echo \"'\$1' cannot be extracted via extract()\" ;;
      esac
    else
        echo \"'\$1' is not a valid file\"
    fi
  }"

L_function="

L()
{
  NEW_LINE=\$'\\\n'
  lsdisplay=\$(ls -lhA | tr -s \" \" | tail -n+2)
  numfiles=\$(printf \"\$lsdisplay\" | wc -l)
  dudisplay=\$(du -shxc .[!.]* * | sort -h | tr -s \"\\\t\" \" \")
  totaldu=\$(echo \${dudisplay} | rev | cut -d \" \" -f2 | rev)
  finaldisplay=\"\${totaldu} in \${numfiles} files and directories\$NEW_LINE\"
  IFS=\$'\\\n'
  for linels in \${lsdisplay}; do
    if [[ \$linels =~ ^d.* ]]; then
      foldername=\$(echo \$linels | cut -d ' ' -f9-)
      for linedu in \${dudisplay}; do
        if [[ \"\$(echo \${linedu} | cut -d ' ' -f2-)\" = \"\${foldername}\" ]]; then
          currentline=\$(echo \${linels} | cut -d \" \" -f-4)
          currentline=\"\$currentline \$(echo \${linedu} | cut -d ' ' -f1)\"
          currentline=\"\$currentline \$(echo \${linels} | cut -d ' ' -f6-)\"
          finaldisplay=\"\$finaldisplay\$NEW_LINE\$currentline\"
          break
        fi
      done
    else
      finaldisplay=\"\$finaldisplay\$NEW_LINE\$linels\"
    fi
  done
  finaldisplay=\"\${finaldisplay}\$NEW_LINE\$NEW_LINE\"
  printf \"\$finaldisplay\"
}
"

### TEMPLATES ###

c_file_template="########################################################################################################################
# -Name:
# -Description:
# -Creation Date:
# -Last Revision:
# -Author:
# -Email:
# -Permissions:
# -Args:
# -Usage:
# -License:
########################################################################################################################


#include \"c_script.h\"


int main(int nargs, char* args[])
{
  printf(\"Hello World\");
}
"

c_header_file_template="// Includes
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
"

makefile_file_template="CC = gcc
CFLAGS = -O3 -Wall

all : c_script

c_script : c_script.c
	\$(CC) \$(CFLAGS) c_script.c -o c_script -lm

run : c_script
	./c_script

.PHONY : clean
clean :
	rm -f c_script
"

python_file_template="#!/usr/bin/env python3
# -*- coding: utf-8 -*-
########################################################################################################################
# -Name:
# -Description:
# -Creation Date:
# -Last Revision:
# -Author:
# -Email:
# -Permissions:
# -Args:
# -Usage:
# -License:
########################################################################################################################


if __name__ == \"__main__\":
    print(\"HELLO WORLD!\")
    exit(0)
"

bash_file_template="#!/usr/bin/env bash

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
  echo \"Hello World\"
  exit 0
}

set -e
main \"\$@\""

latex_file_template="%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2345678901234567890123456789012345678901234567890123456789012345678901234567890
%        1         2         3         4         5         6         7         8
\documentclass[11pt]{article}

% Use helvetica font (similar to Arial)
\renewcommand{\familydefault}{\sfdefault}
\usepackage[scaled=1]{helvet}

% Don't include Table of Contents (ToC) in ToC
% Don't include List of Figures (LoF) in ToC
% Don't include List of Tables (LoT) in ToC
% Include bibliography in ToC with its own section number
\usepackage[nottoc, notlot, notlof, numbib]{tocbibind}

% //W: Kept because error if these commands are removed
\title{}
\date{}
\author{}

\begin{document}


% Title Page
\begin{titlepage}
\centering
%\includegraphics[width=0.5\textwidth]{imgs/logourv}  % Logo
\par
\vspace{1cm}
\Large
{An exemple document of LaTeX\par}
\vspace{1cm}
{John Doe \par}
\vspace{1cm}
{\itshape\Large LaTeX FINAL PROJECT \par}
\vfill

\vspace{1cm}
%\includegraphics[width=0.7\textwidth]{imgs/grafportada}  % Portada Imagen
\par
\vspace{1cm}
\vfill

\large
\raggedright
{Tutor and supervisor: Jane Doe, UL, (jane.doe@LaTeX.cat) \par}
{In cooperation with: LaTeX and Friends \par}
\vspace{2cm}

\raggedleft
\large
November 2020
\par
\end{titlepage}

% Dont number the title page
\pagenumbering{gobble}

% Rest of the document
\setlength{\parskip}{1em}  % Set vertical separation between paragraphs
%\onehalfspacing  % spacing 1.5
\normalsize  % //Spec: normalsize = 11 pt (declared at e headers)

% Resumen (Abstract)
\newpage
\section*{Abstract}  % Use the * to not include section in ToC
  We try to explain a basic example of LaTeX. We will include ToC and references.

% Index (ToC)
\newpage
\setlength{\parskip}{0em}  % Set vertical separation = 0 between paragraphs in the index
\tableofcontents
\newpage

\setlength{\parskip}{1em}  % Set vertical separation between paragraphs for the rest of the doc
%\onehalfspacing  % //Spec: spacing 1.5

% First Section
\pagenumbering{arabic}  % Start numbering in the intro, not in the title or abstract page
\section{Hello World!}
  Hello World!

% Second Section
\section{Advanced Hello World}
  Hello, World. Basic LaTeX Operations:
  \subsection{Itemizes}
    \begin{itemize}
      \item One thing.
      \item Two things.
      \item Last
    \end{itemize}
  \subsection{Enumerates}
    \begin{enumerate}
      \item First thing
      \item Second thing
      \item Third thing \textbf{and last!}
    \end{enumerate}
  \subsection{References}
    We can use \cite{Doe20} to cite, but the same happens citing \cite{Doe19}.

% Bibliography
\newpage
\begin{thebibliography}{0}
\bibitem{Doe20} Doe, J., Martínez A. (2020). How to LaTeX with Linux Auto Customizer. University of Computing, Girona, Spain
\bibitem{Doe19} Doe, J., Priyatniva, A. \& Solanas, A. (2019). Referencing in LaTeX, 10th International Conference on Information, Intelligence, Systems and Applications. https://doi.org/20.1105/IISO.2019.8903718
\end{thebibliography}

\end{document}

"
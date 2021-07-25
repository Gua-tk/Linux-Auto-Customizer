# TO-DO install.sh, install core and common core v1.0

#### CORE CODE NEW FEATURES AND UPDATES

###### UPDATES
- [ ] `functions_install`: put nice color to wget bar in download
- [ ] `functions_install`: Continue previous installation with wget.
- [ ] `functions_install.sh`, `functions_uninstall.sh`, `functions_common.sh`: Create headers and comments in auxiliary functions
- [ ] `functions_common.sh`, `table.md`: Remove spaces for help table
- [ ] `common_data.md`: (for the --help) In the master table, put the extensions .c, .h, etc in bold or put it in another field, so they are not between literal tildes. In that way, they are not recognized in the help.
- [ ] `functions_common.sh`: (for the --help) in autogen help trim spaces in columns
- [ ] `functions_install.sh`: Headers of the generic install mini-functions.

###### NEW FEATURES
- [ ] `install.sh`: Reload `bash` env at the end of install must not need to run bash command, instead use hash -r or similar strategy, also reload font cache
- [ ] `install.sh`: Move favorites subsystem and keybinding subsystem initializations to `~/.profile`, so it is not executed each time we create a terminal. --> Create another variable type for indirect expansion for features in .profile 
- [ ] `install.sh`, `uninstall.sh`: Program traps to intercept signals and respond against them. Show a warning when trying to stop a process in the middle of a critical operation like apt-get or dpkg.
- [ ] `install.sh`, `uninstall.sh`: Add npm packagemanager installationtype
- [ ] `install.sh`, `uninstall.sh`, `customizer.sh`: [Autocompletion features](https://stuff-things.net/2016/05/11/bash-autocompletion/#:~:text=BASH%20autocompletion%20is%20a%20system,to%20complete%20filenames%20and%20paths.&text=You%20can%20override%20this%20behavior,a%20list%20of%20possible%20completions)
- [ ] `data_common.sh`, `install.sh`: Fusion key of permissions + installationtype in `data_common.sh` table to generify the permissions of the installation.
- [ ] `functions_install.sh`: When installing features using package manager in  (by default `apt-get`) it will try to install them with different package managers (`apt-get`, `yum`, `pacman`, `pkg`...) depending on which is the main package-manager

#### NEW INSTALLATIONS AND INSTALLATION UPDATES

###### UPDATES
- [ ] `data_features.sh`: ttf-mscorefonts-installer autoaccept end user agreement or goes out
- [ ] `data_features.sh`: in rsync installation # alias rs="rsync -av --progress"
- [ ] `data_features.sh`: validate `promptcolors` function. Write custom color codes of gnome-terminal profile through gsettings or similar
- [ ] `data_features.sh`, `data_common.sh`: Migrate initialization commands from .bashrc to .profile redefining a bash_functions to a bash_profilefunctions, so they are installed in .profile. Define auxiliar var for that PATH
- [ ] `data_features.sh`: Use nohup in aliases to prevent closing of feature when a process finish if a hanging terminal is closed
- [ ] `data_features.sh`: Add alias \`&\` to notepadqq, and furthermore
- [ ] `data_features.sh`: Colors palette of default profile from terminal function (fonts lookalike)
- [~] `data_features.sh`: `L` function columns, also the alias alias totalusage="df -hl --total | grep total" can be rewritted as an alias or case `L /` of L because it uses du
- [ ] `data_features.sh`: refactor extract function: more robustness and error handling. decompress in a folder
- [ ] `install.sh`: May be possible to achieve a post configuration install to nemo-desktop ? to add some customization such as the rendering thumbnails of images depending on the size
- [ ] `data_features.sh`: All features must be standarized to the default name and format of the variables for indirect expansion.
- [ ] `install.sh`: All manual features in `install.sh` should use the installationtype `environmental` and use the generic_install to get rid of common parts of the code. 
- [ ] `README.md`: Add badges `README.md` using codecov or another code analysis service.
- [ ] `USR_BIN_FOLDER`: There should be no files in USR_BIN_FOLDER. features such as wallpapers, youtube-dl or cheat have to be moved
- [ ] `common_data.sh`: Add alias to change-bg alias chwp="change-bg" `(from customizer)`
- [ ] `data_features.sh`: in net-tools installation: alias ports="netstat -tulanp" # alias nr="net-restart"
- [ ] `data_features.sh`: Search for a new version of caffeine or do the modifications in the actual version, but do not apply a patch #  wget -O - https://gist.githubusercontent.com/syneart/aa8f2f27a103a7f1e1812329fa192e65/raw/caffeine-indicator.patch | patch /usr/bin/caffeine-indicator
- [ ] `data_features.sh`: restore clonezilla which has been lost in combat clonezilla_launcher="[Desktop Entry] Categories=backup;images;restoration;boot;  Comment=Create bootable clonezilla images Encoding=UTF-8  Exec=sudo clonezilla  GenericName=Disk image utility  Icon=/usr/share/gdm/themes/drbl-gdm/clonezilla/ocslogo-1.png  Keywords=clonezilla;CloneZilla;iso  MimeType=  Name=CloneZilla  StartupNotify=true  StartupWMClass=CloneZilla  Terminal=true  TryExec=clonezilla  Type=Application  Version=1.0"   "--clonezilla|--CloneZilla|--cloneZilla;1;| CloneZilla | Disk cloning, disk imaging, data recovery, and deployment | Command \`clonezilla\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | "
- [ ] `install.sh`: register openoffice file associations
- [ ] `screenshots`: Screenshot is temporarily saved in clipboard for `paste` in addition to saving the image at `Images/screenshots`

###### NEW FEATURES
- [~] `data_features.sh`, `common_data.sh`: Add new installation `install_fastcommands` to install aliases - alias rip="sudo shutdown -h now - alias update="sudo apt-get update -y" - alias upgrade="sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get -y autoclean && sudo apt-get -y autoremove" - alias services="sudo systemctl --type=service" - alias cls="clear" alias bi=\"sudo apt --fix-broken install\"
- [ ] `data_features.sh`, `common_data.sh`: `clean` performs different automatic optimizations to release space and delete cluttering such as broken links or broken installations (?) # alias autolclean="sudo apt-get -y autoclean && sudo apt-get -y autoremove"  alias trash="rm -rf ${HOME}/.local/share/Trash/*"
- [ ] `data_features.sh`, `common_data.sh`: `search` function. Searches a therm in a file, a directory or in file names. It has many fallbacks. lg: ls | grep "$1"  fn: "find . -name"
- [ ] `data_features.sh`, `common_data.sh`: `port` function. It returns the name and PID of a process using the given port #  "lsof -i $1"  alias ports="lsof -Pan -i tcp -i udp"
- [ ] `data_features.sh`, `common_data.sh`: `edit` functions. It edits a system or user configuration file by passing the argument of the name. By default with no parameters it should edit .bashrc.  alias editbashrc="editor ${HOME}/.bashrc"  alias editprofile="editor ${HOME}/.profile" alias editfunctions="editor ${HOME}/.bash_functions" sshConfig="pluma ${HOME}/.ssh/config" also edit shortcuts.sh if present, edit fastcommands if present etc. whatever it is interesting 
- [ ] `data_features.sh`: Screenshots Keyboard combination set to the same as for windows or similar (Windows+Shift+s) --> create to function to install custom keyboard shortcut combinations
- [ ] `data_features.sh`, `common_data.sh`: rewrite k as function: #alias k9="kill -9"# alias killbyport="k9 \`lsof -i:3000 -t\`"
- [ ] `data_features.sh`: k function for killing process  --k;0;| Function \`k\` | \`Function for killing processes kill -9\` | Command \`k\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
- [ ] `CONTRIBUTING.md`: Write down the command dependencies of the different features. 
- [ ] `data_features.sh`: Create or integrate loc function bash feature which displays the lines of code of a script
- [ ] `data_features.sh`: Flatten function, which narrows branches of the file system by deleting a folder that contains only another folder.
- [ ] `install.sh`: Add VBox extension pack
- [ ] `install.sh`: SublimeText-Markdown, & other plugins for programs...
- [ ] `install.sh`, `uninstall.sh`: nautilus
- [ ] `install.sh`, `uninstall.sh`, `common_data`: ssh server: alias sshDisable="sudo systemctl disable sshd", alias sshEnable="sudo systemctl enable ssh", alias sshRestart="sudo systemctl restart sshd", alias sshStart="sudo systemctl start sshd", alias sshStatus="sudo systemctl status sshd", alias sshStop="sudo systemctl stop sshd"  
- [ ] `install.sh`, `uninstall.sh`, `common_data`: ssh client
- [ ] `install.sh`, `uninstall.sh`: Cinebench
- [ ] `install.sh`, `uninstall.sh`: fdups (duplicate finder CLI)
- [ ] `install.sh`, `uninstall.sh`: Remmina (desktop access)
- [ ] `install.sh`, `uninstall.sh`: TeamViewer
- [ ] `install.sh`, `uninstall.sh`: codeblocks
- [ ] `install.sh`, `uninstall.sh`: handbrake (format editing tool)
- [ ] `install.sh`, `uninstall.sh`: brasero (cd/dvd burning)
- [ ] `install.sh`, `uninstall.sh`: Axel (download manager)
- [ ] `install.sh`, `uninstall.sh`: HardInfo (Benchmark tool)
- [ ] `install.sh`, `uninstall.sh`: Dbeaver Community (database manager)
- [ ] `install.sh`, `uninstall.sh`: ghostwriter (text editor for markdown and others with html preview)
- [ ] `install.sh`, `uninstall.sh`: jshell (apt-get install default-jdk)
- [ ] `install.sh`, `uninstall.sh`: Search in wikipedia from terminal # alias wiki="wikit" # npm install wikit -g
- [ ] `install.sh`, `uninstall.sh`: `Google`/`translator` internet shortcut launcher and value possibility to use w3m to navigate internet through console and see images there with w3m-img.
- [ ] `git functions`: Git ammend lets you change the message for previous commit; research about changing git commit message after push for git associated functions creation. 
- [ ] `install.sh`, `uninstall.sh`: Mdadm (raid manager)
- [ ] `install.sh`, `uninstall.sh`: matlab (add matlab template)
- [ ] `install.sh`, `uninstall.sh`: CMake https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2.tar.gz
- [ ] `install.sh`, `uninstall.sh`: sherlock
- [ ] `install.sh`, `uninstall.sh`: rosegarden (music edition)
- [ ] `install.sh`, `uninstall.sh`: Ardour (music edition)
- [ ] `install.sh`, `uninstall.sh`: LMMS (music edition)
- [ ] `install.sh`, `uninstall.sh`: guake (terminal at F12 key)
- [ ] `install.sh`, `uninstall.sh`: Remastersys (iso customization)
- [ ] `install.sh`, `uninstall.sh`: UNetbootin (iso customization)
- [ ] `install.sh`, `uninstall.sh`: Blender3D (image edition)
- [ ] `install.sh`, `uninstall.sh`: Agave #sudo apt-get install -y agave 
- [ ] `install.sh`, `uninstall.sh`: aircrack-ng
- [ ] `install.sh`, `uninstall.sh`: nmap
- [ ] `install.sh`, `uninstall.sh`: netcat
- [ ] `install.sh`, `uninstall.sh`: gobuster
- [ ] `install.sh`, `uninstall.sh`: zenmap (nmap gui) (virtual environment)
- [ ] `install.sh`, `uninstall.sh`: metasploit (https://apt.metasploit.com/)
- [ ] `data_features.sh`: Rstudio split libssl-dev dependency 
- [ ] `data_features.sh`: split pgadmin_packagedependencies=("libgmp3-dev" "libpq-dev" "libapache2-mod-wsgi-py3")  # //RF not used

# TO-DO uninstall.sh and uninstall core for v1.0

###### UPDATES
- [ ] `functions_common.sh`, `uninstall.sh`: Show warning in uninstall when activating -o flag

###### NEW FEATURES
- [ ] `uninstall.sh`: Rewrite `uninstall.sh` using generic_uninstall to uninstall the features.
- [ ] `uninstall.sh`: OpenOffice apt-get remove -y libreoffice-base-core libreoffice-impress libreoffice-calc libreoffice-math libreoffice-common libreoffice-ogltrans libreoffice-core libreoffice-pdfimport libreoffice-draw libreoffice-style-breeze libreoffice-gnome libreoffice-style-colibre libreoffice-gtk3 libreoffice-style-elementary libreoffice-help-common libreoffice-style-tango libreoffice-help-en-us libreoffice-writer


# TO-DO customizer.sh and final endpoint for v1.0
Have to be completed after (AFTER!) having all the auxiliar structures into v1.0 of uninstall / install (root functions are already in this point):

###### UPDATES
. [ ] `install.sh`, `customizer.sh`: Install & Uninstall Customizerself installation #FUNCTION alias Install="sudo apt-get install -y" alias `CUSTOMIZER`= `cd ...?` ...
- [ ] `customizer.sh`, `common_data.sh`: Move high-level wrappers from `install.sh` for a set of features, such as "minimal", "custom", "git_customization" etc. in this new endpoint associate all the features that are needed such as sudo install Nemo and sudo uninstall nautilus

###### NEW FEATURES
- [ ] `customizer.sh`: If an argument is provided but not recognized, customizer will try luck by using apt-get to install it --> parametrize the use of package manager
- [ ] `testing.sh`: Tries a batch of functions to install and uninstall each feature and checks that the behaviour is the correct.
- [ ] `customizer.sh`: Create a unique endpoint for all the code in customizer `customizer.sh` which accepts the arguments install uninstall for the recognized features and make the corresponding calls to sudo uninstall.sh ..., sudo install.sh ... And Install.sh ...
- [ ] `customizer.sh`: customizer.sh help, customizer install, customizer uninstall, customizer parallel, customizer status... basic commands


### TO-DO v2.0
- [ ] Creation of \`customizer.py\`file as an alternative endpoint for customizer.sh. We can use it to give to it a graphical interface

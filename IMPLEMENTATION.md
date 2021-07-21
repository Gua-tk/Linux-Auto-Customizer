## Assigned features
##### Aleix
- [x] `functions_install.sh`: create user generic install
- [x] `data_features.sh`: Create high level functions that perform variable indirect expansion to install different types of program.
- [x] `install.sh`, `uninstall.sh`: New argument in install.sh add to favorites -f / -n normal installation without favorites(?) also complementary flag in uninstall.sh
- [ ] `functions_common.sh`: in autogen help trim spaces in columns
- [ ] `USR_BIN_FOLDER`: There should be no files in USR_BIN_FOLDER. features such as wallpapers, youtube-dl or cheat have to be moved

##### Axel
- [~] `data_features.sh`: validate `promptcolors` function. Write custom color codes of gnome-terminal profile through gsettings or similar
- [ ] `data_features.sh`, `install.sh`, `uninstall.sh`: create bash functions that defines all the color schemes and styles in bash, storing the format in variables like RED="\e0]", BLUE="\e0", BOLD="...",  so you can `echo "${RED}${BOLD} This text is in red and bold"`
- [ ] `README.md`: Add badges `README.md` using codecov or another code analysis service.
- [ ] `data_features.sh`: Screenshots Keyboard combination set to the same as for windows or similar (Windows+Shift+s) --> create to function to install custom keyboard shortcut combinations
- [ ] `common_data.md`: In the table, put the extensions .c, .h, etc in bold or put it in another field, so they are not between literal tildes. In that way, they are not recognized in the help.
- [~] `install.sh`, `uninstall.sh`: Add most significative asix2Atesting aliases & end conflicts with Up-to-Date Customizer & Linux-System duplication;
    - function x: `(extract)`
    - function lg: ls | grep "$1"
    - function port: "lsof -i $1"
    - function fn: "find . -name"
    - function `e` performs an echo if $1 is a string text
    - alias clean="sudo apt-get -y autoclean && sudo apt-get -y autoremove"
    - alias shut="shutdown -h now"
    - alias update="sudo apt-get update -y && sudo apt-get upgrade -y"
    - alias upgrade="sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get -y autoclean && sudo apt-get -y autoremove"
    - alias trash="rm -rf ${HOME}/.local/share/Trash/*"
    - alias serv="sudo systemctl --type=service"
    - alias timer="sudo systemctl -t timer"
    - alias totalusage="df -hl --total | grep total"
    - alias uf="sudo systemctl list-unit-files"
    - alias editbashrc="pluma ${HOME}/.bashrc"
    - alias editprofile="pluma ${HOME}/.profile"
    - alias ports="lsof -Pan -i tcp -i udp"
    - alias rs="rsync -av --progress"
    - alias cwp="change-bg" `(from customizer)`
    - alias r="make run"
    - `(adapt to bash features)`: alias editfunctions="pluma ${HOME}/.bash_functions"
    - `(goes to net-tools)`: alias ports="netstat -tulanp" # alias nr="net-restart"
    - `install.sh`, `uninstall.sh`: Cinebench
    - alias sshConfig="pluma ${HOME}/.ssh/config"
    - alias sshDisable="sudo systemctl disable sshd"
    - alias sshEnable="sudo systemctl enable ssh"
    - alias sshRestart="sudo systemctl restart sshd"
    - alias sshStart="sudo systemctl start sshd"
    - alias sshStatus="sudo systemctl status sshd"
    - alias sshStop="sudo systemctl stop sshd"
  

Have to be completed after (AFTER!) having all the auxiliar structures into v1.0 of uninstall / install (root functions are already in this point):
- [ ] `install.sh`: nautilus
- [ ] `install.sh`: fdups  (duplicate finder CLI)
- [ ] `install.sh`: Remmina, TeamViewer: desktop access
- [ ] `install.sh`: codeblocks
- [ ] `install.sh`: handbrake: format editing tool
- [ ] `install.sh`: brasero: cd/dvd burning
- [ ] `install.sh`: Axel: download manager
- [ ] `install.sh`: HardInfo (Benchmark tool)
- [ ] `install.sh`: Dbeaver Community (database manager)
- [ ] `install.sh`: ghostwriter (text editor for markdown and others with html preview)
- [ ] `install.sh`: jshell (apt-get install default-jdk)
- [ ] `install.sh`: check program matching
- [ ] `install.sh`, `uninstall.sh`: Search in wikipedia from terminal # alias wiki="wikit" # npm install wikit -g
- [ ] `install.sh`, `uninstall.sh`: Mdadm (raid manager) blkid (filesystems that has UUID are displayed) lsblk, fstab (lists all available disk partitions) `/etc/fstab`
- [ ] `install.sh`, `uninstall.sh`: matlab
- [ ] `install.sh`, `uninstall.sh`: CMake https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2.tar.gz
- [ ] `install.sh`, `uninstall.sh`: sherlock
- [ ] `install.sh`, `uninstall.sh`: music edition: rosegarden, Ardour, LMMS
- [ ] `install.sh`, `uninstall.sh`: terminal at F12 key: guake
- [ ] `install.sh`, `uninstall.sh`: iso customization: Remastersys, UNetbootin
- [ ] `install.sh`, `uninstall.sh`: image edition: Blender3D, Agave (sudo apt-get install -y agave)
- [ ] `install.sh`, `uninstall.sh`: aircrack-ng
- [ ] `install.sh`, `uninstall.sh`: nmap
- [ ] `install.sh`, `uninstall.sh`: ncat (netcat)
- [ ] `install.sh`, `uninstall.sh`: gobuster
- [ ] `install.sh`, `uninstall.sh`: zenmap (nmap gui) (virtual environment)
- [ ] `install.sh`, `uninstall.sh`: metasploit (https://apt.metasploit.com/)


# TO-DO v1.0

## NEW FEATURES

#### BASE CODE NEW FEATURES AND UPDATES

###### UPDATES
- [ ] `functions_install.sh`, `functions_uninstall.sh`, `functions_common.sh`: Create headers and comments in auxiliary functions
- [ ] `install.sh`, `data_fatures.sh`: Refactor functions of root to use the generic_install function. AutoFirma, OpenOffice, nemo, WireShark, gpaint, iqmol, remaining among others
- [ ] `functions_common.sh`, `table.md`: Remove spaces for help table

###### NEW FEATURES
- [ ] `data_features.sh`, `functions_common.sh`: Manage autostart in generic install: autostarting programs (`caffeine`, `copyq`... ) steam? teams? teamviewer?
- [ ] Reload `bash` env at the end of install must not need to run bash command, instead use hash -r or similar strategy
- [ ] `install.sh`: Move favorites subsystem to `~/.profile`, so it is not executed each time we create a terminal. --> Create another variable type for indirect expansion for features in bashrc
- [ ] `install.sh`, `uninstall.sh`: Program traps to intercept signals and respond against them. Show a warning when trying to stop a process in the middle of a critical operation like apt-get or dpkg.
- [~] `install.sh`, `uninstall.sh`: npm and nodejs (packagemanager installationtype)
- [ ] `install.sh`, `uninstall.sh`, `customizer.sh`: [Autocompletion features](https://stuff-things.net/2016/05/11/bash-autocompletion/#:~:text=BASH%20autocompletion%20is%20a%20system,to%20complete%20filenames%20and%20paths.&text=You%20can%20override%20this%20behavior,a%20list%20of%20possible%20completions)


#### NEW INSTALLATIONS AND INSTALLATION UPDATES

###### UPDATES
- [ ] `data_features.sh`, `data_common.sh`: Migrate initialization commands from .bashrc to .profile redefining a bash_functions to a bash_profilefunctions, so they are installed in .profile. Define auxiliar var for that PATH
- [ ] `data_features.sh`: Use nohub in aliases to prevent closing of feature when a process finish if a hanging terminal is closed
- [ ] `data_features.sh`: Add alias \`&\` to notepadqq, and furthermore
- [ ] `data_features.sh`: Colors palette of default profile from terminal function (fonts lookalike)
- [~] `data_features.sh`: `L` function columns
- [ ] `data_features.sh`: `e` convert to edit and echo function

###### NEW FEATURES
- [ ] `data_features.sh`, `common_data.sh`: rewrite k as function: #alias k9="kill -9"# alias killbyport="k9 \`lsof -i:3000 -t\`"
- [ ] `CONTRIBUTING.md`: Write down the command dependencies of the folder project
- [ ] `data_features.sh`: Create or integrate loc function bash feature which displays the lines of code of a script
- [ ] `data_features.sh`: Flatten function, which narrows branches of the file system by deleting a folder that contains only another folder.

#### MAINTENANCE & UPDATES
- [ ] `data_common.sh`, `install.sh`: Fusion key of permissions + installationtype in `data_common.sh` table to
- [ ] `uninstall.sh`: Show warning in uninstall when activating -o flag
- [ ] `uninstall.sh`: Rewrite `uninstall.sh` functions using the new auxiliary functions, structures, variables
- [ ] `install.sh`: refactor extract function: more robustness and error handling. decompress in a folder

### TO-DO v2.0
- [ ] May be possible to achieve a post configuration install to nemo-desktop ? to add some customization such as the rendering thumbnails of images depending on the size
- [ ] SublimeText-Markdown, & other plugins for programs...
- [ ] Creation of \`customizer.py\`file
- [ ] `install.sh`: Add VBox extension pack
. [ ] `install.sh`, `customizer.sh`: Install & Uninstall Customizerself installation #FUNCTION alias Install="sudo apt-get install -y" alias `CUSTOMIZER`= `cd ...?` ...
- [ ] `customizer.sh`: When having this unique endpoint, if an argument is provided but not recognized, customizer will try luck by using apt-get to install it --> parametrize the use of package manager
- [ ] `customizer.sh`: When installing features using package manager (by default `apt-get`) it will try to install them with different package managers (`apt-get`, `yum`, `pacman`, `pkg`...) depending on which system customizer is run
- [ ] `customizer.sh`: Create a unique endpoint for all the code in customizer `customizer.sh` which accepts the arguments install uninstall for the recognized features and make the corresponding calls to sudo uninstall.sh ..., sudo install.sh ... And Install.sh ...
- [ ] `customizer.sh`: Move high-level wrappers from `install.sh` for a set of features, such as "minimal", "custom", "git_customization" etc. in this new endpoint associate all the features that are needed such as sudo install Nemo and sudo uninstall nautilus
- [ ] `customizer.sh`: customizer.sh help, customizer install, customizer uninstall, customizer parallel, customizer status... basic commands
- [ ] `customizer.sh`: Automated Unit Testing


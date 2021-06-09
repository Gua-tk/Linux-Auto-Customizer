## Assigned features
##### Aleix
- [~] `functions_install.sh`: create user generic install
- [~] `functions_install.sh`: Make download() and decompress() handle relative paths as paths from USR_BIN_FOLDER. if not absolute
- [~] `data_features.sh`: Create high level functions that perform variable indirect expansion to install different types of program.
- [ ] `install.sh`, `uninstall.sh`: New argument in install.sh add to favourites -f / -n normal installation without favourites(?) also complementary flag in uninstall.sh
- [ ] `install.sh`: Move favourites subsystem to ~.profile, so it is not executed each time we create a terminal.
- [ ] `functions_common.sh`: in autogen help trim spaces in columns
- [ ] `USR_BIN_FOLDER`: There should be no files in USR_BIN_FOLDER. features such as wallpapers or cheat have to be moved

##### Axel
- [~] `data_features.sh`: validate `promptcolors` function. Write custom color codes of gnome-terminal profile through gsettings or similar
- [ ] `common_data.sh`: Change ALL the bash function such b, alert, c, dummycommit, etc. that adds new behaviour to the shell to begin with the same name, like "Function b" or "Bash Feature `b` ", so they get sorted in the same place when calling autogenreadme
- [ ] `README.md`: Add badges `README.md` using codecov or another code analysis service.
- [ ] `data_features.sh`, `install.sh`, `uninstall.sh`: create bash functions that defines all the color schemes and styles in bash, storing the format in variables like RED="\e0]", BLUE="\e0", BOLD="...",  so you can `echo "${RED}${BOLD} This text is in red and bold"`
- [ ] Research: Manually add Keyboard shortcuts function for pycharm. Describe the exact process, in order to parametrize and create a func that does it for any program
- [ ] `data_features.sh`: Screenshots Keyboard combination set to the same as for windows or similar (Windows+Shift+s) --> create to function to install custom keyboard shortcut combinations
- [ ] `common_data.md`: In the table, put the extensions .c, .h, etc in bold or put it in another field, so they are not between literal tildes. In that way, they are not recognized in the help.
- [ ] `e` function performs an echo if $1 is a string text
- [~] `install.sh`, `uninstall.sh`: Add most significative asix2Atesting aliases & end conflicts with Up-to-Date Customizer & Linux-System duplication;
    - x `(extract)`
    - alias Clean="sudo apt-get -y autoclean && sudo apt-get -y autoremove"
    - alias Shutdown="shutdown -h now"
    - alias Update="sudo apt-get update -y && sudo apt-get upgrade -y"
    - alias Upgrade="sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get -y autoclean && sudo apt-get -y autoremove"
    - alias Trash="rm -rf ${HOME}/.local/share/Trash/*"
    - `(goes to net-tools)`: alias PORTS="netstat -tulanp" # alias nr="net-restart"
    - alias SERVICE="sudo systemctl --type=service"
    - alias TIMER="sudo systemctl -t timer"
    - alias TOTALUSAGE="df -hl --total | grep total"
    - alias UF="sudo systemctl list-unit-files"
    - alias editbashrc="pluma ${HOME}/.bashrc"
    - `(adapt to bash features)`: alias editfunctions="pluma ${HOME}/.bash_functions"
    - alias editprofile="pluma ${HOME}/.profile"
    - `(modify, expanded behaviour)`: alias fn="find . -name"
    - `function`: alias port="lsof -i $1"
    - alias ports="lsof -Pan -i tcp -i udp"
    - function lg: ls | grep "$1"

- [ ] `install.sh`, `uninstall.sh`: SSH
    - alias sshCheck="sudo service ssh status"
    - alias sshConf="sshConfig"
    - alias sshConfig="pluma ${HOME}/.ssh/config"
    - alias sshDisable="sudo systemctl disable sshd"
    - alias sshEnable="sudo systemctl enable ssh"
    - alias sshRestart="sudo systemctl restart sshd"
    - alias sshStart="sudo systemctl start sshd"
    - alias sshStatus="sudo systemctl status sshd"
    - alias sshStop="sudo systemctl stop sshd"
    - alias sshconf="sshConfig"
    - alias r="make run"
    - alias rs="rsync -av --progress"
    - alias cwp="change-gb" `(from customizer)`

  
Have to be completed after (AFTER!) having all the auxiliar structures into v1.0 of uninstall / install (root functions are already in this point):
- [ ] `uninstall.sh`: nautilus
- [ ] `uninstall.sh`: lolcat
- [ ] `uninstall.sh`: fdups  (duplicate finder CLI)
- [ ] `uninstall.sh`: Remmina, TeamViewer: desktop access
- [ ] `uninstall.sh`: codeblocks
- [ ] `uninstall.sh`: handbrake: format editing tool
- [ ] `uninstall.sh`: brasero: cd/dvd burning
- [ ] `uninstall.sh`: Axel: download manager
- [ ] `uninstall.sh`: HardInfo (Benchmark tool)
- [ ] `uninstall.sh`: Dbeaver Community (database manager)


- [ ] `install.sh`, `uninstall.sh`: jshell
- [ ] `install.sh`, `uninstall.sh`: Search in wikipedia from terminal # alias wiki="wikit" # npm install wikit -g
- [ ] `install.sh`, `uninstall.sh`: Mdadm (raid manager) blkid (filesystems that has UUID are displayed) lsblk, fstab (lists all available disk partitions) `/etc/fstab`
- [ ] `install.sh`, `uninstall.sh`: matlab
- [ ] `install.sh`, `uninstall.sh`: CMake https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2.tar.gz
- [ ] `install.sh`, `uninstall.sh`: sherlock
- [ ] `install.sh`, `uninstall.sh`: music edition: rosegarden, Ardour, LMMS
- [ ] `install.sh`, `uninstall.sh`: terminal at F12 key: guake
- [ ] `install.sh`, `uninstall.sh`: iso customization: Remastersys, UNetbootin
- [ ] `install.sh`, `uninstall.sh`: image edition: Blender3D, Agave (sudo apt-get instal agave)
- [ ] `install.sh`, `uninstall.sh`: aircrack-ng
- [ ] `install.sh`, `uninstall.sh`: nmap
- [ ] `install.sh`, `uninstall.sh`: ncat (netcat)
- [ ] `install.sh`, `uninstall.sh`: gobuster  
- [ ] `install.sh`, `uninstall.sh`: zenmap (nmap gui) (virtual environment)
- [ ] `install.sh`, `uninstall.sh`: metasploit (https://apt.metasploit.com/)


# TO-DO v1.0

#### NEW FEATURES
- [~] Autostarting programs (`caffeine`, )
- [~] `L` function columns
- [ ] `e` convert to edit and echo function
- [ ] turn `k` to `g`
- [ ] scijava-jupyter-kernel
- [ ] rewrite k as function: #alias k9="kill -9"# alias killbyport="k9 \`lsof -i:3000 -t\`"  
- [ ] Install & Uninstall Customizerself installation #FUNCTION alias Install="sudo apt-get install -y" alias `CUSTOMIZER`= `cd ...?` ...
- [ ] `README.md` or `IMPLEMENTATION.md`: Write down the command dependencies of the folder project
- [ ] `install.sh`: Add debug mode, with a simple eval to inject code as a function
- [ ] `install.sh`, `uninstall.sh`: kernels support for jupyter-lab
- [ ] `install.sh`, `uninstall.sh`: npm and nodejs (packagemanager installationtype)  
- [ ] `install.sh`, `uninstall.sh`: ghostwriter (text editor for markdown and others with html preview)  
- [ ] `data_features.sh`: Create or integrate loc function bash feature which displays the lines of code of a script  
- [ ] `data_features.sh`: Flatten function, which narrows branches of the file system by deleting a folder that contains only another folder.
- [ ] `commmon_functions.sh`: Implement execute_installation as a function that only uses as parameter the name of the program, in order to detect it's permissions and way of install for expanding the necessary data for that type of installation. With that, we will distinguish between a fully generic install or it will try to call an existent hardcoded function to install that feature
- [ ] `install.sh`, `uninstall.sh`, `customizer.sh`: [Autocompletion features](https://stuff-things.net/2016/05/11/bash-autocompletion/#:~:text=BASH%20autocompletion%20is%20a%20system,to%20complete%20filenames%20and%20paths.&text=You%20can%20override%20this%20behavior,a%20list%20of%20possible%20completions)
Have to be completed after (AFTER!) having all the auxiliar structures into v1.0 of uninstall / install:
  
- [ ] `customizer.sh`: When having this unique endpoint, if an argument is provided but not recognized, customizer will try luck by using apt-get to install it --> parametrize the use of package manager 
- [ ] `customizer.sh`: When installing features using package manager (by default `apt-get`) it will try to install them with different package managers (`apt-get`, `yum`, `pacman`, `pkg`...) depending on which system customizer is run
- [ ] `customizer.sh`: Create a unique endpoint for all the code in customizer `customizer.sh` which accepts the arguments install uninstall for the recognized features and make the corresponding calls to sudo uninstall.sh ..., sudo install.sh ... And Install.sh ...
- [ ] `customizer.sh`: Move high-level wrappers from `install.sh` for a set of features, such as "minimal", "custom", "git_customization" etc. in this new endpoint associate all the features that are needed such as sudo install Nemo and sudo uninstall nautilus
- [ ] `customizer.sh`: customizer.sh help, customizer install, customizer uninstall, customizer parallel, customizer status... basic commands
- [ ] `customizer.sh`: Automated Unit Testing

#### MAINTENANCE & UPDATES
- [ ] `install.sh`, `uninstall.sh`: Program traps to intercept signals and respond against them. At least sigint programmed to show a warning.
- [ ] `data_features.sh`: Add favorite function that not work when being root --> Root programs in user's favorites bar write to `.profile` or `.bashrc` to set custom favorites bar. move add to favorites to `.bash_profile`
- [ ] `data_features.sh`, `functions_install.sh`: Allow the modification of the Icon or Exec line of the desktop launchers using sed in the root generic install or hardcoding the full launcher. Maybe the second
- [ ] `functions_install.sh`, `functions_uninstall.sh`, `functions_common.sh`: Create headers and comments in auxiliary functions
- [ ] `install.sh`, `data_fatures.sh`: Refactor functions of root to use the generic_install function. AutoFirma, OpenOffice, nemo, WireShark, gpaint, iqmol, remaining among others
- [ ] `data_common.sh`: Refactor order of main table to have the same three sections as in install .sh
- [ ] `uninstall.sh`: refactor order of function to follow theconvention on `install.sh`  
- [ ] `README.md`: Refactor order of the table to follow the conventions on `install.sh`. (implement three sections)
- [ ] `table.md`: Remove spaces for help table
- [ ] `data_common.sh`, `install.sh`: Fusion key of permissions + installationtype in `data_common.sh` table to 
- [ ] `uninstall.sh`: Show warning in uninstall when activating -o flag
- [ ] `uninstall.sh`: Rewrite `uninstall.sh` functions using the new auxiliary functions, structures, variables
- [ ] `install.sh`: refactor extract function: more robustness and error handling. decompress in a folder
- [ ] `install.sh`, `uninstall.sh`: Add several kernels & customizations for jupyter-lab: [text-shortcuts](https://github.com/techrah/jupyterext-text-shortcuts)
    - scala (Almond)  
    - perl
    - ruby 
    - rust (EvCxR Jupyter Kernel)
    - php (Jupyter-PHP)
###### Other Jupyter-lab kernels
    - r (IRkernel)
    - ansible (Ansible Kernel)
    - latex
    - Wolfram Kernel
    - lua (ILua)
    - Xonsh
###### Other Jupyter-lab customizations (further investigation needed)
    - vscode-jupyter (integration of jupyter into vscode)
    - theme-darcula (dark theme Intellij like)
    - # Web stack (probably included already in vscode)    
    - angular
    - react
    - xml
    - html
    - css
    - xslt
    - xsl

### TO-DO v2.0
- [ ] May be possible to achieve a post configuration install to nemo-desktop ? to add some customization such as the rendering thumbnails of images depending on the size
- [ ] SublimeText-Markdown, & other plugins for programs...


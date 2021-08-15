# TO-DO install.sh, install core and common core v1.0

#### CORE CODE NEW FEATURES AND UPDATES

###### UPDATES

###### NEW FEATURES
- [ ] `install.sh`, `uninstall.sh`: Program traps to intercept signals and respond against them. Show a warning when trying to stop a process in the middle of a critical operation like apt-get or dpkg.
- [ ] `functions_install.sh`: When installing features using package manager in  (by default `apt-get`) it will try to install them with different fallback package managers (`yum`, `pacman`, `pkg`, `winget`, `brew`, `pkg`, `snap`, `flatpak`, `chocolatey`, `pip`, `npm`...) depending on which is the main package-manager

#### NEW INSTALLATIONS AND INSTALLATION UPDATES

###### UPDATES

- [ ] `screenshots`: Screenshots need proper key bindings converting to binary. --> probably the screenshots bashfunctions are not present in the same environment that 
       uses the keybinds ? Check bashrc and profile probably different environments. If not, the fastest way to make the functions executable from 
       The keybinds will be putting an executable on your path. This executable will have the code itself instead than in a function and will work 
       system-wide, not only on the bash environment.
- [ ] `desktop launchers`: Change `.ico` & `.png` icon files to `.svg` to make desktop launcher icons more Debian friendly. --> unify url to svg -> This may need external ffmpeg processing of feature icons from .* to .svg convertion
- [ ] `data_features.sh`: Update history [optimization](https://unix.stackexchange.com/questions/6628/what-customizations-have-you-done-on-your-shell-profile-to-increase-productivity)
- [ ] `README.md`: Add badges `README.md` using codecov or another code analysis service.  
- [ ] `.profile`: generate function to print clock with hour. Preferably in python [bash script](https://gitlab.com/Axlfc/clockmoji)
- [ ] `data_features.sh`: `L` function columns, also the alias alias totalusage="df -hl --total | grep total" can be rewritted as an alias or case `L /` of L because it uses du
- [ ] `data_features.sh`: refactor `x` (extract) function: 
                            - do not rely only in extension
                            - decompress in a folder optionally
                            - inform if the package needed is not present and installs it
                            - grow it with the code already in decompress which handles already most common cases ;)
- [ ] `pluma` function should be able to open multiple files at once
###### NEW FEATURES
- [ ] `data_features.sh`, `common_data.sh`: `f` function. Searches a therm in a file, a directory or in file names. It has many fallbacks. lg: ls | grep "$1"  fn: "find . -name"
- [ ] `data_features.sh`, `common_data.sh`: `port` function. It returns the name and PID of a process using the given port #  "lsof -i $1"  alias ports="lsof -Pan -i tcp -i udp"
- [ ] `data_features.sh`, `common_data.sh`: `edit` functions. It edits a system or user configuration file by passing the argument of the name. By default with no parameters it should edit .bashrc.  alias editbashrc="editor ${HOME}/.bashrc"  alias editprofile="editor ${HOME}/.profile" alias editfunctions="editor ${HOME}/.bash_functions" sshConfig="pluma ${HOME}/.ssh/config" also edit shortcuts.sh if present, edit fastcommands if present favorites, keybindings...etc. whatever it is interesting 
- [ ] `data_features.sh`, `common_data.sh`: rewrite k as function: #alias k9="kill -9"# alias killbyport="k9 \`lsof -i:3000 -t\`"
- [ ] `data_features.sh`: k function for killing process  --k;0;| Function \`k\` | \`Function for killing processes kill -9\` | Command \`k\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
- [ ] `CONTRIBUTING.md`: Write down the command dependencies of the different features. 
- [ ] `data_features.sh`: Create or integrate loc function bash feature which displays the lines of code of a script
- [ ] `data_features.sh`: Flatten function, which narrows branches of the file system by deleting a folder that contains only another folder.
- [ ] `install.sh`, `uninstall.sh`, `common_data`: ssh server: alias sshDisable="sudo systemctl disable sshd", alias sshEnable="sudo systemctl enable ssh", alias sshRestart="sudo systemctl restart sshd", alias sshStart="sudo systemctl start sshd", alias sshStatus="sudo systemctl status sshd", alias sshStop="sudo systemctl stop sshd"  
- [ ] `install.sh`, `uninstall.sh`, `common_data`: ssh client user disposable environment features if possible
- [ ] `install.sh`, `uninstall.sh`: Cinebench
- [ ] `install.sh`, `uninstall.sh`: Search in wikipedia from terminal # alias wiki="wikit" # npm install wikit -g
- [ ] `install.sh`, `uninstall.sh`: `Google`/`translator` internet shortcut launcher.
- [ ] `install.sh`, `uninstall.sh`: gnu octave and or scilab
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
- [ ] `install.sh`, `uninstall.sh`: z Compressing function (Have sense having this function if we have `x` function to decompress any compressed file)
# TO-DO uninstall.sh and uninstall core for v1.0

###### UPDATES
- [ ] `functions_common.sh`, `uninstall.sh`: Show warning in uninstall when activating -o flag

###### NEW FEATURES
- [ ] `uninstall.sh`: Rewrite `uninstall.sh` using generic_uninstall to uninstall the features.
- [ ] `functions_uninstall.sh`: create functions to respond to the different installationtypes
- [ ] `functions_uninstall.sh`: refactor to customizer standards the commentaries and headers of uninstall.
- [ ] `functions_uninstall`: function to delete all installations and the common structures
- [ ] `uninstall.sh`: OpenOffice apt-get remove -y libreoffice-base-core libreoffice-impress libreoffice-calc
      libreoffice-math libreoffice-common libreoffice-ogltrans libreoffice-core libreoffice-pdfimport
      libreoffice-draw libreoffice-style-breeze libreoffice-gnome libreoffice-style-colibre libreoffice-gtk3 
      libreoffice-style-elementary libreoffice-help-common libreoffice-style-tango libreoffice-help-en-us 
      libreoffice-writer --> this info goes to data_features.sh as packagenames. Even though install when using 
      a download package installationtype will not use it, uninstall will when removing the feature
- [ ] `data_features.sh`: xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search
gsettings set org.gnome.desktop.background show-desktop-icons true
sudo apt purge nemo nemo*
sudo apt autoremove  

# TO-DO customizer.sh and final endpoint for v1.0
Have to be completed after (AFTER!) having all the auxiliar structures into v1.0 of uninstall / install (root functions are already in this point):

###### UPDATES
. [ ] `install.sh`, `customizer.sh`: Install & Uninstall Customizerself installation #FUNCTION alias Install="sudo apt-get install -y" alias `CUSTOMIZER`= `cd ...?` ...
- [ ] `customizer.sh`, `common_data.sh`: Move high-level wrappers from `install.sh` for a set of features, such as "minimal", "custom", "git_customization" etc. in this new endpoint associate all the features that are needed such as sudo install Nemo and sudo uninstall nautilus

###### NEW FEATURES
- [ ] `customizer.sh`: If an argument is provided but not recognized, customizer will try luck by using apt-get to install it --> parametrize the use of package manager
- [ ] `testing.sh`: extend to do the install and uninstall of each feature and start to checks that the behaviour is the correct.
- [ ] `customizer.sh`: Create a unique endpoint for all the code in customizer `customizer.sh` which accepts the arguments install uninstall for the recognized features and make the corresponding calls to sudo uninstall.sh ..., sudo install.sh ... And Install.sh ...
- [ ] `customizer.sh`: customizer.sh help, customizer install, customizer uninstall, customizer parallel, customizer status... basic commands


### TO-DO v2.0
- [ ] Switch from an extreme programming branching model to a less agile one
- [ ] Implement meaningful changelogs by following patterns in commit messages. Also squash commits that program a single feature
- [ ] Creation of \`customizer.py\`file as an alternative endpoint for customizer.sh. We can use it to give to it a graphical interface (GUI)
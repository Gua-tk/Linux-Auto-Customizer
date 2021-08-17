# TO-DO install.sh, install core and common core v1.0

#### CORE CODE NEW FEATURES AND UPDATES

###### UPDATES

###### NEW FEATURES
- [ ] `install.sh`: Cache of downloads of customizer, add another flag to use / construct the cache (default) or to ignore it
- [ ] `functions_install.sh`: When installing features using package manager in  (by default `apt-get`) it will try to install them with different fallback package managers (`yum`, `pacman`, `pkg`, `winget`, `brew`, `pkg`, `snap`, `flatpak`, `chocolatey`, `pip`, `npm`...) depending on which is the main package-manager


#### NEW INSTALLATIONS AND INSTALLATION UPDATES

###### UPDATES
- [ ] `data_features.sh`: refactor `x` (extract) function do not rely only in extension. Inform if the package needed is not present and installs it. --> Depends on compression function, after completion use file -b --mime-type image.png to detect mimetype

###### NEW FEATURES
- [ ] `CONTRIBUTING.md`: Write down the command dependencies of the different features. 
- [ ] `data_features.sh`: Create or integrate loc function bash feature which displays the total lines of code of a script
- [ ] `data_features.sh`: Flatten function, which narrows branches of the file system by deleting a folder that contains only another folder.
- [ ] `data_features.sh`: Rstudio split libssl-dev dependency to a new feature
- [ ] `data_features.sh`: split pgadmin_packagedependencies=("libgmp3-dev" "libpq-dev" "libapache2-mod-wsgi-py3")  # //RF not used
- [ ] `install.sh`, `uninstall.sh`: z Compressing function (Have sense having this function if we have `x` function to decompress any compressed file)
- [ ]  list inner directories i function (tree -d $1)
- [ ] function r: translates hex values of colors to its natural name and rgb(x,y,z) format...
- [ ] merge: git merge funtion()
- [ ] `install.sh`: giff, a git diff alias
- [ ] `install.sh`, `uninstall.sh`: Cinebench
- [ ] `install.sh`, `uninstall.sh`: Search in wikipedia from terminal # alias wiki="wikit" # npm install wikit -g
- [ ] `install.sh`, `uninstall.sh`: `Google`/`translator`/`soundcloud` internet shortcut launcher.
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
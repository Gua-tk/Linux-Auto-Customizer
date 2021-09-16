# TO-DO install.sh, install core and common core v1.0


#### CORE CODE NEW FEATURES AND UPDATES
###### UPDATES

- [ ] Handle different package managers:
  * [ ] Create associative arrays for each package manager containing the different instructions to install packages using that concrete package manager.
  * [ ] Create new property in data_features.sh which allows to override default package manager being used and some way to recover package manager configurations.


- [ ] Use cat << EOF ... EOF to write long echoes such as the help ones: (cat << EOF text EOF)  
- [~] User environmental features should be also be installed as root user or use flag overwrite for the user. --> There is already some functioning but further testing is required.
- [x] Create a data structure to store the necessary permissions for each installation type.
- [x] protects exits for flag ignore errors.
- [x] repositoryclone installations also are being cached
- [ ] Investigate GetOpts. Apply getopts use at least for the flag argument if it is an improvement
- [ ] Check headers
- [ ] Move cache clone to an API function not a generic
- [ ] In debug mode define different variables that contain debug options such as wget_debug="-d" that are applied to different commands to obtain a simple debug mode

###### NEW FEATURES
- [~] `functions_install.sh`: When installing features using package manager in  (by default `apt-get`) it will try to install them with different fallback package managers (`yum`, `pacman`, `pkg`, `rpm`, `winget`, `brew`, `pkg`, `snap`, `flatpak`, `chocolatey`, `pip`, `npm`...) depending on which is the main package-manager
  * [ ] Packageinstall determine the type of installation that is going to be used. 
- [ ] New property to check some dependencies --> It will be used by features as jupyter. 
- [ ] New property to indicate the package manager to use to install the package, and thus, its corresponding command
- [ ] Move features table from readme to FEATURES.sh
- [ ] Function m() #{man $1 | cat | grep "$2"}
- [ ] Pidgin, Audacious, Timemachine (audio recorder), Qjackctl, leafpad (simple text editor)
- [ ] Music software: hydrogen drum machine, Rakarrack, QSynth, zynaddsub fx, Grip, soundKonverter, SooperLooper, Freqtweak Wavbreaker File Slitt, ReZound, mhWaveEdit, Mixxx, JACK Rack, fmit, Calf Plugin Pack for J, JAMin, QTractor, Gnome Wave Cle...

#### NEW INSTALLATIONS AND INSTALLATION UPDATES
###### UPDATES
- [ ] readmelinedescription of internet launchers is not 'FEATUREKEYNAME opening in google chrome' since it uses xdg-open not chrome directly.
- [ ] tryexec of internet shortcut launchers is not google-chrome since it does use xdg-open, so I guess the tryExec is xdg-open or nothing, but not google-chrome, since it is not used nor mentioned directly.
- [ ] codium, eclipse, text editors in general that don't have a bash function for opening folders, files...
- [ ] use axel instead of wget if it is installed, actually wget does not come installed in Debian by default.
- [ ] add dummy -am argument to commit function which does nothing.
- [x] Update Spotify fallen url

###### NEW FEATURES
- [ ] Autopsy (forensics disk analyzer)
- [x] sonarqube (sonar command)
- [x] meld (GUI diff)

# TO-DO uninstall.sh and uninstall core for v1.0
###### UPDATES
- [ ] protect with if always when reading from common files of customizer

###### NEW FEATURES
- [ ] `functions_common.sh`: program specific arguments for uninstall for removing all structures, empty keybinds files, etc
- [ ] `functions_uninstall.sh`: refactor to customizer standards the commentaries and headers of uninstall.
- [~] `functions_uninstall`: function to delete all installations and the common structures
- [ ] `data_features.sh`: xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search
gsettings set org.gnome.desktop.background show-desktop-icons true
sudo apt purge nemo nemo*
sudo apt autoremove  
- [ ] Customizer wiki --> enciclopedic explanations and definitions
  * features 
  * capabilities
  * tasks
  * properties

# TO-DO customizer.sh and final endpoint for v1.0
Have to be completed after (AFTER!) having all the auxiliar structures into v1.0 of uninstall / install (root functions are already in this point):
###### UPDATES
. [ ] `install.sh`, `customizer.sh`: Install & Uninstall Customizerself installation #FUNCTION alias Install="sudo apt-get install -y" alias `CUSTOMIZER`= `cd ...?` ...
- [ ] `customizer.sh`, `common_data.sh`: Move high-level wrappers from `install.sh` for a set of features, such as "minimal", "custom", "git_customization" etc. in this new endpoint associate all the features that are needed such as sudo install 
- [ ]  Nemo and sudo uninstall nautilus   apt install -y nautilus gnome-shell-extension-desktop-icons

###### NEW FEATURES
- [ ] `customizer.sh`: If an argument is provided but not recognized, customizer will try luck by using apt-get to install it --> parametrize the use of package manager
- [ ] `testing.sh`: extend to do the install and uninstall of each feature and start to checks that the behaviour is the correct.
- [ ] `customizer.sh`: Create a unique endpoint for all the code in customizer `customizer.sh` which accepts the arguments install uninstall for the recognized features and make the corresponding calls to sudo uninstall.sh ..., sudo install.sh ... And Install.sh ...
- [ ] `customizer.sh`: customizer.sh help, 
  [ ] * customizer install --> Add new program to the system (install.sh)
  [ ] * customizer uninstall --> Removes a currently installed program (uninstall.sh)
  [ ] * customizer parallel --> Special argument that will allow to launch various instances alltogether.
  [ ] * customizer status --> List of features being currently installed and its properties. (favorites, keybinds...) (customizertesting) It relies in customizerhealth
  [ ] * customizer update --> Updates the current customizer installation
  [ ] * customizer upgrade --> Updates the current features installed via customizer. Checking for major stable versions of the same features. It relies in customizerhealth
- [ ] create new folder structure in the repo with the classical folders: src, doc...
- [ ] Create license file LICENSE.md 
- [ ] customizer status gives a per system status of the features currently being installed and shows if they have autostart, favorites, keybindings...


### TO-DO v2.0
- [ ] Switch from an extreme programming branching model to a less agile one
- [ ] Implement meaningful changelogs by following patterns in commit messages. Also squash commits that program a single feature
- [ ] Document code using a Wiki
- document functions_install.sh, uninstall, and common API. --> use function headers
- document declarable priperties of each installation --> use guide in data features
- document all functions that are installed as a feature and the different subsystems installed

- [ ] Start using GitHub issues to keep this to-do
- [ ] Creation of \`customizer.py\`file as an alternative endpoint for customizer.sh. We can use it to give to it a graphical interface (GUI)
- [ ] automatically solve customizer self dependencies, like jupyer with Julia.
- [ ] automate packageurls updating per SO / distribution

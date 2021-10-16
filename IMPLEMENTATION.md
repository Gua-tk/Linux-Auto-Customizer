# TO-DO install.sh, install core and common core v1.0


#### CORE CODE NEW FEATURES AND UPDATES
###### UPDATES

# - [~] User environmental features should be able to be installed also as root user. 
#--> features userinherit and environmental already are in thi state, missing pythonvenv and repositoryclone
#--> To achieve this, change the bit value in add program for these two installationtypes to 2, to allow them to be more
#permissive, and thus all features of that type needs to be testes as root, if they can not be installed as root, then a flag override for user permissions should be defined for that features

# - [ ] Investigate GetOpts. Apply getopts use at least for the flag argument if it is an improvement
- [x] Check headers
# - [x] define precise wrappers for features

###### NEW FEATURES
#- [~] `functions_install.sh`: When installing features using package manager in  (by default `apt-get`) it will try to install them with different fallback package managers (`yum`, `pacman`, `pkg`, `rpm`, `winget`, `brew`, `pkg`, `snap`, `flatpak`, `chocolatey`, `pip`, `npm`...) depending on which is the main package-manager
#  * [ ] Packageinstall determine the type of installation that is going to be used.
#- [ ] New property to check some dependencies --> It will be used by features as jupyter.

#### NEW INSTALLATIONS AND INSTALLATION UPDATES
###### UPDATES
#- [ ] tryexec of internet shortcut launchers is not google-chrome since it does use xdg-open, so I guess the tryExec is xdg-open or nothing, but not google-chrome, since it is not used nor mentioned directly.
- [x] codium, eclipse, text editors in general that don't have a bash function for opening folders, files...
- [wontfix] use axel instead of wget if it is installed, actually wget does not come installed in Debian by default.
- [???] k function does not care about upper case and lower case to kill the process efficiently.
- [x] Update Spotify fallen url
- [ ] git bash functions compgen completion tab interaction showing repo branches list

###### NEW FEATURES
- [wontfix] Autopsy (forensics disk analyzer)
#- [ ] Function m() #{man $1 | cat | grep "$2"}  
- [wontfix] Pidgin, Audacious, Timemachine (audio recorder), Qjackctl, leafpad (simple text editor)
- [wontfix] Music software: hydrogen drum machine, Rakarrack, QSynth, zynaddsub fx, Grip, soundKonverter, SooperLooper, Freqtweak Wavbreaker File Slitt, ReZound, mhWaveEdit, Mixxx, JACK Rack, fmit, Calf Plugin Pack for J, JAMin, QTractor, Gnome Wave Cle...


# TO-DO uninstall.sh and uninstall core for v1.0
###### UPDATES
- [x] protect with if always when reading from common files of customizer

###### NEW FEATURES
- [x] `functions_uninstall.sh`: refactor to customizer standards the commentaries and headers of uninstall.
- [x] `functions_uninstall`: function to delete all installations and the common structures
- [x] `data_features.sh`: in nautilus install.
xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search
gsettings set org.gnome.desktop.background show-desktop-icons true
sudo apt purge nemo nemo*
sudo apt autoremove  
- [x] Customizer wiki --> enciclopedic explanations and definitions
  * features 
  * capabilities
  * tasks
  * properties

# TO-DO customizer.sh and final endpoint for v1.0
Have to be completed after (AFTER!) having all the auxiliar structures into v1.0 of uninstall / install (root functions are already in this point):
###### UPDATES
#. [ ] `install.sh`, `customizer.sh`: Install & Uninstall Customizerself installation #FUNCTION alias Install="sudo apt-get install -y" alias `CUSTOMIZER`= `cd ...?` ...
# - [ ] `customizer.sh`, `common_data.sh`: Move high-level wrappers from `install.sh` for a set of features, such as "minimal", "custom", "git_customization" etc. in this new endpoint associate all the features that are needed such as sudo install 

###### NEW FEATURES
#- [ ] `customizer.sh`: If an argument is provided but not recognized, customizer will try luck by using apt-get to install it --> parametrize the use of package manager
#- [ ] `testing.sh`: extend to do the install and uninstall of each feature and start to checks that the behaviour is the correct.
#- [ ] `customizer.sh`: Create a unique endpoint for all the code in customizer `customizer.sh` which accepts the arguments install uninstall for the recognized features and make the corresponding calls to sudo uninstall.sh ..., sudo install.sh ... And Install.sh ...
#- [ ] `customizer.sh`: customizer.sh help, 
#  [ ] * customizer install --> Add new program to the system (install.sh)
#  [ ] * customizer uninstall --> Removes a currently installed program (uninstall.sh)
#  [ ] * customizer parallel --> Special argument that will allow to launch various instances alltogether.
#  [ ] * customizer status --> List of features being currently installed and its properties. (favorites, keybinds...) (customizertesting) It relies in customizerhealth
#  [ ] * customizer update --> Updates the current customizer installation
#  [ ] * customizer upgrade --> Updates the current features installed via customizer. Checking for major stable versions of the same features. It relies in customizerhealth
#- [ ] create new folder structure in the repo with the classical folders: src, doc...
- [x] Create license file LICENSE.md 
#- [] customizer status gives a per system status of the features currently being installed and shows if they have autostart, favorites, keybindings...


### TO-DO v2.0
- [x] Switch from an extreme programming branching model to a less agile one
- [x] Implement meaningful changelogs by following patterns in commit messages. Also squash commits that program a single feature
- [x] Document code using a Wiki
- document functions_install.sh, uninstall, and common API. --> use function headers
- document declarable priperties of each installation --> use guide in data features
- document all functions that are installed as a feature and the different subsystems installed

- [x] Start using GitHub issues to keep this to-do
- [ ] Creation of \`customizer.py\`file as an alternative endpoint for customizer.sh. We can use it to give to it a graphical interface (GUI)
- [ ] automatically solve customizer self dependencies, like jupyer with Julia.
- [wontfix] automate packageurls updating per SO / distribution

# TO-DO install.sh, install core and common core v1.0

#### CORE CODE NEW FEATURES AND UPDATES

###### UPDATES
- [ ] Extract generic install of dependencies in root generic to a common property function. --> (This is done to have all programs having its own dependencies in place in self package installation)
- [ ] Create new property in data_features.sh which allows to override default package manager being used and some way to recover package manager configurations.

###### NEW FEATURES
- [~] `functions_install.sh`: When installing features using package manager in  (by default `apt-get`) it will try to install them with different fallback package managers (`yum`, `pacman`, `pkg`, `rpm`, `winget`, `brew`, `pkg`, `snap`, `flatpak`, `chocolatey`, `pip`, `npm`...) depending on which is the main package-manager
  * [x] Parametrized $DEFAULT_PACKAGE_MANAGER
  * [ ] uninstall using apt-get instead of dpkg
  * [ ] function to detect the preferred package manager by OS by looking at /etc/os-release
  * [ ] For each Linux OS, how to unpacking, install, uninstall, update, upgrade, autoclean...
  * [ ] Packageinstall determine the type of installation that is going to be used.
- [ ] `CONTRIBUTING.md`: Write down the command dependencies of the different features. 

#### NEW INSTALLATIONS AND INSTALLATION UPDATES

###### UPDATES
- [ ] `data_features.sh`: refactor `x` (extract) function do not rely only in extension. Inform if the package needed is not present and installs it. --> Depends on compression function, after completion use file -b --mime-type image.png to detect mimetype
- [ ] Extract pakage dependencies to a optional property, so even "user" programs can have its dependencies on the same installation:
  * [ ] `data_features.sh`: Rstudio split libssl-dev dependency to a new feature
  * [ ] `data_features.sh`: split pgadmin_packagedependencies=("libgmp3-dev" "libpq-dev" "libapache2-mod-wsgi-py3")  # //RF not used
  * [ ] `data_features.sh`: bring features that are pure dependencies to the installation that they depend. example: mendeley  



###### NEW FEATURES
- [~] `data_features.sh`: Create or integrate loc function bash feature which displays the total lines of code of a script
- [ ] `data_features.sh`: Flatten function, which narrows branches of the file system by deleting a folder that contains only another folder.
- [ ] `install.sh`, `uninstall.sh`: sherlock https://github.com/sherlock-project/sherlock#installation


# TO-DO uninstall.sh and uninstall core for v1.0

###### UPDATES
- [ ] `functions_common.sh`, `uninstall.sh`: Show warning in uninstall when activating -o flag
- [ ] protect with if always when reading from common filed of customizer
###### NEW FEATURES
- [ ] `functions_commo.sh`: program specific arguments for uninstall for removing all structures, empty keybinds files, etc
- [ ] `functions_uninstall.sh`: refactor to customizer standards the commentaries and headers of uninstall.
- [ ] `functions_uninstall`: function to delete all installations and the common structures
- [ ] `data_features.sh`: xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search
gsettings set org.gnome.desktop.background show-desktop-icons true
sudo apt purge nemo nemo*
sudo apt autoremove  

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
- [ ] `customizer.sh`: customizer.sh help, customizer install, customizer uninstall, customizer parallel, customizer status... basic commands


### TO-DO v2.0
- [ ] Switch from an extreme programming branching model to a less agile one
- [ ] Implement meaningful changelogs by following patterns in commit messages. Also squash commits that program a single feature
- [ ] Document code using a Wikipedia
- document functions_install.sh, uninstall, and common API. --> use function headers
- document declarable priperties of each installation --> use guide in data features
- document all functions that are installed as a feature and the different subsystems installed

- [ ] Start using GitHub issues to keep this to-do
- [ ] Creation of \`customizer.py\`file as an alternative endpoint for customizer.sh. We can use it to give to it a graphical interface (GUI)
- [ ] automatically solve customizer self dependencies, like jupyer with Julia.
- [ ] automate packageurls updating per SO / distribution

### Capabilities
Capabilities are **a set of abstract functionalities that can be used in any feature installed by _The Customizer_**. A 
capability is activated for a feature if one or more variables following a certain naming convention are declared. 
Variables declared in a feature are called *properties*. Properties can:
* Activate and configure a capability for a certain feature.
* Declare data to be used in other active capabilities for a certain feature. 
* Be mandatory in all features, be mandatory if another certain capability is declared or be totally optional. 

Capabilities include the following functionalities:
* Create, move and write to file.
* Autoimport `bash` scripts on terminal creation.
* Autoimport `bash` scripts on boot.
* Install packages using the default package manager.
* Install packages from file.
* Override default package manager.
* Create `python` virtual environments.
* Install dependencies with `pip` in a `python` virtual environment.
* Run code in a `python` virtual environment.
* Create a desktop launcher.
* Create aliases in path, so they can be used without specifying the full path.
* Append `cron` jobs to the current `crontab`.
* Add keyboard shortcuts. 
* Download files.
* Decompress files.
* Associate file extensions to desktop launchers.
* Add package repositories. 
* Add package repository signatures.
* Autostart application on boot.
* Clone repositories.
* Add desktop launcher to favorites bar.
* Run manual `bash` code in three different points of an installation with access to _The Customizer_ private functions 
  and variables.

Currently, capabilities are executed in a predefined order. In future versions it will be changed so capabilities are 
executed in an order defined by the feature. The order is the following:
1. Override default package manager.
2. Run manual `bash` code (pre-installation).
3. Add package repository signatures.
4. Add package repositories. 
5. Install packages using the default package manager (dependencies).
6. Install packages using the default package manager (main packages).
7. Clone repositories.
8. Download files & decompress if they are compressed.
9. Create `python` virtual environment, install dependencies with `pip` in a `python` virtual environment and run code 
   in a `python` virtual environment.
10. Run manual `bash` code (mid-installation).
11. Create, move and write to file.
12. Append `cron` jobs to the current `crontab`.
13. Create a desktop launcher.
14. Autoimport `bash` scripts on terminal creation.
15. Autoimport `bash` scripts on boot.
16. Add desktop launcher to favorites bar.
17. Associate file extensions to desktop launchers.
18. Add keyboard shortcuts.
19. Create aliases in path, so they can be used without specifying the full path.
20. Run manual `bash` code (post-installation).

To activate a certain capability, a property that follows a certain naming scheme has to be declared in the scope of the 
feature where we want to activate it. The contents of those properties will configure the activated capability. The 
properties that are defined for a feature determine its behaviour. To obtain the contents of those variables, we use 
`bash` indirect expansion.

Features are identified by a unique string called `FEATURE_KEY_NAME`. The `FEATURE_KEY_NAME` does not contain special 
characters and is expected to be a name that is representative for the feature. 

To know in which feature we need to activate a certain capability, we prepend the `FEATURE_KEY_NAME` of the feature to 
the name of the variable that activates a certain capability.

For example, if we want to create a feature that installs `zsh` with the `FEATURE_KEY_NAME` being `zshell` and we want 
this feature to install the package `zsh` using the capability of installing packages that is controlled by the variable 
naming `packagenames`, we should declare:
```shell
zshell_packagenames=("zsh")
```

This means that when we issue the installation of this feature with `customizer-install zshell` it will install the 
package zsh with the default package manager.  

Each `FEATURE_KEY_NAME` has to be added in the array `feature_keynames` of `common_data.sh` to be recognized as an 
available feature. 

The following properties are mandatory and used to declare metadata of each feature that can be used to autocomplete the
data requirements of some capabilities.
- FEATUREKEYNAME_arguments: Array containing the arguments recognized to select the current feature. The arguments  #
  are the "name" of the feature, which for third-party software is the known name of the software itself and for    #
  functionalities is usually a description of what the function does in one or two words. Also, for historical and  #
  practical reasons we keep the first argument as the main command that the feature installs, which coincides with  #
  the FEATUREKEYNAME of the feature itself.                                                                         #
  The arguments have to be in lower case and in the case of a possible separation by any symbol, use underscore (_).#
  This will cause multiple argument matching in install.sh and uninstall.sh by ignoring case and interpreting       #
  underscores as a possible separation with multiple underscores or multiple hyphens.                               #
  For example, the feature with FEATUREKEYNAME "code" is the software Visual Studio Code which has the arguments    #
  "code", "visual_studio_code" and "visual_studio". This matches the string itself plus their variants with         #
  different casing or different separation, such as matching "Visual_Studio", "VISUAL-studio", "Code", "--code",    #
  "--viSual_Studio", etc.                                                                                           #
  The list of FEATUREKEYNAMEs is also used as first source of arguments, since it should contain the names of the   #
  commands that are going to be installed, which is something that we can suppose unique.                           #
- FEATUREKEYNAME_name: Stores the feature's name. Maps to property 'Name=' of the desktop launcher if not
  overridden.                                                                  #
- FEATUREKEYNAME_version: Feature version. For downloaded programs is the version of the downloaded bundle or binary
  and for package manager installations or external feature is "System dependent" or "enterprise dependent"; for
  example Google documents is "Google dependent". Maps to property 'Version=' of the desktop launcher if not
  overridden.                                                                           #
- FEATUREKEYNAME_description: Feature objective description. Defines what is that you are installing. Maps to
  property 'GenericName=' of the desktop launcher if not overridden.                                                           #
- FEATUREKEYNAME_commentary: Commentary for the feature. It can be anything relevant to comment about the feature or
  its usage, but not its description (we have a metadata for that). Property 'Comment=' of the desktop launcher.
- FEATUREKEYNAME_tags: Contains keywords related with the feature. This keywords will be used to add the feature to
  the wrapper with the same name as the tag that it is in. Maps to the property 'Keywords=' of the desktop launcher
  if not overridden.
- FEATUREKEYNAME_icon: A name of the filename including its extension in
  ${CUSTOMIZER_PROJECT_FOLDER}/data/static/${CURRENT_INSTALLATION_KEYNAME} that contains an image to represent the
  feature. Maps to property 'Icon=' of the desktop launcher if not overridden. If an icon is not defined, the icon
  will be deduced to
  ${CUSTOMIZER_PROJECT_FOLDER}/data/static/${CURRENT_INSTALLATION_KEYNAME}/${CURRENT_INSTALLATION_KEYNAME}.${file_extension}
  where ${file_extension} is svg or png. If this icon is not found, the icon will be the logo of the customizer, in
  ${CUSTOMIZER_PROJECT_FOLDER}/.github/logo.png .
- FEATUREKEYNAME_systemcategories: Property 'Categories=' of the desktop launcher. It is used by Gnome to put the
  launchers in the respective containers in the dashboard. This keywords will be used to add the feature to the
  wrapper with the same name as the tag that it is in. Maps to the property 'SystemCategories=' of the desktop
  launcher if not overridden.
    * Main categories (all desktop launchers must have one of these categories)
    AudioVideo Audio Video Development Education Game Graphics Network Office Science Settings System Utility
    * Additional categories (provide additional info, can be added as many as needed)
  Building Debugger IDE GUIDesigner Profiling RevisionControl Translation Calendar ContactManagement Database
  Dictionary Chart Email Finance FlowChart PDA ProjectManagement Presentation Spreadsheet WordProcessor 2DGraphics
  VectorGraphics RasterGraphics 3DGraphics Scanning OCR Photography Publishing Viewer TextTools DesktopSettings
  HardwareSettings Printing PackageManager Dialup InstantMessaging Chat IRCClient Feed FileTransfer HamRadio News
  P2P RemoteAccess Telephony TelephonyTools VideoConference WebBrowser WebDevelopment Midi Mixer Sequencer Tuner TV
  AudioVideoEditing Player Recorder DiscBurning ActionGame AdventureGame ArcadeGame BoardGame BlocksGame CardGame
  KidsGame LogicGame RolePlaying Shooter Simulation SportsGame StrategyGame Art Construction Music Languages
  ArtificialIntelligence Astronomy Biology Chemistry ComputerScience DataVisualization Economy Electricity Geography
  Geology Geoscience History Humanities ImageProcessing Literature Maps Math NumericalAnalysis MedicalSoftware
  Physics Robotics Spirituality Sports ParallelComputing Amusement Archiving Compression Electronics Emulator
  Engineering FileTools FileManager TerminalEmulator Filesystem Monitor Security Accessibility Calculator Clock
  TextEditor Documentation Adult Core KDE GNOME XFCE GTK Qt Motif Java ConsoleOnly Screensaver TrayIcon Applet Shell

    * Launcher categories in the dash (sorted when nemo is installed):
#    These are the classes in which the desktop launchers are classified. To know if a desktop launchers belongs to a
#    certain class the "Categories" field of a desktop launcher is used. This field contains a list of categories that
#    categorize the desktop launcher. These are used to group the desktop launchers in the dash.
#    The categories relate to the class in the following way:
#    Class name        |        Categories
#    accessories       |        Utility
#    chrome-apps       |        chrome-apps
#    games             |        Game
#    graphics          |        Graphics
#    internet          |        Network, WebBrowser, Email
#    office            |        Office
#    programming       |        Development
#    science           |        Science
#    sound & video     |        AudioVideo, Audio, Video
#    system-tools      |        System, Settings
#    universal-access  |        Accessibility
#    wine              |        Wine, X-Wine, Wine-Programs-Accessories
#
#    * The order for the mandatory properties is:
#    FEATUREKEYNAME_name
#    FEATUREKEYNAME_description
#    FEATUREKEYNAME_version
#    FEATUREKEYNAME_tags
#    FEATUREKEYNAME_systemcategories
#    FEATUREKEYNAME_commentary
#    FEATUREKEYNAME_arguments
#
########################################################################################################################

#  - FEATUREKEYNAME_icon: A path to an image to represent the feature pointing customizer icon in the repository
#    features data. Property 'Icon=' of the desktop launcher. Fallback to customizer global icons.
### Optional properties                                                                                                #
#  - FEATUREKEYNAME_launchernames: TODO depreacate
#    Array of names of launchers to be copied from the launchers folder of the system.   #
#    Used as fallback for autostart and associatedfiletypes.                                                           #
#  - FEATUREKEYNAME_binariesinstalledpaths: Array of relative paths from the downloaded folder of the features to      #
#    binaries that will be added to the PATH. Its name in the PATH is added by using a ";" to separate it from the     #
#    relative path: "binaries/common/handbrake.sh;handbrake". It will be used to inherit when there is no override.    #
#  - FEATUREKEYNAME_bashfunctions: Array of contents of functions to be executed on the start of every terminal        #
#    session, in our case .bashrc.                                                                                     #
#  - FEATUREKEYNAME_associatedfiletypes: Array of mime types to be associated with the feature. Its launchers in       #
#    launchercontents or the defined launchernames will be used as desktop launchers to associate the mime type.       #
#    Optionally it can have a custom desktop launcher added after a ; of an associated file type to use a custom       #
#    .desktop launcher: "text/x-chdr;sublime"                                                                          #
#  - FEATUREKEYNAME_keybindings: Array of keybindings to be associated with the feature. Each keybinding has 3 fields  #
#    separated. from each other using ";": Command;key_combination;keybinding_description.                             #
#  - FEATUREKEYNAME_downloads: Array of links to a valid download file separated by ";" from the desired name or full  #
#    pathfor that file.                                                                                                #
#    It will downloaded in ${BIN_FOLDER}/APPNAME/DESIREDFILENAME                                                       #
#  - FEATUREKEYNAME_downloadKeys: Array of keys that references a new download.
#    Each download can be configured with additional properties:
#    * FEATUREKEYNAME_DOWNLOADKEY_type: Optional property that can be "compressed", "package" or "regular". If not
#      defined, the behaviour will be one of the three below depending on the mimetype of the downloaded file.
#      "compressed": Means that after the download is completed in BIN_FOLDER it will try to decompress the file in
#      place if a single folder exists in the root of the compressed file, if not it will be decompressed in
#      BIN_FOLDER/CURRENT_INSTALLATION_KEYNAME .
#      "package": Means that after the download is completed in BIN_FOLDER/CURRENT_INSTALLATION_KEYNAME the downloaded
#      file will be installed as a package using the default package manager for the current operating system. If the
#      downloaded file is a compressed file, the file will be decompressed and all the packages inside will be installed recursively.
#      "regular": Means that the file has to be downloaded in BIN_FOLDER/CURRENT_INSTALLATION_KEYNAME and nothing more.
#    * FEATUREKEYNAME_DOWNLOADKEY_doNotInherit: If this variable is defined with some text in it and the type defined
#      or deduced for this download is "compressed", the file will be forced to be decompressed in place instead of
#      the decision between being decompressed in place if a single folder exists in the root of the compressed file or
#      being decompressed in BIN_FOLDER/CURRENT_INSTALLATION_KEYNAME in place.
#    * FEATUREKEYNAME_DOWNLOADKEY_downloadPath: if this variable exists the data in it will be used as the place where
#      the downloaded file will be placed.
#    * FEATUREKEYNAME_DOWNLOADKEY_URL: URL that will be used for the download.
#    * FEATUREKEYNAME_DOWNLOADKEY_installedPackages: This property is mandatory for completeness of the uninstallation
#      if the downloaded file is or contains packages to be installed. It enumerates the names of the installed
#      packages, so they can be used by uninstall to know which packages to uninstall using the default package manager.
#  - FEATUREKEYNAME_gpgSignatures: Array of urls pointing to gpgSignatures that have to be added to GPG_TRUSTED_FOLDER.
#  - FEATUREKEYNAME_sources: Array of strings defining sources that have to be added to APT_SOURCES_LIST_FOLDER
#  - FEATUREKEYNAME_manualcontentavailable: 3 bits separated by ; defining if there's manual code to be executed from  #
#    a function following the next naming rules: install_FEATUREKEYNAME_pre, install_FEATUREKEYNAME_mid,               #
#    install_FEATUREKEYNAME_post.                                                                                      #
#  - FEATUREKEYNAME_filekeys: Array containing the FILEKEYs to indirect expand file content and file path to create    #
#    a new file. Content and path of the file can be set using the two following variables:                            #
#    - FEATUREKEYNAME_FILEKEY_content: Variable with the content of a file identified in each feature with a particular#
#    FILEKEY.                                                                                                          #
#    - FEATUREKEYNAME_FILEKEY_path: Variable with the path where we need to store the file with that FILEKEY.          #
#                                                                                                                      #
#  - FEATUREKEYNAME_flagsoverride: Contains bits that will override the current state of the flags in the declared     #
#    installations. Its format is the following:                                                                       #
#            1                  2                   3                    4                  5                 6        #
#    ${FLAG_PERMISSION};${FLAG_OVERWRITE};${FLAG_IGNORE_ERRORS};${FLAG_QUIETNESS};${FLAG_FAVORITES};${FLAG_AUTOSTART}  #
#  - FEATUREKEYNAME_bashinitializations: Array containing bash scripts that executed on system boot, by default        #
#    ${HOME_FOLDER}/.profile.                                                                                          #
#  - FEATUREKEYNAME_autostartlaunchers: Array containing autostart launchers explicitly to respond to FLAG_AUTOSTART   #
#    and autostart on boot the feature where they are defined in.                                                      #
#  - FEATUREKEYNAME_packagedependencies: Array of name of packages to be installed using apt-get before main installation.    #
#    Used in: packageinstall, packagemanager.                                                                          #
#  - FEATUREKEYNAME_movefiles: Allows file moving from installation folder to other ones in the system, matching *     #
#  - FEATUREKEYNAME_package_manager_override: Allows to load another package manager and its calls for a certain       #
#    feature, reloading it back after its installation.                                                                #
#  - FEATUREKEYNAME_launcherkeynames: Keynames to expand features properties of the desktop launcher when overriding.
#    A desktop launcher will be created for each keyname defined in this property                                      #
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_name: Overrides the Name field in the overridden launcher.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_version: Overrides the Version field in the overridden launcher.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_commentary: Overrides the Commentary field in the overridden launcher.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_tags: Overrides the Keywords field in the overridden launcher.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_icon: Overrides the Icon field in the overridden launcher.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_description: Overrides the GenericName field in the overridden launcher.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_mimetypes: Overrides the Mimetype field in the overridden launcher.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_exec: Overrides the Exec field in the overridden launcher. If not present the
#      Exec field will be deduced from the first position of the binariesinstalledpaths property.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_systemcategories: Overrides the SystemCategories field in the overridden launcher.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_terminal: By default is 'false', but if defined the supplied value is overridden.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_notify: Shows an hourglass in the cursor until the app is loaded. By default true
#      but overridden by this variable.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_windowclass: Used to group multiple windows launched from the same launcher and
#      in other situations. By default the feaurekeyname overrides by this variable. Corresponds to StartupWMClass=
#      property from desktop launcher.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_nodisplay: Used to show or not show launcher in the dashboard. By default the
#      feaurekeyname but overriden by this variable.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_autostartcondition: Sets the AutostartCondition field. Not added if not present.
#      This is used to autostart the app thrown by the launcher if a certain condition is met.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_autorestart: Sets the X-GNOME-AutoRestart field. Not added if not present. This is
#      used by Gnome to restart the application if shut down. Useful for services such as the graphical service in Nemo
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_autorestartdelay: Sets the X-GNOME-Autostart-Delay field of the launcher. Not added
#      if not present. This is used by Gnome to wait a certain amount of time before autostarting the application of the
#      launcher .
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_windowclass: Used to group multiple windows launched from the same launcher. It
#      overrides the WindowsClass field of the desktop launcher. If not present is deduced to be the
#      ${CURRENT_INSTALLATION_KEYNAME}
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_ubuntuGetText: Used to set X-Ubuntu-Gettext-Domain inside desktop launcher.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_XMultipleArgs: Sets X-MultipleArgs inside desktop launcher, possibles values are:
#      false or true. By default not defined.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_usesNotifications: Sets X-GNOME-UsesNotifications inside desktop launcher,
#      possibles values are: true or false. By default not defined.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_dBusActivatable: Sets DBusActivatable, possibles values are: false or true. By
#      default not defined.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_path: Sets Path inside desktop launcher. By default not defined.
#    * FEATUREkEYNAME_LAUNCHERKEYNAME_protocols: Sets X-KDE-Protocols inside desktop launcher. By default not defined.
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_actionkeynames: Sets as many actions as needed by adding keynames to them.
#      For each keyname defined we need to define the following three properties.
#      - FEATUREKEYNAME_LAUNCHERKEYNAME_ACTIONKEYNAME_name: Name of the action
#      - FEATUREKEYNAME_LAUNCHERKEYNAME_ACTIONKEYNAME_exec: Value of the command to execute in this action.
#      - FEATUREKEYNAME_LAUNCHERKEYNAME_ACTIONKEYNAME_icon: Customizer logo if no icon at feature level
#        provided. If not, overridden by the value of this variable
#      - FEATUREKEYNAME_LAUNCHERKEYNAME_ACTIONKEYNAME_onlyShowIn: Sets desktop managers OnlyShowIn property in desktop #
#         action           #
### Installation type dependent properties                                                                             #
#  - FEATUREKEYNAME_packagenames: Array of names of packages to be installed using apt-get as dependencies of the      #
#    feature. Used in: packageinstall, packagemanager.                                                                 #                                                                                          #
#  - FEATUREKEYNAME_repositoryurl: Repository to be cloned. Used in: repositoryclone.                                  #
#  - FEATUREKEYNAME_manualcontent: String containing three elements separated by ; that can be 1 or 0 and indicate if  #
#    there is manual code for that feature to be executed or not. If it is in one, it will try to execute a function   #
#    with its name following a certain pattern.                                                                        #
#  - FEATUREKEYNAME_pipinstallations: Array containing set of programs to be installed via pip. Used in: pythonvenv.   #
#  - FEATUREKEYNAME_pythoncommands: Array containing set of instructions to be executed by the venv using python3.     #
#    Used in: pythonvenv.                                                                                              #
########################################################################################################################
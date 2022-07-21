#!/usr/bin/env bash
########################################################################################################################
# - Name: Linux Auto Customizer data of features.                                                                      #
# - Description: Defines all variables containing the data needed to install and uninstall all features.               #
# - Creation Date: 28/5/19                                                                                             #
# - Last Modified: 11/8/21                                                                                             #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: aleix.marine@estudiants.urv.cat                                                                             #
# - Permissions: This script should not be executed directly, only sourced to import its variables.                    #
# - Arguments: No arguments                                                                                            #
# - Usage: Sourced from install.sh                                                                                     #
# - License: GPL v2.0                                                                                                  #
########################################################################################################################


########################################################################################################################
######################################## INSTALLATION SPECIFIC VARIABLES ###############################################
########################################################################################################################
# The variables in here follow a naming scheme that is required for each feature to obtain its data by variable        #
# indirect expansion. The variables that are defined for an installation determine its behaviour.                      #
# Each installations has its own FEATUREKEYNAME, which is an string that matches a unique feature. We use the name of  #
# the main terminal command installed by the feature used to run it. This string must be added to the array            #
# feature_keynames in common_data.sh to be recognised by the customizer as an available installation.                  #
# The variables must follow the next pattern: FEATUREKEYNAME_PROPERTY. Some variables can be defined in all features,  #
# some are only used depending on the installation type (TODO deprecate)
#  and others have to be defined always for each feature.         #
#                                                                                                                      #
#                                                                                                                      #
###### Available properties:                                                                                           #
#                                                                                                                      #
### Mandatory properties:                                                                                              #
#  - FEATUREKEYNAME_arguments: Array containing the arguments recognized to select the current feature. The arguments  #
#    are the "name" of the feature, which for third-party software is the known name of the software itself and for    #
#    functionalities is usually a description of what the function does in one or two words. Also, for historical and  #
#    practical reasons we keep the first argument as the main command that the feature installs, which coincides with  #
#    the FEATUREKEYNAME of the feature itself.                                                                         #
#    The arguments have to be in lower case and in the case of a possible separation by any symbol, use underscore (_).#
#    This will cause multiple argument matching in install.sh and uninstall.sh by ignoring case and interpreting       #
#    underscores as a possible separation with multiple underscores or multiple hyphens.                               #
#    For example, the feature with FEATUREKEYNAME "code" is the software Visual Studio Code which has the arguments    #
#    "code", "visual_studio_code" and "visual_studio". This matches the string itself plus their variants with         #
#    different casing or different separation, such as matching "Visual_Studio", "VISUAL-studio", "Code", "--code",    #
#    "--viSual_Studio", etc.                                                                                           #
#    The list of FEATUREKEYNAMEs is also used as first source of arguments, since it should contain the names of the   #
#    commands that are going to be installed, which is something that we can suppose unique.                           #
#  - FEATUREKEYNAME_installationtype. TODO deprecate.
#    Define the type of installation, which sets a fixed behaviour that obtains its   #
#    input from predefined sets of properties for each installation type (check next section Installation type         #
#    dependent properties). This can be set to:                                                                        #
#    * "packageinstall": Downloads a .deb package and installs it using dpkg.                                          #
#    * "packagemanager": Uses de package manager such as apt-get to install packages and dependency packages.          #
#    * "userinherit": Downloads a compressed file containing an unique folder.                                         #
#    * "repositoryclone": Clone a repository inside the directory of the current feature installing.                   #
#    * "environmental": Uses only the common part of every installation type. Has no type-dependent properties.        #
#  - FEATUREKEYNAME_readmeline: Contains the readme line of the table for each feature.    TODO deprecate
#  - FEATUREKEYNAME_name: Stores the feature's name. Maps to property 'Name=' of the desktop launcher if not
#    overridden.                                                                  #
#  - FEATUREKEYNAME_version: Feature version. For downloaded programs is the version of the downloaded bundle or binary
#    and for package manager installations or external feature is "System dependent" or "enterprise dependent"; for
#    example Google documents is "Google dependent". Maps to property 'Version=' of the desktop launcher if not
#    overridden.                                                                           #
#  - FEATUREKEYNAME_description: Feature objective description. Defines what is that you are installing. Maps to
#    property 'GenericName=' of the desktop launcher if not overridden.                                                           #
#  - FEATUREKEYNAME_commentary: Commentary for the feature. It can be anything relevant to comment about the feature or
#    its usage, but not its description (we have a metadata for that). Property 'Comment=' of the desktop launcher.
#  - FEATUREKEYNAME_tags: Contains keywords related with the feature. This keywords will be used to add the feature to
#    the wrapper with the same name as the tag that it is in. Maps to the property 'Keywords=' of the desktop launcher
#    if not overridden.
#  - FEATUREKEYNAME_icon: A name of the filename including its extension in
#    ${CUSTOMIZER_PROJECT_FOLDER}/data/static/${CURRENT_INSTALLATION_KEYNAME} that contains an image to represent the
#    feature. Maps to property 'Icon=' of the desktop launcher if not overridden. If an icon is not defined, the icon
#    will be deduced to
#    ${CUSTOMIZER_PROJECT_FOLDER}/data/static/${CURRENT_INSTALLATION_KEYNAME}/${CURRENT_INSTALLATION_KEYNAME}.${file_extension}
#    where ${file_extension} is svg or png. If this icon is not found, the icon will be the logo of the customizer, in
#    ${CUSTOMIZER_PROJECT_FOLDER}/.github/logo.png .
#  - FEATUREKEYNAME_systemcategories: Property 'Categories=' of the desktop launcher. It is used by Gnome to put the
#    launchers in the respective containers in the dashboard. This keywords will be used to add the feature to the
#    wrapper with the same name as the tag that it is in. Maps to the property 'SystemCategories=' of the desktop
#    launcher if not overridden.
#
#    * Main categories (all desktop launchers must have one of these categories)
#      AudioVideo Audio Video Development Education Game Graphics Network Office Science Settings System Utility
#
#    * Additional categories (provide additional info, can be added as many as needed)
#    Building Debugger IDE GUIDesigner Profiling RevisionControl Translation Calendar ContactManagement Database
#    Dictionary Chart Email Finance FlowChart PDA ProjectManagement Presentation Spreadsheet WordProcessor 2DGraphics
#    VectorGraphics RasterGraphics 3DGraphics Scanning OCR Photography Publishing Viewer TextTools DesktopSettings
#    HardwareSettings Printing PackageManager Dialup InstantMessaging Chat IRCClient Feed FileTransfer HamRadio News
#    P2P RemoteAccess Telephony TelephonyTools VideoConference WebBrowser WebDevelopment Midi Mixer Sequencer Tuner TV
#    AudioVideoEditing Player Recorder DiscBurning ActionGame AdventureGame ArcadeGame BoardGame BlocksGame CardGame
#    KidsGame LogicGame RolePlaying Shooter Simulation SportsGame StrategyGame Art Construction Music Languages
#    ArtificialIntelligence Astronomy Biology Chemistry ComputerScience DataVisualization Economy Electricity Geography
#    Geology Geoscience History Humanities ImageProcessing Literature Maps Math NumericalAnalysis MedicalSoftware
#    Physics Robotics Spirituality Sports ParallelComputing Amusement Archiving Compression Electronics Emulator
#    Engineering FileTools FileManager TerminalEmulator Filesystem Monitor Security Accessibility Calculator Clock
#    TextEditor Documentation Adult Core KDE GNOME XFCE GTK Qt Motif Java ConsoleOnly Screensaver TrayIcon Applet Shell
#
#    Launcher categories in the dash (sorted when nemo is installed):
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
#    relative path: "binaries/common/handbreak.sh;handbreak". It will be used to inherit when there is no overrrite.   #
#  - FEATUREKEYNAME_launchercontents: TODO depreacate
#    Array of contents of launchers to be created in the desktop and dashboard.       #
#    They are used as fallback for autostart too.                                                                      #
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
#  - FEATUREKEYNAME_package_manager_override: Allows to load7bd571be2a4a93fa2d266d6d8b6cd5852379748d another package manager and its calls for a certain       #
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
#    * FEATUREKEYNAME_LAUNCHERKEYNAME_actionkeynames: Sets as many actions as needed by adding keynames to them.
#      For each keyname defined we need to define the following three properties.
#      - FEATUREKEYNAME_LAUNCHERKEYNAME_ACTIONKEYNAME_name: Name of the action
#      - FEATUREKEYNAME_LAUNCHERKEYNAME_ACTIONKEYNAME_exec: Value of the command to execute in this action.
#      - FEATUREKEYNAME_LAUNCHERKEYNAME_ACTIONKEYNAME_icon: Customizer logo if no icon at feature level
#        provided. If not, overridden by the value of this variable
### Installation type dependent properties                                                                             #
#  - FEATUREKEYNAME_packagenames: Array of names of packages to be installed using apt-get as dependencies of the      #
#    feature. Used in: packageinstall, packagemanager.                                                                 #
#  - FEATUREKEYNAME_packageurls: TODO deprecated Link to the .deb file to download. Used in: packageinstall.                           #
#  - FEATUREKEYNAME_compressedfileurl: TODO deprecated Internet link to a compressed file. Used in: userinherit and in packageinstall  #
#    as fallback if no urls are supplied in packageurls; in that case will also need a compressedfiletype.             #
#  - FEATUREKEYNAME_compressedfilepathoverride: TODO deprecated Designs another path to perform download and decompression.            #
#    Used in: userinherit.                                                                                             #
#  - FEATUREKEYNAME_repositoryurl: Repository to be cloned. Used in: repositoryclone.                                  #
#  - FEATUREKEYNAME_manualcontent: String containing three elements separated by ; that can be 1 or 0 and indicate if  #
#    there is manual code for that feature to be executed or not. If it is in one, it will try to execute a function   #
#    with its name following a certain pattern.                                                                        #
#  - FEATUREKEYNAME_pipinstallations: Array containing set of programs to be installed via pip. Used in: pythonvenv.   #
#  - FEATUREKEYNAME_pythoncommands: Array containing set of instructions to be executed by the venv using python3.     #
#    Used in: pythonvenv.                                                                                              #
#  - FEATUREKEYNAME_donotinherit: TODO deprecated It does not expect a directory into a compressed file only to decompress in place.   #
########################################################################################################################

####################### UNHOLY LINE OF TESTING. UPWARDS IS TESTED, BELOW IS NOT ##############################


add_name="Function add"
add_description="Alias to git add with completion"
add_version="1.0"
add_tags=("gitbashfunctions" "bashfunctions" "git")
add_systemcategories=("System" "Utility")
add_arguments=("add" "add_function")
add_commentary="A git terminal shortcut"
add_bashfunctions=("add.sh")

aircrackng_name="Aircrack-ng"
aircrackng_description="Complete suite of security tools to assess WiFi network security"
aircrackng_version="1.6"
aircrackng_tags=("attack" "network" "security")
aircrackng_systemcategories=("System" "Utility" "Security" "Network" "Development")
aircrackng_arguments=("aircrack_ng" "aircrackng")
aircrackng_commentary="Very complete"
aircrackng_packagenames=("aircrack-ng")

aisleriot_name="AisleRiot Solitaire"
aisleriot_description="Solitaire Classic Card Game"
aisleriot_version="3.22.9"
aisleriot_tags=("cards" "game" "cardsgame")
aisleriot_systemcategories=("Game" "CardGame")
aisleriot_arguments=("aisleriot" "solitaire" "gnome_solitaire")
aisleriot_commentary="Implementation of the classical game solitaire"
aisleriot_bashfunctions=("aisleriot.sh")
aisleriot_launcherkeynames=("default")
aisleriot_default_exec="sol"
aisleriot_launchernames=("sol")  # TODO @AleixMT extract launcher data
aisleriot_packagenames=("aisleriot")

alert_name="Function alert"
alert_description="Alias to show a notification at the end of a commands"
alert_version="1.0"
alert_tags=("bashfunctions" "notify" "notification" "info")
alert_systemcategories=("Utility" "System" "Calendar")
alert_arguments=("alert" "alert_alias" "alias_alert")
alert_commentary="Useful to remember events"
alert_packagedependencies=("libnotify-bin")
alert_bashfunctions=("alert.sh")

ansible_description="Application deployment engine"
ansible_name="Ansible"
ansible_version="5.0.0"
ansible_tags=("automation" "development" "deployment")
ansible_systemcategories=("Development" "ProjectManagement" "ComputerScience" "Monitor")
ansible_arguments=("ansible")
ansible_commentary="IT automation engine that automates cloud provisioning, configuration management, application deployment"
ansible_packagenames=("ansible")

ant_name="Ant"
ant_description="Automation tool for software build"
ant_version="1.10.11"
ant_tags=("automation" "development" "deployment")
ant_systemcategories=("Development" "Building" "Utility")
ant_arguments=("ant" "apache_ant")
ant_commentary="Tool to automatize repetitive tasks, usually during the compilation, building and deployment phase of the software development"
ant_bashfunctions=("ant.sh")
ant_binariesinstalledpaths=("bin/ant;ant")
ant_downloadKeys=("bundle")
ant_bundle_URL="https://ftp.cixug.es/apache//ant/binaries/apache-ant-1.10.11-bin.tar.gz"
ant_flagsoverride="1;;;;;"

anydesk_name="Anydesk"
anydesk_description="PC Remote controller"
anydesk_version="6.1.1"
anydesk_tags=("remote" "control" "cloud")
anydesk_systemcategories=("Accessibility" "Network" "RemoteAccess" "FileTransfer" "P2P")
anydesk_arguments=("any_desk")
anydesk_commentary="Remote control pc, sync with the cloud, remote file transfer, wake remote computers..."
anydesk_packagedependencies=("libminizip1" "libgtkglext1")
anydesk_bashfunctions=("anydesk.sh")
anydesk_binariesinstalledpaths=("anydesk;anydesk")
anydesk_downloadKeys=("bundle")
anydesk_bundle_URL="https://download.anydesk.com/linux/anydesk-6.1.1-amd64.tar.gz"
anydesk_launcherkeynames=("default")

apache2_name="Apache httpd server project"
apache2_description="Web server"
apache2_version="2.4.52"
apache2_tags=("development" "deployment")
apache2_systemcategories=("Development" "WebDevelopment" )
apache2_arguments=("apache2")
apache2_commentary="open-source HTTP server for modern operating systems including UNIX and Windows"
apache2_packagenames=("apache2" "apache2-utils")

ardour_name="Ardour5"
ardour_description="Audio editor"
ardour_version="System dependent"
ardour_tags=("music" "audio" "production")
ardour_systemcategories=("Audio" "Music")
ardour_commentary="Music development in one place"
ardour_arguments=("ardour")
# ardour_icon="ardour.svg"
ardour_launcherkeynames=("default")
ardour_default_exec="ardour5"
ardour_bashfunctions=("ardour.sh")
ardour_packagenames=("ardour")  # TODO @AleixMT extract launcher data
ardour_launchernames=("ardour")

aspell_name="GNU Aspell"
aspell_description="Spell checker"
aspell_version="0.60.8"
aspell_tags=("development" "deployment" "Education" "Office" "Utility" "Documentation" "FileTools" "Humanities" "Languages" "WordProcessor" "Dictionary" "Translation")
aspell_systemcategories=("Translation" "System" "Settings" "Dictionary")
aspell_arguments=("aspell")
aspell_commentary="Free and open source spell checker in Linux. Can be used to check spelling from provided files or stdin"
aspell_packagenames=("aspell-es" "aspell-ca")

audacity_name="Audacity"
audacity_description="Digital audio editor and recording"
audacity_version="2.3.3"
audacity_tags=("music" "audio" "producing")
audacity_systemcategories=("Audio" "Music")
audacity_arguments=("audacity")
audacity_commentary="You can create and edit your own music"
audacity_launcherkeynames=("default")
audacity_default_exec="audacity"
audacity_bashfunctions=("audacity.sh")
# TODO @AleixMT import launcher data audacity_launchernames=("audacity")
audacity_packagenames=("audacity" "audacity-data")

# TODO: Tested
AutoFirma_name="AutoFirma"
AutoFirma_description="Electronic signature application"
AutoFirma_version="1.0"
AutoFirma_tags=("digitalsign")
AutoFirma_systemcategories=("GNOME" "Application" "Office")
AutoFirma_arguments=("auto_firma")
AutoFirma_commentary="Cliente @firma"
AutoFirma_launcherkeynames=("default")
AutoFirma_default_exec="/usr/bin/AutoFirma %u"
AutoFirma_default_windowclass="autofirma"
AutoFirma_associatedfiletypes=("x-scheme-handler/afirma")
AutoFirma_bashfunctions=("AutoFirma.sh")
AutoFirma_downloadKeys=("bundle")
AutoFirma_bundle_URL="https://estaticos.redsara.es/comunes/autofirma/1/6/5/AutoFirma_Linux.zip"
AutoFirma_bundle_type="package"
AutoFirma_bundle_installedPackages=("AutoFirma")
AutoFirma_packagedependencies=("libnss3-tools")

axel_name="axel"
axel_description="Download manager"
axel_version="1.6"
axel_tags=("downloader" "network")
axel_systemcategories=("FileTransfer" "Utility")
axel_arguments=("axel")
axel_commentary="Like wget but fancier and faster"
axel_packagenames=("axel")

B_name="Function B"
B_description="Function that source ~/.profile and ~/.bashrc"
B_version="1.0"
B_tags=("bashfunctions" "profile" "bashrc")
B_systemcategories=("System" "Utility")
B_arguments=("B" "B_function")
B_commentary="B reload environment"
B_bashfunctions=("B.sh")

b_name="Function b"
b_description="Alias for bash"
b_version="1.0"
b_tags=("bashfunctions" "bash")
b_systemcategories=("System" "Utility")
b_arguments=("b" "b_function")
b_commentary="b reload bash environment"
b_bashfunctions=("b.sh")

bashcolors_name="Function colors"
bashcolors_description="Function and variables to use color in terminal"
bashcolors_version="1.0"
bashcolors_tags=("bashfunctions" "bashrc" "color")
bashcolors_systemcategories=("System" "Utility")
bashcolors_arguments=("bash_colors" "colors" "colours")
bashcolors_commentary="Bring color to the terminal text"
bashcolors_bashfunctions=("bashcolors.sh")

blender_name="Blender"
blender_description="2D and 3D image modeling and animation, fx, video edit..."
blender_version="1.0"
blender_tags=("animation" "3D" "FX" "3d" "cg modeling" "animation" "painting" "sculpting" "texturing" "video editing" "video tracking" "rendering" "render engine" "cycles" "game engine" "python")
blender_systemcategories=("2DGraphics" "3DGraphics" "Graphics" "Video" "Art" "ImageProcessing")
blender_arguments=("blender" "blender_3d")
blender_commentary="3D modeling, animation, rendering and post-production"
blender_downloadKeys=("bundle")
blender_bundle_URL="https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.93/blender-2.93.3-linux-x64.tar.xz"
blender_binariesinstalledpaths=("blender;blender")
blender_launcherkeynames=("defaultLauncher")
blender_defaultLauncher_exec="blender %f"
blender_defaultLauncher_mimetypes=("application/x-blender")

branch_name="Function branch"
branch_description="Alias for git branch"
branch_version="1.0"
branch_tags=("bashfunctions" "bash" "gitbashfunctions")
branch_systemcategories=("System" "Utility")
branch_arguments=("branch")
branch_commentary="branch creates a new branch of the git repository"
branch_bashfunctions=("branch.sh")

# TODO: Tested
brasero_name="Brasero"
brasero_description="Software for image burning"
brasero_version="1.0"
brasero_tags=("bashfunctions" "bash" "gitbashfunctions")
brasero_systemcategories=("System" "Utility")
brasero_arguments=("brasero")
brasero_commentary="branch creates a new branch of the git repository"
brasero_bashfunctions=("brasero.sh")
brasero_launcherkeynames=("defaultLauncher")
brasero_defaultLauncher_exec="brasero"
brasero_packagenames=("brasero")

c_name="Function b"
c_description="Function that changes the directory or clears the screen"
c_version="1.0"
c_tags=("bashfunctions" "bash")
c_systemcategories=("System" "Utility")
c_commentary="cd and clear the screen"
c_arguments=("c")
c_bashfunctions=("c.sh")

caffeine_name="Caffeine"
caffeine_description="Simple indicator applet on Ubuntu panel that allows to temporarily prevent the activation of the screensaver, screen lock, and the sleep power saving mode."
caffeine_version="System dependent"
caffeine_tags=("utility")
caffeine_systemcategories=("System" "Utility" "Settings")
caffeine_arguments=("caffeine" "coffee" "cafe")
caffeine_commentary="You will never see a lock screen again. "
caffeine_launchernames=("caffeine-indicator")  # TODO @AleixMT extract launcher data
caffeine_manualcontentavailable="1;0;1"
caffeine_packagenames=("caffeine")
install_caffeine_pre()
{
  apt-get purge -y caffeine
}
install_caffeine_post()
{
  wget -O - https://gist.githubusercontent.com/syneart/aa8f2f27a103a7f1e1812329fa192e65/raw/caffeine-indicator.patch | patch /usr/bin/caffeine-indicator
}
uninstall_caffeine_pre()
{
 :
}
uninstall_caffeine_post()
{
 :
}

calibre_name="Calibre"
calibre_description="e-book reader"
calibre_version="System dependent"
calibre_tags="office"
calibre_systemcategories=("Office")
calibre_arguments=("calibre")
calibre_commentary="To organize the digital books that you have"
calibre_bashfunctions=("calibre.sh")
calibre_launchernames=("calibre-gui")
calibre_packagenames=("calibre")  # TODO @AleixMT extract launcher data

# TODO: tested
changebg_name="Change Background"
changebg_description="Function that changes the wallpaper using one random image from user images folder. It also downloads wallpapers and installs a cronjob to change the wallpaper every 5 minutes"
changebg_version="1.0"
changebg_tags=("utility" "terminal")
changebg_systemcategories=("System" "Utility" "Settings")
changebg_arguments=("change_bg" "wallpaper" "wallpapers" "backgrounds" "desktop_back_grounds" "change_back_grounds")
changebg_commentary="Just like in Windows"
changebg_movefiles=("*.jpg;${XDG_PICTURES_DIR}/wallpapers" "*.png;${XDG_PICTURES_DIR}/wallpapers" "*.jpeg;${XDG_PICTURES_DIR}/wallpapers" )
changebg_binariesinstalledpaths=("cronscript.sh;changebg")
changebg_cronscript_content="cronscript.sh"
changebg_cronscript_path="cronscript.sh"
changebg_cronjob_content="cronjob"
changebg_cronjob_path="cronjob"
changebg_filekeys=("cronscript" "cronjob")
changebg_manualcontentavailable="0;0;1"
changebg_repositoryurl="https://github.com/AleixMT/wallpapers"
install_changebg_post() {
  if [ -n "${SUDO_USER}" ]; then
    (crontab -u "${SUDO_USER}" -l ; cat "${BIN_FOLDER}/changebg/cronjob") | crontab -u "${SUDO_USER}" -
  else
    (crontab -l ; cat "${BIN_FOLDER}/changebg/cronjob") | crontab -
  fi
}
uninstall_changebg_post() {
  :
  #crontab "${USR_BIN_FOLDER}/changebg/cronjob"
}

cheat_name="Cheat"
cheat_description="Provides access to community-driven cheat sheets and snippets for Linux/UNIX commands and many programming languages"
cheat_version="Cheat creator dependent"
cheat_tags=("terminal" "utility" "info" "develop" "scripts")
cheat_systemcategories=("Terminal" "Utility" "ConsoleOnly")
cheat_arguments=("cheat" "cht.sh")
cheat_commentary="Literally cheats for programming"
cheat_packagedependencies=("curl")
cheat_binariesinstalledpaths=("cht.sh;cheat")
cheat_downloadKeys=("script")
cheat_script_URL="https://cht.sh/:cht.sh"
cheat_script_downloadPath="cht.sh"

checkout_name="Function checkout"
checkout_description="Alias for git checkout"
checkout_version="1.0"
checkout_tags=("aliases" "gitbashfunctions")
checkout_systemcategories=("System" "Utility")
checkout_arguments=("checkout")
checkout_commentary="A terminal shortcut for git"
checkout_bashfunctions=("checkout.sh")

# TODO DBusActivatable=true
# TODO tested
cheese_name="Cheese"
cheese_description="Webcam Booth"
cheese_version="System dependent"
cheese_tags=("photo" "video" "webcam")
cheese_systemcategories=("Video")
cheese_arguments=("cheese")
cheese_commentary="Take photos and videos with your webcam, with fun graphical effects"
cheese_bashfunctions=("cheese.sh")
cheese_launchernames=("org.gnome.Cheese")
cheese_packagenames=("cheese")
cheese_launcherkeynames=("defaultLauncher")
cheese_defaultLauncher_ubuntuGetText="cheese"

clean_name="Function clean"
clean_description="Remove files and contents from the trash bin and performs sudo apt-get -y autoclean and sudo apt-get -y autoremove."
clean_version="1.0"
clean_tags=("bashfunctions" "aliases" "shortcuts")
clean_systemcategories=("System" "Utility")
clean_arguments=("clean")
clean_commentary="Remove usesles packages from cache and empty your trash bin"
clean_bashfunctions=("clean.sh")

# TODO tested
clementine_name="Clementine"
clementine_description="Music player"
clementine_version="System dependent"
clementine_tags=("music")
clementine_systemcategories=("Music" "Audio")
clementine_arguments=("clementine")
clementine_commentary="Modern music player and library organizer"
clementine_bashfunctions=("clementine.sh")
clementine_launchernames=("clementine")  # TODO @AleixMT extract launcher data
clementine_packagenames=("clementine")

clion_name="CLion"
clion_description="Cross-platform C/C++ IDE"
clion_version="2021.3"
clion_tags=("IDE" "programming" "studio" "dev")
clion_systemcategories=("IDE" "Development")
clion_arguments=("clion")
clion_commentary="Very capable C++ IDE"
clion_associatedfiletypes=("text/x-c++hdr" "text/x-c++src" "text/x-chdr" "text/x-csrc")
clion_bashfunctions=("clion.sh")
clion_binariesinstalledpaths=("bin/clion.sh;clion")
clion_downloadKeys=("bundle")
clion_bundle_URL="https://download.jetbrains.com/cpp/CLion-2021.3.tar.gz"
clion_launcherkeynames=("default")
clion_default_windowclass="jetbrains-clion"
clion_default_exec="clion %F"

clone_name="Function clone"
clone_description="Function for \`git clone \$1\`"
clone_version="1.0"
clone_tags=("gitbashfunctions")
clone_systemcategories=("System" "Utility")
clone_arguments=("clone")
clone_commentary="Download repository from url"
clone_bashfunctions=("clone.sh")

# TODO: tested
clonezilla_name="Clonezilla"
clonezilla_description="Disk image utility"
clonezilla_version="System dependent"
clonezilla_tags=("disk" "backup" "drives")
clonezilla_systemcategories=("Filesystem" "ConsoleOnly" "System" "Utility" "Backup" "Images" "Restoration" "Boot")
clonezilla_arguments=("clonezilla")
clonezilla_commentary="Disk cloning, disk imaging, data recovery, and deployment"
clonezilla_packagenames=("clonezilla")
clonezilla_launcherkeynames=("defaultLauncher")
clonezilla_defaultLauncher_exec="sudo clonezilla"
clonezilla_defaultLauncher_terminal="true"

cmake_name="Cmake"
cmake_description="Compile C and c make"
cmake_version="3.21.1-linux-x86_64"
cmake_tags=("development" "c")
cmake_systemcategories=("Development" "Utility")
cmake_commentary="Automatize compilation of C / C++ projects"
cmake_arguments=("cmake" "c_make")
cmake_binariesinstalledpaths=("bin/ccmake;ccmake" "bin/cmake;cmake" "bin/cmake-gui;cmake-gui" "bin/cpack;cpack" "bin/ctest;ctest")
cmake_downloadKeys=("bundle")
cmake_bundle_URL="https://github.com/Kitware/CMake/releases/download/v3.21.1/cmake-3.21.1-linux-x86_64.tar.gz"

cmatrix_name="Cmatrix"
cmatrix_description="Enter The Matrix"
cmatrix_version="System dependent"
cmatrix_tags=("terminal" "matrix")
cmatrix_systemcategories=("ConsoleOnly")
cmatrix_commentary="Cool terminal screensaver"
cmatrix_arguments=("cmatrix")
cmatrix_launcherkeynames=("default")
cmatrix_default_terminal="true"
cmatrix_bashfunctions=("cmatrix.sh")
cmatrix_packagenames=("cmatrix")

code_name="Visual Studio Code"
code_description="General purpose IDE"
code_version="Microsoft dependent"
code_tags=("development" "microsoft" "code")
code_systemcategories=("Development" "Utility")
code_arguments=("code" "visual_studio_code" "visual_studio")
code_commentary="The IDE of Microsoft"
code_bashfunctions=("code.sh")
code_binariesinstalledpaths=("code;code")
code_downloadKeys="bundle"
code_bundle_URL="https://go.microsoft.com/fwlink/?LinkID=620884"
code_launcherkeynames="default"
code_default_exec="code %f"
code_default_windowclass="visual-studio-code"

codeblocks_name="Code::Blocks"
codeblocks_description="IDE for programming"
codeblocks_version="System dependent"
codeblocks_tags=("development")
codeblocks_systemcategories=("Development" "IDE" "Building")
codeblocks_arguments=("codeblocks" "code::blocks")
codeblocks_commentary="Program in C without about the compiler"
codeblocks_bashfunctions=("codeblocks.sh")
# codeblocks_launchernames=("codeblocks")  # TODO @AleixMT extract launcher data
codeblocks_packagenames=("codeblocks")

codium_name="VSCodium"
codium_description="Community-driven distribution of Microsoft’s editor VSCode."
codium_version="Microsoft dependent"
codium_tags=("development" "microsoft" "code")
codium_systemcategories=("Development" "IDE" "Programming")
codium_arguments=("codium" "vs_codium")
codium_commentary="The IDE of Microsoft"
codium_bashfunctions=("codium.sh")
codium_binariesinstalledpaths=("bin/codium;codium")
codium_downloadKeys=("bundle")
codium_bundle_doNotInherit="yes"
codium_bundle_downloadPath="${BIN_FOLDER}/codium/"
codium_bundle_URL="https://github.com/VSCodium/vscodium/releases/download/1.62.2/VSCodium-linux-x64-1.62.2.tar.gz"
codium_launcherkeynames=("default")

commit_name="Function commit"
commit_description="Function that makes git commit -am"
commit_version="1.0"
commit_tags=("gitbashfunctions" "git")
commit_systemcategories=("System" "Utility")
commit_arguments=("commit")
commit_commentary="Save current local file changes to git repository"
commit_bashfunctions=("commit.sh")

config_name="Function config"
config_description="Function that does a git config accepting two parameters username and email"
config_version="1.0"
config_tags=("git-user-configuration" "gitbashfunctions")
config_systemcategories=("System" "Utility")
config_arguments=("git_config" "config_function")
config_commentary="Configure your git username and email"
config_bashfunctions=("config.sh")

converters_name="Functions converters"
converters_description="Convert any number to any numeric system"
converters_version="1.0"
converters_tags=("bashfunctions" "convert" "info")
converters_systemcategories=("System" "Utility")
converters_arguments=("converters")
converters_commentary="bintodec, decobin, hextodec..."
converters_bashfunctions=("converters.sh")
converters_binariesinstalledpaths=("converters/to.py;to" "converters/dectoutf.py;dectoutf" "converters/utftodec.py;utftodec")
converters_repositoryurl="https://github.com/Axlfc/converters"

copyq_name="CopyQ"
copyq_description="A clipboard manager application that comes with extra features such as editing and scripting"
copyq_version="1.0"
copyq_tags=("history" "clipboard")
copyq_systemcategories=("System" "Utility")
copyq_commentary="Autostart enabled"
copyq_arguments=("copyq")
copyq_launchernames=("com.github.hluk.copyq")
copyq_packagenames=("copyq")  # TODO @AleixMT extract launcher data
copyq_flagsoverride=";;;;;1"  # Always autostart

curl_name="curl"
curl_description="Curl is a CLI command for retrieving or sending data to a server"
curl_version="System dependent"
curl_tags=("terminal" "web")
curl_systemcategories=("System" "Utility")
curl_arguments=("curl")
curl_commentary="Autostart enabled"
curl_packagenames=("curl")

customizer_name="Linux Auto Customizer"
customizer_description="Custom local installation manager"
customizer_version="developer dependent"
customizer_tags=("development" "GNU" "environment")
customizer_systemcategories=("Development" "Utility" "System" "Programming" "PackageManager" "Settings")
customizer_arguments=("customizer" "linux_auto_customizer" "auto_customizer" "linux_customizer")
customizer_commentary="Collection of fast and custom all types of installations and uninstallations in GNU/Linux"
customizer_manualcontentavailable="0;0;1"
customizer_flagsoverride="0;;;;;"  # Install always as root
customizer_bashfunctions=("customizer.sh")
install_customizer_post()
{
  ln -sf "${DIR}/uninstall.sh" /usr/bin/customizer-uninstall
  ln -sf "${DIR}/install.sh" /usr/bin/customizer-install
}
uninstall_customizer_post()
{
  remove_file /usr/bin/customizer-install
  remove_file /usr/bin/customizer-uninstall
}

d_name="Function d"
d_description="Function for dif or git diff"
d_version="1.0"
d_tags=("bash" "gitbashfunctions" "info")
d_systemcategories=("System" "Utility")
d_arguments=("d")
d_commentary="See changes of files"
d_bashfunctions=("d.sh")

# TODO: tested
dart_name="Dart"
dart_description="General purpose programming language, specialized on front-end"
dart_version="2.16.2 Linux x64"
dart_tags=("developing" "programming")
dart_systemcategories=("Programming" "WebProgramming")
dart_arguments=("dart")
dart_commentary="Used in the Customizer GUI"
dart_downloadKeys=("bundleCompressed")
dart_bundleCompressed_URL="https://storage.googleapis.com/dart-archive/channels/stable/release/2.16.2/sdk/dartsdk-linux-x64-release.zip"
dart_binariesinstalledpaths=("bin/dart;dart" "bin/dart2js;dart2js" "bin/dartanalyzer;dartanalyzer" "bin/dartaotruntime;dartaotruntime" "bin/dartdevc;dartdevc" "bin/dartdoc;dartdoc" "bin/pub;pub")

dbeaver_name="DBeaver"
dbeaver_description="SQL Client IDE"
dbeaver_version="1.0"
dbeaver_tags=("bashfunctions" "bash" "gitbashfunctions")
dbeaver_systemcategories=("IDE" "Database" "Network" "Development")
dbeaver_arguments=("dbeaver")
dbeaver_commentary="Manage several instances of SQL databases"
dbeaver_downloadKeys=("bundle")
dbeaver_bundle_URL="https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"
dbeaver_package_manager_override="apt-get"
# TODO: dbeaver_launchernames=("dbeaver-ce")
dbeaver_launcherkeynames=("defaultLauncher")
dbeaver_defaultLauncher_exec="dbeaver"

dconfEditor_name="dconf-editor"
dconfEditor_description="Editor settings"
dconfEditor_version="1.0"
dconfEditor_tags=("editor" "settings")
dconfEditor_systemcategories=("System" "Utility" "Settings" "GNOME" "DesktopSettings")
dconfEditor_arguments=("dconf_editor" "dconf")
dconfEditor_commentary="Edit system environment variables"
# TODO: dconfEditor_launchernames=("ca.desrt.dconf-editor")
dconfEditor_launcherkeynames=("defaultLauncher")
dconfEditor_defaultLauncher_exec="dconf-editor"
dconfEditor_packagenames=("dconf-editor")

dia_name="Dia"
dia_description="Graph and relational"
dia_version="1.0"
dia_tags=("graph" "relational")
dia_systemcategories=("FlowChart" "Graphics" "Development")
dia_arguments=("dia")
dia_commentary="Diagrams for developers"
dia_packagenames=("dia-common")
dia_launchernames=("dia")
dia_bashfunctions=("dia.sh")

discord_name="Discord"
discord_description="All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone."
discord_version="Discord dependent"
discord_tags=("VoiceChat" "Messaging" "Social")
discord_systemcategories=("InstantMessaging" "Network")
discord_arguments=("discord")
discord_commentary="Chat and video stream online"
discord_bashfunctions=("discord.sh")
discord_binariesinstalledpaths=("Discord;discord")
discord_downloadKeys=("bundle")
discord_bundle_URL="https://discord.com/api/download?platform=linux&format=tar.gz"

docker_name="Docker"
docker_description="Containerization service"
docker_version="20.10.6"
docker_tags=("development" "containerization" "system")
docker_systemcategories=("System" "Utility")
docker_arguments=("docker")
docker_commentary="Application isolation"
docker_downloadKeys=("bundle")
docker_bundle_URL="https://download.docker.com/linux/static/stable/x86_64/docker-20.10.6.tgz"
docker_binariesinstalledpaths=("docker;docker" "containerd;containerd" "containerd-shim;containerd-shim" "containerd-shim-runc-v2;containerd-shim-runc-v2" "ctr;ctr" "dockerd;dockerd" "docker-init;docker-init" "docker-proxy;docker-proxy" "runc;runc")

documents_name="Google Documents"
documents_description="Google Documents opening in Browser"
documents_version="Google dependent"
documents_tags=("google" "internet_shortcuts")
documents_systemcategories=("Office" "Documentation" "WebBrowser" "WordProcessor" "FlowChart")
documents_arguments=("documents" "google_document" "google_documents" "document")
documents_commentary="take notes or edit rich text documents"
documents_bashfunctions=("documents.sh")
documents_launcherkeynames=("default")
documents_default_exec="xdg-open https://docs.google.com/document/"

drive_name="Google Drive"
drive_description="Google Drive opening in Browser"
drive_tags=("google" "internet_shortcuts")
drive_version="Google dependent"
drive_systemcategories=("ProjectManagement" "Documentation")
drive_arguments=("drive" "google_drive")
drive_commentary="File hosting service from Google"
drive_bashfunctions=("drive.sh")
drive_launcherkeynames=("default")
drive_default_exec="xdg-open https://drive.google.com/"

dropbox_name="Dropbox"
dropbox_description="File hosting service"
dropbox_version="2020.03.04_amd64"
dropbox_tags=("file_hostig" "cloud" "storage")
dropbox_systemcategories=("CMS" "WebDevelopment" "Web")
dropbox_arguments=("dropbox")
dropbox_commentary="Web file hosting"
dropbox_packagenames=("dropbox")
# TODO: dropbox_launchernames=("dropbox")
dropbox_packagedependencies=("python3-gpg")
dropbox_downloadKeys=("bundle")
dropbox_bundle_URL="https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb"
dropbox_package_manager_override="apt-get"

# TODO @AleixMT wontfix, trim and test. if not working will be deleted
drupal_name="Drupal"
drupal_description="Web CMS"
drupal_version="9.2.10"
drupal_tags=("CMS" "web" "development")
drupal_systemcategories=("CMS" "WebDevelopment" "Web")
drupal_arguments=("drupal")
drupal_commentary="Web server app for web magament"
drupal_packagedependencies=("php-dom" "php-gd")
drupal_downloadKeys=("bundle")
drupal_bundle_URL="https://ftp.drupal.org/files/projects/drupal-9.2.10.tar.gz"
drupal_bundle_downloadPath="/var/www/html"
drupal_bashfunctions=("drupal.sh")
drupal_launcherkeynames="default"
drupal_default_exec="xdg-open http://localhost/drupal"
drupal_manualcontentavailable="0;0;1"
install_drupal_post()
{
  create_folder /var/www/html/drupal/sites/default/files/translations 777
}
uninstall_drupal_post()
{
  remove_folder /var/www/html/drupal/
}

duckduckgo_name="Duckduckgo"
duckduckgo_description="Duckduckgo opening in Browser"
duckduckgo_version="Google dependent"
duckduckgo_tags=("search" "internet_shortcuts")
duckduckgo_systemcategories=("WebBrowser")
duckduckgo_arguments=("duckduckgo")
duckduckgo_commentary="take notes or edit rich text documents"
duckduckgo_bashfunctions=("duckduckgo.sh")
duckduckgo_launcherkeynames=("default")
duckduckgo_default_exec="xdg-open https://duckduckgo.com/"
duckduckgo_description="Opens DuckDuckGo in Chrome"

e_name="Function e"
e_description="Multi function to edit a file or project in folder"
e_version="1.0"
e_tags=("bashfunctions" "bash")
e_systemcategories=("System" "Utility")
e_arguments=("e")
e_commentary="edit files or projects"
e_bashfunctions=("e.sh")

E_name="Function E"
E_description="Multi Function to edit a set of hardcoded key files using an argument"
E_version="1.0"
E_tags=("bashfunctions" "bash")
E_systemcategories=("System" "Utility")
E_arguments=("E")
E_commentary="A terminal shortcut"
E_bashfunctions=("E.sh")

eclipse_name="Eclipse IDE"
eclipse_description="IDE for Java"
eclipse_version="4.2.2-linux-gtk-x86_64"
eclipse_tags=("IDE" "programming" "development")
eclipse_systemcategories=("Development" "IDE" "WebDevelopment" "Web")
eclipse_arguments=("eclipse")
eclipse_commentary="Fully functional for professional Java programming"
eclipse_bashfunctions=("eclipse.sh")
eclipse_binariesinstalledpaths=("eclipse;eclipse")
eclipse_downloadKeys=("bundle")
eclipse_bundle_URL="http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.2.2-201302041200/eclipse-SDK-4.2.2-linux-gtk-x86_64.tar.gz"
eclipse_launcherkeynames=("default")
eclipse_default_windowclass="Eclipse"

emojis_name="Function emojis"
emojis_description="Function to find strings in files in the directory in the 1st argument"
emojis_version="1.0"
emojis_tags=("bashfunctions" "emojis" "info")
emojis_systemcategories=("System" "Utility")
emojis_arguments=("emojis" "emoji")
emojis_commentary="Print emojis name in terminal when passing an emoji and prints emoji name when an emoji is passed to it. "
emojis_packagedependencies=("fonts-symbola")
emojis_bashfunctions=("emojis.sh")

evolution_name="Evolution"
evolution_description="User calendar agend, planning"
evoltion_version="1.0"
evolution_tags=("bashfunctions" "bash")
evolution_systemcategories=("System" "Utility")
evolution_arguments=("evolution")
evolution_commentary="edit files or projects"
evolution_bashfunctions=("evolution.sh")
# TODO: Extract properties evolution_launchernames=("evolution-calendar")
evolution_packagenames=("evolution")

F_name="Function F"
F_description="Function to find strings in files in the directory in the 1st argument"
F_version="1.0"
F_tags=("bashfunctions" "bash" "info")
F_systemcategories=("System" "Utility")
F_arguments=("F")
F_commentary="A terminal shortcut"
F_bashfunctions=("F.sh")

f_name="Function f"
f_description="Function for finding strings in files, files in directories and show found files"
f_version="1.0"
f_tags=("bashfunctions" "bash" "info")
f_systemcategories=("System" "Utility")
f_arguments=("f")
f_commentary="A terminal shortcut"
f_bashfunctions=("f.sh")

firc_name="F-irc"
firc_description="CLI IRC client"
firc_version="1.0"
firc_tags=("irc" "chat" "terminal" "social" "instantmessaging")
firc_systemcategories=("ConsoleOnly" "Communication" "InstantMessaging")
firc_arguments=("f_irc")
firc_commentary="Dedicated servers to chat in terminal"
firc_packagenames=("f-irc")
firc_launcherkeynames=("terminalLauncher")
firc_terminalLauncher_exec="f-irc"
firc_terminalLauncher_terminal="true"

facebook_name="Facebook"
facebook_description="Facebook opening in Browser"
facebook_version="Google dependent"
facebook_tags=("social" "internet_shortcuts")
facebook_systemcategories=("InstantMessaging" "Chat" "Feed")
facebook_arguments=("facebook")
facebook_commentary="Social media"
facebook_bashfunctions=("facebook.sh")
facebook_launcherkeynames=("default")
facebook_default_exec="xdg-open https://facebook.com/"

fastcommands_name="Fast commands"
fastcommands_description="Collection of multi-purpose commands"
fastcommands_version="1.0"
fastcommands_tags=("fast" "terminal" "bashfunctions")
fastcommands_systemcategories=("System" "Utility")
fastcommands_arguments=("fast_commands")
fastcommands_commentary="The useful arguments you always forget from commands you love."
fastcommands_bashfunctions=("fastcommands.sh")

fdupes_name="fdupes"
fdupes_description="Searches for duplicated files within given directories"
fdupes_version="System dependent"
fdupes_tags=("files" "duplication")
fdupes_systemcategories=("System" "Utility")
fdupes_arguments=("fdupes")
fdupes_commentary="Search for identic files"
fdupes_packagenames=("fdupes")

fetch_name="Function fetch"
fetch_description="Alias for git fetch --prune"
fetch_version="1.0"
fetch_tags=("gitbashfunctions" "terminal")
fetch_systemcategories=("System" "Utility")
fetch_arguments=("fetch")
fetch_commentary="A terminal shortcut for git."
fetch_bashfunctions=("fetch.sh")

ffmpeg_name="ffmpeg"
ffmpeg_description="Super fast video / audio encoder"
ffmpeg_version="System dependent"
ffmpeg_systemcategories=("Utility")
ffmpeg_commentary="Terminal media encoder"
ffmpeg_tags=("media" "video" "encoder")
ffmpeg_arguments=("ffmpeg" "youtube_dl_dependencies")
ffmpeg_packagenames=("ffmpeg")

filezilla_name="FileZilla"
filezilla_description="FTP Client & Server"
filezilla_version="System dependent"
filezilla_tags=("ftp")
filezilla_systemcategories=("FileManager" "Network")
filezilla_arguments=("filezilla")
filezilla_commentary="Open source ftp"
filezilla_bashfunctions=("filezilla.sh")
filezilla_packagenames=("filezilla")
filezilla_launcherkeynames=("default")
filezilla_default_windowclass="FileZilla"

firefox_name="Firefox"
firefox_description="Web browser"
firefox_version="System dependent"
firefox_tags=("browser")
firefox_systemcategories=("Network" "WebBrowser")
firefox_arguments=("firefox")
firefox_commentary="Free web browser"
firefox_bashfunctions=("firefox.sh")
# TODO: firefox_launchernames=("firefox")
firefox_packagenames=("firefox")
firefox_launcherkeynames=("default")
firefox_default_exec="firefox"

# TODO: tested
flutter_name="Flutter"
flutter_description="Tool to create responsive GUIs"
flutter_version="2.10.5-stable"
flutter_tags=("programming" "development" "webProgramming")
flutter_systemcategories=("WebDevelopment" "Development")
flutter_arguments=("flutter")
flutter_commentary="For the customizer GUI"
flutter_packagedependencies=("bash" "curl" "file" "git" "mkdir" "rm" "unzip" "which" "xz-utils" "zip" "clang" "cmake" "ninja-build" "pkg-config" "libgtk-3-dev" "liblzma-dev")
flutter_downloadKeys=("bundleCompressed")
flutter_bundleCompressed_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_2.10.5-stable.tar.xz"
flutter_binariesinstalledpaths=("bin/dart;dart" "bin/flutter;flutter" "bin/dart.bat;dart.bat" "bin/flutter.bat;flutter.bat")
flutter_manualcontentavailable="0;0;1"
flutter_install_post()
{
   flutter config --enable-linux-desktop
}
flutter_uninstall_post()
{
  :
}

# TODO: Font unification

fonts_alegreya_sans_installationtype="userinherit"
fonts_alegreya_sans_arguments=("fonts_alegreya_sans")
fonts_alegreya_sans_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_alegreya_sans_compressedfileurl="https://fonts.google.com/download?family=Alegreya%20Sans"
fonts_alegreya_sans_readmeline="| fonts-alegreya_sans | Installs font | Install alegreya font || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_firacode_installationtype="packagemanager"
fonts_firacode_arguments=("fonts_firacode")
fonts_firacode_packagenames=("fonts-firacode")
fonts_firacode_readmeline="| fonts-firacode | Installs font | Install firacode font ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_hack_installationtype="packagemanager"
fonts_hack_arguments=("fonts_hack")
fonts_hack_packagenames=("fonts-hack")
fonts_hack_readmeline="| fonts-hack | Installs font | Install hack font ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_hermit_installationtype="packagemanager"
fonts_hermit_arguments=("fonts_hermit")
fonts_hermit_packagenames=("fonts-hermit")
fonts_hermit_readmeline="| fonts-hermit | Installs font | Install hermit font ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_lato_installationtype="userinherit"
fonts_lato_arguments=("fonts_lato")
fonts_lato_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_lato_compressedfileurl="https://fonts.google.com/download?family=Lato"
fonts_lato_readmeline="| fonts-lato | Installs font | Install lato font || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_noto_sans_installationtype="userinherit"
fonts_noto_sans_arguments=("fonts_noto_sans")
fonts_noto_sans_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_noto_sans_compressedfileurl="https://fonts.google.com/download?family=Noto%20Sans"
fonts_noto_sans_readmeline="| fonts-noto_sans | Installs font| Install noto_sans font || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_oswald_installationtype="userinherit"
fonts_oswald_arguments=("fonts_oswald")
fonts_oswald_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_oswald_compressedfileurl="https://fonts.google.com/download?family=Oswald"
fonts_oswald_readmeline="| fonts-oswald | Installs font| Install oswald font || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_oxygen_installationtype="userinherit"
fonts_oxygen_arguments=("fonts_oxygen")
fonts_oxygen_compressedfilepathoverride="${FONTS_FOLDER}"
fonts_oxygen_compressedfileurl="https://fonts.google.com/download?family=Oxygen"
fonts_oxygen_readmeline="| fonts-oxygen | Installs font | Install oxygen font || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fonts_roboto_installationtype="packagemanager"
fonts_roboto_arguments=("fonts_roboto")
fonts_roboto_packagenames=("fonts-roboto")
fonts_roboto_readmeline="| fonts-roboto | Installs font| Install roboto font ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

forms_name="Google Forms"
forms_description="Google Forms opening in Browser"
forms_version="Google dependent"
forms_tags=("google" "internet_shortcuts")
forms_systemcategories=("Documentation")
forms_arguments=("forms" "google_forms")
forms_commentary="make polls and surveys to retrieve statistical data"
forms_bashfunctions=("forms.sh")
forms_launcherkeynames=("default")
forms_default_exec="xdg-open https://docs.google.com/forms/"

freecad_name="FreeCAD"
freecad_description="General-purpose parametric 3D computer-aided design modeler and a building information modeling"
freecad_version="System dependent"
freecad_tags=("3D" "design")
freecad_systemcategories=("3D") # TODO
freecad_arguments=("freecad")
freecad_commentary="Create 3D shapes"
# TODO: freecad_launchernames=("freecad")
freecad_launcherkeynames=("default")
freecad_default_exec="freecad"
freecad_packagenames=("freecad")

gcc_name="gcc"
gcc_description="C compiler for GNU systems"
gcc_version="System dependent"
gcc_tags=("GNU" "C")
gcc_systemcategories=("System" "Utility")
gcc_arguments=("gcc")
gcc_commentary="Typical dependency for any compilation"
gcc_bashfunctions=("gcc.sh")
gcc_packagenames=("gcc")

geany_name="Geany"
geany_description="Lightweight GUI text editor using Scintilla and GTK, including basic IDE features"
geany_version="System dependent"
geany_tags=("TextEditor")
geany_systemcategories=("IDE") # TODO
geany_arguments=("geany")
geany_commentary="Classic text editor"
# TODO: geany_launchernames=("geany")
geany_launcherkeynames=("default")
geany_default_exec="geany"
geany_packagenames=("geany")

geogebra_name="GeoGebra"
geogebra_description="Geometry visualization plotter and calculator with GUI"
geogebra_version="4.2.2"
geogebra_tags=("GeoGebra" "geogebra")
geogebra_systemcategories=("Viewer" "Geometry" "DataVisualization" "Math" "Calculator")
geogebra_arguments=("geogebra" "geogebra_classic_6" "geogebra_6")
geogebra_commentary="Plot 2D functions"
geogebra_binariesinstalledpaths=("GeoGebra;geogebra")
geogebra_downloadKeys=("bundle")
geogebra_bundle_URL="https://download.geogebra.org/package/linux-port6"

ghostwriter_name="GhostWriter"
ghostwriter_description="Text editor without distractions."
ghostwriter_version="System dependent"
ghostwriter_tags=("text_editor" "writer")
ghostwriter_systemcategories=("TextEditor")
ghostwriter_arguments=("ghostwriter")
ghostwriter_commentary="To render markdown"
# TODO ghostwriter_launchernames=("ghostwriter")
ghostwriter_launcherkeynames=("default")
ghostwriter_default_exec="ghostwriter"
ghostwriter_packagenames=("ghostwriter")

gimp_name="Gimp"
gimp_description="Raster graphics editor used for image manipulation and image editing, free-form drawing, transcoding between different image file formats."
gimp_version="System dependent"
gimp_tags=("GeoGebra" "geogebra")
gimp_systemcategories=("Viewer") # TODO
gimp_arguments=("gimp")
gimp_commentary="The alternative to Photoshop"
#TODO: gimp_launchernames=("gimp")
gimp_launcherkeynames=("default")
gimp_default_exec="gimp"
gimp_packagenames=("gimp")

git_name="git"
git_description="Version manager"
git_version="System dependent"
# TODO git_tags=()
# TODO git_systemcategories=()
git_arguments=("git")
git_commentary="Software for tracking changes in any set of files, usually used for coordinating work among programmers collaboratively developing source code during software development"
git_packagenames=("git" "git-all" "git-lfs")

gitcm_name="Git Credentials Manager"
gitcm_description="Plug-in for git to automatically use personal tokens"
gitcm_version="gcmcore-linux_amd64.2.0.696"
gitcm_tags=("GeoGebra" "geogebra")
gitcm_systemcategories=("Viewer" "Geometry" "DataVisualization" "Math" "Calculator")
gitcm_arguments=("git_c_m")
gitcm_commentary="Plot 2D functions"
gitcm_binariesinstalledpaths=("git-credential-manager-core;gitcm")
gitcm_downloadKeys=("bundle")
gitcm_bundle_URL="https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.696/gcmcore-linux_amd64.2.0.696.tar.gz"
gitcm_bundle_doNotInherit="yes"
gitcm_bundle_downloadPath="${BIN_FOLDER}/gitcm/"
gitcm_manualcontentavailable="0;0;1"
install_gitcm_post()
{
  gitcm configure
  git config --global credential.credentialStore plaintext
}
uninstall_gitcm_post()
{
  :
}

github_name="Github"
github_description="Github opening in Browser"
github_version="Google dependent"
github_tags=("internet_shortcuts")
github_systemcategories=("RevisionControl")
github_commentary="Hosting repositories online"
github_arguments=("github")
github_bashfunctions=("github.sh")
github_launcherkeynames=("default")
github_default_exec="xdg-open https://github.com/"

githubDesktop_name="GitHub Desktop"
githubDesktop_description="GitHub Application"
githubDesktop_version="System dependent"
# TODO githubDesktop_tags=()
# TODO githubDesktop_systemcategories=()
githubDesktop_arguments=("github_desktop")
githubDesktop_launchernames=("github-desktop")
githubDesktop_packagenames=("github")
githubDesktop_downloadKeys=("bundle")
githubDesktop_bundle_URL="https://github.com/shiftkey/desktop/releases/download/release-2.6.3-linux1/GitHubDesktop-linux-2.6.3-linux1.deb"
githubDesktop_package_manager_override="apt-get"

gitk_name="GitHub Desktop"
gitk_description="Git Application"
gitk_version="System dependent"
# TODO gitk_tags=()
# TODO gitk_systemcategories=()
gitk_arguments=("gitk")
git_commentary="GUI for git"
gitk_packagedependencies=("unifont")
gitk_bashfunctions=("gitk.sh")
gitk_packagenames=("gitk")

gitlab_name="Gitlab"
gitlab_description="Gitlab opening in Browser"
gitlab_version="Google dependent"
gitlab_tags=("search" "internet_shortcuts")
gitlab_systemcategories=("RevisionControl")
gitlab_arguments=("git_lab")
gitlab_commentary="Hosting repositories online"
gitlab_bashfunctions=("gitlab.sh")
gitlab_launcherkeynames=("default")
gitlab_default_exec="xdg-open https://gitlab.com/"

gitPristine_name="git pristine alias"
gitPristine_description="Alias to obtain a pristine last version of a git repository"
gitPristine_version="1.0"
gitPristine_systemcategories=("Utility" "Terminal")
gitPristine_commentary="Handy alias to obtain a clean state in a git repository"
gitPristine_tags=("git" "gitFunctions" "terminal")
gitPristine_arguments=("pristine" "git_pristine")
gitPristine_bashfunctions=("pristine.sh")

gitprompt_installationtype="repositoryclone"
gitprompt_arguments=("git_prompt")
gitprompt_bashfunctions=("gitprompt.sh")
gitprompt_readmeline="| gitprompt | Special prompt in git repositories | Command \`gitprompt\`|| <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
gitprompt_repositoryurl="https://github.com/magicmonty/bash-git-prompt.git"

gmail_name="Gmail"
gmail_description="Gmail opening in Browser"
gmail_version="Google dependent"
gmail_systemcategories=("Email")
gmail_commentary="Send/Receive e-mails"
gmail_tags=("email" "internet_shortcuts")
gmail_arguments=("gmail" "google_mail")
gmail_bashfunctions=("gmail.sh")
gmail_launcherkeynames=("default")
gmail_default_exec="xdg-open https://mail.google.com/"

gnatGps_name="GNAT Programming Studio"
gnatGps_description="Programming Studio for Ada and C"
gnatGps_version="System dependent"
gnatGps_systemcategories=("Development" "IDE")
gnatGps_commentary="Send/Receive e-mails"
gnatGps_tags=("ide" "editor" "ada" "c")
gnatGps_arguments=("gnatGps")
gnatGps_launcherkeynames=("default")
gnatGps_default_exec="/usr/bin/gnat-gps"
gnatGps_packagenames=("gnat-gps")

calculator_name="GNOME calculator"
calculator_description="GUI calculator"
calculator_version="System dependent"
calculator_tags=("calculator" "gnome")
calculator_systemcategories=("GNOME" "GTK" "Calculator" "Math")
calculator_commentary="2+2=?"
calculator_arguments=("gnome_calculator" "calculator" "calc")
calculator_launchernames=("org.gnome.Calculator")
calculator_packagenames=("gnome-calculator")

chess_name="GNOME Chess"
chess_description="Plays a full game of chess against a human being or other computer program"
chess_version="System dependent"
chess_tags=("chess" "game" "gnome" "strategy")
chess_systemcategories=("BoardGame" "LogicGame" "GNOME" "GTK" "Game" "BoardGame")
chess_commentary="Click and play"
chess_arguments=("gnome_chess" "chess")
chess_packagenames=("gnome-chess")
chess_launcherkeynames=("defaultLauncher")
chess_defaultLauncher_exec="gnome-chess"
chess_defaultLauncher_ubuntuGetText="gnome-chess"
chess_associatedfiletypes=("application/x-chess-pgn")

go_name="go language"
go_description="google programming language"
go_version="1.17.linux-amd64"
go_systemcategories=("Programming")
go_commentary="To develop API REST"
go_tags=("search" "internet_shortcuts")
go_arguments=("go" "go_lang")
go_downloadkeys=("bundle")
go_bundle_URL="https://golang.org/dl/go1.17.linux-amd64.tar.gz"
go_bundle_downloadPath="/usr/local"
go_flagsoverride="0;;;;;"  # Install always as root
go_bashinitializations=("go.sh")

google_name="Google"
google_description="google opening in Browser"
google_version="Google dependent"
google_systemcategories=("Documentation")
google_commentary="Search any content in the internet"
google_tags=("search" "internet_shortcuts")
google_arguments=("google")
google_bashfunctions=("google.sh")
google_launcherkeynames=("default")
google_default_exec="xdg-open https://www.google.com/"

googlecalendar_name="Google Calendar"
googlecalendar_description="Google Calendar opening in Browser"
googlecalendar_version="Google dependent"
googlecalendar_systemcategories=("Calendar")
googlecalendar_commentary="Calendar, add, edit and remove events"
googlecalendar_tags=("search" "internet_shortcuts")
googlecalendar_arguments=("google_calendar")
googlecalendar_bashfunctions=("googlecalendar.sh")
googlecalendar_launcherkeynames=("default")
googlecalendar_default_exec="xdg-open https://calendar.google.com/"

chrome_name="Google Chrome"
chrome_description="Web Browser"
chrome_version="Google dependent"
chrome_tags=("browser" "network")
chrome_systemcategories=("Network" "WebBrowser")
chrome_commentary="The all-in-one browser"
chrome_arguments=("google_chrome")
chrome_bashfunctions=("google_chrome.sh")
chrome_flagsoverride=";;;;1;"
chrome_arguments=("chrome" "google_chrome" "googlechrome")
chrome_launcherkeynames=("default")
chrome_default_exec="google-chrome"
chrome_packagedependencies=("libxss1" "libappindicator1" "libindicator7" "fonts-liberation")
chrome_downloadKeys=("debianPackage")
chrome_debianPackage_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
chrome_debianPackage_installedPackages="google-chrome-stable"
chrome_package_manager_override="apt-get"
chrome_launcherkeys=("default")
chrome_keybindings=("google-chrome;<Primary><Alt><Super>c;Google Chrome")

gpaint_name="GNU Paint"
gpaint_description="Raster graphics editor similar to Microsoft Paint"
gpaint_version="Google dependent"
gpaint_tags=("browser" "network")
gpaint_systemcategories=("Graphics" "2DGraphics" "RasterGraphics")
gpaint_commentary="A small-scale painting program for GNOME, the GNU Desktop"
gpaint_arguments=("gpaint")
gpaint_launcherkeynames=("default")
gpaint_default_exec="gpaint"
gpaint_default_ubuntuGetText="gpaint-2"
gpaint_packagenames=("gpaint")

gparted_name="GParted"
gparted_description="Creating, deleting, resizing, moving, checking, and copying disk partitions and their file systems"
gparted_version="System dependent"
gparted_tags=("disk" "utility")
gparted_systemcategories=("System" "Utility" "FileTools" "GNOME")
gparted_commentary="GUI to manage local disks and partitions"
gparted_arguments=("gparted")
gparted_launchernames=("gparted")
gparted_packagenames=("gparted")

gradle_name="Gradle"
gradle_description="Automatize building applications"
gradle_version="7.4.2-all"
gradle_tags=("developing" "programming" "automatization")
gradle_systemcategories=("Utility" "System" "WebDevelopment" "Development")
gradle_commentary="Yet another meta-compiler"
gradle_arguments=("gradle" "gradle_build")
gradle_downloadKeys=("bundleCompressed")
gradle_bundleCompressed_URL="https://services.gradle.org/distributions/gradle-7.4.2-all.zip"
gradle_binariesinstalledpaths=("bin/gradle;gradle" "bin/gradle.bat;gradle.bat")

guake_name="Guake Terminal"
guake_description="Terminal Emulator"
guake_version="System dependent"
guake_tags=("terminal" "utility")
# TODO guake_systemcategories=("System" "Utility" "FileTools" "GNOME")
guake_commentary="Press F12 to display a terminal"
guake_arguments=("guake")
guake_bashfunctions=("guake.sh")
guake_packagenames=("guake")
# TODO guake_launchernames=("guake")
guake_launcherkeynames=("default")
guake_default_exec="guake"
guake_flagsoverride=";;;;;1"  # Always autostart

gvim_name="GVim"
gvim_description="Text Editor"
gvim_version="System dependent"
gvim_tags=("terminal" "utility")
# TODO gvim_systemcategories=("System" "Utility" "FileTools" "GNOME")
gvim_commentary="Vim with a built-in GUI"
gvim_arguments=("gvim" "vim_gtk3")
#TODO gvim_launchernames=("gvim")
gvim_launcherkeynames=("default")
gvim_default_exec="gvim"
gvim_packagenames=("vim-gtk3")

h_name="Function h"
h_description="Search in your history for previous commands entered, stands by history | grep \"\$@\""
h_version="1.0"
h_systemcategories=("System" "Utility")
h_tags=("bashfunctions" "terminal" "info")
h_commentary="Search your previous terminal commands"
h_arguments=("h")
h_bashfunctions=("h.sh")

handbrake_name="Handbrake"
handbrake_description="Text Editor"
handbrake_version="System dependent"
handbrake_tags=("terminal" "utility")
# TODO handbrake_systemcategories=("System" "Utility" "FileTools" "GNOME")
handbrake_commentary="Video Transcoder"
handbrake_arguments=("handbrake")
# TODO handbrake_launchernames=("fr.handbrake.ghb")
handbrake_launcherkeynames=("default")
handbrake_default_exec="handbrake"
handbrake_packagenames=("handbrake")

hard_name="Function hard"
hard_description="Alias for git reset HEAD --hard"
hard_version="1.0"
hard_tags=("gitbashfunctions" "terminal")
hard_systemcategories=("System" "Utility")
hard_arguments=("hard" "hard_git" "git_hard")
hard_commentary="A terminal shortcut for git"
hard_bashfunctions=("hard.sh")

hardinfo_name="Hardinfo"
hardinfo_description=""
hardinfo_version="System dependent"
hardinfo_tags=("info" "hardware")
# TODO hardinfo_systemcategories=()
hardinfo_arguments=("hardinfo")
hardinfo_commentary="Check pc hardware info"
hardinfo_packagenames=("hardinfo")
hardinfo_launcherkeynames=("default")
hardinfo_default_exec="hardinfo"
# TODO hardinfo_launchernames=("hardinfo")

historyoptimization_name="Function history optimization"
historyoptimization_description="Shared history in terminal session and other tweaks for the terminal history"
historyoptimization_version="1.0"
historyoptimization_tags=("bashfunctions" "terminal")
historyoptimization_systemcategories=("System" "Utility")
historyoptimization_arguments=("history_optimization")
historyoptimization_commentary="Increased the size of bash history, store multiline commands in just one line, force append and not overwrite to history, ignore repeated commands when appending to history, deleted tracking history of some simple commands: \`ls\`, \`cd\`, \`gitk\`... "
historyoptimization_bashfunctions=("history_optimization.sh")

i_name="Function i"
i_description="Shows folder structures"
i_version="1.0"
i_tags=("bashfunctions" "terminal" "info")
i_systemcategories=("System" "Utility")
i_arguments=("i" "i_function" "info")
i_commentary="A terminal shortcut"
i_bashfunctions=("i.sh")

ideac_name="IntelliJ IDEA Community Edition"
ideac_description="Java IDE"
ideac_version="2021.3"
ideac_tags=("IDE" "development" "text editor" "dev" "programming" "java")
ideac_systemcategories=("Debugger" "IDE" "WebDevelopment" "ComputerScience" "Development")
ideac_arguments=("ideac" "intellij_community")
ideac_commentary="Integrated development environment written in Java for developing computer software"
ideac_associatedfiletypes=("text/x-java")
ideac_bashfunctions=("ideac.sh")
ideac_binariesinstalledpaths=("bin/idea.sh;ideac")
ideac_downloadKeys=("bundle")
ideac_bundle_URL="https://download.jetbrains.com/idea/ideaIC-2021.3.tar.gz"
ideac_launcherkeynames=("launcher")
ideac_launcher_exec="ideac %f"
ideac_launcher_windowclass="jetbrains-ideac"
ideac_launcher_actionkeynames=("newwindow")
ideac_launcher_newwindow_name="IntelliJ Community New Window"
ideac_launcher_newwindow_exec="ideac"

ideau_name="IntelliJ IDEA Ultimate Edition"
ideau_description="Java IDE"
ideau_version="2021.3"
ideau_tags=("IDE" "development" "text editor" "dev" "programming" "java")
ideau_systemcategories=("Debugger" "IDE" "WebDevelopment" "ComputerScience" "Development")
ideau_arguments=("ideau" "intellij_ultimate")
ideau_commentary="Integrated development environment written in Java for developing computer software"
ideau_associatedfiletypes=("text/x-java")
ideau_bashfunctions=("ideau.sh")
ideau_binariesinstalledpaths=("bin/idea.sh;ideau")
ideau_downloadKeys=("bundle")
ideau_bundle_URL="https://download.jetbrains.com/idea/ideaIU-2021.3.tar.gz"
ideau_launcherkeynames=("launcher")
ideau_launcher_exec="ideau %f"
ideau_launcher_windowclass="jetbrains-idea"
ideau_launcher_actionkeynames=("newwindow")
ideau_launcher_newwindow_name="IntelliJ Community New Window"
ideau_launcher_newwindow_exec="ideau"

inkscape_name="Inkscape"
inkscape_description="Vector Graphics Editor"
inkscape_version="System dependent"
inkscape_tags=("design" "graphics")
#TODO inkscape_systemcategories=()
inkscape_arguments=("ink_scape")
inkscape_commentary="Vector graphics editor used to create vector images, primarily in Scalable Vector Graphics format"
# TODO inkscape_launchernames=("inkscape")
inkscape_launcherkeynames=("default")
inkscape_default_exec="inkscape"
inkscape_packagenames=("inkscape")

instagram_name="Instagram"
instagram_description="Instagram opening in Browser"
instagram_version="Google dependent"
instagram_tags=("search" "internet_shortcuts")
instagram_systemcategories=("Calendar")
instagram_arguments=("instagram")
instagram_commentary="Calendar, add and remove events"
instagram_bashfunctions=("instagram.sh")
instagram_launcherkeynames=("default")
instagram_default_exec="xdg-open https://instagram.com"

ipe_name="Function ipe"
ipe_description="Returns the public IP"
ipe_version="1.0"
ipe_tags=("bashfunctions" "terminal" "network" "info")
ipe_systemcategories=("System" "Utility")
ipe_arguments=("ipe")
ipe_commentary="A terminal shortcut"
ipe_bashfunctions=("ipe.sh")

ipi_name="Function ipi"
ipi_description="Returns the private IP"
ipi_version="1.0"
ipi_tags=("bashfunctions" "terminal" "network" "info")
ipi_systemcategories=("System" "Utility")
ipi_arguments=("ipi")
ipi_commentary="A terminal shortcut"
ipi_bashfunctions=("ipi.sh")

ips_name="Function ips"
ips_description="Returns the IP information"
ips_version="1.0"
ips_tags=("bashfunctions" "terminal" "network" "info")
ips_systemcategories=("System" "Utility")
ips_arguments=("ips")
ips_commentary="A terminal shortcut"
ips_bashfunctions=("ips.sh")

iqmol_name="IQmol"
iqmol_description="Molecule visualizer"
iqmol_version="System dependent"
# TODO iqmol_tags=()
# TODO iqmol_systemcategories=()
iqmol_arguments=("iqmol")
iqmol_bashfunctions=("iqmol.sh")
# iqmol_downloads=("http://www.iqmol.org/images/icon.png;iqmol_icon.png")
iqmol_description="Program to visualize molecular data"
iqmol_launcherkeynames=("defaultLauncher")
iqmol_defaultLauncher_exec="iqmol"
iqmol_launchercontents=("
[Desktop Entry]
Categories=Visualization;
Comment=${iqmol_description}
Encoding=UTF-8
Exec=iqmol
GenericName=Molecule visualizer
Icon=${BIN_FOLDER}/iqmol/iqmol_icon.png
Keywords=molecules;chemistry;3d;
MimeType=
Name=IQmol
StartupNotify=true
StartupWMClass=IQmol
Terminal=false
TryExec=iqmol
Type=Application
Version=1.0
")
iqmol_downloadKeys=("bundle")
iqmol_bundle_URL="http://www.iqmol.org/download.php?get=iqmol_2.14.deb"

iqmol_package_manager_override="apt-get"
iqmol_readmeline="| IQmol | ${iqmol_description} | Command \`iqmol\`, silent alias, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

j_name="Function j"
j_description="Alias for jobs -l"
j_version="1.0"
j_tags=("bashfunctions" "terminal" "system" "info")
j_systemcategories=("System" "Utility")
j_arguments=("j")
j_commentary="A terminal shortcut"
j_bashfunctions=("j.sh")

java_name="Java Development Kit 8"
java_description="Implementation of version 8 of the Java (programming language) SE Platform"
java_version="openlogic-openjdk-8u262-b10-linux-x64"
java_tags=("programming" "development")
java_systemcategories=("Development")
java_arguments=("java" "java_development_kit" "java_development" "java_development_kit_8" "jdk" "jdk_8")
java_commentary="To execute java applications"
java_bashfunctions=("java.sh")
java_binariesinstalledpaths=("bin/java;java" "bin/keytool;keytool")
java_downloadKeys=("bundle")
java_bundle_URL="https://builds.openlogic.com/downloadJDK/openlogic-openjdk/8u262-b10/openlogic-openjdk-8u262-b10-linux-x64.tar.gz"

julia_name="Julia and IJulia"
julia_description="High-level, high-performance dynamic language for technical computing"
julia_version="julia-1.0.5-linux-x86_64"
# TODO julia_tags=()
# TODO julia_systemcategories=()
julia_arguments=("julia")
julia_binariesinstalledpaths=("bin/julia;julia")
julia_downloadKeys=("bundle")
julia_bundle_URL="https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.5-linux-x86_64.tar.gz"
julia_launchercontents=("
[Desktop Entry]
Name=Julia
Comment=${julia_description}
Exec=julia
Icon=${BIN_FOLDER}/julia/share/icons/hicolor/scalable/apps/julia.svg
Terminal=true
Type=Application
Categories=Development;ComputerScience;Building;Science;Math;NumericalAnalysis;ParallelComputing;DataVisualization;ConsoleOnly;
")
julia_readmeline="| Julia and IJulia | ${julia_description} | Commands \`julia\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT change keyname to single word such jupyter
jupyterLab_installationtype="pythonvenv"
jupyterLab_arguments=("jupyter_lab" "jupyter" "lab")
jupyterLab_bashfunctions=("jupyter_lab.sh")
jupyterLab_binariesinstalledpaths=("bin/jupyter-lab;jupyter-lab" "bin/jupyter;jupyter" "bin/ipython;ipython" "bin/ipython3;ipython3")
jupyterLab_packagedependencies=("libkrb5-dev")
jupyterLab_flagsoverride=";;1;;;"  # Ignore Errors to check dependencies. This is a patch
jupyterLab_description="IDE with a lot of possible customization and usable for different programming languages."
jupyterLab_launchercontents=("
[Desktop Entry]
Categories=IDE; text_editor;
Comment=${jupyterLab_description}
Encoding=UTF-8
GenericName=jupyter-lab
Keywords=jupyter; programming; text; webpage;
MimeType=
Name=Jupyter Lab
StartupNotify=true
StartupWMClass=jupyter
Terminal=false
Type=Application
Version=1.0
Icon=${BIN_FOLDER}/jupyterLab/share/icons/hicolor/scalable/apps/notebook.svg
Exec=jupyter-lab &
")
jupyterLab_manualcontentavailable="1;1;0"
jupyterLab_pipinstallations=("jupyter jupyterlab jupyterlab-git jupyterlab_markup" "bash_kernel" "pykerberos pywinrm[kerberos]" "powershell_kernel" "iarm" "ansible-kernel" "kotlin-jupyter-kernel" "vim-kernel" "theme-darcula")
jupyterLab_pythoncommands=("bash_kernel.install" "iarm_kernel.install" "ansible_kernel.install" "vim_kernel.install")  # "powershell_kernel.install --powershell-command powershell"  "kotlin_kernel fix-kernelspec-location"
jupyterLab_readmeline="| Jupyter Lab | ${jupyterLab_description} | alias \`lab\`, commands \`jupyter-lab\`, \`jupyter-lab\`, \`ipython\`, \`ipython3\`, desktop launcher and dashboard launcher. Recognized programming languages: Python, Ansible, Bash, IArm, Kotlin, PowerShell, Vim. || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
install_jupyterLab_pre() {
  local -r dependencies=("npm" "R" "julia")
  for dependency in "${dependencies[@]}"; do

    if ! which "${dependency}" &>/dev/null; then
      output_proxy_executioner "echo ERROR: ${dependency} is not installed. You can installing using bash install.sh --npm --R --julia" "${FLAG_QUIETNESS}"
      exit 1
    fi
  done
}
install_jupyterLab_mid() {
  # Enable dark scrollbars by clicking on Settings -> JupyterLab Theme -> Theme Scrollbars in the JupyterLab menus.
  "${BIN_FOLDER}/jupyterLab/bin/jupyter" labextension install @telamonian/theme-darcula
  "${BIN_FOLDER}/jupyterLab/bin/jupyter" labextension enable @telamonian/theme-darcula

  "${BIN_FOLDER}/jupyterLab/bin/jupyter" lab build

  # ijs legacy install
  npm config set prefix "${HOME_FOLDER}/.local"
  npm install -g ijavascript
  ijsinstall

  # Set up IRKernel for R-jupyter
  # R -e "install.packages('IRkernel')
  # install.packages(c('rzmq', 'repr', 'uuid','IRdisplay'),
  #                repos = c('http://irkernel.github.io/',
  #                getOption('repos')),
  #                type = 'source')
  # IRkernel::installspec()"

  # install jupyter-lab dependencies down
  julia -e '#!/.local/bin/julia
  using Pkg
  Pkg.add("IJulia")
  Pkg.build("IJulia")'
}
uninstall_jupyterLab_pre() {
  :
}
uninstall_jupyterLab_mid() {

  # install jupyter-lab dependencies down
  #julia -e '#!/.local/bin/julia
  #using Pkg
  #Pkg.add("IJulia")
  #Pkg.build("IJulia")'
  :
}

k_name="Function k"
k_description="Kill processes by PID and name of process"
k_version="1.0"
k_tags=("bashfunctions" "terminal" "system")
k_systemcategories=("System" "Utility")
k_arguments=("k")
k_commentary="A terminal shortcut"
k_bashfunctions=("k.sh")

keep_name="Google Keep"
keep_description="keep opening in Browser"
keep_version="Google dependent"
keep_tags=("search" "internet_shortcuts")
keep_systemcategories=("Documentation")
keep_arguments=("keep" "google_keep")
keep_commentary="Add and remove notes online"
keep_bashfunctions=("keep.sh")
keep_launcherkeynames=("default")
keep_default_exec="xdg-open https://keep.google.com"

keyboardfix_name="Fix Fn key Keychron K8 ISO UK"
keyboardfix_description="Fixes the Fn key in combination with the Function keys F1, F2, etc. which happens to not work in some keyboards"
keyboardfix_version="System dependent"
# TODO keyboardfix_tags=()
# TODO keyboardfix_systemcategories=()
keyboardfix_arguments=("keyboard_fix" "fix_keyboard")
keyboardfix_commentary="To properly using the Fn key"
keyboardfix_filekeys=("keyboardconf")
keyboardfix_keyboardconf_path="/etc/modprobe.d/hid_apple.conf"
keyboardfix_keyboardconf_content="keyboard.conf"
keyboardfix_manualcontentavailable="0;0;1"
keyboardfix_flagsoverride="0;;;;;"  # Root mode
install_keyboardfix_post()
{
  update-initramfs -u -k all
}
uninstall_keyboardfix_pre()
{
  :
}


L_name="Function L"
L_description="Function that lists files in a directory, but listing the directory sizes"
L_version="1.0"
L_tags=("bashfunctions" "terminal" "info")
L_systemcategories=("System" "Utility")
L_arguments=("L")
L_commentary="A terminal shortcut"
L_bashfunctions=("L.sh")

l_name="Function l"
l_description="alias for \`ls\`"
l_version="1.0"
l_tags=("bashfunctions" "terminal" "system" "info")
l_systemcategories=("System" "Utility")
l_arguments=("l")
l_commentary="A terminal shortcut"
l_bashfunctions=("l.sh")

latex_installationtype="packagemanager"
latex_arguments=("latex")
latex_description="Software system for document preparation"
latex_launchercontents=("
[Desktop Entry]
Name=TeXdoctk
Exec=texdoctk
Comment=${latex_description}
Type=Application
Type=Application
Terminal=false
Categories=Settings;
Icon=/usr/share/icons/Yaru/256x256/mimetypes/text-x-tex.png")
latex_launchernames=("texmaker")
latex_packagedependencies=("perl-tk" )
latex_packagenames=("texlive-latex-extra" "texmaker" "perl-tk")
latex_readmeline="| LaTeX | ${latex_description} | Command \`tex\` (LaTeX compiler) and \`texmaker\` (LaTeX IDE), desktop launchers for \`texmaker\` and LaTeX documentation ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

lmms_name="lmms"
lmms_description="Software for making music"
lmms_version="System dependent"
# TODO lmms_tags=()
# TODO lmms_systemcategories=()
lmms_arguments=("lmms")
lmms_bashfunctions=("lmms.sh")
lmms_packagenames=("lmms")
# TODO lmms_launchernames=("lmms")
lmms_launcherkeynames=("defaultLauncher")
lmms_defaultLauncher_exec="lmms"

loc_name="Function loc"
loc_description="Counts lines of code"
loc_version="1.0"
loc_tags=("bashfunctions" "terminal" "system" "info")
loc_systemcategories=("System" "Utility")
loc_arguments=("loc" "function_loc")
loc_commentary="A terminal shortcut"
loc_bashfunctions=("loc.sh")

lolcat_name="Function lolcat"
lolcat_description="Same as the command \`cat\` but outputting the text in rainbow color and concatenate string"
lolcat_version="System dependent"
lolcat_tags=("terminal" "system")
lolcat_systemcategories=("System" "Utility")
lolcat_arguments=("lolcat")
lolcat_commentary="Terminal rainbow font"
lolcat_bashfunctions=("lolcat.sh")
lolcat_packagenames=("lolcat")

mahjongg_name="GNOME Mahjongg"
mahjongg_description="Implementation for GNU systems of the famous popular chinese game Mahjongg"
mahjongg_version="System dependent"
mahjongg_tags=("mahjongg" "game" "gnome" "strategy")
mahjongg_systemcategories=("BoardGame" "LogicGame" "GNOME" "GTK" "Game" "BoardGame")
mahjongg_arguments=("gnome_mahjongg" "mahjongg")
mahjongg_commentary="Click and play"
# TODO mahjongg_launchernames=("org.gnome.Mahjongg")
mahjongg_launcherkeynames=("default")
mahjongg_default_exec="gnome-mahjongg"
mahjongg_packagenames=("gnome-mahjongg")

matlab_name="Matlab"
matlab_description="IDE + programming language specialized in matrix operations"
matlab_version="Matlab dependent"
# TODO matlab_tags=()
# TODO matlab_systemcategories=()
matlab_arguments=("matlab" "mat_lab" "math_works")
# Matlab can only be downloaded by creating an account, making it impossible to download the file programmatically.
# Instead, download the linux installation file of matlab and manually cache it into customizer cache in order to
# install matlab. To do so, put this file into $CACHE_FOLDER and rename it to "matlab_compressed_file"
matlab_downloadKeys=("bundle")
matlab_bundle_URL="https://es.mathworks.com/downloads/web_downloads"

# It is an installer. Decompress in temporal folder to install and remove afterwards
matlab_compressedfilepathoverride="${TEMP_FOLDER}"
# When following the graphical installation of matlab, install it in $BIN_FOLDER/matlab in order to find the executables
# when creating these links in the path.
matlab_binariesinstalledpaths=("bin/matlab;matlab" "bin/mex;mex")
matlab_launcherkeynames=("defaultLauncher")
matlab_defaultLauncher_exec="matlab -desktop"
matlab_launchercontents=(
"[Desktop Entry]
Version=1.0
Type=Application
Name=MATLAB R2021a
Icon=${BIN_FOLDER}/matlab/matlab_icon.svg
Exec=matlab -desktop
Terminal=false
")
matlab_manualcontentavailable="0;1;0"
matlab_bashfunctions=("matlab.sh")
install_matlab_mid()
{
  "${TEMP_FOLDER}/matlab/install"  # Execute installer
  rm -Rf "${TEMP_FOLDER}/matlab"
}
uninstall_matlab_mid()
{
  :
}

mdadm_name="mdadm"
mdadm_description="Manage RAID systems"
mdadm_version="2021.3"
mdadm_tags=("raid" "drive")
# TODO mdadm_systemcategories=("Development")
mdadm_arguments=("mdadm")
mdadm_commentary="Program disk data mirroring for backups"
mdadm_packagenames=("mdadm")

megasync_name="MegaSync"
megasync_description="Synchronises folders between your computer and your MEGA Cloud Drive"
megasync_version="4.6.1-2.1_amd64"
megasync_tags=("hosting" "cloud")
# TODO megasync_systemcategories=("GTK" "Development")
megasync_arguments=("megasync" "mega")
megasync_commentary="Access it with your MEGA account."
megasync_packagedependencies=("nemo" "libc-ares2" "libmediainfo0v5" "libqt5x11extras5" "libzen0v5")
megasync_downloadKeys=("packageDefault" "packageDesktop")
megasync_packageDefault_URL="https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/megasync_4.6.1-2.1_amd64.deb"
megasync_packageDefault_installedPackages="megasync"
megasync_packageDesktop_URL="https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/nemo-megasync_4.0.2_amd64.deb"
megasync_packageDesktop_installedPackages="nemo-megasync"
megasync_package_manager_override="apt-get"
# TODO megasync_launchernames=("megasync")
megasync_launcherkeynames=("default")
megasync_default_exec="megasync"

meld_name="Meld"
meld_description="Diff viewer to compare and merge your files"
meld_version="2021.3"
meld_tags=("diff" "merge" "dev" "development" "programming")
meld_systemcategories=("GTK" "Development")
meld_commentary="Meld visual diff viewer and merge tool for developers"
meld_arguments=("meld")
meld_packagedependencies=("libgtksourceview-4-dev" "libgtksourceview-3.0-1")
meld_bashfunctions=("meld.sh")
meld_associatedfiletypes=("application/x-meld-comparison")
meld_binariesinstalledpaths=("bin/meld;meld")
meld_downloadKeys=("bundle")
meld_bundle_URL="https://download.gnome.org/sources/meld/3.21/meld-3.21.0.tar.xz"
meld_launcherkeynames=("default")
meld_default_exec="meld %F"

# TODO: Test without properties X-SuSE-translate=false and X-Mendeley-Version=1
mendeley_name="Mendeley Desktop"
mendeley_description="Research Paper Manager"
mendeley_version="1.0"
mendeley_tags=("research" "reference")
mendeley_systemcategories=("Education" "Utility" "Literature" "Qt")
mendeley_arguments=("mendeley")
mendeley_commentary="It is most known for its reference manager which is used to manage and share research papers and generate bibliographies for scholarly articles"
mendeley_associatedfiletypes=("x-scheme-handler/mendeley" "application/pdf" "text/x-bibtex")
mendeley_downloadKeys=("bundle")
mendeley_bundle_URL="https://www.mendeley.com/autoupdates/installer/Linux-x64/stable-incoming"
mendeley_binariesinstalledpaths="bin/mendeleydesktop;mendeley"
mendeley_packagedependencies=("gconf2" "qt5-default" "qt5-doc" "qt5-doc-html" "qtbase5-examples" "qml-module-qtwebengine")
mendeley_launcherkeynames="default"
mendeley_default_exec="mendeley %f"

merge_name="Function merge"
merge_description="Function for git merge"
merge_version="1.0"
merge_tags=("gitbashfunctions" "git")
merge_systemcategories=("System" "Utility")
merge_arguments=("merge" "merge_function" "function_merge" "git_merge")
merge_commentary="A terminal function for merging in git"
merge_bashfunctions=("merge.sh")

mines_name="GNOME Mines"
mines_description="Implementation for GNU systems of the famous game mines"
mines_version="System dependent"
mines_tags=("mines" "game" "gnome" "strategy")
mines_systemcategories=("BoardGame" "LogicGame" "GNOME" "GTK" "Game" "BoardGame")
mines_arguments=("gnome_mines" "mines")
mines_commentary="Click and play"
# TODO mines_launchernames=("org.gnome.Mines")
mines_launcherkeynames=("default")
mines_default_exec="gnome-mines"
mines_packagenames=("gnome-mines")

# TODO: merge with fonts
msttcorefonts_installationtype="packagemanager"
msttcorefonts_arguments=("msttcorefonts")
msttcorefonts_packagenames=("msttcorefonts")
msttcorefonts_readmeline="| font Msttcorefonts | Windows classic fonts | Install mscore fonts ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

mvn_name="Apache Maven"
mvn_description="Apache Maven is a software project management and comprehension tool. Based on the concept of a project object model (POM)"
mvn_version="3.6.3"
mvn_tags=("echempad" "development")
mvn_systemcategories=("ConsoleOnly" "Java" "PackageManager")
mvn_arguments=("mvn")
mvn_commentary="Useful with Java projects"
mvn_binariesinstalledpaths=("bin/mvn;mvn")
mvn_downloadKeys=("bundleCompressed")
mvn_bundleCompressed_URL="https://ftp.cixug.es/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz"
mvn_bashfunctions=("mvn.sh")

nano_name="nano"
nano_description=""
nano_version="System dependent"
# TODO nano_tags=()
# TODO nano_systemcategories=()
nano_arguments=("nano")
nano_commentary="CLI File editor"
nano_packagenames=("nano")
nano_filekeys=("conf")
nano_conf_path="${HOME_FOLDER}/.nanorc"
nano_conf_content=("nanorc")
nano_manualcontentavailable="0;0;1"
install_nano_post()
{
  # Set nano as the default git editor
  if which git &>/dev/null; then
    git config --global core.editor "nano"
  fi

  # Set editor to nano using the entry displayed in update-alternatives --list editor
  if isRoot; then
    nano_default_path="$(update-alternatives --list editor | grep -Eo "^.*nano.*$" | head -1)"
    if [ -n "${nano_default_path}" ]; then
      update-alternatives --set editor "${nano_default_path}"
    fi
  fi
}
uninstall_nano_post()
{
  # Restore editor to the default one (usually vim)
  if isRoot; then
    update-alternatives --auto editor
  fi

  # Restore default editor to git if we have it installed
  if which git &>/dev/null; then
    git config --global core.editor "editor"
  fi

}

nautilus_name="Nautilus"
nautilus_description="Desktop manager"
nautilus_version="System dependent"
# TODO nautilus_tags=()
# TODO nautilus_systemcategories=()
nautilus_arguments=("nautilus")
nautilus_commentary="Standard file and desktop manager"
nautilus_bashinitializations=("nautilus.sh")
# TODO nautilus_launchernames=("org.gnome.Nautilus")
nautilus_launcherkeynames=("default")
nautilus_default_exec="nautilus"
nautilus_packagenames=("nautilus")

ncat_name="ncat"
ncat_description="Reverse shell"
ncat_version="System dependent"
# TODO ncat_tags=()
# TODO ncat_systemcategories=()
ncat_arguments=("ncat")
ncat_commentary="Reads and writes across the network"
ncat_packagenames=("ncat")

nedit_name="NEdit"
nedit_description=""
nedit_version="System dependent"
# TODO nedit_tags=()
# TODO nedit_systemcategories=()
nedit_arguments=("nedit")
nedit_commentary="Multi-purpose text editor and source code editor"
nedit_packagenames=("nedit")
# TODO nedit_launchernames=("nedit")
nedit_launcherkeynames=("default")
nedit_default_exec="nedit"

nemo_name="Nemo Desktop"
nemo_description="Access and organize files"
nemo_version="System dependent"
# TODO nemo_tags=("folders" "filesystem" "explorer")
# TODO nemo_systemcategories=("GTK" "Utility" "Core")
nemo_arguments=("nemo" "nemo_desktop")
nemo_commentary="File and desktop manager, usually with better options and less bugs than nautilus. *We recommend this explorer to view correctly the launchers*"
nemo_bashfunctions=("nemo.sh")
nemo_bashinitializations=("nemo_config.sh")
nemo_packagenames=("nemo")
nemo_packagedependencies=("dconf-editor")
nemo_description="File and desktop manager, usually with better options and less bugs than nautilus. *We recommend this explorer to view correctly the launchers*"
nemo_launcherkeynames=("defaultLauncher" "autostartLauncher")
nemo_defaultLauncher_exec="nemo %U"
nemo_defaultLauncher_name="Files"
nemo_defaultLauncher_ubuntuGetText="nemo"
nemo_defaultLauncher_actions=("openhome" "opencomputer" "opentrash" "openserver")
nemo_defaultLauncher_openhome_name="Home"
nemo_defaultLauncher_openhome_exec="nemo %U"
nemo_defaultLauncher_opencomputer_name="Computer"
nemo_defaultLauncher_opencomputer_exec="nemo computer:///"
nemo_defaultLauncher_opentrash_name="Trash"
nemo_defaultLauncher_opentrash_exec="nemo trash:///"
nemo_defaultLauncher_openserver_name="Server Connect"
nemo_defaultLauncher_openserver_exec="nemo-connect-server"
nemo_associatedfiletypes=("inode/directory" "application/x-gnome-saved-search")
# TODO 
nemo_launchercontents=("
[Desktop Entry]
OnlyShowIn=GNOME;Unity;KDE;
StartupNotify=false

")
nemo_autostartLauncher_name="Nemo"
nemo_autostartLauncher_comment="Start Nemo desktop at log in"
nemo_autostartLauncher_exec="nemo-desktop"
# TODO
nemo_autostartlaunchers=("
[Desktop Entry]
Type=Application
AutostartCondition=GSettings org.nemo.desktop show-desktop-icons
X-GNOME-AutoRestart=true
X-GNOME-Autostart-Delay=2
NoDisplay=false
")
nemo_flagsoverride=";;;;;1"  # Always autostart
nemo_keybindings=("nemo;<Super>e;Nemo File Explorer")

netflix_name="Netflix"
netflix_version="Google dependent"
netflix_tags=("film" "television" "internet_shortcuts")
netflix_systemcategories=("Player")
netflix_arguments=("netflix" "google_netflix")
netflix_commentary="View films and TV series online"
netflix_bashfunctions=("netflix.sh")
netflix_launcherkeynames=("default")
netflix_default_exec="xdg-open https://www.netflix.com"
netflix_description="Netflix opening in Browser"

netTools_name="net-tools"
netTools_description="Set of network tools"
netTools_version="System dependent"
# TODO netTools_tags=("network")
# TODO netTools_systemcategories=()
netTools_arguments=("net_tools")
netTools_commentary="GUI network interfaces. *We recommend this explorer to view correctly the launchers*"
netTools_bashfunctions=("net_tools.sh")
netTools_packagenames=("net-tools")

nmap_name="nmap"
nmap_description="Scan and network security used for port scanning."
nmap_version="System dependent"
# TODO nmap_tags=()
# TODO nmap_systemcategories=()
nmap_arguments=("nmap")

nodejs_name="NodeJS"
nodejs_description="JavaScript language for the developers."
nodejs_version=""
# TODO nodejs_tags=()
# TODO nodejs_systemcategories=()
nodejs_arguments=("node" "node_js")
nodejs_downloadKeys=("bundle")
nodejs_bundle_URL="https://nodejs.org/dist/v14.17.0/node-v14.17.0-linux-x64.tar.xz"
nodejs_binariesinstalledpaths=("bin/node;node" "bin/npm;npm" "bin/npx;npx")

npm_name="npm"
npm_description="Nodejs package manager"
npm_version="System dependent"
# TODO npm_tags=()
# TODO npm_systemcategories=()
npm_arguments=("npm")
npm_packagenames=("npm")
npm_launchernames=("npm")

notepadqq_name="Notepadqq"
notepadqq_description="Text editor that is designed by developers for the developers. It supports more than 100 programming languages"
notepadqq_version="System dependent"
# TODO notepadqq_tags=()
# TODO notepadqq_systemcategories=()
notepadqq_arguments=("notepad_qq")
notepadqq_packagenames=("notepadqq")
notepadqq_launchernames=("notepadqq")

notflix_name="Function notflix"
notflix_description="Stream title movies via console magnet tracking"
notflix_version="1.0"
# TODO notflix_tags=()
# TODO notflix_systemcategories=()
notflix_arguments=("notflix")
notflix_packagedependencies=("curl" "vlc")
notflix_bashfunctions=("notflix.sh")

obsStudio_name="Open Broadcaster Software Studio"
obsStudio_description="Streaming and recording software"
obsStudio_version="System dependent"
obsStudio_tags=("stream" "online")
obsStudio_systemcategories=("Utility" "Recorder")
obsStudio_arguments=("obs_studio" "obs")
obsStudio_commentary="The basic tool for a streamer"
# TODO port info obsStudio_launchernames=("com.obsproject.Studio")
obsStudio_launcherkeynames=("defautLauncher")
obsStudio_defaultLauncher_exec="obs"
obsStudio_packagedependencies=("ffmpeg")
obsStudio_packagenames=("obs-studio")

octave_name="GNU Octave"
octave_description="Programming language and IDE"
octave_version="1.0"
# TODO octave_tags=()
# TODO octave_systemcategories=()
octave_arguments=("octave" "gnu_octave" "octave_cli")
octave_bashfunctions=("octave.sh")
octave_packagenames=("octave")
#TODO octave_launchernames=("org.octave.Octave")
octave_launcherkeynames=("defaultLauncher")
octave_defaultLauncher_exec="octave"

okular_name="Okular"
okular_description="PDF viewer"
okular_version="System dependent"
# TODO okular_tags=()
# TODO okular_systemcategories=()
okular_arguments=("okular")
#TODO okular_launchernames=("org.kde.okular")
okular_packagenames=("okular")
octave_launcherkeynames=("defaultLauncher")
octave_defaultLauncher_exec="octave"

onedrive_name="OneDrive client"
onedrive_description="A free Microsoft OneDrive Client"
onedrive_version="2.4.13-1build1_amd64"
onedrive_tags=("iochem")
onedrive_systemcategories=("System" "Utility")
onedrive_arguments=("one_drive")
onedrive_commentary="Supports OneDrive Personal, OneDrive for Business, OneDrive for Office365 and SharePoint"
onedrive_downloadKeys=("debPackage")
onedrive_debPackage_installedPackages=("onedrive")
onedrive_debPackage_URL="http://es.archive.ubuntu.com/ubuntu/pool/universe/o/onedrive/onedrive_2.4.13-1build1_amd64.deb"
onedrive_launcherkeynames=("defaultLauncher")
onedrive_defaultLauncher_exec="onedrive --monitor --verbose ; sleep 5"
onedrive_defaultLauncher_terminal="true"
onedrive_defaultLauncher_actionkeynames=("sync" "reauthorize")
onedrive_defaultLauncher_sync_name="Sync files"
onedrive_defaultLauncher_sync_exec="onedrive --monitor --verbose ; sleep 5"
onedrive_defaultLauncher_reauthorize_name="Reauthorize"
onedrive_defaultLauncher_reauthorize_exec="onedrive --monitor --verbose --logout re-authorize ; sleep 5"

libreoffice_name="LibreOffice"
libreoffice_description="Office suite for open-source systems"
libreoffice_version="System dependent"
# TODO libreoffice_tags=()
# TODO libreoffice_systemcategories=()
libreoffice_arguments=("open_office" "office" "libre_office")
libreoffice_packagenames=("libreoffice-base-core" "libreoffice-impress" "libreoffice-calc" "libreoffice-math" "libreoffice-common" "libreoffice-ogltrans" "libreoffice-core" "libreoffice-pdfimport" "libreoffice-draw" "libreoffice-style-breeze" "libreoffice-gnome" "libreoffice-style-colibre" "libreoffice-gtk3" "libreoffice-style-elementary" "libreoffice-help-common" "libreoffice-style-tango" "libreoffice-help-en-us" "libreoffice-writer")
# TODO libreoffice_launchernames=("libreoffice-impress" "libreoffice-calc" "libreoffice-draw" "libreoffice-math" "libreoffice-startcenter" "libreoffice-writer")  # "libreoffice-xsltfilter"

opensshServer_name="openssh-server"
opensshServer_description="SSH server"
opensshServer_version="System dependent"
# TODO opensshServer_tags=()
# TODO opensshServer_systemcategories=()
opensshServer_arguments=("openssh_server")
opensshServer_packagenames=("openssh-server")
opensshServer_bashfunctions=("openssh_server.sh")
opensshServer_manualcontentavailable="0;0;1"
opensshServer_conf=(
"Port 3297  # Change default port for ssh server to listen"
"LogLevel VERBOSE  # Verbose on logs"
"LoginGraceTime 60  # Time allowed for a successful connection"
"PermitRootLogin no  # Do not allow root user to log in"
"PasswordAuthentication no  # Deactivate password logins"
"ChallengeResponseAuthentication no  # Uses a backend for extra challenges in authentication"
"AllowTcpForwarding no  # Can be used to exploit vulnerabilities"
"X11Forwarding no  # Can be used to tunnel graphical sessions but can be used as vulnerability"
"MaxStartups 2:100:3  # Allowed 2 unauthenticated connections to the server, 100 % chance of dropping with more than 2 connections, 3 simultaneous sessions allowed"
"AllowUsers  # Allow these users to access the ssh server"
"ClientAliveInterval 300  # Time that the server will wait before sending a null paint to keep the connection alive"
"ClientAliveCountMax 0  # Maximum number of keep-alive sent to client before dropping"
"PubkeyAuthentication yes  # Used to accept login by public keys infrastructure"
"RSAAuthentication yes  # Allow authentication with RSA key generation algorithm"
)
install_opensshServer_post()
{
  for conf_element in "${opensshServer_conf[@]}"; do
    append_text "${conf_element}" "${SSH_GLOBAL_CONF_PATH}"
  done
}
uninstall_opensshServer_post()
{
  for conf_element in "${opensshServer_conf[@]}"; do
    remove_line "${conf_element}" "${SSH_GLOBAL_CONF_PATH}"
  done
}

outlook_name="Outlook"
outlook_description="outlook opening in Browser"
outlook_version="Google dependent"
outlook_tags=("search" "internet_shortcuts")
outlook_systemcategories=("Email")
outlook_arguments=("outlook" "microsoft_outlook")
outlook_commentary="Email client from Microsoft"
outlook_bashfunctions=("outlook.sh")
outlook_launcherkeynames=("default")
outlook_default_exec="xdg-open https://outlook.live.com"

overleaf_name="Overleaf"
overleaf_version="Google dependent"
overleaf_tags=("LaTeX" "text_editor" "internet_shortcuts")
overleaf_systemcategories=("ProjectManagement" "Documentation" "TextEditor")
overleaf_arguments=("overleaf")
overleaf_commentary="Email client from Microsoft"
overleaf_bashfunctions=("overleaf.sh")
overleaf_launcherkeynames=("default")
overleaf_default_exec="xdg-open https://www.overleaf.com"
overleaf_description="overleaf opening in Browser"

p_name="Function p"
p_description="Check processes names and PID's from given port"
p_version="1.0"
p_tags=("bashfunctions" "bash" "info")
p_systemcategories=("System" "Utility")
p_arguments=("p" "port" "port_function" "p_function" "function_p")
p_commentary="A terminal shortcut"
p_bashfunctions=("p.sh")

pacman_name="Pac-man"
pacman_description="Implementation of the classical arcade game"
pacman_version="System dependent"
# TODO pacman_tags=()
# TODO pacman_systemcategories=()
pacman_arguments=("pacman")
# TODO pacman_launchernames=("pacman")
pacman_packagenames=("pacman")

parallel_name="GNUparallel"
parallel_description="Command-line driven utility for Linux and other Unix-like operating systems which allows the user to execute shell scripts or commands in parallel"
parallel_version="System dependent"
# TODO parallel_tags=()
# TODO parallel_systemcategories=()
parallel_arguments=("parallel" "gnu_parallel")
parallel_packagenames=("parallel")

pdfgrep_name="pdfgrep"
pdfgrep_description="CLI utility that makes it possible to search for text in a PDF file without opening the file"
pdfgrep_version="System dependent"
# TODO pdfgrep_tags=()
# TODO pdfgrep_systemcategories=()
pdfgrep_arguments=("pdfgrep")
pdfgrep_packagenames=("pdfgrep")

pgadmin_installationtype="pythonvenv"
pgadmin_arguments=("pgadmin" "pgadmin4")
pgadmin_binariesinstalledpaths=("lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgAdmin4.py;pgadmin")
pgadmin_confoverride_path="lib/${PYTHON_VERSION}/site-packages/pgadmin4/config_local.py"
pgadmin_confoverride_content="config_local.py"
pgadmin_executionscript_path="pgadmin_exec.sh"
pgadmin_executionscript_content="pgadmin_exec.sh"
pgadmin_filekeys=("confoverride" "executionscript")
pgadmin_description="PostgreSQL Tools"
pgadmin_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${pgadmin_description}
Encoding=UTF-8
GenericName=pgadmin4
Keywords=pgadmin
MimeType=
Name=pgAdmin 4
StartupNotify=true
StartupWMClass=pgadmin
Terminal=false
Type=Application
Version=1.0
Icon=${BIN_FOLDER}/pgadmin/lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgadmin/static/img/logo-256.png
Exec=bash ${BIN_FOLDER}/pgadmin/pgadmin_exec.sh
")
pgadmin_manualcontentavailable="0;1;0"
pgadmin_pipinstallations=("pgadmin4")
pgadmin_packagedependencies=("libgmp3-dev" "libpq-dev" "libapache2-mod-wsgi-py3")
pgadmin_readmeline="| pgAdmin | ${pgadmin_description} | Command \`pgadmin4\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
install_pgadmin_mid() {
  # Create a valid binary in the path. In this case if we want the same schema as other programs we need to set a
  # shebang that points to the virtual environment that we just created, so the python script of pgadmin has all the
  # information on how to call the script using the correct python interpreter, which is the one in the virtual
  # environment an not the python system interpreter.

  # Prepend shebang line to python3 interpreter of the venv
  echo "#!${BIN_FOLDER}/pgadmin/bin/python3" | cat - "${BIN_FOLDER}/pgadmin/lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgAdmin4.py" > "${BIN_FOLDER}/pgadmin/lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgAdmin4.py.tmp" && mv "${BIN_FOLDER}/pgadmin/lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgAdmin4.py.tmp" "${BIN_FOLDER}/pgadmin/lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgAdmin4.py"
  chmod +x "${BIN_FOLDER}/pgadmin/lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgAdmin4.py"
}
uninstall_pgadmin_mid() {
  :
}

php_name="php"
php_description="Programming language"
php_version="System dependent"
# TODO php_tags=()
# TODO php_systemcategories=()
php_arguments=("php")
php_packagenames=("php" "libapache2-mod-php" "php7.4" "libapache2-mod-php7.4" "php7.4-mysql" "php-common" "php7.4-cli" "php7.4-common" "php7.4-json" "php7.4-opcache" "php7.4-readline")

phppgadmin_installationtype="packagemanager"
phppgadmin_arguments=("phppgadmin")
phppgadmin_packagenames=("phppgadmin")
phppgadmin_downloads=("https://upload.wikimedia.org/wikipedia/commons/1/16/Google_Slides_2020_Logo.svg;phppgadmin.svg")
phppgadmin_url="http://localhost/phppgadmin"
phppgadmin_bashfunctions=("phppgadmin.sh")
phppgadmin_readmeline="| phppgadmin | GUI for SQL Database Management | It runs an instance of the program at localhost/phppgadmin ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
phppgadmin_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=GUI for SQL Database Management
Encoding=UTF-8
GenericName=phppgadmin
Keywords=phppgadmin
MimeType=
Name=phpPgAdmin
StartupNotify=true
StartupWMClass=phppggadmin
Terminal=false
Type=Application
Version=1.0
Icon=${BIN_FOLDER}/pgadmin/lib/${PYTHON_VERSION}/site-packages/pgadmin4/pgadmin/static/img/logo-256.png
Exec=nohup xdg-open ${phppgadmin_url}
TryExec=xdg-open
")

php_name="pluma"
php_description="Fork of gedit 2.0 that supports many plugins and new features"
php_version="System dependent"
# TODO php_tags=()
# TODO php_systemcategories=()
pluma_arguments=("pluma")
pluma_bashfunctions=("pluma.sh")
#TODO pluma_launchernames=("pluma")
pluma_packagenames=("pluma")
pluma_launcherkeynames=("defaultLauncher")
pluma_defaultLauncher_exec="pluma"

postman_name="=Postman"
postman_description="Application to maintain and organize collections of REST API calls"
postman_version="System dependent"
# TODO postman_tags=()
# TODO postman_systemcategories=()
postman_arguments=("postman")
postman_binariesinstalledpaths=("Postman;postman")
postman_downloadKeys=("bundle")
postman_bundle_URL="https://dl.pstmn.io/download/latest/linux64"
postman_launcherkeynames=("defaultLauncher")
postman_defaultLauncher_exec="postman"
postman_launchercontents=("
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=postman
Comment=${postman_description}
Icon=${BIN_FOLDER}/postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
")

presentation_name="Google Presentation"
presentation_version="Google dependent"
presentation_tags=("presentation" "google" "internet_shortcuts")
presentation_systemcategories=("ProjectManagement" "Documentation" "TextEditor")
presentation_arguments=("presentation" "google_presentation")
presentation_commentary="Create presentations online"
presentation_bashfunctions=("presentation.sh")
presentation_launcherkeynames=("default")
presentation_default_exec="xdg-open https://docs.google.com/presentation/"
presentation_description="Google Presentation opening in Browser"

prompt_name="Function prompt"
prompt_description="Installs a new colourful prompt on terminal window"
prompt_version="1.0"
prompt_tags=("bashfunctions" "terminal" "info")
prompt_systemcategories=("System" "Utility")
prompt_arguments=("prompt")
prompt_commentary="Adds a personalized prompt that shows the date, return code of last executed program, user, group and working directory. It also changes the prompt colour of introduced text to green. It changes the terminal windows title, adds colourful aliases and ensures completion"
prompt_bashfunctions=("prompt.sh" "prompt_command.sh")

psql_name="PostGreSQL"
psql_description="Databases and Database Managers"
psql_version="System dependent"
# TODO psql_tags=()
# TODO psql_systemcategories=()
psql_arguments=("psql" "postgresql")
psql_packagedependencies=("libc6-i386" "lib32stdc++6" "libc6=2.31-0ubuntu9.2")
psql_packagenames=("postgresql-client-12" "postgresql-12" "libpq-dev" "postgresql-server-dev-12")

pull_name="Function pull"
pull_description="Decorates call to git pull forcing to not fast-forward"
pull_version="1.0"
pull_tags=("gitbashfunctions" "git")
pull_systemcategories=("System" "Utility")
pull_arguments=("pull")
pull_commentary="A terminal function for git"
pull_bashfunctions=("pull.sh")

push_name="Function push"
push_description="Decorates call to git push by setting upstream branch if needed"
push_version="1.0"
push_tags=("gitbashfunctions" "git")
push_systemcategories=("System" "Utility")
push_arguments=("push")
push_commentary="A terminal function for git"
push_bashfunctions=("push.sh")

pycharm_name="PyCharm Community"
pycharm_description="Integrated development environment used in computer programming"
pycharm_version="2021.3"
pycharm_tags=("IDE" "development" "text editor" "dev" "programming" "python")
pycharm_systemcategories=("Debugger" "IDE" "WebDevelopment" "ComputerScience" "Development")
pycharm_arguments=("pycharm" "pycharm_community")
pycharm_icon="pycharm.png"
pycharm_associatedfiletypes=("text/sh" "text/x-python" "text/x-python3")
pycharm_bashfunctions=("pycharm.sh")
pycharm_binariesinstalledpaths=("bin/pycharm.sh;pycharm")
pycharm_downloadKeys=("bundle")
pycharm_bundle_URL="https://download.jetbrains.com/python/pycharm-community-2021.3.tar.gz"
pycharm_keybindings=("pycharm;<Primary><Alt><Super>p;Pycharm")
pycharm_launcherkeynames=("launcher")
pycharm_launcher_exec="pycharm %F"
pycharm_launcher_windowclass="jetbrains-pycharm"
pycharm_launcher_actionkeynames=("newwindow")
pycharm_launcher_newwindow_name="Pycharm New Window"
pycharm_launcher_newwindow_exec="pycharm"

pycharmpro_name="PyCharm Professional"
pycharmpro_description="Integrated development environment used in computer programming"
pycharmpro_version="2021.3"
pycharmpro_tags=("IDE" "development" "text editor" "dev" "programming" "python")
pycharmpro_systemcategories=("Debugger" "IDE" "WebDevelopment" "ComputerScience" "Development")
pycharmpro_arguments=("pycharm_pro")
pycharmpro_icon="pycharmpro.png"
pycharmpro_associatedfiletypes=("text/sh" "text/x-python" "text/x-python3")
pycharmpro_bashfunctions=("pycharmpro.sh")
pycharmpro_binariesinstalledpaths=("bin/pycharm.sh;pycharmpro")
pycharmpro_downloadKeys=("bundle")
pycharmpro_bundle_URL="https://download.jetbrains.com/python/pycharm-professional-2021.3.tar.gz"
pycharmpro_launcherkeynames=("launcher")
pycharmpro_launcher_exec="pycharmpro %F"
pycharmpro_launcher_windowclass="jetbrains-pycharmpro"
pycharmpro_launcher_actionkeynames=("newwindow")
pycharmpro_launcher_newwindow_name="Pycharm Professional New Window"
pycharmpro_launcher_newwindow_exec="pycharmpro"

pypy3_name="pypy3"
pypy3_description="Faster interpreter for the Python3 programming language"
pypy3_version="System dependent"
# TODO pypy3_tags=()
# TODO pypy3_systemcategories=()
pypy3_arguments=("pypy3" "pypy")
pypy3_binariesinstalledpaths=("bin/pypy3;pypy3" "bin/pip3.6;pypy3-pip")
pypy3_downloadKeys=("bundle")
pypy3_bundle_URL="https://downloads.python.org/pypy/pypy3.6-v7.3.1-linux64.tar.bz2"
pypy3_manualcontentavailable="0;1;0"
pypy3_packagedependencies=("pkg-config" "libfreetype6-dev" "libpng-dev" "libffi-dev")
# Installs pypy3 dependencies, pypy3 and basic subsystems (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
install_pypy3_mid() {
  # Install subsystems using pip
  "${BIN_FOLDER}/pypy3/bin/pypy3" -m ensurepip

  # Forces download of pip and of subsystems
  "${BIN_FOLDER}/pypy3/bin/pip3.6" --no-cache-dir -q install --upgrade pip
  "${BIN_FOLDER}/pypy3/bin/pip3.6" --no-cache-dir install cython numpy
  # Currently not supported
  # ${BIN_FOLDER}/${pypy3_version}/bin/pip3.6 --no-cache-dir install matplotlib
}
# Installs pypy3 dependencies, pypy3 and basic subsystems (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
uninstall_pypy3_mid() {
  :
}

python3_name="Python3"
python3_description="Interpreted, high-level and general-purpose programming language"
python3_version="System dependent"
# TODO python3_tags=()
# TODO python3_systemcategories=()
python3_arguments=("python_3" "python" "v")
python3_bashfunctions=("v.sh")
python3_packagenames=("python-dev" "python3-dev" "python3-pip" "python3-venv" "python3-wheel" "python3.8-venv")  # "python3-pyqt5" "python3-pyqt4" "python-qt4"

R_name="R"
R_description="Programming language"
R_version="System dependent"
# TODO R_tags=()
# TODO R_systemcategories=()
R_arguments=("R" "r_base")
R_jupyterLab_function=("
install.packages('IRkernel')
install.packages(c('rzmq', 'repr', 'uuid','IRdisplay'),
                  repos = c('http://irkernel.github.io/',
                  getOption('repos')),
                  type = 'source')
IRkernel::installspec()
")
R_launchernames=("R")
R_packagenames=("r-base")
R_packagedependencies=("libzmq3-dev" "python3-zmq")

reddit_name="Reddit"
reddit_version="Google dependent"
reddit_tags=("forum" "internet_shortcuts")
reddit_systemcategories=("InstantMessaging" "Chat")
reddit_arguments=("reddit")
reddit_commentary="Reddit forum"
reddit_bashfunctions=("reddit.sh")
reddit_launcherkeynames=("default")
reddit_default_exec="xdg-open https://www.reddit.com"
reddit_description="Google reddit opening in Browser"

remmina_name="Remmina"
remmina_description="Remote Desktop Contol"
remmina_version="System dependent"
# TODO remmina_tags=()
# TODO remmina_systemcategories=()
remmina_arguments=("remmina")
remmina_packagenames=("remmina")
# TODO remmina_launchernames=("org.remmina.Remmina")
remmina_launcherkeynames=("defaultLauncher")
remmina_defaultLauncher_exec="remmina"

rosegarden_name="Rosegarden"
rosegarden_description="Software for music production"
rosegarden_version="System dependent"
# TODO rosegarden_tags=()
# TODO rosegarden_systemcategories=()
rosegarden_arguments=("rosegarden")
rosegarden_bashfunctions=("rosegarden.sh")
rosegarden_packagenames=("rosegarden")
# TODO rosegarden_launchernames=("com.rosegardenmusic.rosegarden")
rosegarden_launcherkeynames=("defaultLauncher")
rosegarden_defaultLauncher_exec="rosegarden"

rstudio_name="RStudio"
rstudio_description="Default application for .R files "
rstudio_version="System dependent"
rstudio_tags=("rstudio")
rstudio_systemcategories=("Network")
rstudio_arguments=("r_studio")
rstudio_associatedfiletypes=("text/plain")
rstudio_bashfunctions=("rstudio.sh")
rstudio_binariesinstalledpaths=("bin/rstudio;rstudio")
rstudio_downloadKeys=("bundle" "packageDependency")
rstudio_packageDependency_URL="http://security.debian.org/debian-security/pool/updates/main/o/openssl1.0/libssl1.0.2_1.0.2u-1~deb9u4_amd64.deb"
rstudio_bundle_URL="https://download1.rstudio.org/desktop/debian9/x86_64/rstudio-1.4.1717-amd64-debian.tar.gz"
rstudio_launcherkeynames=("default")
rstudio_default_windowClass="RStudio"
rstudio_associatedfiletypes=("text/plain")
rstudio_packagedependencies=("libssl-dev" "openssl102")

rsync_name="Grsync"
rsync_description="Software for file/folders synchronization"
rsync_version="System dependent"
# TODO rsync_tags=()
# TODO rsync_systemcategories=()
rsync_arguments=("rsync" "grsync")
rsync_packagedependencies=("libcanberra-gtk-module" "libcanberra-gtk3-module" "libcanberra-gtk-module:i386")
rsync_packagenames=("rsync" "grsync")
# TODO rsync_launchernames=("grsync")
rsync_bashfunctions=("rsync.sh")
rsync_launcherkeynames=("grsyncLauncher")
rsync_grsyncLauncher_exec="grsync"

rust_name="Rust"
rust_description="Programming Language"
rust_version="System dependent"
# TODO rust_tags=()
# TODO rust_systemcategories=()
rustc_arguments=("rustc")
rustc_packagenames=("rustc")
rustc_packagedependencies=("cmake" "build-essential")
# rustc_url=("https://sh.rustup.rs")

s_name="Function s"
s_description="Function to execute any program silently and in the background"
s_version="1.0"
s_tags=("bashfunctions" "terminal")
s_systemcategories=("System" "Utility")
s_arguments=("s")
s_commentary="A terminal function"
s_bashfunctions=("s.sh")

scala_name=Scala""
scala_description="Programming language"
scala_version="System dependent"
# TODO scala_tags=()
# TODO scala_systemcategories=()
scala_arguments=("scala")
scala_packagenames=("scala")

scilab_name="Scilab"
# TODO scilab_description=""
scilab_version="System dependent"
# TODO scilab_tags=()
# TODO scilab_systemcategories=()
scilab_arguments=("scilab")
scilab_bashfunctions=("scilab.sh")
scilab_binariesinstalledpaths=("bin/scilab;scilab" "bin/scilab-cli;scilab-cli" "bin/scinotes;scinotes")
scilab_packagedependencies=("openjdk-8-jdk-headless" "libtinfo5")
scilab_downloadKeys=("bundle")
scilab_bundle_URL="https://www.scilab.org/download/6.1.0/scilab-6.1.0.bin.linux-x86_64.tar.gz"
scilab_packagenames=("scilab")
scilab_launcherkeynames=("defaultLauncher") # TODO
scilab_defaultLauncher_exec="bash ${BIN_FOLDER}/scilab/bin/scilab"
scilab_launchercontents=("
[Desktop Entry]
Comment=Scientific software package for numerical computations
Comment[fr]=Logiciel scientifique de calcul numérique
Comment[de]=eine Wissenschaftssoftware für numerische Berechnungen
Comment[ru]=Научная программа для численных расчётов
Exec=bash ${BIN_FOLDER}/scilab/bin/scilab
GenericName=Scientific Software Package
GenericName[fr]=Logiciel de calcul numérique
GenericName[de]=Wissenschaftssoftware
GenericName[ru]=Научный программный комплекс
Icon=${BIN_FOLDER}/scilab/share/icons/hicolor/256x256/apps/scilab.png
MimeType=application/x-scilab-sci;application/x-scilab-sce;application/x-scilab-tst;application/x-scilab-dem;application/x-scilab-sod;application/x-scilab-xcos;application/x-scilab-zcos;application/x-scilab-bin;application/x-scilab-cosf;application/x-scilab-cos;
Name=Scilab
StartupNotify=false
Terminal=false
Type=Application
Categories=Science;Math;
Keywords=Science;Math;Numerical;Simulation
")

screenshots_name="Screenshots"
screenshots_description="Takes a screenshot and saves it to custom ~/Images/screenshots folder and save it to the clipboard for pasting"
screenshots_version="System dependent"
# TODO screenshots_tags=()
# TODO screenshots_systemcategories=()
screenshots_arguments=("screenshots")
screenshots_filekeys=("screenshotwindow" "screenshotarea" "screenshotfull")
screenshots_keybindings=("scr-area;<Primary><Alt><Super>a;Screenshot Area" "scr-full;<Primary><Alt><Super>s;Screenshot Full" "scr-window;<Primary><Alt><Super>w;Screenshot Window")
screenshots_screenshotwindow_path="screenshot_window.sh"
screenshots_screenshotwindow_content="screenshot_window.sh"
screenshots_screenshotarea_path="screenshot_area.sh"
screenshots_screenshotarea_content="screenshot_area.sh"
screenshots_screenshotfull_path="screenshot_full.sh"
screenshots_screenshotfull_content="screenshot_full.sh"
screenshots_binariesinstalledpaths=("screenshot_area.sh;scr-area" "screenshot_window.sh;scr-window" "screenshot_full.sh;scr-full")
screenshots_packagedependencies=("gnome-screenshot" "xclip")

sherlock_installationtype="repositoryclone"
sherlock_arguments=("sherlock")
sherlock_bashfunctions=("sherlock.sh")
sherlock_repositoryurl="https://github.com/sherlock-project/sherlock.git"
sherlock_manualcontentavailable="0;0;1"
sherlock_readmeline="| Sherlock | Tool to obtain linked social media accounts using user name | Commands \`sherlock\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
install_sherlock_post() {
  python3 -m pip install -r "${BIN_FOLDER}/sherlock/requirements.txt"
}
uninstall_sherlock_post() {
  :
}

shortcuts_name="Path shortcuts"
shortcuts_description="Installs custom variables pointing to interesting folders regarding customizer"
shortcuts_version="1.0"
shortcuts_tags=("bashfunctions")
shortcuts_systemcategories=("System" "Utility")
shortcuts_arguments=("shortcuts")
shortcuts_commentary="A terminal function"
shortcuts_bashfunctions=("shortcuts.sh")

shotcut_name="Shotcut"
shotcut_description="Cross-platform video editing"
shotcut_version="System dependent"
shotcut_tags=("video" "editVideo" "videoEdit" "editor" "editing")
shotcut_systemcategories=("VideoEdit" "Video")
shotcut_arguments=("shotcut")
shotcut_commentary="Cut scenes and sequences to edit films and videos."
shotcut_launcherkeynames="default"
shotcut_default_exec="shotcut"
shotcut_default_windowclass="ShotCut"
shotcut_packagenames=("shotcut")

shotwell_name="Shotwell"
shotwell_description="Media organizer"
shotwell_version="System dependent"
# TODO shotwell_tags=()
# TODO shotwell_systemcategories=()
shotwell_arguments=("shotwell")
# TODO shotwell_launchernames=("shotwell")
shotwell_packagenames=("shotwell")
shotwell_launcherkeynames=("defaultLauncher")
shotwell_defaultLauncher_exec="shotwell"

# TODO @AleixMT wontfix
skype_name="Skype"
skype_description="Call & conversation tool service"
skype_version="System dependent"
# TODO skype_tags=()
# TODO skype_systemcategories=()
skype_arguments=("skype")
skype_packagenames=("skype")
skype_launchernames=("skypeforlinux")
skype_downloadKeys=("bundle")
skype_bundle_URL="https://go.skype.com/skypeforlinux-64.deb"
skype_package_manager_override="apt-get"

slack_name="Slack"
slack_description="Platform to coordinate your work with a team"
slack_version="System dependent"
# TODO slack_tags=()
# TODO slack_systemcategories=()
slack_arguments=("slack")
slack_packagenames=("slack-desktop")
slack_downloadKeys=("bundle")
slack_bundle_URL="https://downloads.slack-edge.com/linux_releases/slack-desktop-4.11.1-amd64.deb"
slack_package_manager_override="apt-get"
slack_launchernames=("slack")

sonarqube_name="Sonarqube"
sonarqube_description="Platform to evaluate source code"
sonarqube_version="System dependent"
# TODO sonarqube_tags=()
# TODO sonarqube_systemcategories=()
sonarqube_arguments=("sonarqube")
sonarqube_binariesinstalledpaths=("bin/linux-x86-64/sonar.sh;sonar")
sonarqube_downloadKeys=("bundle")
sonarqube_bundle_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.0.1.46107.zip"

sonicPi_name="Sonic Pi"
sonicPi_description="programming language that ouputs sounds as compilation product"
sonicPi_version="System dependent"
# TODO sonicPi_tags=()
# TODO sonicPi_systemcategories=()
sonicPi_arguments=("sonic_pi")
# TODO sonicPi_launchernames=("sonic-pi")
sonicPi_packagenames=("sonic-pi")
sonicPi_launcherkeynames=("defaultLauncher")
sonicPi_defaultLauncher_exec="sonic-pi"

soundcloud_name="Soudcloud"
soundcloud_description="Soudcloud opening in Browser"
soundcloud_version="Google dependent"
soundcloud_tags=("music" "internet_shortcuts")
soundcloud_systemcategories=("Music" "Player")
soundcloud_arguments=("soudcloud")
soundcloud_commentary="soundcloud listen music online"
soundcloud_bashfunctions=("soundcloud.sh")
soundcloud_launcherkeynames=("default")
soundcloud_default_exec="xdg-open https://www.soundcloud.com"

spotify_name="Spotify"
spotify_description="Play music in stream"
spotify_version="1.1.72"
spotify_tags=("music" "stream")
spotify_systemcategories=("Music" "Audio")
spotify_arguments=("spotify")
spotify_icon="spotify.png"
spotify_launcherkeynames=("launcher")
spotify_launcher_exec="spotify %U"
spotify_launcher_actionkeynames=("Playpause" "Next" "Previous" "Stop")
spotify_launcher_Playpause_name="⏯"
spotify_launcher_Playpause_exec="dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"
spotify_launcher_Next_name="⏭"
spotify_launcher_Next_exec="dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"
spotify_launcher_Previous_name="⏮"
spotify_launcher_Previous_exec="dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous"
spotify_launcher_Stop_name="⏹"
spotify_launcher_Stop_exec="dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop"
spotify_bashfunctions=("spotify.sh")
spotify_launchernames=("spotify")
spotify_downloadKeys=("bundle")
spotify_bundle_URL="https://repository-origin.spotify.com/pool/non-free/s/spotify-client/spotify-client_1.1.72.439.gc253025e_amd64.deb"
spotify_package_manager_override="apt-get"
spotify_packagedependencies=("libgconf-2-4")
spotify_readmeline="| Spotify | Music streaming service | Command \`spotify\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

spreadsheets_name="Google Spreadsheets"
spreadsheets_description="Google Spreadsheets opening in Browser"
spreadsheets_version="Google dependent"
spreadsheets_tags=("google" "spreadsheets" "internet_shortcuts")
spreadsheets_systemcategories=("Documentation" "Spreadsheet")
spreadsheets_arguments=("spreadsheets" "google_spreadsheets")
spreadsheets_commentary="spreadsheets editor online"
spreadsheets_bashfunctions=("spreadsheets.sh")
spreadsheets_launcherkeynames=("default")
spreadsheets_default_exec="xdg-open https://docs.google.com/spreadsheets"

ssh_name="ssh"
ssh_description="SSH client"
ssh_version="System dependent"
# TODO ssh_tags=()
# TODO ssh_systemcategories=()
ssh_arguments=("ssh")
ssh_packagenames=("ssh-client")
# ssh_downloads=("https://upload.wikimedia.org/wikipedia/commons/6/64/Human-folder-remote-ssh.svg;ssh_icon.svg")
ssh_bashfunctions=("ssh.sh")
ssh_packagedependencies=("openssh-sftp-server" "openssh-client")
ssh_launcherkeynames=("defaultLauncher")
ssh_defaultLauncher_exec="ssh"
ssh_launchercontents=("[Desktop Entry]
Categories=ssh;remote;shell;
Comment=Remote access to a server through a secure channel
Encoding=UTF-8
Exec=sssh
GenericName=Secure Shell
Icon=${BIN_FOLDER}/ssh/ssh_icon.svg
Keywords=ssh;remote;shell
MimeType=
Name=SSH
StartupNotify=true
StartupWMClass=ssh
Terminal=true
TryExec=ssh
Type=Application
Version=1.0
")

status_name="Function status"
status_description="Alias of git status"
status_version="1.0"
status_tags=("gitbashfunctions" "terminal")
status_systemcategories=("System" "Utility")
status_arguments=("status")
status_commentary="A terminal function"
status_bashfunctions=("status.sh")

steam_name="Steam"
steam_description="Video game digital distribution service"
steam_version="System dependent"
# TODO steam_tags=()
# TODO steam_systemcategories=()
steam_arguments=("steam")
steam_launchernames=("steam")
steam_packagenames=("steam-launcher")
steam_packagedependencies=("curl")
steam_downloadKeys=("bundle")
steam_bundle_URL="https://steamcdn-a.akamaihd.net/client/installer/steam.deb"
steam_package_manager_override="apt-get"

# @TODO tested
studio_name="Android Studio"
studio_description="IDE for Android, Google's operating system"
studio_version="Google dependent"
studio_tags=("ide" "graphical" "programming" "android" "studio" "dev")
studio_systemcategories=("Development" "Java" "WebDevelopment" "IDE")
studio_arguments=("studio" "android_studio")
studio_commentary="The choice when developing Android apps"
studio_bashfunctions=("studio.sh")
studio_binariesinstalledpaths=("bin/studio.sh;studio")
studio_downloadKeys=("bundleCompressed")
studio_bundleCompressed_URL="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2021.2.1.14/android-studio-2021.2.1.14-linux.tar.gz"
studio_launcherkeynames=("defaultLauncher")
studio_defaultLauncher_exec="studio %F"
studio_defaultLauncher_windowclass="jetbrains-android-studio"

sublime_name="Sublime Text"
sublime_description="Source code editor with an emphasis on source code editing"
sublime_version="sublime_text_build_4126_x64"
sublime_tags=("sublime" "text" "studio" "dev")
sublime_systemcategories=("IDE" "Development")
sublime_arguments=("sublime" "sublime_text" "subl")
sublime_commentary="Text Editor, programming..."
sublime_keybindings=("sublime;<Primary><Alt><Super>e;Sublime Text")
sublime_associatedfiletypes=("text/x-sh" "text/x-c++hdr" "text/x-c++src" "text/x-chdr" "text/x-csrc" "text/x-python" "text/x-python3")
sublime_bashfunctions=("sublime.sh")
sublime_binariesinstalledpaths=("sublime_text;sublime")
sublime_downloadKeys=("bundle")
sublime_bundle_URL="https://download.sublimetext.com/sublime_text_build_4126_x64.tar.xz"
sublime_launcherkeynames=("default")
sublime_default_exec="sublime %F"
sublime_default_windowclass="Sublime"

sudoku_name="GNOME Sudoku"
sudoku_description="Implementation for GNU systems of the famous popular mathematical game sudoku"
sudoku_version="System dependent"
sudoku_tags=("sudoku" "game" "gnome" "strategy")
sudoku_systemcategories=("BoardGame" "LogicGame" "GNOME" "GTK" "Game" "BoardGame")
sudoku_arguments=("gnome_sudoku" "sudoku")
sudoku_commentary="Click and play"
# TODO sudoku_launchernames=("org.gnome.Sudoku")
sudoku_launcherkeynames=("default")
sudoku_default_exec="gnome-sudoku"
sudoku_packagenames=("gnome-sudoku")

synaptic_name="Synaptic Package Manager"
synaptic_description="Package Manager"
synaptic_version="System dependent"
synaptic_tags=("packageManager")
synaptic_systemcategories=("PackageManager" "GTK" "System" "Settings")
synaptic_arguments=("synaptic")
synaptic_commentary="Graphical installation manager to install, remove and upgrade software packages"
synaptic_packagenames=("synaptic")
synaptic_launcherkeynames=("default")
synaptic_default_windowclass="synaptic"
synaptic_default_exec="synaptic"
synaptic_default_ubuntuGetText="synaptic"

sysmontask_installationtype="repositoryclone"
sysmontask_name="Sysmontask"
sysmontask_description="Control panel for linux"
sysmontask_version="System dependent"
# TODO sysmontask_tags=()
# TODO sysmontask_systemcategories=()
sysmontask_arguments=("sysmontask")
sysmontask_flagsoverride="0;;;;;"  # To install the cloned software it has to be run as root
sysmontask_bashfunctions=("sysmontask.sh")
# TODO sysmontask_launchernames=("SysMonTask")
sysmontask_manualcontentavailable="0;1;0"
sysmontask_repositoryurl="https://github.com/KrispyCamel4u/SysMonTask.git"
install_sysmontask_mid() {
  (
    cd "${BIN_FOLDER}/sysmontask" || exit
    python3 setup.py install
  )
}
uninstall_sysmontask_mid() {
  :
}

systemFonts_installationtype="environmental"
systemFonts_name="Change default fonts"
systemFonts_description="Sets pre-defined fonts to desktop environment."
systemFonts_version="System dependent"
# TODO systemFonts_tags=()
# TODO systemFonts_systemcategories=()
systemFonts_arguments=("system_fonts")
systemFonts_commentary="A new set of fonts is updated in the system's screen."
systemFonts_bashinitializations=("
  # Check if gsettings command is available
  if ! command -v gsettings &> /dev/null
  then
    return
  fi

  # Interface text
  gsettings set org.gnome.desktop.interface font-name 'Roboto Medium 11'
  # Document text //RF
  gsettings set org.gnome.desktop.interface document-font-name 'Fira Code weight=453 10'
  # Monospaced text
  gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Regular 12'
  # Inherited window titles
  gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Hermit Bold 9'
")
systemFonts_readmeline="|  |  |  || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

teamviewer_name="Team Viewer"
teamviewer_description="Video remote pc control"
teamviewer_version="System dependent"
# TODO teamviewer_tags=()
# TODO teamviewer_systemcategories=()
teamviewer_arguments=("teamviewer")
# TODO teamviewer_launchernames=("com.teamviewer.TeamViewer")
teamviewer_downloadKeys=("bundle")
teamviewer_bundle_URL="https://download.teamviewer.com/download/linux/teamviewer_amd64.deb"
teamviewer_package_manager_override="apt-get"
teamviewer_launcherkeynames=("defaultLauncher")
teamviewer_defaultLauncher_exec="teamviewer"

teams_name="Microsoft Teams"
teams_description="Video Conference, calls and meetings"
teams_version="System dependent"
# TODO teams_tags=()
# TODO teams_systemcategories=()
teams_arguments=("teams" "microsoftteams")
teams_launchernames=("teams")
teams_packagenames=("teams")
teams_downloadKeys=("bundle")
teams_bundle_URL="https://go.microsoft.com/fwlink/p/?LinkID=2112886&clcid=0x40a&culture=es-es&country=ES"

# TODO: Tested
telegram_name="Telegram"
telegram_description="Cloud-based instant messaging software and application servic"
telegram_version="System dependent"
telegram_tags=("chat" "network" "social")
telegram_systemcategories=("Network" "Chat")
telegram_arguments=("telegram")
telegram_commentary="Open source messaging platform"
telegram_binariesinstalledpaths=("Telegram;telegram")
telegram_bashfunctions=("telegram.sh")
telegram_downloadKeys=("bundle")
telegram_bundle_URL="https://telegram.org/dl/desktop/linux"
telegram_launcherkeynames=("default")
telegram_default_windowclass="Telegram"
telegram_default_exec="telegram -- %u"
telegram_associatedfiletypes=("x-scheme-handler/tg")

templates_name="Templates"
templates_description="Different collection of templates for starting code projects: Python3 script (\`.py\`), Bash script (\`.sh\`), LaTeX document (\`.tex\`), C script (\`.c\`), C header script (\`.h\`), makefile example (\`makefile\`) and empty text file (\`.txt\`)"
templates_version="1.0"
templates_tags=("bashfunctions" "terminal")
templates_systemcategories=("System" "Utility")
templates_arguments=("templates")
templates_commentary="In the file explorer, right click on any folder to see the contextual menu of \"create document\", where all the templates are located"
templates_filekeys=("c" "headers" "makefile" "python" "bash" "latex" "empty")
templates_c_path="${XDG_TEMPLATES_DIR}/c_script.c"
templates_c_content="c_script.c"
templates_headers_path="${XDG_TEMPLATES_DIR}/c_script_header.h"
templates_headers_content="c_script_header.h"
templates_makefile_path="${XDG_TEMPLATES_DIR}/makefile"
templates_makefile_content="makefile"
templates_python_path="${XDG_TEMPLATES_DIR}/python3_script.py"
templates_python_content="python3_script.py"
templates_bash_path="${XDG_TEMPLATES_DIR}/shell_script.sh"
templates_bash_content="shell_script.sh"
templates_latex_path="${XDG_TEMPLATES_DIR}/latex_document.tex"
templates_latex_content="latex_document.tex"
templates_empty_path="${XDG_TEMPLATES_DIR}/empty_text_file.txt"
templates_empty_content="empty_text_file.txt"

terminal_name="GNOME Terminal"
terminal_description="Terminal of the system"
terminal_version="System dependent"
terminal_tags=("terminal")
terminal_systemcategories=("GNOME" "GTK")
terminal_arguments=("gnome_terminal")
terminal_commentary="Open a new gnome-terminal window"
terminal_keybindings=("gnome-terminal;<Primary><Alt><Super>t;GNOME Terminal")
# TODO: terminal_launchernames=("org.gnome.Terminal")
terminal_launcherkeynames=("default")
terminal_default_exec="gnome-terminal"
terminal_packagenames=("gnome-terminal")

# TODO: Tested
terminalBackground_name="Terminal Background"
terminalBackground_description="Change color palette and apply other custom settings of gnome-terminal"
terminalBackground_version="1.0"
terminalBackground_tags=("terminal" "customization" "palette")
terminalBackground_systemcategories=("Terminal")
terminalBackground_arguments=("terminal_background")
terminalBackground_commentary="Fancy"
terminalBackground_bashinitializations=("terminal_background.sh")

terminator_name="Terminator"
terminator_description="Terminal emulator for Linux programmed in Python"
terminator_version="System dependent"
# TODO terminator_tags=()
# TODO terminator_systemcategories=()
terminator_arguments=("terminator")
# TODO terminator_launchernames=("terminator")
terminator_packagenames=("terminator")
terminator_launcherkeynames=("defaultLauncher")
terminator_defaultLauncher_exec="terminator"

thunderbird_name="Thunderbird"
thunderbird_description="Email, personal information manager, news, RSS and chat client"
thunderbird_version="System dependent"
# TODO thunderbird_tags=()
# TODO thunderbird_systemcategories=()
thunderbird_arguments=("thunderbird")
# TODO thunderbird_launchernames=("thunderbird")
thunderbird_packagenames=("thunderbird")
thunderbird_bashfunctions=("thunderbird.sh")
thunderbird_launcherkeynames=("defaultLauncher")
thunderbird_defaultLauncher_exec="thunderbird"

tilix_name="Tilix"
tilix_description="Advanced GTK3 tiling terminal emulator"
tilix_version="System dependent"
# TODO tilix_tags=()
# TODO tilix_systemcategories=()
tilix_arguments=("tilix")
# TODO tilix_launchernames=("com.gexperts.Tilix")
tilix_packagenames=("tilix")
tilix_launcherkeynames=("defaultLauncher")
tilix_defaultLauncher_exec="tilix"

tmux_name="Terminal multiplexor"
tmux_description="Terminal multiplexor"
tmux_version="System dependent"
tmux_tags=("terminal" "sessions")
tmux_systemcategories=("System" "Utility")
tmux_arguments=("tmux")
tmux_commentary="Increase productivity using terminal. Manage sessions, windows and panes."
tmux_launcherkeynames=("defaultLauncher")
tmux_defaultLauncher_exec="tmux"
tmux_defaultLauncher_terminal="true"
tmux_packagenames=("tmux")
tmux_packagedependencies=("xdotool" "xclip" "tmuxp" "bash-completion")
tmux_bashfunctions=("tmux_functions.sh")
tmux_filekeys=("tmuxconf" "clockmoji" "cronjob")
tmux_clockmoji_content="tmux_clockmoji.sh"
tmux_clockmoji_path="clockmoji.sh"
tmux_tmuxconf_content="tmux.conf"
tmux_tmuxconf_path="${HOME_FOLDER}/.tmux.conf"
tmux_cronjob_content="cronjob"
tmux_cronjob_path="cronjob"
tmux_manualcontentavailable="0;0;1"
install_tmux_post() {
  if [ -n "${SUDO_USER}" ]; then
    (crontab -u "${SUDO_USER}" -l ; cat "${BIN_FOLDER}/tmux/cronjob") | crontab -u "${SUDO_USER}" -
  else
    (crontab -l ; cat "${BIN_FOLDER}/tmux/cronjob") | crontab -
  fi
}
uninstall_tmux_post() {
  cp "${CUSTOMIZER_PROJECT_FOLDER}/src/features/tmux/cronjob" "${CUSTOMIZER_PROJECT_FOLDER}/src/features/tmux/cronjob.tmp"
  translate_variables "${CUSTOMIZER_PROJECT_FOLDER}/src/features/tmux/cronjob.tmp"
  if [ -n "${SUDO_USER}" ]; then
    crontab -u "${SUDO_USER}" -l | sed "s;$(cat "${CUSTOMIZER_PROJECT_FOLDER}/src/features/tmux/cronjob.tmp");;g" | crontab -u "${SUDO_USER}" -
  else
    crontab -l | sed "s;$(cat "${CUSTOMIZER_PROJECT_FOLDER}/src/features/tmux/cronjob.tmp");;g" | crontab -
  fi
  rm -f "${CUSTOMIZER_PROJECT_FOLDER}/src/features/tmux/cronjob.tmp"
}

tomcat_name="Apache Tomcat Server"
tomcat_description="Servlet container"
tomcat_version="9.0.43"
tomcat_tags=("server" "web")
tomcat_systemcategories=("System" "Utility" "Development" "Network")
tomcat_arguments=("tomcat" "apache_tomcat" "tomcat_server" "apache")
tomcat_commentary="Basic tool for web development using Java servlets"
tomcat_downloadKeys=("bundle")
tomcat_bundle_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.43/bin/apache-tomcat-9.0.43.tar.gz"

tor_name="The Onion Router browser"
tor_description="Browser focused on security and privacy. Can browse through the onion protocol"
tor_version="System dependent"
tor_tags=("security" "web" "browser")
tor_systemcategories=("System" "Utility" "Development" "Network" "WebBrowser" "Security")
tor_arguments=("tor" "tor_browser")
tor_commentary="Browse the Internet with maximum privacy."
# TODO tor_launchernames=("torbrowser")
tor_packagenames=("torbrowser-launcher")
tor_launcherkeynames=("defaultLauncher")
tor_defaultLauncher_exec="tor"

traductor_name="Google Traductor"
traductor_description="Google Traductor opening in Browser"
traductor_version="Google dependent"
traductor_tags=("google" "traductor" "internet_shortcuts")
traductor_systemcategories=("Translation")
traductor_arguments=("traductor" "google_traductor")
traductor_commentary="Traduce to any language"
traductor_bashfunctions=("traductor.sh")
traductor_launcherkeynames=("default")
traductor_default_exec="xdg-open https://translate.google.com"

transmission_name="Transmission"
transmission_description="A set of lightweight Torrent client (in GUI, CLI and daemon form)"
transmission_version="System dependent"
# TODO transmission_tags=()
# TODO transmission_systemcategories=()
transmission_arguments=("transmission_gtk" "transmission")
transmission_packagenames=("transmission")
transmission_launcherkeynames=("defaultLauncher")
transmission_defaultLauncher_exec="transmission-gtk"

trello_name="Trello"
trello_description="Google trello opening in Browser"
trello_version="Google dependent"
trello_tags=("administration" "internet_shortcuts")
trello_systemcategories=("ProjectManagement")
trello_arguments=("trello")
trello_commentary="Project administration"
trello_bashfunctions=("trello.sh")
trello_launcherkeynames=("default")
trello_default_exec="xdg-open https://trello.com"

tumblr_name="Tumblr"
tumblr_description="Tumblr opening in Browser"
tumblr_version="Google dependent"
tumblr_tags=("internet_shortcuts")
tumblr_systemcategories=("Feed")
tumblr_arguments=("tumblr")
tumblr_commentary="Blogs multimedia"
tumblr_bashfunctions=("tumblr.sh")
tumblr_launcherkeynames=("default")
tumblr_default_exec="xdg-open https://www.tumblr.com/"

tweaks_name="GNOME Tweaks"
tweaks_description="GUI for system customization"
tweaks_version="System dependent"
tweaks_tags=("tweaks" "game" "gnome" "strategy")
tweaks_systemcategories=("GNOME" "GTK")
tweaks_arguments=("gnome_tweak_tool" "tweaks" "gnome_tweak" "gnome_tweak_tools" "gnome_tweaks")
tweaks_commentary="Tweaks for system"
tweaks_packagenames=("gnome-tweak-tool")
# TODO: tweaks_launchernames=("org.gnome.tweaks")
tweaks_launcherkeynames=("default")
tweaks_default_exec="gnome-tweak-tool"

twitch_name="Twitch"
twitch_description="Twitch.tv opening in Browser"
twitch_version="Google dependent"
twitch_tags=("streaming" "internet_shortcuts")
twitch_systemcategories=("VideoConference")
twitch_arguments=("twitch")
twitch_commentary="Online streaming platform"
twitch_bashfunctions=("twitch.sh")
twitch_launcherkeynames=("default")
twitch_default_exec="xdg-open https://twitch.tv"

twitter_name="Twitter"
twitter_description="twitter.tv opening in Browser"
twitter_version="Google dependent"
twitter_tags=("internet_shortcuts")
twitter_systemcategories=("InstantMessaging" "Chat" "Feed")
twitter_arguments=("twitter")
twitter_commentary="Microblogging online social platform"
twitter_bashfunctions=("twitter.sh")
twitter_launcherkeynames=("default")
twitter_default_exec="xdg-open https://twitter.com"

u_name="Function u"
u_description="Opens given link in default web browser"
u_version="1.0"
u_tags=("bashfunctions" "web" "browser")
u_systemcategories=("System" "Utility" "Network" "WebBrowser")
u_arguments=("u")
u_commentary="Terminal shortcut to open a URL from terminal"
u_bashfunctions=("u.sh")

uget_name="uget"
uget_description="GUI utility to manage downloads"
uget_version="System dependent"
# TODO uget_tags=()
# TODO uget_systemcategories=()
uget_arguments=("u_get")
uget_launchernames=("uget-gtk")
uget_packagedependencies=("aria2")
uget_packagenames=("uget")
uget_launcherkeynames=("defaultLauncher")
uget_defaultLauncher_exec="uget-gtk"

upgrade_name="Function Upgrade"
upgrade_description="update your system packages"
upgrade_version="1.0"
upgrade_tags=("system" "management" "apt" "update" "upgrade")
upgrade_systemcategories=("System" "Utility")
upgrade_arguments=("upgrade")
upgrade_commentary="Update, upgrade and clean packages in a single command"
upgrade_bashfunctions=("upgrade.sh")

virtualbox_name="VirtualBox"
virtualbox_description="Hosted hypervisor for x86 virtualization"
virtualbox_version="System dependent"
# TODO virtualbox_tags=()
# TODO virtualbox_systemcategories=()
virtualbox_arguments=("virtual_box")
virtualbox_bashfunctions=("virtualbox.sh")
virtualbox_launchernames=("virtualbox")
virtualbox_packagedependencies=("make" "gcc" "perl" "python" "build-essential" "dkms" "libsdl1.2debian" "virtualbox-guest-utils" "libqt5printsupport5" "libqt5x11extras5" "libcurl4" "virtualbox-guest-dkms" "linux-headers-$(uname -r)" "libqt5opengl5" "linux-headers-generic" "linux-source" "linux-generic" "linux-signed-generic")
virtualbox_packagenames=("virtualbox-6.1")
virtualbox_downloadKeys=("bundle")
virtualbox_bundle_URL="https://download.virtualbox.org/virtualbox/6.1.28/virtualbox-6.1_6.1.28-147628~Ubuntu~eoan_amd64.deb"
virtualbox_package_manager_override="apt-get"
virtualbox_launcherkeynames=("defaultLauncher")
virtualbox_defaultLauncher_exec="virtualbox"

vlc_name="VLC"
vlc_description="Media player software, and streaming media server"
vlc_version="System dependent"
# TODO vlc_tags=()
# TODO vlc_systemcategories=()
vlc_arguments=("vlc")
vlc_launchernames=("vlc")
vlc_packagenames=("vlc")
vlc_launcherkeynames=("defaultLauncher")
vlc_defaultLauncher_exec="vlc"

vncviewer_name="VNC Viewer"
vncviewer_description="VNC client"
vncviewer_version="6.21.1109"
vncviewer_tags=("remote" "control" "network")
vncviewer_systemcategories=("Utility" "Network" "Viewer" "Monitor" "RemoteAccess" "Accessibility")
vncviewer_arguments=("vnc_viewer")
vncviewer_commentary="Control of the server computer remotely through a cross-platform client."
vncviewer_launcherkeynames=("default")
vncviewer_default_exec="vncviewer" # TODO: test launcher
vncviewer_binariesinstalledpaths=("vncviewer;vncviewer")
vncviewer_downloadKeys=("bundle")
vncviewer_bundle_URL="https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-6.21.1109-Linux-x64-ANY.tar.gz"

whatsapp_name="Whatsapp Web"
whatsapp_description="Whatsapp Web opening in Browser"
whatsapp_version="Google dependent"
whatsapp_tags=("internet_shortcuts")
whatsapp_systemcategories=("InstantMessaging" "Chat")
whatsapp_arguments=("whatsapp" "whatsapp_web")
whatsapp_commentary="Whatsapp Web for messaging"
whatsapp_bashfunctions=("whatsapp.sh")
whatsapp_launcherkeynames=("default")
whatsapp_default_exec="xdg-open https://web.whatsapp.com"

wikipedia_name="Wikipedia"
wikipedia_description="Wikipedia opening in Browser"
wikipedia_version="Google dependent"
wikipedia_tags=("internet_shortcuts")
wikipedia_systemcategories=("Documentation")
wikipedia_arguments=("wikipedia")
wikipedia_commentary="Free encyclopedia"
wikipedia_bashfunctions=("wikipedia.sh")
wikipedia_launcherkeynames=("default")
wikipedia_default_exec="xdg-open https://www.wikipedia.org"

wikit_name="Wikit"
wikit_description="Wikipedia search inside terminal"
wikit_version="System dependent"
# TODO wikit_tags=()
# TODO wikit_systemcategories=()
wikit_arguments=("wikit")
wikit_manualcontentavailable=";1;"
wikit_flagsoverride="1;;;;;"  # Install always as user
install_wikit_mid() {
  npm install wikit -g
}
uninstall_wikit_mid() {
  npm remove wikit -g
}

xclip_name="xclip"
xclip_description="Utility for pasting."
xclip_version="System dependent"
xclip_tags=("paste")
# TODO xclip_systemcategories=()
xclip_arguments=("x_clip")
xclip_packagenames=("xclip")

youtube_name="Youtube"
youtube_description="Youtube opening in Browser"
youtube_version="Google dependent"
youtube_tags=("internet_shortcuts")
youtube_systemcategories=("VideoConference")
youtube_arguments=("youtube")
youtube_commentary="Watch videos online"
youtube_bashfunctions=("youtube.sh")
youtube_launcherkeynames=("default")
youtube_default_exec="xdg-open https://www.youtube.com"


####################### UNHOLY LINE OF TRIMMING. UPWARDS IS LEGACY, BELOW IS NEW ##############################
#FEATUREKEYNAME_name=""
#FEATUREKEYNAME_description=""
#FEATUREKEYNAME_version="System dependent"
#FEATUREKEYNAME_tags=()
#FEATUREKEYNAME_systemcategories=()
#FEATUREKEYNAME_arguments=()

####################### UNHOLY LINE OF TRIMMING. UPWARDS IS LEGACY, BELOW IS NEW ##############################


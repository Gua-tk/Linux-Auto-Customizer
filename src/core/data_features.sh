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
######################################### IMPORT COMMON VARIABLES ######################################################
########################################################################################################################

if [ -f "${DIR}/data_common.sh" ]; then
  source "${DIR}/data_common.sh"
else
  # output without output_proxy_executioner because it does not exist at this point, since we did not source common_data
  echo -e "\e[91m$(date +%Y-%m-%d_%T) -- ERROR: data_common.sh not found. Aborting..."
  exit 1
fi


########################################################################################################################
######################################## INSTALLATION SPECIFIC VARIABLES ###############################################
########################################################################################################################
# The variables in here follow a naming scheme that is required for each feature to obtain its data by variable        #
# indirect expansion. The variables that are defined for an installation determine its behaviour.                      #
# Each installations has its own FEATUREKEYNAME, which is an string that matches a unique feature. We use the name of  #
# the main terminal command installed by the feature used to run it. This string must be added to the array            #
# feature_keynames in data_common.sh to be recognised by the customizer as an available installation.                  #
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
########################################################################################################################

<<<<<<< HEAD
=======
#  - FEATUREKEYNAME_icon: A path to an image to represent the feature pointing customizer icon in the repository
#    features data. Property 'Icon=' of the desktop launcher. Fallback to customizer global icons.
>>>>>>> 5d121be5d800d78886423c74e6dcb06b91112955
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
#      in other situations. By default the feaurekeyname overrides by this variable.
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

a_arguments=("a")
a_name="Function a"
a_description="Function that displays environment aliases using compgen -a"
a_version="1.0"
a_tags=("bashfunctions" "aliases" "info")
a_systemcategories=("System" "Utility")
a_commentary="A terminal shortcut"
a_bashfunctions=("a.sh")

add_arguments=("add" "add_function")
add_name="Function add"
add_description="Alias to git add with completion"
add_version="1.0"
add_tags=("gitbashfunctions" "bashfunctions" "git")
add_systemcategories=("System" "Utility")
add_commentary="A git terminal shortcut"
add_bashfunctions=("add.sh")

aircrack_ng_arguments=("aircrack_ng" "aircrackng")
aircrack_ng_packagenames=("aircrack-ng")
aircrack_ng_name="Aircrack-ng"
aircrack_ng_description="Complete suite of security tools to assess WiFi network security"
aircrack_ng_version="1.6"
aircrack_ng_tags=("attack" "network" "security")
aircrack_ng_systemcategories=("System" "Utility" "Security" "Network" "Development")
aircrack_ng_commentary="Very complete"

aisleriot_arguments=("aisleriot" "solitaire" "gnome_solitaire")
aisleriot_name="AisleRiot Solitaire"
aisleriot_commentary="Implementation of the classical game solitaire"
aisleriot_description="Solitaire Classic Card Game"
aisleriot_version="3.22.9"
aisleriot_tags=("cards" "game" "cardsgame")
aisleriot_systemcategories=("Game" "CardGame")
aisleriot_bashfunctions=("aisleriot.sh")
aisleriot_launcherkeynames=("default")
aisleriot_default_exec="sol"
aisleriot_launchernames=("sol")  # TODO @AleixMT extract launcher data
aisleriot_packagenames=("aisleriot")

alert_arguments=("alert" "alert_alias" "alias_alert")
alert_name="Function alert"
alert_description="Alias to show a notification at the end of a commands"
alert_version="1.0"
alert_packagedependencies=("libnotify-bin")
alert_tags=("bashfunctions" "notify" "notification" "info")
alert_systemcategories=("Utility" "System" "Calendar")
alert_commentary="Useful to remember events"
alert_bashfunctions=("alert.sh")

ansible_arguments=("ansible")
ansible_name="Ansible"
ansible_commentary="IT automation engine that automates cloud provisioning, configuration management, application deployment"
ansible_description="Application deployment engine"
ansible_version="5.0.0"
ansible_tags=("automation" "development" "deployment")
ansible_systemcategories=("Development" "ProjectManagement" "ComputerScience" "Monitor")
ansible_packagenames=("ansible")

ant_arguments=("ant" "apache_ant")
ant_name="Ant"
ant_commentary="Tool to automatize repetitive tasks, usually during the compilation, building and deployment phase of the software development"
ant_description="Automation tool for software build"
ant_version="1.10.11"
ant_tags=("automation" "development" "deployment")
ant_systemcategories=("Development" "Building" "Utility")
ant_bashfunctions=("ant.sh")
ant_binariesinstalledpaths=("bin/ant;ant")
ant_compressedfileurl="https://ftp.cixug.es/apache//ant/binaries/apache-ant-1.10.11-bin.tar.gz"
ant_flagsoverride="1;;;;;"

anydesk_arguments=("any_desk")
anydesk_name="Anydesk"
anydesk_commentary="Remote control pc, sync with the cloud, remote file transfer, wake remote computers..."
anydesk_version="6.1.1"
anydesk_tags=("remote" "control" "cloud")
anydesk_systemcategories=("Accessibility" "Network" "RemoteAccess" "FileTransfer" "P2P")
anydesk_packagedependencies=("libminizip1" "libgtkglext1")
anydesk_bashfunctions=("anydesk.sh")
anydesk_binariesinstalledpaths=("anydesk;anydesk")
anydesk_compressedfileurl="https://download.anydesk.com/linux/anydesk-6.1.1-amd64.tar.gz"
anydesk_description="PC Remote controller"
anydesk_launcherkeynames=("default")

apache2_arguments=("apache2")
apache2_name="Apache httpd server project"
apache2_commentary="open-source HTTP server for modern operating systems including UNIX and Windows"
apache2_description="Web server"
apache2_version="2.4.52"
apache2_tags=("development" "deployment")
apache2_systemcategories=("Development" "WebDevelopment" )
apache2_packagenames=("apache2" "apache2-utils")

ardour_arguments=("ardour")
ardour_name="Ardour5"
ardour_commentary="Music development in one place"
ardour_version="System dependent"
ardour_description="Software for music production"
ardour_tags=("music" "audio" "production")
ardour_icon="ardour.svg"
ardour_systemcategories=("Audio" "Music")
ardour_launcherkeynames=("default")
ardour_default_exec="ardour5"
ardour_bashfunctions=("ardour.sh")
ardour_packagenames=("ardour")  # TODO @AleixMT extract launcher data
ardour_launchernames=("ardour")

aspell_arguments=("aspell")
aspell_name="GNU Aspell"
aspell_commentary="Free and open source spell checker in Linux. Can be used to check spelling from provided files or stdin"
aspell_description="Spell checker"
aspell_systemcategories=("Translation" "System" "Settings" "Dictionary")
aspell_version="0.60.8"
aspell_tags=("development" "deployment" "Education" "Office" "Utility" "Documentation" "FileTools" "Humanities" "Languages" "WordProcessor" "Dictionary" "Translation")
aspell_packagenames=("aspell-es" "aspell-ca")

atom_arguments=("atom")
atom_name="Atom"
atom_commentary="Text and source code editor"
atom_version="1.59.0"
atom_tags=("IDE" "programming")
atom_icon="atom.png"
atom_systemcategories=("IDE" "TextTools" "TextEditor" "Development")
atom_launcherkeynames=("default")
atom_default_exec="atom"
atom_launchernames=("atom")  # TODO @AleixMT extract launcher data
atom_packageurls=("https://atom.io/download/deb")

audacity_arguments=("audacity")
audacity_name="Audacity"
audacity_commentary="Digital audio editor and recording"
audacity_version="2.3.3"
audacity_tags=("music" "audio" "producing")
audacity_icon="audacity.svg"
audacity_systemcategories=("Audio" "Music")
audacity_launcherkeynames=("default")
audacity_default_exec="audacity"
audacity_bashfunctions=("audacity.sh")
audacity_launchernames=("audacity") # TODO @AleixMT imort launcher data
audacity_packagenames=("audacity" "audacity-data")

# TODO @AleixMT chnage keyname to be in small letter
AutoFirma_arguments=("auto_firma")
AutoFirma_name="AutoFirma"
AutoFirma_commentary="For the spanish DNI v3.0"
AutoFirma_description="Electronic signature application"
AutoFirma_version="1.0"
AutoFirma_tags=("digitalsign")
AutoFirma_icon="AutoFirma.png"
AutoFirma_systemcategories=("Utility")
AutoFirma_launcherkeynames=("default")
AutoFirma_default_exec="AutoFirma"
AutoFirma_bashfunctions=("AutoFirma.sh")
AutoFirma_packageurls=("https://estaticos.redsara.es/comunes/autofirma/1/6/5/AutoFirma_Linux.zip")
AutoFirma_launchernames=("afirma")  # TODO @AleixMT extract launcher data
AutoFirma_packagedependencies=("libnss3-tools")
AutoFirma_packagenames=("AutoFirma")

axel_arguments=("axel")
axel_packagenames=("axel")
axel_name="axel"
axel_description="Download manager"
axel_commentary="Like wget but fancier and faster"
axel_version="1.6"
axel_systemcategories=("FileTransfer" "Utility")
axel_tags=("downloader" "network")

####################### UNHOLY LINE OF TRIMMING. UPWARDS IS NEW, BELOW IS LEGACY ##############################

B_arguments=("B" "B_function")
B_name="Function B"
B_description="Function that source ~/.profile and ~/.bashrc"
B_version="1.0"
B_tags=("bashfunctions" "profile" "bashrc")
B_systemcategories=("System" "Utility")
B_commentary="B reload environment"
B_bashfunctions=("B.sh")

b_arguments=("b" "b_function")
b_name="Function b"
b_description="Alias for bash"
b_version="1.0"
b_tags=("bashfunctions" "bash")
b_systemcategories=("System" "Utility")
b_commentary="b reload bash environment"
b_bashfunctions=("b.sh")

bashcolors_arguments=("bash_colors" "colors" "colours")
bashcolors_name="Function colors"
bashcolors_description="Function and variables to use color in terminal"
bashcolors_version="1.0"
bashcolors_tags=("bashfunctions" "bashrc" "color")
bashcolors_systemcategories=("System" "Utility")
bashcolors_commentary="Bring color to the terminal text"
bashcolors_bashfunctions=("bashcolors.sh")

blender_downloadKeys=("bundle")
blender_bundle_URL="https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.93/blender-2.93.3-linux-x64.tar.xz"
blender_arguments=("blender" "blender_3d")
blender_name="Blender"
blender_description="2D and 3D image modeling and animation, fx, video edit..."
blender_version="1.0"
blender_tags=("animation" "3D" "FX" "3d" "cg modeling" "animation" "painting" "sculpting" "texturing" "video editing" "video tracking" "rendering" "render engine" "cycles" "game engine" "python")
blender_systemcategories=("2DGraphics" "3DGraphics" "Graphics" "Video" "Art" "ImageProcessing")
blender_commentary="3D modeling, animation, rendering and post-production"
blender_binariesinstalledpaths=("blender;blender")
blender_launcherkeynames=("defaultLauncher")
blender_defaultLauncher_exec="blender %f"
blender_defaultLauncher_mimetypes=("application/x-blender")

branch_name="Function branch"
branch_description="Alias for git branch"
branch_version="1.0"
branch_tags=("bashfunctions" "bash" "gitbashfunctions")
branch_systemcategories=("System" "Utility")
branch_commentary="branch creates a new branch of the git repository"
branch_arguments=("branch")
branch_bashfunctions=("branch.sh")

brasero_installationtype="packagemanager"
brasero_arguments=("brasero")
brasero_description="Software for image burning"
brasero_version="1.0"
brasero_tags=("bashfunctions" "bash" "gitbashfunctions")
brasero_systemcategories=("System" "Utility")
brasero_commentary="branch creates a new branch of the git repository"
brasero_bashfunctions=("brasero.sh")
brasero_launcherkeynames=("defaultLauncher")
brasero_defaultLauncher_exec="brasero"
# TODO: brasero_launchernames=("brasero")
brasero_packagenames=("brasero")

c_arguments=("c")
c_name="Function b"
c_description="Function that changes the directory or clears the screen"
c_version="1.0"
c_tags=("bashfunctions" "bash")
c_systemcategories=("System" "Utility")
c_commentary="cd and clear the screen"
c_bashfunctions=("c.sh")

caffeine_installationtype="packagemanager"
caffeine_arguments=("caffeine" "coffee" "cafe")
caffeine_launchernames=("caffeine-indicator")  # TODO @AleixMT extract launcher data
caffeine_manualcontentavailable="1;0;1"
caffeine_packagenames=("caffeine")
caffeine_readmeline="| Caffeine | Simple indicator applet on Ubuntu panel that allows to temporarily prevent the activation of the screensaver, screen lock, and the sleep power saving mode. | Commands \`caffeine\`, \`caffeinate\` and \`caffeine-indicator\`, desktop launcher for \`caffeine\`, dashboard launcher for \`caffeine\` and \`caffeine-indicator\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
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

calibre_installationtype="packagemanager"
calibre_arguments=("calibre")
calibre_bashfunctions=("calibre.sh")
calibre_launchernames=("calibre-gui")
calibre_packagenames=("calibre")  # TODO @AleixMT extract launcher data
calibre_readmeline="| Calibre | e-book reader| Commmand \`calibre\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

changebg_installationtype="repositoryclone"
changebg_arguments=("change_bg" "wallpaper" "wallpapers")
changebg_movefiles=("*.jpg;${XDG_PICTURES_DIR}/wallpapers" "*.png;${XDG_PICTURES_DIR}/wallpapers" "*.jpeg;${XDG_PICTURES_DIR}/wallpapers" )
changebg_binariesinstalledpaths=("cronscript.sh;changebg")
changebg_cronscript_content="cronscript.sh"
changebg_cronscript_path="cronscript.sh"
changebg_cronjob_content="cronjob"
changebg_cronjob_path="cronjob"
changebg_filekeys=("cronscript" "cronjob")
changebg_manualcontentavailable="0;0;1"
changebg_readmeline="| Function \`changebg\` | Function that changes the wallpaper using one random image from user images folder. It also downloads wallpapers and installs a cronjob to change the wallpaper every 5 minutes | Function \`changebg\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
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

cheat_installationtype="environmental"
cheat_arguments=("cheat" "cht.sh")
cheat_binariesinstalledpaths=("cht.sh;cheat")
cheat_downloads=("https://cht.sh/:cht.sh;cht.sh")
cheat_readmeline="| cheat.sh | Provides access to community-driven cheat sheets and snippets for Linux/UNIX commands and many programming languages | Command \`cheat\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

checkout_name="Function checkout"
checkout_description="Alias for git checkout"
checkout_version="1.0"
checkout_tags=("bashfunctions" "aliases" "gitbashfunctions")
checkout_systemcategories=("System" "Utility")
checkout_commentary="A terminal shortcut for git"
checkout_arguments=("checkout")
checkout_bashfunctions=("checkout.sh")

cheese_installationtype="packagemanager"
cheese_arguments=("cheese")
cheese_bashfunctions=("cheese.sh")
cheese_launchernames=("org.gnome.Cheese")  # TODO @AleixMT extract launcher data
cheese_packagenames=("cheese")
cheese_readmeline="| Cheese | GNOME webcam application | Command \`cheese\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

clean_name="Function checkout"
clean_description="Remove files and contents from the trash bin and performs sudo apt-get -y autoclean and sudo apt-get -y autoremove."
clean_version="1.0"
clean_tags=("bashfunctions" "aliases" "gitbashfunctions" "shortcuts")
clean_systemcategories=("System" "Utility")
clean_commentary="Remove usesles packages from cache and empty your trash bin"
clean_arguments=("clean")
clean_bashfunctions=("clean.sh")

clementine_installationtype="packagemanager"
clementine_arguments=("clementine")
clementine_bashfunctions=("clementine.sh")
clementine_launchernames=("clementine")  # TODO @AleixMT extract launcher data
clementine_packagenames=("clementine")
clementine_readmeline="| Clementine | Modern music player and library organizer | Command \`clementine\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

clion_installationtype="userinherit"
clion_arguments=("clion")
clion_associatedfiletypes=("text/x-c++hdr" "text/x-c++src" "text/x-chdr" "text/x-csrc")
clion_bashfunctions=("clion.sh")
clion_binariesinstalledpaths=("bin/clion.sh;clion")
clion_compressedfileurl="https://download.jetbrains.com/cpp/CLion-2021.3.tar.gz"
clion_launchercontents=("[Desktop Entry]
Categories=Development;IDE;
Comment=${clion_description}
Encoding=UTF-8
Exec=clion %F
GenericName=C Programing IDE
Icon=${BIN_FOLDER}/clion/bin/clion.png
Keywords=IDE;programming;android;studio;dev;
MimeType=
Name=CLion
StartupNotify=true
StartupWMClass=jetbrains-clion
Terminal=false
TryExec=clion
Type=Application
Version=1.0
")
clion_description="Cross-platform C/C++ IDE"
clion_readmeline="| Clion | ${clion_description} | Command \`clion\`, silent alias \`clion\`, desktop launcher, dashboard launcher, associated with mimetypes \`.c\`, \`.h\` and \`.cpp\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

clone_installationtype="environmental"
clone_arguments=("clone")
clone_bashfunctions=("clone.sh")
clone_readmeline="| Function \`clone\` | Function for \`git clone \$1\`|  Command \`clone\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

clonezilla_installationtype="packagemanager"
clonezilla_arguments=("clonezilla")
clonezilla_packagenames=("clonezilla")
clonezilla_description="Disk cloning, disk imaging, data recovery, and deployment"
clonezilla_readmeline="| CloneZilla | ${clonezilla_description} | Command \`clonezilla\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
clonezilla_launchercontents=("[Desktop Entry]
Categories=backup;images;restoration;boot;
Comment=${clonezilla_description}
Encoding=UTF-8
Exec=sudo clonezilla
GenericName=Disk image utility
Icon=/usr/share/gdm/themes/drbl-gdm/clonezilla/ocslogo-1.png
Keywords=clonezilla;CloneZilla;iso
MimeType=
Name=CloneZilla
StartupNotify=true
StartupWMClass=CloneZilla
Terminal=true
TryExec=clonezilla
Type=Application
Version=1.0
")

cmake_installationtype="userinherit"
cmake_binariesinstalledpaths=("bin/ccmake;ccmake" "bin/cmake;cmake" "bin/cmake-gui;cmake-gui" "bin/cpack;cpack" "bin/ctest;ctest")
cmake_compressedfileurl="https://github.com/Kitware/CMake/releases/download/v3.21.1/cmake-3.21.1-linux-x86_64.tar.gz"
cmake_arguments=("cmake" "c_make")
cmake_readmeline="| Cmake | Compile C and c make | Command \`cmake\`, \`ccmake\`, \`cmake-gui\`, \`cpack\`, \`ctest\`  ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

cmatrix_installationtype="packagemanager"
cmatrix_arguments=("cmatrix")
cmatrix_bashfunctions=("cmatrix.sh")
cmatrix_launchercontents=("
[Desktop Entry]
Categories=matrix;
Comment=Matrix
Encoding=UTF-8
Exec=cmatrix
GenericName=cmatrix
Icon=/var/lib/app-info/icons/ubuntu-focal-universe/64x64/bless_bless-48x48.png
Keywords=cmatrix;matrix;
MimeType=
Name=CMatrix
StartupNotify=true
StartupWMClass=cmatrix
Terminal=true
TryExec=cmatrix
Type=Application
Version=1.0
")
cmatrix_packagenames=("cmatrix")
cmatrix_description="Terminal screensaver from The Matrix"
cmatrix_readmeline="| Cmatrix | ${cmatrix_description} | Command \`cmatrix\`, function \`matrix\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

code_installationtype="userinherit"
code_arguments=("code" "visual_studio_code" "visual_studio")
code_bashfunctions=("code.sh")
code_binariesinstalledpaths=("code;code")
code_compressedfileurl="https://go.microsoft.com/fwlink/?LinkID=620884"
code_launchercontents=("[Desktop Entry]
Categories=Development;IDE;
Comment=${code_description}
Encoding=UTF-8
Exec=code %f
GenericName=IDE for programming
Icon=${BIN_FOLDER}/code/resources/app/resources/linux/code.png
Keywords=code;
MimeType=
Name=Visual Studio Code
StartupNotify=true
StartupWMClass=visual-studio-code
Terminal=false
TryExec=code
Type=Application
Version=1.0
")
code_description="Source-code editor"
code_readmeline="| Visual Studio Code | ${code_description} | Command \`code\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

codeblocks_installationtype="packagemanager"
codeblocks_arguments=("codeblocks" "code::blocks")
codeblocks_bashfunctions=("codeblocks.sh")
codeblocks_launchernames=("codeblocks")  # TODO @AleixMT extract launcher data
codeblocks_packagenames=("codeblocks")
codeblocks_readmeline="| Code::Blocks | IDE for programming  | Command \`codeblocks\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

codium_installationtype="userinherit"
codium_donotinherit="yes"
codium_bashfunctions=("codium.sh")
codium_compressedfilepathoverride="${BIN_FOLDER}/codium"
codium_binariesinstalledpaths=("bin/codium;codium")
codium_compressedfileurl="https://github.com/VSCodium/vscodium/releases/download/1.62.2/VSCodium-linux-x64-1.62.2.tar.gz"
codium_launchercontents=("[Desktop Entry]
Name=VSCodium
StartupWMClass=codium
Comment=Community-driven distribution of Microsoft’s editor VSCode.
GenericName=codium
Exec=codium
Icon=${BIN_FOLDER}/codium/resources/app/resources/linux/code.png
Type=Application
Categories=IDE;Programming;
")

commit_arguments=("commit")
commit_name="Function commit"
commit_description="Function that makes git commit -am"
commit_version="1.0"
commit_tags=("gitbashfunctions" "git")
commit_systemcategories=("System" "Utility")
commit_commentary="Save current local file changes to git repository"
commit_bashfunctions=("commit.sh")

config_arguments=("git_config" "config_function")
config_name="Function config"
config_description="Function that does a git config accepting two parameters username and email"
config_version="1.0"
config_tags=("git-user-configuration" "gitbashfunctions")
config_systemcategories=("System" "Utility")
config_commentary="Configure your git username and email"
config_bashfunctions=("config.sh")

converters_arguments=("converters")
converters_name="Functions converters"
converters_description="Convert any number to any numeric system"
converters_version="1.0"
converters_tags=("bashfunctions" "convert" "info")
converters_systemcategories=("System" "Utility")
converters_commentary="bintodec, decobin, hextodec..."
converters_bashfunctions=("converters.sh")
converters_binariesinstalledpaths=("converters/to.py;to" "converters/dectoutf.py;dectoutf" "converters/utftodec.py;utftodec")
converters_repositoryurl="https://github.com/Axlfc/converters"

copyq_installationtype="packagemanager"
copyq_arguments=("copyq")
copyq_name="Functions converters"
copyq_description="A clipboard manager application that comes with extra features such as editing and scripting"
copyq_version="1.0"
copyq_tags=("history" "clipboard")
copyq_systemcategories=("System" "Utility")
copyq_commentary="Autostart enabled"
copyq_launchernames=("com.github.hluk.copyq")
copyq_packagenames=("copyq")  # TODO @AleixMT extract launcher data
copyq_flagsoverride=";;;;;1"  # Always autostart

curl_arguments=("curl")
curl_name="Functions converters"
curl_description="Curl is a CLI command for retrieving or sending data to a server"
curl_version="System dependent"
curl_tags=("terminal" "web")
curl_systemcategories=("System" "Utility")
curl_commentary="Autostart enabled"
curl_packagenames=("curl")

# TODO: CUSTOMIZER 1.0
customizer_installationtype="environmental"
customizer_arguments=("customizer" "linux_auto_customizer" "auto_customizer" "linux_customizer")
customizer_repositoryurl="https://github.com/AleixMT/Linux-Auto-Customizer"
customizer_manualcontentavailable="0;0;1"
customizer_flagsoverride="0;;;;;"  # Install always as root
customizer_bashfunctions=("customizer.sh")
customizer_readmeline="| Linux Auto Customizer | Program and function management and automations | Command \`customizer-install\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
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

d_arguments=("d")
d_name="Function d"
d_description="Function for dif or git diff"
d_version="1.0"
d_tags=("bash" "gitbashfunctions" "info")
d_systemcategories=("System" "Utility")
d_commentary="See changes of files"
d_bashfunctions=("d.sh")

dbeaver_arguments=("dbeaver")
dbeaver_packageurls=("https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb")
dbeaver_name="DBeaver"
dbeaver_description="SQL Client IDE"
dbeaver_version="1.0"
dbeaver_tags=("bashfunctions" "bash" "gitbashfunctions")
dbeaver_systemcategories=("IDE" "Database" "Network" "Development")
dbeaver_commentary="Manage several instances of SQL databases"
dbeaver_package_manager_override="apt-get"
# TODO: dbeaver_launchernames=("dbeaver-ce")
dbeaver_launcherkeynames=("defaultLauncher")
dbeaver_defaultLauncher_exec="dbeaver"

dconf_editor_arguments=("dconf_editor" "dconf")
dconf_editor_name="dconf-editor"
dconf_editor_description="Editor settings"
dconf_editor_version="1.0"
dconf_editor_tags=("editor" "settings")
dconf_editor_systemcategories=("System" "Utility" "Settings" "GNOME" "DesktopSettings")
dconf_editor_commentary="Edit system environment variables"
# TODO: dconf_editor_launchernames=("ca.desrt.dconf-editor")
dconf_editor_launcherkeynames=("defaultLauncher")
dconf_editor_defaultLauncher_exec="dconf-editor"
dconf_editor_packagenames=("dconf-editor")

dia_arguments=("dia")
dia_name="Dia"
dia_description="Graph and relational"
dia_version="1.0"
dia_tags=("graph" "relational")
dia_systemcategories=("FlowChart" "Graphics" "Development")
dia_commentary="Diagrams for developers"
dia_packagenames=("dia-common")
dia_launchernames=("dia")
dia_bashfunctions=("dia.sh")

discord_arguments=("discord")
discord_name="Discord"
discord_description="All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone."
discord_version="Discord dependent"
discord_tags=("VoiceChat" "Messaging" "Social")
discord_systemcategories=("InstantMessaging" "Network")
discord_commentary="Chat and video stream online"
discord_bashfunctions=("discord.sh")
discord_binariesinstalledpaths=("Discord;discord")
discord_downloadKeys=("bundle")
discord_bundle_URL="https://discord.com/api/download?platform=linux&format=tar.gz"

docker_arguments=("docker")
docker_name="Docker"
docker_description="Containerization service"
docker_version="20.10.6"
docker_tags=("development" "containerization" "system")
docker_systemcategories=("System" "Utility")
docker_commentary="Application isolation"
docker_compressedfileurl="https://download.docker.com/linux/static/stable/x86_64/docker-20.10.6.tgz"
docker_binariesinstalledpaths=("docker;docker" "containerd;containerd" "containerd-shim;containerd-shim" "containerd-shim-runc-v2;containerd-shim-runc-v2" "ctr;ctr" "dockerd;dockerd" "docker-init;docker-init" "docker-proxy;docker-proxy" "runc;runc")

documents_arguments=("documents" "google_document" "google_documents" "document")
documents_name="Google Documents"
documents_description="Google Documents opening in Chrome"
documents_version="Google dependent"
documents_bashfunctions=("documents.sh")
documents_launcherkeynames=("default")
documents_systemcategories=("Office" "Documentation" "WebBrowser" "WordProcessor" "FlowChart")
documents_commentary="take notes or edit rich text documents"
documents_tags=("google" "internet_shortcuts")
documents_default_exec="xdg-open https://docs.google.com/document/"

drive_arguments=("drive" "google_drive")
drive_name="Google Drive"
drive_description="Google Drive opening in Chrome"
drive_version="Google dependent"
drive_bashfunctions=("drive.sh")
drive_launcherkeynames=("default")
drive_systemcategories=("ProjectManagement" "Documentation")
drive_commentary="File hosting service from Google"
drive_tags=("google" "internet_shortcuts")
drive_default_exec="xdg-open https://drive.google.com/"

dropbox_installationtype="packageinstall"
dropbox_arguments=("dropbox")
dropbox_packagenames=("dropbox")
dropbox_launchernames=("dropbox")
dropbox_packagedependencies=("python3-gpg")
dropbox_packageurls=("https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb")
dropbox_package_manager_override="apt-get"
dropbox_readmeline="| Dropbox | File hosting service | Command \`dropbox\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT wontfix, trim and test. if not working will be deleted
drupal_installationtype="userinherit"
drupal_arguments=("drupal")
drupal_compressedfilepathoverride="/var/www/html"
drupal_downloads=("https://upload.wikimedia.org/wikipedia/commons/7/75/Druplicon.vector.svg;drupal_icon.svg")
drupal_packagedependencies=("php-dom" "php-gd")
#drupal_binariesinstalledpaths=("drupal;drupal")
#drupal_compressedfileurl="https://www.drupal.org/download-latest/tar.gz" # This url might not be working stably as expected...
drupal_compressedfileurl="https://ftp.drupal.org/files/projects/drupal-9.2.10.tar.gz"
drupal_description="Web CMS"
drupal_url="http://localhost/drupal"
drupal_bashfunctions=("drupal.sh")
drupal_launchercontents=("[Desktop Entry]
Categories=CMS;web;
Comment=${drupal_description}
Encoding=UTF-8
Exec=xdg-open ${drupal_url}
GenericName=IDE
Icon=${BIN_FOLDER}/drupal/drupal_icon.svg
Keywords=CMS;web;
MimeType=
Name=Drupal
StartupNotify=true
StartupWMClass=Drupal
Terminal=false
TryExec=xdg-open
Type=Application
Version=4.2.2
")
drupal_readmeline="| Drupal | ${drupal_description} | Command \`drupal\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
drupal_manualcontentavailable="0;0;1"
install_drupal_post()
{
  create_folder /var/www/html/drupal/sites/default/files/translations 777
}
uninstall_drupal_post()
{
  remove_folder /var/www/html/drupal/
}

duckduckgo_arguments=("duckduckgo")
duckduckgo_name="Duckduckgo"
duckduckgo_description="Duckduckgo opening in Chrome"
duckduckgo_version="Google dependent"
duckduckgo_systemcategories=("WebBrowser")
duckduckgo_commentary="take notes or edit rich text documents"
duckduckgo_tags=("search" "internet_shortcuts")
duckduckgo_bashfunctions=("duckduckgo.sh")
duckduckgo_launcherkeynames=("default")
duckduckgo_default_exec="xdg-open https://duckduckgo.com/"
duckduckgo_description="Opens DuckDuckGo in Chrome"

e_name="Function e"
e_description="Multi function to edit a file or project in folder"
e_version="1.0"
e_tags=("bashfunctions" "bash")
e_systemcategories=("System" "Utility")
e_commentary="edit files or projects"
e_arguments=("e")
e_bashfunctions=("e.sh")

E_name="Function E"
E_description="Multi Function to edit a set of hardcoded key files using an argument"
E_version="1.0"
E_tags=("bashfunctions" "bash")
E_systemcategories=("System" "Utility")
E_commentary="A terminal shortcut"
E_arguments=("E")
E_bashfunctions=("E.sh")

eclipse_installationtype="userinherit"
eclipse_arguments=("eclipse")
eclipse_bashfunctions=("eclipse.sh")
eclipse_binariesinstalledpaths=("eclipse;eclipse")
eclipse_compressedfileurl="http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.2.2-201302041200/eclipse-SDK-4.2.2-linux-gtk-x86_64.tar.gz"
eclipse_description="IDE for Java"
eclipse_launchercontents=("[Desktop Entry]
Categories=Development;IDE;
Comment=${eclipse_description}
Encoding=UTF-8
Exec=eclipse
GenericName=IDE
Icon=${BIN_FOLDER}/eclipse/icon.xpm
Keywords=IDE;programming;
MimeType=
Name=Eclipse IDE
StartupNotify=true
StartupWMClass=Eclipse
Terminal=false
TryExec=eclipse
Type=Application
Version=4.2.2
")
eclipse_readmeline="| Eclipse | ${eclipse_description} | Command \`eclipse\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

emojis_installationtype="environmental"
emojis_arguments=("emojis" "emoji")
emojis_packagedependencies=("fonts-symbola")
emojis_readmeline=
emojis_bashfunctions=("emojis.sh")
emojis_readmeline="| Function \`emojis\` | Print emojis name in terminal when passing an emoji and prints emoji name when an emoji is passed to it. | Command \`emoji\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

evolution_installationtype="packagemanager"
evolution_arguments=("evolution")
evolution_bashfunctions=("evolution.sh")
evolution_launchernames=("evolution-calendar")
evolution_packagenames=("evolution" )
evolution_readmeline="| evolution | User calendar agend, planning | Command \`evolution\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

F_name="Function F"
F_description="Function to find strings in files in the directory in the 1st argument"
F_version="1.0"
F_tags=("bashfunctions" "bash" "info")
F_systemcategories=("System" "Utility")
F_commentary="A terminal shortcut"
F_arguments=("F")
F_bashfunctions=("F.sh")

f_name="Function f"
f_description="Function for finding strings in files, files in directories and show found files"
f_version="1.0"
f_tags=("bashfunctions" "bash" "info")
f_systemcategories=("System" "Utility")
f_commentary="A terminal shortcut"
f_arguments=("f")
f_bashfunctions=("f.sh")

firc_name="F-irc"
firc_description="CLI IRC client"
firc_version="1.0"
firc_tags=("irc" "chat" "terminal" "social" "instantmessaging")
firc_systemcategories=("ConsoleOnly" "Communication" "InstantMessaging")
firc_commentary="Dedicated servers to chat in terminal"
firc_arguments=("f_irc")
firc_packagenames=("f-irc")
firc_launcherkeynames=("terminalLauncher")
firc_terminalLauncher_exec="f-irc"
firc_terminalLauncher_terminal="true"

facebook_bashfunctions=("facebook.sh")
facebook_name="Facebook"
facebook_description="Facebook opening in Chrome"
facebook_version="Google dependent"
facebook_systemcategories=("InstantMessaging" "Chat" "Feed")
facebook_commentary="Social media"
facebook_tags=("social" "internet_shortcuts")
facebook_arguments=("facebook")
facebook_bashfunctions=("facebook.sh")
facebook_launcherkeynames=("default")
facebook_default_exec="xdg-open https://facebook.com/"

fastcommands_name="Fast commands"
fastcommands_description="Collection of multi-purpose commands"
fastcommands_version="1.0"
fastcommands_systemcategories=("System" "Utility")
fastcommands_commentary="The useful arguments you always forget from commands you love."
fastcommands_tags=("fast" "terminal" "bashfunctions")
fastcommands_arguments=("fast_commands")
fastcommands_bashfunctions=("fastcommands.sh")

fdupes_installationtype="packagemanager"
fdupes_arguments=("fdupes")
fdupes_packagenames=("fdupes")
fdupes_readmeline="| Fdupes | Searches for duplicated files within given directories | Command \`fdupes\`|| <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

fetch_name="Function fetch"
fetch_description="Alias for git fetch --prune"
fetch_version="1.0"
fetch_systemcategories=("System" "Utility")
fetch_commentary="A terminal shortcut for git."
fetch_tags=("gitbashfunctions" "terminal")
fetch_arguments=("fetch")
fetch_bashfunctions=("fetch.sh")

ffmpeg_installationtype="packagemanager"
ffmpeg_arguments=("ffmpeg" "youtube_dl_dependencies")
ffmpeg_packagenames=("ffmpeg")
ffmpeg_readmeline="| ffmpeg | Super fast video / audio encoder | Command \`ffmpeg\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

filezilla_installationtype="packagemanager"
filezilla_arguments=("filezilla")
filezilla_bashfunctions=("filezilla.sh")
filezilla_packagenames=("filezilla")
filezilla_downloads=("https://upload.wikimedia.org/wikipedia/commons/0/01/FileZilla_logo.svg;filezilla_icon.svg")
filezilla_readmeline="| FileZilla | FTP Client & Server | Command \`filezilla\`, desktop launcher, dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
filezilla_launchercontents=("[Desktop Entry]
Categories=Network;
Comment=FTP Client & Server
Encoding=UTF-8
Exec=filezilla
Icon=${BIN_FOLDER}/filezilla/filezilla_icon.svg
GenericName=Document
Keywords=forms;
MimeType=
Name=FileZilla
StartupNotify=true
StartupWMClass=FileZilla
Terminal=false
TryExec=filezilla
Type=Application
Version=1.0
")

firefox_installationtype="packagemanager"
firefox_arguments=("firefox")
firefox_bashfunctions=("firefox.sh")
firefox_launchernames=("firefox")
firefox_packagenames=("firefox")
firefox_readmeline="| Firefox | Free web browser | Command \`firefox\`, desktop launcher, dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

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

forms_arguments=("forms" "google_forms")
forms_name="Google Forms"
forms_description="Google Forms opening in Chrome"
forms_version="Google dependent"
forms_systemcategories=("Documentation")
forms_commentary="make polls and surveys to retrieve statistical data"
forms_tags=("google" "internet_shortcuts")
forms_bashfunctions=("forms.sh")
forms_launcherkeynames=("default")
forms_default_exec="xdg-open https://docs.google.com/forms/"

freecad_installationtype="packagemanager"
freecad_arguments=("freecad")
freecad_launchernames=("freecad")
freecad_packagenames=("freecad")
freecad_readmeline="| FreeCAD | General-purpose parametric 3D computer-aided design modeler and a building information modeling | Command \`freecad\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

gcc_installationtype="packagemanager"
gcc_arguments=("gcc")
gcc_bashfunctions=("gcc.sh")
gcc_packagenames=("gcc")
gcc_readmeline="| GNU C Compiler | C compiler for GNU systems | Command \`gcc\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

geany_installationtype="packagemanager"
geany_arguments=("geany")
geany_launchernames=("geany")
geany_packagenames=("geany")
geany_readmeline="| Geany | Lightweight GUI text editor using Scintilla and GTK, including basic IDE features | Command \`geany\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

geogebra_installationtype="userinherit"
geogebra_arguments=("geogebra" "geogebra_classic_6" "geogebra_6")
geogebra_binariesinstalledpaths=("GeoGebra;geogebra")
geogebra_compressedfileurl="https://download.geogebra.org/package/linux-port6"
geogebra_downloads=("https://upload.wikimedia.org/wikipedia/commons/5/57/Geogebra.svg;geogebra_icon.svg")
geogebra_description="Geometry calculator GUI"
geogebra_launchercontents=("[Desktop Entry]
Categories=geometry;
Comment=${geogebra_description}
Encoding=UTF-8
Exec=geogebra
GenericName=Geometry visualization plotter
Icon=${BIN_FOLDER}/geogebra/geogebra_icon.svg
Keywords=GeoGebra;geogebra;
MimeType=
Name=GeoGebra
StartupNotify=true
StartupWMClass=geogebra
Terminal=false
TryExec=geogebra
Type=Application
Version=4.2.2
")
geogebra_readmeline="| GeoGebra | ${geogebra_description} | Command \`geogebra\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

ghostwriter_installationtype="packagemanager"
ghostwriter_arguments=("ghostwriter")
ghostwriter_launchernames=("ghostwriter")
ghostwriter_packagenames=("ghostwriter")
ghostwriter_readmeline="| GhostWriter | Text editor without distractions. | Command \`ghostwriter, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gimp_installationtype="packagemanager"
gimp_arguments=("gimp")
gimp_launchernames=("gimp")
gimp_packagenames=("gimp")
gimp_readmeline="| Gimp | Raster graphics editor used for image manipulation and image editing, free-form drawing, transcoding between different image file formats. | Command \`gimp\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

git_installationtype="packagemanager"
git_arguments=("git")
git_packagenames=("git" "git-all" "git-lfs")
git_readmeline="| git | Software for tracking changes in any set of files, usually used for coordinating work among programmers collaboratively developing source code during software development | Command \`git\` and \`gitk\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gitcm_installationtype="userinherit"
gitcm_arguments=("git_c_m")
gitcm_binariesinstalledpaths=("git-credential-manager-core;gitcm")
gitcm_compressedfileurl="https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.696/gcmcore-linux_amd64.2.0.696.tar.gz"
gitcm_compressedfilepathoverride="${BIN_FOLDER}/gitcm"  # It has not a folder inside
gitcm_donotinherit="yes"
gitcm_readmeline="| Git Credentials Manager | Plug-in for git to automatically use personal tokens | Command \`gitcm\` || <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |"
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

github_arguments=("github")
github_name="Github"
github_description="Github opening in Chrome"
github_version="Google dependent"
github_systemcategories=("RevisionControl")
github_commentary="Hosting repositories online"
github_tags=("internet_shortcuts")
github_bashfunctions=("github.sh")
github_launcherkeynames=("default")
github_default_exec="xdg-open https://github.com/"

github_desktop_installationtype="packageinstall"
github_desktop_arguments=("github_desktop")
github_desktop_launchernames=("github-desktop")
github_desktop_packagenames=("github")
github_desktop_packageurls=("https://github.com/shiftkey/desktop/releases/download/release-2.6.3-linux1/GitHubDesktop-linux-2.6.3-linux1.deb")
github_desktop_package_manager_override="apt-get"
github_desktop_readmeline="| GitHub Desktop | GitHub Application | Command \`github-desktop\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gitk_installationtype="packagemanager"
gitk_arguments=("gitk")
gitk_packagedependencies=("unifont")
gitk_bashfunctions=("gitk.sh")
gitk_packagenames=("gitk")
gitk_readmeline="| Gitk | GUI for git | Command \`gitk\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gitlab_arguments=("git_lab")
gitlab_name="Gitlab"
gitlab_description="Gitlab opening in Chrome"
gitlab_version="Google dependent"
gitlab_systemcategories=("RevisionControl")
gitlab_commentary="Hosting repositories online"
gitlab_tags=("search" "internet_shortcuts")
gitlab_bashfunctions=("gitlab.sh")
gitlab_launcherkeynames=("default")
gitlab_default_exec="xdg-open https://gitlab.com/"

gitprompt_installationtype="repositoryclone"
gitprompt_arguments=("git_prompt")
gitprompt_bashfunctions=("gitprompt.sh")
gitprompt_readmeline="| gitprompt | Special prompt in git repositories | Command \`gitprompt\`|| <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
gitprompt_repositoryurl="https://github.com/magicmonty/bash-git-prompt.git"

gmail_arguments=("gmail" "google_mail")
gmail_name="Gmail"
gmail_version="Google dependent"
gmail_systemcategories=("Email")
gmail_commentary="Send/Receive e-mails"
gmail_tags=("email" "internet_shortcuts")
gmail_bashfunctions=("gmail.sh")
gmail_launcherkeynames=("default")
gmail_default_exec="xdg-open https://mail.google.com/"
gmail_description="Gmail opening in Chrome"

gnat_gps_installationtype="packagemanager"
gnat_gps_arguments=("gnat_gps")
gnat_gps_description="Programming Studio for Ada and C"
gnat_gps_launchercontents=("
[Desktop Entry]
Type=Application
Name=GNAT Programming Studio
Comment=${gnat_gps_description}
Exec=/usr/bin/gnat-gps
Icon=/usr/share/doc/gnat-gps/html/users_guide/_static/favicon.ico
Terminal=false
Categories=Development;IDE
Keywords=ide;editor;ada;c
")
gnat_gps_packagenames=("gnat-gps")
gnat_gps_readmeline="| GNAT | ${gnat_gps_description} | Command \`gnat-gps\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT change to one word keyname
gnome_calculator_installationtype="packagemanager"
gnome_calculator_arguments=("gnome_calculator" "calculator" "calc")
gnome_calculator_launchernames=("org.gnome.Calculator")
gnome_calculator_packagenames=("gnome-calculator")
gnome_calculator_readmeline="| Calculator | GUI calculator| Commmand \`calculator\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT change to one word keyname
gnome_chess_installationtype="packagemanager"
gnome_chess_arguments=("gnome_chess" "chess")
gnome_chess_launchernames=("org.gnome.Chess")
gnome_chess_packagenames=("gnome-chess")
gnome_chess_readmeline="| Chess | Plays a full game of chess against a human being or other computer program | Command \`gnome-chess\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT change to one word keyname
gnome_mahjongg_installationtype="packagemanager"
gnome_mahjongg_arguments=("gnome_mahjongg" "mahjongg")
gnome_mahjongg_launchernames=("org.gnome.Mahjongg")
gnome_mahjongg_packagenames=("gnome-mahjongg")
gnome_mahjongg_readmeline="| Mahjongg | Implementation for GNU systems of the famous popular chinese game Mahjongg | Command \`gnome-mahjongg\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT change to one word keyname
gnome_mines_installationtype="packagemanager"
gnome_mines_arguments=("gnome_mines" "mines")
gnome_mines_launchernames=("org.gnome.Mines")
gnome_mines_packagenames=("gnome-mines")
gnome_mines_readmeline="| Mines | Implementation for GNU systems of the famous game mines | Command \`gnome-mines\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT change to one word keyname
gnome_sudoku_installationtype="packagemanager"
gnome_sudoku_arguments=("gnome_sudoku" "sudoku")
gnome_sudoku_launchernames=("org.gnome.Sudoku")
gnome_sudoku_packagenames=("gnome-sudoku")
gnome_sudoku_readmeline="| sudoku | Implementation for GNU systems of the famous popular mathematical game sudoku | Command \`gnome-sudoku\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gnome_terminal_installationtype="packagemanager"
gnome_terminal_arguments=("gnome_terminal")
gnome_terminal_keybindings=("gnome-terminal;<Primary><Alt><Super>t;GNOME Terminal")
gnome_terminal_launchernames=("org.gnome.Terminal")
gnome_terminal_packagenames=("gnome-terminal")
gnome_terminal_readmeline="| GNOME terminal | Terminal of the system | Command \`gnome-terminal\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT change to one word keyname
gnome_tweak_tool_installationtype="packagemanager"
gnome_tweak_tool_arguments=("gnome_tweak_tool" "tweaks" "gnome_tweak" "gnome_tweak_tools" "gnome_tweaks")
gnome_tweak_tool_packagenames=("gnome-tweak-tool")
gnome_tweak_tool_launchernames=("org.gnome.tweaks")
gnome_tweak_tool_readmeline="| GNOME Tweaks | GUI for system customization | command and desktop launcher... ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

go_installationtype="userinherit"
go_arguments=("go" "go_lang")
go_compressedfileurl="https://golang.org/dl/go1.17.linux-amd64.tar.gz"
go_compressedfilepathoverride="/usr/local"
go_flagsoverride="0;;;;;"  # Install always as root
go_bashinitializations=("go.sh")
go_readmeline="| go | programming language | command \`go\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

google_arguments=("google")
google_name="Google"
google_version="Google dependent"
google_systemcategories=("Documentation")
google_commentary="Search any content in the internet"
google_tags=("search" "internet_shortcuts")
google_bashfunctions=("google.sh")
google_launcherkeynames=("default")
google_default_exec="xdg-open https://www.google.com/"
google_description="google opening in Chrome"

googlecalendar_arguments=("google_calendar")
googlecalendar_name="Google Calendar"
googlecalendar_version="Google dependent"
googlecalendar_systemcategories=("Calendar")
googlecalendar_commentary="Calendar, add, edit and remove events"
googlecalendar_tags=("search" "internet_shortcuts")
googlecalendar_bashfunctions=("googlecalendar.sh")
googlecalendar_launcherkeynames=("default")
googlecalendar_default_exec="xdg-open https://calendar.google.com/"
googlecalendar_description="Google Calendar opening in Chrome"

# TODO @AleixMT chnage keyname to chrome
google_chrome_name="Google Chrome"
google_chrome_arguments=("google_chrome")
google_chrome_bashfunctions=("google_chrome.sh")
google_chrome_flagsoverride=";;;;1;"
google_chrome_arguments=("chrome" "google_chrome" "googlechrome")
google_chrome_commentary="The all-in-one browser"
google_chrome_version="Google dependent"
google_chrome_tags=("browser" "network")
google_chrome_systemcategories=("Network" "WebBrowser")
google_chrome_launcherkeynames=("default")
google_chrome_default_exec="google-chrome"
google_chrome_packagedependencies=("libxss1" "libappindicator1" "libindicator7" "fonts-liberation")
google_chrome_downloadKeys=("debianPackage")
google_chrome_debianPackage_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
google_chrome_debianPackage_installedPackages="google-chrome-stable"
google_chrome_package_manager_override="apt-get"
google_chrome_launcherkeys=("default")
google_chrome_keybindings=("google-chrome;<Primary><Alt><Super>c;Google Chrome")

gpaint_installationtype="packagemanager"
gpaint_arguments=("gpaint")
gpaint_launchercontents=("
[Desktop Entry]
Name=GNU Paint
Comment=A small-scale painting program for GNOME, the GNU Desktop
TryExec=gpaint
Exec=gpaint
Icon=/usr/share/icons/hicolor/scalable/apps/gpaint.svg
Terminal=0
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;
X-Ubuntu-Gettext-Domain=gpaint-2
")
gpaint_packagenames=("gpaint")
gpaint_readmeline="| Gpaint | Raster graphics editor similar to Microsoft Paint | Command \`gpaint\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

gparted_installationtype="packagemanager"
gparted_arguments=("gparted")
gparted_launchernames=("gparted")
gparted_packagenames=("gparted")
gparted_readmeline="| GParted | Creating, deleting, resizing, moving, checking, and copying disk partitions and their file systems | Command \`gparted\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

guake_installationtype="packagemanager"
guake_arguments=("guake")
guake_bashfunctions=("guake.sh")
guake_packagenames=("guake")
guake_launchernames=("guake")
guake_readmeline="| guake | Press F12 to display a terminal | Command \`guake\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
guake_flagsoverride=";;;;;1"  # Always autostart

gvim_installationtype="packagemanager"
gvim_arguments=("gvim" "vim_gtk3")
gvim_launchernames=("gvim")
gvim_packagenames=("vim-gtk3")
gvim_readmeline="| Gvim | Vim with a built-in GUI | Command \`gvim\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

h_name="Function h"
h_description="Search in your history for previous commands entered, stands by history | grep \"\$@\""
h_version="1.0"
h_systemcategories=("System" "Utility")
h_commentary="Search your previous terminal commands"
h_tags=("bashfunctions" "terminal" "info")
h_arguments=("h")
h_bashfunctions=("h.sh")

handbrake_installationtype="packagemanager"
handbrake_arguments=("handbrake")
handbrake_launchernames=("fr.handbrake.ghb")
handbrake_packagenames=("handbrake")
handbrake_readmeline="| Handbrake | Video Transcoder | Command \`handbrake\`, Desktop and dashboard launchers || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

hard_name="Function h"
hard_description="Alias for git reset HEAD --hard"
hard_version="1.0"
hard_systemcategories=("System" "Utility")
hard_commentary="A terminal shortcut for git"
hard_tags=("gitbashfunctions" "terminal")
hard_arguments=("hard" "hard_git" "git_hard")
hard_bashfunctions=("hard.sh")

hardinfo_installationtype="packagemanager"
hardinfo_arguments=("hardinfo")
hardinfo_packagenames=("hardinfo")
hardinfo_launchernames=("hardinfo")
hardinfo_readmeline="| Hardinfo | Check pc hardware info | Command \`hardinfo\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

historyoptimization_name="Function history optimization"
historyoptimization_description="Shared history in terminal session and other tweaks for the terminal history"
historyoptimization_version="1.0"
historyoptimization_systemcategories=("System" "Utility")
historyoptimization_commentary="Increased the size of bash history, store multiline commands in just one line, force append and not overwrite to history, ignore repeated commands when appending to history, deleted tracking history of some simple commands: \`ls\`, \`cd\`, \`gitk\`... "
historyoptimization_tags=("bashfunctions" "terminal")
historyoptimization_arguments=("history_optimization")
historyoptimization_bashfunctions=("history_optimization.sh")

i_name="Function i"
i_description="Shows folder structures"
i_version="1.0"
i_systemcategories=("System" "Utility")
i_commentary="A terminal shortcut"
i_tags=("bashfunctions" "terminal" "info")
i_arguments=("i" "i_function" "info")
i_bashfunctions=("i.sh")

ideac_installationtype="userinherit"
ideac_arguments=("ideac" "intellij_community")
ideac_name="IntelliJ Community"
ideac_commentary="Integrated development environment written in Java for developing computer software"
ideac_version="2021.3"
ideac_tags=("IDE" "development" "text editor" "dev" "programming" "java")
ideac_systemcategories=("Debugger" "IDE" "WebDevelopment" "ComputerScience" "Development")
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

ideau_installationtype="userinherit"
ideau_arguments=("ideau" "intellij_ultimate")
ideau_name="IntelliJ Ultimate"
ideau_commentary="Integrated development environment written in Java for developing computer software"
ideau_version="2021.3"
ideau_tags=("IDE" "development" "text editor" "dev" "programming" "java")
ideau_systemcategories=("Debugger" "IDE" "WebDevelopment" "ComputerScience" "Development")
ideau_associatedfiletypes=("text/x-java")
ideau_bashfunctions=("ideau.sh")
ideau_binariesinstalledpaths=("bin/idea.sh;ideau")
ideau_compressedfileurl="https://download.jetbrains.com/idea/ideaIU-2021.3.tar.gz"
ideau_launcherkeynames=("launcher")
ideau_launcher_exec="ideau %f"
ideau_launcher_windowclass="jetbrains-idea"
ideau_launcher_actionkeynames=("newwindow")
ideau_launcher_newwindow_name="IntelliJ Community New Window"
ideau_launcher_newwindow_exec="ideau"
ideau_launchercontents=("
[Desktop Entry]
Categories=Development;IDE;
Comment=${ideau_description}
Encoding=UTF-8
Exec=ideau %f
GenericName=Java programing IDE
Icon=${BIN_FOLDER}/ideau/bin/idea.png
Keywords=IDE;programming;java;dev;
MimeType=
Name=IntelliJ IDEA Ultimate Edition
StartupNotify=true
StartupWMClass=jetbrains-idea
Terminal=false
TryExec=ideau
Type=Application
Version=1.0
")
ideau_readmeline="| intelliJ Ultimate | ${ideau_description} | Command \`ideau\`, silent alias for \`ideau\`, desktop launcher, dashboard launcher and association to \`.java\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li><li>- [x] Fedora</li></ul> |"

inkscape_installationtype="packagemanager"
inkscape_arguments=("ink_scape")
inkscape_launchernames=("inkscape")
inkscape_packagenames=("inkscape")
inkscape_readmeline="| Inkscape | Vector graphics editor used to create vector images, primarily in Scalable Vector Graphics format | Command \`inkscape\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

instagram_arguments=("instagram")
instagram_name="Instagram"
instagram_version="Google dependent"
instagram_systemcategories=("Calendar")
instagram_commentary="Calendar, add and remove events"
instagram_tags=("search" "internet_shortcuts")
instagram_bashfunctions=("instagram.sh")
instagram_launcherkeynames=("default")
instagram_default_exec="xdg-open https://instagram.com"
instagram_description="Instagram opening in Chrome"

ipe_name="Function ipe"
ipe_description="Returns the public IP"
ipe_version="1.0"
ipe_systemcategories=("System" "Utility")
ipe_commentary="A terminal shortcut"
ipe_tags=("bashfunctions" "terminal" "network" "info")
ipe_arguments=("ipe")
ipe_bashfunctions=("ipe.sh")

ipi_name="Function ipi"
ipi_description="Returns the private IP"
ipi_version="1.0"
ipi_systemcategories=("System" "Utility")
ipi_commentary="A terminal shortcut"
ipi_tags=("bashfunctions" "terminal" "network" "info")
ipi_arguments=("ipi")
ipi_bashfunctions=("ipi.sh")

ips_name="Function ips"
ips_description="Returns the IP information"
ips_version="1.0"
ips_systemcategories=("System" "Utility")
ips_commentary="A terminal shortcut"
ips_tags=("bashfunctions" "terminal" "network" "info")
ips_arguments=("ips")
ips_bashfunctions=("ips.sh")

iqmol_installationtype="packageinstall"
iqmol_arguments=("iqmol")
iqmol_bashfunctions=("iqmol.sh")
iqmol_downloads=("http://www.iqmol.org/images/icon.png;iqmol_icon.png")
iqmol_description="Program to visualize molecular data"
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
iqmol_packageurls=("http://www.iqmol.org/download.php?get=iqmol_2.14.deb")
iqmol_package_manager_override="apt-get"
iqmol_readmeline="| IQmol | ${iqmol_description} | Command \`iqmol\`, silent alias, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

j_name="Function j"
j_description="Alias for jobs -l"
j_version="1.0"
j_systemcategories=("System" "Utility")
j_commentary="A terminal shortcut"
j_tags=("bashfunctions" "terminal" "system" "info")
j_arguments=("j")
j_bashfunctions=("j.sh")

java_installationtype="userinherit"
java_arguments=("java" "java_development_kit" "java_development" "java_development_kit_8" "jdk" "jdk_8")
java_bashfunctions=("java.sh")
java_binariesinstalledpaths=("bin/java;java" "bin/keytool;keytool")
java_compressedfileurl="https://builds.openlogic.com/downloadJDK/openlogic-openjdk/8u262-b10/openlogic-openjdk-8u262-b10-linux-x64.tar.gz"
java_readmeline="| Java Development Kit 8 | Implementation of version 8 of the Java (programming language) SE Platform | Commands \`java\`, \`javac\` and \`jar\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

julia_installationtype="userinherit"
julia_arguments=("julia")
julia_binariesinstalledpaths=("bin/julia;julia")
julia_compressedfileurl="https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.5-linux-x86_64.tar.gz"
julia_description="High-level, high-performance dynamic language for technical computing"
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
jupyter_lab_installationtype="pythonvenv"
jupyter_lab_arguments=("jupyter_lab" "jupyter" "lab")
jupyter_lab_bashfunctions=("jupyter_lab.sh")
jupyter_lab_binariesinstalledpaths=("bin/jupyter-lab;jupyter-lab" "bin/jupyter;jupyter" "bin/ipython;ipython" "bin/ipython3;ipython3")
jupyter_lab_flagsoverride=";;1;;;"  # Ignore Errors to check dependencies. This is a patch
jupyter_lab_description="IDE with a lot of possible customization and usable for different programming languages."
jupyter_lab_launchercontents=("
[Desktop Entry]
Categories=IDE; text_editor;
Comment=${jupyter_lab_description}
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
Icon=${BIN_FOLDER}/jupyter_lab/share/icons/hicolor/scalable/apps/notebook.svg
Exec=jupyter-lab &
")
jupyter_lab_manualcontentavailable="1;1;0"
jupyter_lab_pipinstallations=("jupyter jupyterlab jupyterlab-git jupyterlab_markup" "bash_kernel" "pykerberos pywinrm[kerberos]" "powershell_kernel" "iarm" "ansible-kernel" "kotlin-jupyter-kernel" "vim-kernel" "theme-darcula")
jupyter_lab_pythoncommands=("bash_kernel.install" "iarm_kernel.install" "ansible_kernel.install" "vim_kernel.install")  # "powershell_kernel.install --powershell-command powershell"  "kotlin_kernel fix-kernelspec-location"
jupyter_lab_readmeline="| Jupyter Lab | ${jupyter_lab_description} | alias \`lab\`, commands \`jupyter-lab\`, \`jupyter-lab\`, \`ipython\`, \`ipython3\`, desktop launcher and dashboard launcher. Recognized programming languages: Python, Ansible, Bash, IArm, Kotlin, PowerShell, Vim. || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
install_jupyter_lab_pre() {
  local -r dependencies=("npm" "R" "julia")
  for dependency in "${dependencies[@]}"; do

    if ! which "${dependency}" &>/dev/null; then
      output_proxy_executioner "echo ERROR: ${dependency} is not installed. You can installing using bash install.sh --npm --R --julia" "${FLAG_QUIETNESS}"
      exit 1
    fi
  done
}
install_jupyter_lab_mid() {
  # Enable dark scrollbars by clicking on Settings -> JupyterLab Theme -> Theme Scrollbars in the JupyterLab menus.
  "${BIN_FOLDER}/jupyter_lab/bin/jupyter" labextension install @telamonian/theme-darcula
  "${BIN_FOLDER}/jupyter_lab/bin/jupyter" labextension enable @telamonian/theme-darcula

  "${BIN_FOLDER}/jupyter_lab/bin/jupyter" lab build

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
uninstall_jupyter_lab_pre() {
  :
}
uninstall_jupyter_lab_mid() {

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
k_systemcategories=("System" "Utility")
k_commentary="A terminal shortcut"
k_tags=("bashfunctions" "terminal" "system")
k_arguments=("k")
k_bashfunctions=("k.sh")

keep_arguments=("keep" "google_keep")
keep_name="Google Keep"
keep_version="Google dependent"
keep_systemcategories=("Documentation")
keep_commentary="Add and remove notes online"
keep_tags=("search" "internet_shortcuts")
keep_bashfunctions=("keep.sh")
keep_launcherkeynames=("default")
keep_default_exec="xdg-open https://keep.google.com"
keep_description="keep opening in Chrome"

keyboardfix_installationtype="environmental"
keyboardfix_arguments=("keyboard_fix" "fix_keyboard")
keyboardfix_description="Fixes the Fn key in combination with the Function keys F1, F2, etc. which happens to not work in some keyboards"
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
L_systemcategories=("System" "Utility")
L_commentary="A terminal shortcut"
L_tags=("bashfunctions" "terminal" "info")
L_arguments=("L")
L_bashfunctions=("L.sh")

l_name="Function l"
l_description="alias for \`ls\`"
l_version="1.0"
l_systemcategories=("System" "Utility")
l_commentary="A terminal shortcut"
l_tags=("bashfunctions" "terminal" "system" "info")
l_arguments=("l")
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

# TODO @AleixMT integrate into anydesk
libgtkglext1_installationtype="packagemanager"
libgtkglext1_arguments=("libgtkglext1" "anydesk_dependencies")
libgtkglext1_packagenames=("libgtkglext1")
libgtkglext1_readmeline="| libgtkglext1 | Anydesk dependency | Used when Anydesk is run ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT integrate into ? (discover what program has dependency) or delete
libkrb5_dev_installationtype="packagemanager"
libkrb5_dev_arguments=("libkrb5_dev" "kerberos_dependencies")
libkrb5_dev_packagenames=("libkrb5-dev")
libkrb5_dev_readmeline="| libkrb5-dev | Kerberos dependency | Used when Jupiter Lab is run ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT integrate into zoom
libxcb_xtest0_installationtype="packagemanager"
libxcb_xtest0_arguments=("libxcb_xtest0")
libxcb_xtest0_packagenames=("libxcb-xtest0")
libxcb_xtest0_readmeline="| libxcb-xtest0 | Zoom dependency | Used when Zoom is run ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

lmms_installationtype="packagemanager"
lmms_arguments=("lmms")
lmms_bashfunctions=("lmms.sh")
lmms_packagenames=("lmms")
lmms_launchernames=("lmms")
lmms_readmeline="| lmms | Software for making music | command \`lmms\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

loc_name="Function loc"
loc_description="Counts lines of code"
loc_version="1.0"
loc_systemcategories=("System" "Utility")
loc_commentary="A terminal shortcut"
loc_tags=("bashfunctions" "terminal" "system" "info")
loc_arguments=("loc" "function_loc")
loc_bashfunctions=("loc.sh")

lolcat_name="Function lolcat"
lolcat_description="Same as the command \`cat\` but outputting the text in rainbow color and concatenate string"
lolcat_version="System dependent"
lolcat_systemcategories=("System" "Utility")
lolcat_commentary="Terminal rainbow font"
lolcat_tags=("terminal" "system")
lolcat_arguments=("lolcat")
lolcat_bashfunctions=("lolcat.sh")
lolcat_packagenames=("lolcat")

matlab_installationtype="userinherit"
matlab_arguments=("matlab" "mat_lab" "math_works")
# Matlab can only be downloaded by creating an account, making it impossible to download the file programmatically.
# Instead, download the linux installation file of matlab and manually cache it into customizer cache in order to
# install matlab. To do so, put this file into $CACHE_FOLDER and rename it to "matlab_compressed_file"
matlab_compressedfileurl="https://es.mathworks.com/downloads/web_downloads"
# It is an installer. Decompress in temporal folder to install and remove afterwards
matlab_compressedfilepathoverride="${TEMP_FOLDER}"
# When following the graphical installation of matlab, install it in $BIN_FOLDER/matlab in order to find the executables
# when creating these links in the path.
matlab_binariesinstalledpaths=("bin/matlab;matlab" "bin/mex;mex")
matlab_downloads=('https://upload.wikimedia.org/wikipedia/commons/2/21/Matlab_Logo.png;matlab_icon.svg')
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
matlab_readmeline="| Matlab | IDE + programming language specialized in matrix operations | command \`matlab\`, \'mex\' ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [x] Debian</li></ul> |"
install_matlab_mid()
{
  "${TEMP_FOLDER}/matlab/install"  # Execute installer
  rm -Rf "${TEMP_FOLDER}/matlab"
}
uninstall_matlab_mid()
{
  :
}

mdadm_installationtype="packagemanager"
mdadm_arguments=("mdadm")
mdadm_packagenames=("mdadm")
mdadm_readmeline="| mdadm | Manage RAID systems | Command \`mdadm\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

megasync_installationtype="packageinstall"
megasync_arguments=("megasync" "mega")
megasync_packagedependencies=("nemo" "libc-ares2" "libmediainfo0v5" "libqt5x11extras5" "libzen0v5")
megasync_packageurls=("https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/megasync_4.6.1-2.1_amd64.deb" "https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/nemo-megasync_4.0.2_amd64.deb")
megasync_package_manager_override="apt-get"
megasync_launchernames=("megasync")
megasync_packagenames=("nautilus-megasync" "megasync")
megasync_readmeline="| MegaSync | Synchronises folders between your computer and your MEGA Cloud Drive | Command \`megasync\`, desktop launcher, dashboard launcher and integration with \`nemo\` file explorer ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

meld_installationtype="userinherit"
meld_packagedependencies=("libgtksourceview-4-dev" "libgtksourceview-3.0-1")
meld_arguments=("meld")
meld_bashfunctions=("meld.sh")
meld_binariesinstalledpaths=("bin/meld;meld")
meld_compressedfileurl="https://download.gnome.org/sources/meld/3.21/meld-3.21.0.tar.xz"
meld_launchercontents=("
[Desktop Entry]
Name=Meld
Name[bg]=Meld
Name[bs]=Meld
Name[ca]=Meld
Name[ca@valencia]=Meld
Name[cs]=Meld
Name[da]=Meld
Name[de]=Meld
Name[dz]=མེལཌི་
Name[el]=Meld
Name[en_CA]=Meld
Name[en_GB]=Meld
Name[eo]=Meldo
Name[es]=Meld
Name[eu]=Meld
Name[fi]=Meld
Name[fr]=Meld
Name[gl]=Meld
Name[he]=‏Meld
Name[hu]=Meld
Name[id]=Meld
Name[it]=Meld
Name[ja]=Meld
Name[ko]=Meld
Name[nb]=Meld
Name[ne]=मेल्ड
Name[nl]=Meld
Name[oc]=Meld
Name[pa]=Meld
Name[pl]=Meld
Name[pt]=Meld
Name[pt_BR]=Meld
Name[ro]=Meld
Name[ru]=Meld
Name[sk]=Meld
Name[sl]=Meld
Name[sq]=Meld
Name[sr]=Мелд
Name[sr@latin]=Meld
Name[sv]=Meld
Name[tr]=Meld
Name[uk]=Обʼєднати
Name[vi]=Meld
Name[zh_CN]=Meld
Name[zh_TW]=Meld
GenericName=Diff Viewer
GenericName[bg]=Преглед на разлики
GenericName[bs]=Diff pregledač
GenericName[ca]=Visualitzador de diferències
GenericName[ca@valencia]=Visualitzador de diferències
GenericName[cs]=Prohlížeč rozdílů
GenericName[da]=Diff-fremviser
GenericName[de]=Diff-Betrachter
GenericName[el]=Προβολή διαφορών
GenericName[eo]=Montrilo de diferencoj
GenericName[es]=Visor de diferencias
GenericName[eu]=Diferentzia-ikustailea
GenericName[fi]=Erojen vertailija
GenericName[fr]=Visionneur de différences
GenericName[gl]=Visualizador Diff
GenericName[he]=מציג הבדלי קבצים
GenericName[hu]=Eltérésmegjelenítő
GenericName[id]=Penampil Diff
GenericName[it]=Visualizzatore di differenze
GenericName[ja]=差分ビューアー
GenericName[nb]=Vis forskjeller
GenericName[oc]=Visionador de diferéncias
GenericName[pl]=Przeglądarka różnic
GenericName[pt]=Visualizador de diferenças
GenericName[pt_BR]=Visualizador de diff
GenericName[ro]=Vizualizator de diferențe
GenericName[ru]=Просмотр различий
GenericName[sk]=Prehliadač rozdielov
GenericName[sl]=Pregledovalnik sprememb
GenericName[sr]=Прегледач разлика
GenericName[sr@latin]=Pregledač razlika
GenericName[sv]=Diffvisare
GenericName[tr]=Fark Görüntüleyicisi
GenericName[vi]=Bộ so sánh sự khác biệt Meld
GenericName[zh_CN]=差异查看器
GenericName[zh_TW]=差異檢視程式
X-GNOME-FullName=Meld Diff Viewer
X-GNOME-FullName[bg]=Програма за сравняване Meld
X-GNOME-FullName[bs]=Meld Diff pregledač
X-GNOME-FullName[ca]=Visualitzador de diferències Meld
X-GNOME-FullName[ca@valencia]=Visualitzador de diferències Meld
X-GNOME-FullName[cs]=Prohlížeč rozdílů Meld
X-GNOME-FullName[da]=Meld - diff-fremviser
X-GNOME-FullName[de]=Meld Diff-Betrachter
X-GNOME-FullName[dz]=མེལཌི་མ་འདྲཝ་སྟོན་མི་
X-GNOME-FullName[el]=Προβολή διαφορών Meld
X-GNOME-FullName[en_CA]=Meld Diff Viewer
X-GNOME-FullName[en_GB]=Meld Diff Viewer
X-GNOME-FullName[eo]=Meldo - Montrilo de diferencoj
X-GNOME-FullName[es]=Visor de diferencias Meld
X-GNOME-FullName[eu]=Meld diferentzia-ikustailea
X-GNOME-FullName[fi]=Meld - erojen vertailija
X-GNOME-FullName[fr]=Meld visionneur de différences
X-GNOME-FullName[gl]=Visualizador Diff Meld
X-GNOME-FullName[he]=מציג הבדלי קבצים
X-GNOME-FullName[hu]=Meld eltérésmegjelenítő
X-GNOME-FullName[id]=Meld Penampil Diff
X-GNOME-FullName[it]=Visualizzatore di differenze Meld
X-GNOME-FullName[ja]=Meld 差分ビューアー
X-GNOME-FullName[ko]=Meld 차이 보기
X-GNOME-FullName[nb]=Meld visning av forskjeller
X-GNOME-FullName[ne]=मेल्ड फरक दर्शक
X-GNOME-FullName[nl]=Meld diff-weergave
X-GNOME-FullName[oc]=Visionador de diferéncias Meld
X-GNOME-FullName[pl]=Przeglądarka różnic Meld
X-GNOME-FullName[pt]=Visualizador de Diferenças Meld
X-GNOME-FullName[pt_BR]=Visualizador de diff Meld
X-GNOME-FullName[ro]=Vizualizatorul de diferențe Meld
X-GNOME-FullName[ru]=Meld — приложение для просмотра различий
X-GNOME-FullName[sk]=Prehliadač rozdielov Meld
X-GNOME-FullName[sl]=Meld pregledovalnik različic
X-GNOME-FullName[sq]=Parësi i Dallimesh Meld
X-GNOME-FullName[sr]=Прегледач разлика Мелд
X-GNOME-FullName[sr@latin]=Pregledač razlika Meld
X-GNOME-FullName[sv]=Meld diffvisare
X-GNOME-FullName[tr]=Meld Fark Görüntüleyicisi
X-GNOME-FullName[uk]=Переглядач відмінностей Meld
X-GNOME-FullName[vi]=Bộ so sánh sự khác biệt Meld
X-GNOME-FullName[zh_CN]=Meld Diff 差异查看器
X-GNOME-FullName[zh_TW]=Meld 差異檢視程式
Comment=Compare and merge your files
Comment[bg]=Сравняване и сливане на файлове
Comment[bs]=Poredite i združite svoje datoteke
Comment[ca]=Compareu i fusioneu fitxers
Comment[ca@valencia]=Compareu i fusioneu fitxers
Comment[cs]=Porovnává a slučuje soubory
Comment[da]=Sammenlign og flet dine filer
Comment[de]=Vergleichen und Zusammenführen von Dateien
Comment[el]=Σύγκριση και συγχώνευση των αρχείων σας
Comment[eo]=Kompari kaj kunfandi dosierojn
Comment[es]=Compare y combine sus archivos
Comment[eu]=Konparatu eta konbinatu fitxategiak
Comment[fi]=Vertaa ja yhdistä tiedostoja
Comment[fr]=Comparer et fusionner des fichiers
Comment[gl]=Compare e combine os seus ficheiros
Comment[he]=השוואה ומיזוג של קבצים
Comment[hu]=Fájlok összehasonlítása és összefésülése
Comment[id]=Membandingkan dan menggabung berkas-berkas Anda
Comment[it]=Confronta e unisce file
Comment[ja]=複数のファイルを比較したりマージしたりします
Comment[nb]=Sammenligne og flett sammen dine filer
Comment[oc]=Comparar e fusionar de fichièrs
Comment[pl]=Porównywanie i scalanie plików
Comment[pt]=Compare e una os seus ficheiros.
Comment[pt_BR]=Compare e mescle seus arquivos
Comment[ro]=Comparați-vă și combinati-vă fișierele
Comment[ru]=Сравнение и объединение файлов
Comment[sk]=Porovná a zlúči vaše súbory
Comment[sl]=Primerjava in združevanje datotek
Comment[sr]=Упоређујте и спајајте ваше датотеке
Comment[sr@latin]=Upoređujte i spajajte vaše datoteke
Comment[sv]=Jämför och sammanfoga dina filer
Comment[tr]=Dosyalarınızı karşılaştırın ve birleştirin
Comment[vi]=So sánh và trộn các tập tin của bạn
Comment[zh_CN]=比较和合并您的文件
Comment[zh_TW]=比對及合併您的檔案
# TRANSLATORS: Search terms to find this application. Do NOT translate or localize the semicolons! The list MUST also end with a semicolon!
Keywords=diff;merge;
Keywords[cs]=rozdíl;odlišnosti;diff;porovnání;porovnávání;srovnání;srovnávání;slučování;sloučení;
Keywords[da]=diff;flet;
Keywords[de]=diff;merge;
Keywords[es]=diff;mezcla;
Keywords[eu]=diff;merge;
Keywords[fi]=diff;merge;yhdistäminen;
Keywords[fr]=diff;fusion;
Keywords[gl]=comparar;combinar;
Keywords[hu]=diff;merge;különbség;patch;folt;
Keywords[id]=diff;merge;
Keywords[it]=diff;merge;differenze;unione;
Keywords[ja]=diff;merge;比較;マージ;
Keywords[pl]=różnica;diff;merge;scalanie;łączenie;połącz;porównaj;łata;łatka;patch;
Keywords[pt]=diff;diferenças;comparar;unir;
Keywords[pt_BR]=comparar;diferença;diff;mesclar;mesclagem;merge;
Keywords[ro]=diff;merge;diferență;diferențe;îmbinare;
Keywords[sl]=diff;merge;primerjava;usklajevanje;
Keywords[sr]=разлике;стопи;
Keywords[sr@latin]=razlike;stopi;
Keywords[sv]=diff;merge;sammanfogning;
Keywords[tr]=diff;fark;birleştir;merge;
Keywords[zh_TW]=差異;合併;diff;merge;
Exec=meld %F
Terminal=false
Type=Application
Icon=${BIN_FOLDER}/meld/data/icons/hicolor/scalable/apps/org.gnome.meld.svg
MimeType=application/x-meld-comparison;
StartupNotify=true
Categories=GTK;Development;
")
meld_readmeline="| Meld | Visual diff and merge tool for developers | Command \`meld\`, desktop launcher, dashboard launcher and integration with \`nemo\` file explorer ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

mendeley_installationtype="userinherit"
mendeley_arguments=("mendeley")
mendeley_compressedfileurl="https://www.mendeley.com/autoupdates/installer/Linux-x64/stable-incoming"
mendeley_binariesinstalledpaths="bin/mendeleydesktop;mendeley"
mendeley_packagedependencies=("gconf2" "qt5-default" "qt5-doc" "qt5-doc-html" "qtbase5-examples" "qml-module-qtwebengine")
mendeley_description="It is most known for its reference manager which is used to manage and share research papers and generate bibliographies for scholarly articles"
mendeley_readmeline="| Mendeley | ${mendeley_description} | Command \`mendeley\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
mendeley_launchercontents=("
[Desktop Entry]
Name=Mendeley Desktop
GenericName=Research Paper Manager
Comment=${mendeley_description}
Exec=mendeley %f
Icon=${BIN_FOLDER}/mendeley/share/icons/hicolor/128x128/apps/mendeleydesktop.png
Terminal=false
Type=Application
Categories=Education;Literature;Qt;
X-SuSE-translate=false
MimeType=x-scheme-handler/mendeley;application/pdf;text/x-bibtex;
X-Mendeley-Version=1
")

merge_name="Function merge"
merge_description="Function for git merge"
merge_version="1.0"
merge_tags=("gitbashfunctions" "git")
merge_systemcategories=("System" "Utility")
merge_commentary="A terminal function for merging in git"
merge_arguments=("merge" "merge_function" "function_merge" "git_merge")
merge_bashfunctions=("merge.sh")

msttcorefonts_installationtype="packagemanager"
msttcorefonts_arguments=("msttcorefonts")
msttcorefonts_packagenames=("msttcorefonts")
msttcorefonts_readmeline="| font Msttcorefonts | Windows classic fonts | Install mscore fonts ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

mvn_installationtype="userinherit"
mvn_arguments=("mvn")
mvn_binariesinstalledpaths=("bin/mvn;mvn")
mvn_compressedfileurl="https://ftp.cixug.es/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz"
mvn_readmeline="| Maven | Build automation tool used primarily for Java projects | Command \`mvn\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li><li>- [x] Fedora</li></ul> |"
mvn_bashfunctions=("mvn.sh")

nano_installationtype="packagemanager"
nano_arguments=("nano")
nano_packagenames=("nano")
nano_readmeline="| nano | CLI File editor | Command \`nano\` and syntax highlighting ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
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
  if [ ${EUID} == 0 ]; then
    nano_default_path="$(update-alternatives --list editor | grep -Eo "^.*nano.*$" | head -1)"
    if [ -n "${nano_default_path}" ]; then
      update-alternatives --set editor "${nano_default_path}"
    fi
  fi
}
uninstall_nano_post()
{
  # Restore editor to the default one (usually vim)
  if [ ${EUID} == 0 ]; then
    update-alternatives --auto editor
  fi

  # Restore default editor to git if we have it installed
  if which git &>/dev/null; then
    git config --global core.editor "editor"
  fi

}

nautilus_installationtype="packagemanager"
nautilus_arguments=("nautilus")
nautilus_bashinitializations=("nautilus.sh")
nautilus_launchernames=("org.gnome.Nautilus")
nautilus_packagenames=("nautilus")
nautilus_readmeline="| Nautilus | Standard file and desktop manager | Command \`nautilus\` Desktop launcher and dashboard launcher for the file manager ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

ncat_installationtype="packagemanager"
ncat_packagenames=("ncat")
ncat_arguments=("ncat")
ncat_readmeline="| ncat | Reads and writes across the network | Command \`ncat\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

nedit_installationtype="packagemanager"
nedit_arguments=("nedit")
nedit_packagenames=("nedit")
nedit_launchernames=("nedit")
nedit_readmeline="| NEdit | Multi-purpose text editor and source code editor | Command \`nedit\` desktop launcher, dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

nemo_installationtype="packagemanager"
nemo_arguments=("nemo" "nemo_desktop")
nemo_bashfunctions=("nemo.sh")
nemo_bashinitializations=("nemo_config.sh")
nemo_packagenames=("nemo")
nemo_packagedependencies=("dconf-editor")
nemo_description="File and desktop manager, usually with better options and less bugs than nautilus. *We recommend this explorer to view correctly the launchers*"
nemo_launchercontents=("
[Desktop Entry]
OnlyShowIn=GNOME;Unity;KDE;
X-Ubuntu-Gettext-Domain=nemo

Name=Files
Name[am]=ፋይሎች
Name[ar]=الملفات
Name[bg]=Файлове
Name[ca]=Fitxers
Name[ca@valencia]=Fitxers
Name[cs]=Soubory
Name[cy]=Ffeiliau
Name[da]=Filer
Name[de]=Dateien
Name[el]=Αρχεία
Name[eo]=Dosieroj
Name[es]=Archivos
Name[et]=Failid
Name[eu]=Fitxategiak
Name[fi]=Tiedostot
Name[fr]=Fichiers
Name[fr_CA]=Fichiers
Name[he]=קבצים
Name[hr]=Nemo
Name[hu]=Fájlok
Name[id]=Berkas
Name[is]=Skrár
Name[kab]=Ifuyla
Name[ko]=파일
Name[lt]=Failai
Name[nl]=Bestanden
Name[pl]=Pliki
Name[pt]=Ficheiros
Name[pt_BR]=Arquivos
Name[ro]=Fișiere
Name[ru]=Файлы
Name[sk]=Súbory
Name[sl]=Datoteke
Name[sr]=Датотеке
Name[sr@latin]=Датотеке
Name[sv]=Filer
Name[th]=แฟ้ม
Name[tr]=Dosyalar
Name[uk]=Файли
Name[zh_CN]=文件
Name[zh_HK]=檔案
Comment=Access and organize files
Comment[am]=ፋይሎች ጋር መድረሻ እና ማደራጃ
Comment[ar]=الوصول إلى الملفات وتنظيمها
Comment[bg]=Достъп и управление на файлове
Comment[ca]=Organitzeu i accediu als fitxers
Comment[ca@valencia]=Organitzeu i accediu als fitxers
Comment[cs]=Přístup k souborům a jejich správa
Comment[cy]=Mynediad i drefnu ffeiliau
Comment[da]=Tilgå og organisér filer
Comment[de]=Dateien aufrufen und organisieren
Comment[el]=Πρόσβαση και οργάνωση αρχείων
Comment[en_GB]=Access and organise files
Comment[eo]=Atingi kaj organizi dosierojn
Comment[es]=Acceder a los archivos y organizarlos
Comment[et]=Ligipääs failidele ning failipuu korrastamine
Comment[eu]=Atzitu eta antolatu fitxategiak
Comment[fi]=Avaa ja järjestä tiedostoja
Comment[fr]=Accéder aux fichiers et les organiser
Comment[fr_CA]=Accéder aux fichiers et les organiser
Comment[he]=גישה לקבצים וארגונם
Comment[hr]=Pristupite i organizirajte datoteke
Comment[hu]=Fájlok elérése és rendszerezése
Comment[ia]=Acceder e organisar le files
Comment[id]=Akses dan kelola berkas
Comment[ie]=Accesse e ordina files
Comment[is]=Aðgangur og skipulag skráa
Comment[it]=Accede ai file e li organizza
Comment[kab]=Kcem udiɣ suddes ifuyla
Comment[ko]=파일 접근 및 정리
Comment[lt]=Gauti prieigą prie failų ir juos tvarkyti
Comment[nl]=Bestanden gebruiken en organiseren
Comment[pl]=Porządkowanie i dostęp do plików
Comment[pt]=Aceder e organizar ficheiros
Comment[pt_BR]=Acesse e organize arquivos
Comment[ro]=Accesează și organizează fișiere
Comment[ru]=Управление и доступ к файлам
Comment[sk]=Prístup a organizácia súborov
Comment[sl]=Dostop in razvrščanje datotek
Comment[sr]=Приступите датотекама и организујте их
Comment[sr@latin]=Приступите датотекама и организујте их
Comment[sv]=Kom åt och organisera filer
Comment[th]=เข้าถึงและจัดระเบียบแฟ้ม
Comment[tr]=Dosyalara eriş ve düzenle
Comment[uk]=Доступ до файлів та впорядковування файлів
Comment[zh_CN]=访问和组织文件
Comment[zh_HK]=存取與組織檔案
Exec=nemo %U
Icon=folder
# Translators: these are keywords of the file manager
Keywords=folders;filesystem;explorer;
Terminal=false
Type=Application
StartupNotify=false
Categories=GNOME;GTK;Utility;Core;
MimeType=inode/directory;application/x-gnome-saved-search;
Actions=open-home;open-computer;open-trash;

[Desktop Action open-home]
Name=Home
Name[af]=Tuis
Name[am]=ቤት
Name[ar]=المجلد الرئيسي
Name[be]=Дом
Name[bg]=Домашна папка
Name[bn]=হোম
Name[bs]=Početni direktorij
Name[ca]=Carpeta de l'usuari
Name[ca@valencia]=Carpeta de l'usuari
Name[cs]=Domov
Name[cy]=Cartref
Name[da]=Hjem
Name[de]=Persönlicher Ordner
Name[el]=Προσωπικός φάκελος
Name[eo]=Hejmo
Name[es]=Carpeta personal
Name[et]=Kodu
Name[eu]=Karpeta nagusia
Name[fi]=Koti
Name[fr]=Dossier personnel
Name[fr_CA]=Dossier personnel
Name[ga]=Baile
Name[gd]=Dhachaigh
Name[gl]=Cartafol persoal
Name[he]=בית
Name[hr]=Osobna mapa
Name[hu]=Saját mappa
Name[ia]=Al domo
Name[id]=Beranda
Name[ie]=Hem
Name[is]=Heimamappa
Name[ja]=ホーム
Name[kab]=Agejdan
Name[kk]=Үй
Name[kn]=ಮನೆ
Name[ko]=홈
Name[ku]=Mal
Name[lt]=Namai
Name[ml]=ആസ്ഥാനം
Name[mr]=मुख्य
Name[ms]=Rumah
Name[nb]=Hjem
Name[nl]=Persoonlijke map
Name[oc]=Dorsièr personal
Name[pl]=Katalog domowy
Name[pt]=Pasta Pessoal
Name[pt_BR]=Pasta pessoal
Name[ro]=Dosar personal
Name[ru]=Домашняя папка
Name[sk]=Domov
Name[sl]=Domov
Name[sr]=Почетна
Name[sr@latin]=Početna
Name[sv]=Hem
Name[ta]=இல்லம்
Name[tg]=Асосӣ
Name[th]=บ้าน
Name[tr]=Ev Dizini
Name[uk]=Домівка
Name[ur]=المنزل
Name[vi]=Nhà
Name[zh_CN]=主目录
Name[zh_HK]=家
Name[zh_TW]=家
Exec=nemo %U

[Desktop Action open-computer]
Name=Computer
Name[af]=Rekenaar
Name[am]=ኮምፒዩተር
Name[ar]=الكمبيوتر
Name[ast]=Ordenador
Name[be]=Кампутар
Name[bg]=Компютър
Name[bn]=কম্পিউটার
Name[bs]=Računar
Name[ca]=Ordinador
Name[ca@valencia]=Ordinador
Name[cs]=Počítač
Name[cy]=Cyfrifiadur
Name[de]=Rechner
Name[el]=Υπολογιστής
Name[eo]=Komputilo
Name[es]=Equipo
Name[et]=Arvuti
Name[eu]=Ordenagailua
Name[fi]=Tietokone
Name[fr]=Poste de travail
Name[fr_CA]=Poste de travail
Name[gd]=Coimpiutair
Name[gl]=Computador
Name[he]=מחשב
Name[hr]=Računalo
Name[hu]=Számítógép
Name[ia]=Computator
Name[id]=Komputer
Name[ie]=Computator
Name[is]=Tölva
Name[ja]=コンピュータ
Name[kab]=Aselkim
Name[kk]=Компьютер
Name[kn]=ಗಣಕ
Name[ko]=컴퓨터
Name[ku]=Komputer
Name[lt]=Kompiuteris
Name[ml]=കമ്പ്യൂട്ടർ
Name[mr]=संगणक
Name[ms]=Komputer
Name[nb]=Datamaskin
Name[nn]=Datamaskin
Name[oc]=Ordenador
Name[pl]=Komputer
Name[pt]=Computador
Name[pt_BR]=Computador
Name[ru]=Компьютер
Name[sk]=Počítač
Name[sl]=Računalnik
Name[sq]=Kompjuteri
Name[sr]=Рачунар
Name[sr@latin]=Računar
Name[sv]=Dator
Name[ta]=கணினி
Name[tg]=Компютер
Name[th]=คอมพิวเตอร์
Name[tr]=Bilgisayar
Name[uk]=Комп’ютер
Name[ur]=کمپیوٹر
Name[vi]=Máy tính
Name[zh_CN]=计算机
Name[zh_HK]=電腦
Name[zh_TW]=電腦
Exec=nemo computer:///

[Desktop Action open-trash]
Name=Trash
Name[af]=Asblik
Name[am]=ቆሻሻ
Name[ar]=سلة المهملات
Name[ast]=Papelera
Name[be]=Сметніца
Name[bg]=Кошче
Name[bn]=ট্র্যাশ
Name[bs]=Smeće
Name[ca]=Paperera
Name[ca@valencia]=Paperera
Name[cs]=Koš
Name[cy]=Sbwriel
Name[da]=Papirkurv
Name[de]=Papierkorb
Name[el]=Απορρίμματα
Name[en_GB]=Rubbish Bin
Name[eo]=Rubujo
Name[es]=Papelera
Name[et]=Prügi
Name[eu]=Zakarrontzia
Name[fi]=Roskakori
Name[fr]=Corbeille
Name[fr_CA]=Corbeille
Name[ga]=Bruscar
Name[gd]=An sgudal
Name[gl]=Lixo
Name[he]=אשפה
Name[hr]=Smeće
Name[hu]=Kuka
Name[ia]=Immunditia
Name[id]=Tempat sampah
Name[ie]=Paper-corb
Name[is]=Rusl
Name[it]=Cestino
Name[ja]=ゴミ箱
Name[kab]=Iḍumman
Name[kk]=Себет
Name[kn]=ಕಸಬುಟ್ಟಿ
Name[ko]=휴지통
Name[ku]=Avêtî
Name[lt]=Šiukšlinė
Name[ml]=ട്രാഷ്
Name[mr]=कचरापेटी
Name[ms]=Tong Sampah
Name[nb]=Papirkurv
Name[nds]=Papierkorb
Name[nl]=Prullenbak
Name[nn]=Papirkorg
Name[oc]=Escobilhièr
Name[pl]=Kosz
Name[pt]=Lixo
Name[pt_BR]=Lixeira
Name[ro]=Coș de gunoi
Name[ru]=Корзина
Name[sk]=Kôš
Name[sl]=Smeti
Name[sq]=Koshi
Name[sr]=Смеће
Name[sr@latin]=Kanta
Name[sv]=Papperskorg
Name[ta]=குப்பைத் தொட்டி
Name[tg]=Сабад
Name[th]=ถังขยะ
Name[tr]=Çöp
Name[uk]=Смітник
Name[ur]=ردی
Name[vi]=Thùng rác
Name[zh_CN]=回收站
Name[zh_HK]=垃圾桶
Name[zh_TW]=回收筒
Exec=nemo trash:///
")
nemo_readmeline="| Nemo Desktop | Access and organise files | Command \`nemo\` for the file manager, and \`nemo-desktop\` for the desktop manager service. Desktop launcher and dashboard launcher for the file manager ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
nemo_autostartlaunchers=("
[Desktop Entry]
Type=Application
Name=Nemo
Comment=Start Nemo desktop at log in
Exec=nemo-desktop
AutostartCondition=GSettings org.nemo.desktop show-desktop-icons
X-GNOME-AutoRestart=true
X-GNOME-Autostart-Delay=2
NoDisplay=false
")
nemo_flagsoverride=";;;;;1"  # Always autostart
nemo_keybindings=("nemo;<Super>e;Nemo File Explorer")

netflix_arguments=("netflix" "google_netflix")
netflix_name="Netflix"
netflix_version="Google dependent"
netflix_systemcategories=("Player")
netflix_commentary="View films and TV series online"
netflix_tags=("film" "television" "internet_shortcuts")
netflix_bashfunctions=("netflix.sh")
netflix_launcherkeynames=("default")
netflix_default_exec="xdg-open https://www.netflix.com"
netflix_description="Netflix opening in Chrome"

net_tools_installationtype="packagemanager"
net_tools_arguments=("net_tools")
net_tools_bashfunctions=("net_tools.sh")
net_tools_packagenames=("net-tools")
net_tools_readmeline="| net-tools | GUI network interfaces. *We recommend this explorer to view correctly the launchers* | Command \`net-tools\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

nmap_installationtype="packagemanager"
nmap_arguments=("nmap")
nmap_readmeline="| nmap | Scan and network security used for port scanning. | Command \`nmap\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

nodejs_installationtype="userinherit"
nodejs_arguments=("node" "node_js")
nodejs_binariesinstalledpaths=("bin/node;node" "bin/npm;npm" "bin/npx;npx")
nodejs_compressedfileurl="https://nodejs.org/dist/v14.17.0/node-v14.17.0-linux-x64.tar.xz"
nodejs_readmeline="| NodeJS | JavaScript packagemanager for the developers. | Command \`node\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

npm_installationtype="packagemanager"
npm_arguments=("npm")
npm_packagenames=("npm")
npm_launchernames=("npm")
npm_readmeline="| npm | Nodejs package manager | Command \`npm\` ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

notepadqq_installationtype="packagemanager"
notepadqq_arguments=("notepad_qq")
notepadqq_packagenames=("notepadqq")
notepadqq_launchernames=("notepadqq")
notepadqq_readmeline="| Notepadqq | Text editor that is designed by developers for the developers. It supports more than 100 programming languages | Command \`notepadqq\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT wontfix
notflix_installationtype="environmental"
notflix_arguments=("notflix")
notflix_packagedependencies=("curl" "vlc")
notflix_bashfunctions=("notflix.sh")
notflix_readmeline="| Function \`notflix\` | Stream title movies via console magnet tracking | Function \`notflix\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

obs_studio_name="Open Broadcaster Software Studio"
obs_studio_commentary="The basic tool for a streamer"
obs_studio_description="Streaming and recording software"
obs_studio_version="System dependent"
obs_studio_tags=("stream" "online")
obs_studio_systemcategories=("Utility" "Recorder")
obs_studio_arguments=("obs_studio" "obs")
# TODO port info obs_studio_launchernames=("com.obsproject.Studio")
obs_studio_launcherkeynames=("defautLauncher")
obs_studio_defaultLauncher_exec="obs"
obs_studio_packagedependencies=("ffmpeg")
obs_studio_packagenames=("obs-studio")

octave_installationtype="packagemanager"
octave_arguments=("octave" "gnu_octave" "octave_cli")
octave_bashfunctions=("octave.sh")
octave_packagenames=("octave")
octave_launchernames=("org.octave.Octave")
octave_readmeline="| GNU Octave | Programming language and IDE | Command \`octave\`, desktop launcher and dashboard launcher. ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

okular_installationtype="packagemanager"
okular_arguments=("okular")
okular_launchernames=("org.kde.okular")
okular_packagenames=("okular")
okular_readmeline="| Okular | PDF viewer | Command \`okular\`, desktop launcher and dashboard launcher ||   <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT wontfix substitute by github.com/abraunegg/onedrive with clone install
onedrive_installationtype="environmental"
onedrive_arguments=("onedrive")
onedrive_url="https://onedrive.live.com/"
onedrive_bashfunctions=("onedrive.sh")
onedrive_downloads=("https://upload.wikimedia.org/wikipedia/commons/3/3c/Microsoft_Office_OneDrive_%282019%E2%80%93present%29.svg;onedrive_icon.svg")
onedrive_description="Microsoft OneDrive opening in Chrome"
onedrive_launchercontents=("
[Desktop Entry]
Categories=FileSharing;
Comment=${onedrive_description}
Encoding=UTF-8
Exec=xdg-open ${onedrive_url}
Icon=${BIN_FOLDER}/onedrive/onedrive_icon.svg
GenericName=OneDrive
Keywords=onedrive;
MimeType=
Name=OneDrive
StartupNotify=true
StartupWMClass=onedrive
Terminal=false
TryExec=xdg-open
Type=Application
Version=1.0
")
onedrive_readmeline="| OneDrive | ${onedrive_description} | Command \`onedrive\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

libreoffice_installationtype="packagemanager"
libreoffice_arguments=("open_office" "office" "libre_office")
libreoffice_packagenames=("libreoffice-base-core" "libreoffice-impress" "libreoffice-calc" "libreoffice-math" "libreoffice-common" "libreoffice-ogltrans" "libreoffice-core" "libreoffice-pdfimport" "libreoffice-draw" "libreoffice-style-breeze" "libreoffice-gnome" "libreoffice-style-colibre" "libreoffice-gtk3" "libreoffice-style-elementary" "libreoffice-help-common" "libreoffice-style-tango" "libreoffice-help-en-us" "libreoffice-writer")
#openoffice_packageurls=("https://downloads.sourceforge.net/project/openofficeorg.mirror/4.1.9/binaries/en-US/Apache_OpenOffice_4.1.9_Linux_x86-64_install-deb_en-US.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fopenofficeorg.mirror%2Ffiles%2F4.1.9%2Fbinaries%2Fen-US%2FApache_OpenOffice_4.1.9_Linux_x86-64_install-deb_en-US.tar.gz%2Fdownload&ts=1614201028")
libreoffice_launchernames=("libreoffice-impress" "libreoffice-calc" "libreoffice-draw" "libreoffice-math" "libreoffice-startcenter" "libreoffice-writer")  # "libreoffice-xsltfilter"
libreoffice_readmeline="| OpenOffice | Office suite for open-source systems | Command \`openoffice4\` in PATH, desktop launchers for \`base\`, \`calc\`, \`draw\`, \`math\` and \`writer\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

openssl102_installationtype="packageinstall"
openssl102_arguments=("openssl102")
openssl102_packageurls=("http://security.debian.org/debian-security/pool/updates/main/o/openssl1.0/libssl1.0.2_1.0.2u-1~deb9u4_amd64.deb")
opensll102_package_manager_override="apt-get"
openssl102_readmeline="| openssl1.0 | RStudio dependency | Used for running rstudio ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

openssh_server_installationtype="packagemanager"
openssh_server_arguments=("openssh_server")
openssh_server_packagenames=("openssh-server")
openssh_server_bashfunctions=("openssh_server.sh")
openssh_server_readmeline="| openssh-server | SSH server | Used for running an SSH server ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
openssh_server_manualcontentavailable="0;0;1"
openssh_server_conf=(
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
install_openssh_server_post()
{
  for conf_element in "${openssh_server_conf[@]}"; do
    append_text "${conf_element}" "${SSH_GLOBAL_CONF_PATH}"
  done
}
uninstall_openssh_server_post()
{
  for conf_element in "${openssh_server_conf[@]}"; do
    remove_line "${conf_element}" "${SSH_GLOBAL_CONF_PATH}"
  done
}

outlook_arguments=("outlook" "microsoft_outlook")
outlook_name="Outlook"
outlook_version="Google dependent"
outlook_systemcategories=("Email")
outlook_commentary="Email client from Microsoft"
outlook_tags=("search" "internet_shortcuts")
outlook_bashfunctions=("outlook.sh")
outlook_launcherkeynames=("default")
outlook_default_exec="xdg-open https://outlook.live.com"
outlook_description="outlook opening in Chrome"

overleaf_arguments=("overleaf")
overleaf_name="Overleaf"
overleaf_version="Google dependent"
overleaf_systemcategories=("ProjectManagement" "Documentation" "TextEditor")
overleaf_commentary="Email client from Microsoft"
overleaf_tags=("LaTeX" "text_editor" "internet_shortcuts")
overleaf_bashfunctions=("overleaf.sh")
overleaf_launcherkeynames=("default")
overleaf_default_exec="xdg-open https://www.overleaf.com"
overleaf_description="overleaf opening in Chrome"

p_name="Function p"
p_description="Check processes names and PID's from given port"
p_version="1.0"
p_tags=("bashfunctions" "bash" "info")
p_systemcategories=("System" "Utility")
p_commentary="A terminal shortcut"
p_arguments=("p" "port" "port_function" "p_function" "function_p")
p_bashfunctions=("p.sh")

pacman_installationtype="packagemanager"
pacman_arguments=("pacman")
pacman_launchernames=("pacman")
pacman_packagenames=("pacman")
pacman_readmeline="| Pac-man | Implementation of the classical arcade game | Command \`pacman\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li>x</li><li>- [ ] Debian</li></ul> |"

parallel_installationtype="packagemanager"
parallel_arguments=("parallel" "gnu_parallel")
parallel_packagenames=("parallel")
parallel_readmeline="| GNUparallel | Command-line driven utility for Linux and other Unix-like operating systems which allows the user to execute shell scripts or commands in parallel | Command \`parallel\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

pdfgrep_installationtype="packagemanager"
pdfgrep_arguments=("pdfgrep")
pdfgrep_packagenames=("pdfgrep")
pdfgrep_readmeline="| pdfgrep | CLI utility that makes it possible to search for text in a PDF file without opening the file | Command \`pdfgrep\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

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

php_installationtype="packagemanager"
php_arguments=("php")
php_packagenames=("php" "libapache2-mod-php" "php7.4" "libapache2-mod-php7.4" "php7.4-mysql" "php-common" "php7.4-cli" "php7.4-common" "php7.4-json" "php7.4-opcache" "php7.4-readline")
php_readmeline="| php | Programming language | Command \`php\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

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

pluma_installationtype="packagemanager"
pluma_arguments=("pluma")
pluma_bashfunctions=("pluma.sh")
pluma_launchernames=("pluma")
pluma_packagenames=("pluma")
pluma_readmeline="| pluma | Fork of gedit 2.0 that supports many plugins and new features | Command \`pluma\`, desktop launcjer and dashboard launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

postman_installationtype="userinherit"
postman_arguments=("postman")
postman_binariesinstalledpaths=("Postman;postman")
postman_compressedfileurl="https://dl.pstmn.io/download/latest/linux64"
postman_description="Application to maintain and organize collections of REST API calls"
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
postman_readmeline="| Postman | ${postman_description} | Command \`postman\`, desktop launcher and dashboard launcher  ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

presentation_arguments=("presentation" "google_presentation")
presentation_name="Google Presentation"
presentation_version="Google dependent"
presentation_systemcategories=("ProjectManagement" "Documentation" "TextEditor")
presentation_commentary="Create presentations online"
presentation_tags=("presentation" "google" "internet_shortcuts")
presentation_bashfunctions=("presentation.sh")
presentation_launcherkeynames=("default")
presentation_default_exec="xdg-open https://docs.google.com/presentation/"
presentation_description="Google Presentation opening in Chrome"

prompt_name="Function prompt"
prompt_description="Installs a new colourful prompt on terminal window"
prompt_version="1.0"
prompt_tags=("bashfunctions" "terminal" "info")
prompt_systemcategories=("System" "Utility")
prompt_commentary="Adds a personalized prompt that shows the date, return code of last executed program, user, group and working directory. It also changes the prompt colour of introduced text to green. It changes the terminal windows title, adds colourful aliases and ensures completion"
prompt_arguments=("prompt")
prompt_bashfunctions=("prompt.sh" "prompt_command.sh")

psql_installationtype="packagemanager"
psql_arguments=("psql" "postgresql")
psql_packagedependencies=("libc6-i386" "lib32stdc++6" "libc6=2.31-0ubuntu9.2")
psql_packagenames=("postgresql-client-12" "postgresql-12" "libpq-dev" "postgresql-server-dev-12")
psql_readmeline="| PostGreSQL | Installs \`psql\`|  Command \`psql\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

pull_name="Function pull"
pull_description="Decorates call to git pull forcing to not fast-forward"
pull_version="1.0"
pull_tags=("gitbashfunctions" "git")
pull_systemcategories=("System" "Utility")
pull_commentary="A terminal function for git"
pull_arguments=("pull")
pull_bashfunctions=("pull.sh")

push_name="Function push"
push_description="Decorates call to git push by setting upstream branch if needed"
push_version="1.0"
push_tags=("gitbashfunctions" "git")
push_systemcategories=("System" "Utility")
push_commentary="A terminal function for git"
push_arguments=("push")
push_bashfunctions=("push.sh")

pycharm_installationtype="userinherit"
pycharm_arguments=("pycharm" "pycharm_community")
pycharm_name="PyCharm Community"
pycharm_commentary="Integrated development environment used in computer programming"
pycharm_version="2021.3"
pycharm_tags=("IDE" "development" "text editor" "dev" "programming" "python")
pycharm_icon="pycharm.png"
pycharm_systemcategories=("Debugger" "IDE" "WebDevelopment" "ComputerScience" "Development")
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

pycharmpro_installationtype="userinherit"
pycharmpro_arguments=("pycharm_pro")
pycharmpro_name="PyCharm Professional"
pycharmpro_commentary="Integrated development environment used in computer programming"
pycharmpro_version="2021.3"
pycharmpro_tags=("IDE" "development" "text editor" "dev" "programming" "python")
pycharmpro_icon="pycharmpro.png"
pycharmpro_systemcategories=("Debugger" "IDE" "WebDevelopment" "ComputerScience" "Development")
pycharmpro_associatedfiletypes=("text/sh" "text/x-python" "text/x-python3")
pycharmpro_bashfunctions=("pycharmpro.sh")
pycharmpro_binariesinstalledpaths=("bin/pycharm.sh;pycharmpro")
pycharmpro_compressedfileurl="https://download.jetbrains.com/python/pycharm-professional-2021.3.tar.gz"
pycharmpro_launcherkeynames=("launcher")
pycharmpro_launcher_exec="pycharmpro %F"
pycharmpro_launcher_windowclass="jetbrains-pycharmpro"
pycharmpro_launcher_actionkeynames=("newwindow")
pycharmpro_launcher_newwindow_name="Pycharm Professional New Window"
pycharmpro_launcher_newwindow_exec="pycharmpro"

pypy3_installationtype="userinherit"
pypy3_arguments=("pypy3" "pypy")
pypy3_binariesinstalledpaths=("bin/pypy3;pypy3" "bin/pip3.6;pypy3-pip")
pypy3_compressedfileurl="https://downloads.python.org/pypy/pypy3.6-v7.3.1-linux64.tar.bz2"
pypy3_manualcontentavailable="0;1;0"
pypy3_readmeline="| pypy3 | Faster interpreter for the Python3 programming language | Commands \`pypy3\` and \`pypy3-pip\` in the PATH || <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
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

python3_installationtype="packagemanager"
python3_arguments=("python_3" "python" "v")
python3_bashfunctions=("v.sh")
python3_packagenames=("python-dev" "python3-dev" "python3-pip" "python3-venv" "python3-wheel" "python3.8-venv")  # "python3-pyqt5" "python3-pyqt4" "python-qt4"
python3_readmeline="| Python3 | Interpreted, high-level and general-purpose programming language | Commands \`python\`, \`python3\`, \`pip3\` and Function \`v\` is for activate/deactivate python3 virtual environments (venv) can be used as default \`v\` as a command creates the /venv/ environment we can activate/deactivate new or existing virtual environments, command \`v namevenv\` creates /namevenv/ we can activate the virtual environment again using \`v namenv\` or deactivate same again, using \`v namenv\` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

R_installationtype="packagemanager"
R_arguments=("R" "r_base")
R_jupyter_lab_function=("
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
R_readmeline="| R | Programming language | Commands \`R\`, Dashboard Launcher, Desktop Launcher|| <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |  "

reddit_arguments=("reddit")
reddit_name="Reddit"
reddit_version="Google dependent"
reddit_systemcategories=("InstantMessaging" "Chat")
reddit_commentary="Reddit forum"
reddit_tags=("forum" "internet_shortcuts")
reddit_bashfunctions=("reddit.sh")
reddit_launcherkeynames=("default")
reddit_default_exec="xdg-open https://www.reddit.com"
reddit_description="Google reddit opening in Chrome"

remmina_installationtype="packagemanager"
remmina_arguments=("remmina")
remmina_packagenames=("remmina")
remmina_launchernames=("org.remmina.Remmina")
remmina_readmeline="| Remmina | Remote Desktop Contol | Commands \`remmina\`, Desktop launcher and Icon || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |  "

rosegarden_installationtype="packagemanager"
rosegarden_arguments=("rosegarden")
rosegarden_bashfunctions=("rosegarden.sh")
rosegarden_packagenames=("rosegarden")
rosegarden_launchernames=("com.rosegardenmusic.rosegarden")
rosegarden_readmeline="| Rosegarden | Software for music production | Commands \`rosegarden\`, Desktop launcher and Icon || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |  "

rstudio_installationtype="userinherit"
rstudio_arguments=("r_studio")
rstudio_associatedfiletypes=("text/plain")
rstudio_bashfunctions=("rstudio.sh")
rstudio_binariesinstalledpaths=("bin/rstudio;rstudio")
rstudio_compressedfileurl="https://download1.rstudio.org/desktop/debian9/x86_64/rstudio-1.4.1717-amd64-debian.tar.gz"
rstudio_description="Default application for .R files "
rstudio_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${rstudio_description}
Encoding=UTF-8
Exec=rstudio
GenericName=RStudio
Icon=${BIN_FOLDER}/rstudio/www/images/favicon.ico
Keywords=rstudio
MimeType=text/plain;
Name=RStudio
StartupNotify=true
StartupWMClass=RStudio
Terminal=false
TryExec=rstudio
Type=Application
Version=1.0
")
rstudio_packagedependencies=("libssl-dev")
rstudio_readmeline="| RStudio | ${rstudio_description} | Commands \`rstudio\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |  "

rsync_installationtype="packagemanager"
rsync_arguments=("rsync" "grsync")
rsync_packagedependencies=("libcanberra-gtk-module" "libcanberra-gtk3-module" "libcanberra-gtk-module:i386")
rsync_packagenames=("rsync" "grsync")
rsync_launchernames=("grsync")
rsync_bashfunctions=("rsync.sh")
rsync_readmeline="| Grsync | Software for file/folders synchronization | Commands \`grsync\`, desktop launcher and \`rsync\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

rustc_installationtype="packagemanager"
rustc_arguments=("rustc")
rustc_packagenames=("rustc")
rustc_packagedependencies=("cmake" "build-essential")
rustc_readmeline="| Rust | Programming Language | Installs \`rustc\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
# rustc_url=("https://sh.rustup.rs")

s_name="Function s"
s_description="Function to execute any program silently and in the background"
s_version="1.0"
s_tags=("bashfunctions" "terminal")
s_systemcategories=("System" "Utility")
s_commentary="A terminal function"
s_arguments=("s")
s_bashfunctions=("s.sh")

scala_installationtype="packagemanager"
scala_arguments=("scala")
scala_packagenames=("scala")
scala_readmeline="| Scala | Programming language | Command \`scala\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

scilab_installationtype="userinherit"
scilab_arguments=("scilab")
scilab_bashfunctions=("scilab.sh")
scilab_binariesinstalledpaths=("bin/scilab;scilab" "bin/scilab-cli;scilab-cli" "bin/scinotes;scinotes")
scilab_packagedependencies=("openjdk-8-jdk-headless" "libtinfo5")
scilab_compressedfileurl="https://www.scilab.org/download/6.1.0/scilab-6.1.0.bin.linux-x86_64.tar.gz"
scilab_packagenames=("scilab")
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
scilab_readmeline="| Scilab | Programming language | Command \`scala\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

screenshots_installationtype="environmental"
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
screenshots_readmeline="| Screenshots | Takes a screenshot and saves it to custom ~/Images/screenshots folder and save it to the clipboard for pasting | Commands \`screenshot-full\` \`screenshot-window\` \`screenshot-area\`||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

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
shortcuts_commentary="A terminal function"
shortcuts_arguments=("shortcuts")
shortcuts_bashfunctions=("shortcuts.sh")
shortcuts_readmeline="| shortcuts |  | variables... (\$DESK...) || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

shotcut_installationtype="packagemanager"
shotcut_arguments=("shotcut")
shotcut_description="Cross-platform video editing"
shotcut_launchercontents=("
[Desktop Entry]
Categories=video;
Comment=${shotcut_description}
Encoding=UTF-8
Exec=shotcut
GenericName=shotcut
Icon=/usr/share/icons/hicolor/64x64/apps/org.shotcut.Shotcut.png
Keywords=video;editing;editor;VideoEdit;
MimeType=
Name=Shotcut
StartupNotify=true
StartupWMClass=ShotCut
Terminal=false
TryExec=shotcut
Type=Application
Version=1.0")
shotcut_packagenames=("shotcut")
shotcut_readmeline="| ShotCut | ${shotcut_description} | Command \`shotcut\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

shotwell_installationtype="packagemanager"
shotwell_arguments=("shotwell")
shotwell_launchernames=("shotwell")
shotwell_packagenames=("shotwell")
shotwell_readmeline="| Shotwell | Cross-platform video editing | Command \`shotwell\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

# TODO @AleixMT wontfix
skype_installationtype="packageinstall"
skype_arguments=("skype")
skype_packagenames=("skype")
skype_launchernames=("skypeforlinux")
skype_packageurls=("https://go.skype.com/skypeforlinux-64.deb")
skype_package_manager_override="apt-get"
skype_readmeline="| Skype | Call & conversation tool service | Icon Launcher... ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

slack_installationtype="packageinstall"
slack_arguments=("slack")
slack_packagenames=("slack-desktop")
slack_packageurls=("https://downloads.slack-edge.com/linux_releases/slack-desktop-4.11.1-amd64.deb")
slack_package_manager_override="apt-get"
slack_launchernames=("slack")
slack_readmeline="| Slack | Platform to coordinate your work with a team | Icon Launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

sonarqube_installationtype="userinherit"
sonarqube_arguments=("sonarqube")
sonarqube_binariesinstalledpaths=("bin/linux-x86-64/sonar.sh;sonar")
sonarqube_compressedfileurl="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.0.1.46107.zip"
sonarqube_readmeline="| Sonarqube | Platform to evaluate source code | Command Icon Launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

sonic_pi_installationtype="packagemanager"
sonic_pi_arguments=("sonic_pi")
sonic_pi_launchernames=("sonic-pi")
sonic_pi_packagenames=("sonic-pi")
sonic_pi_readmeline="| Sonic Pi | programming language that ouputs sounds as compilation product | Command \`sonic-pi\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

soundcloud_arguments=("soudcloud")
soundcloud_name="Soudcloud"
soundcloud_version="Google dependent"
soundcloud_systemcategories=("Music" "Player")
soundcloud_commentary="soundcloud listen music online"
soundcloud_tags=("music" "internet_shortcuts")
soundcloud_bashfunctions=("soundcloud.sh")
soundcloud_launcherkeynames=("default")
soundcloud_default_exec="xdg-open https://www.soundcloud.com"
soundcloud_description="Soudcloud opening in Chrome"

spotify_installationtype="packageinstall"
spotify_arguments=("spotify")
spotify_name="Spotify"
spotify_commentary="Play music in stream"
spotify_version="1.1.72"
spotify_tags=("music" "stream")
spotify_icon="spotify.png"
spotify_systemcategories=("Music" "Audio")
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
spotify_packageurls=("https://repository-origin.spotify.com/pool/non-free/s/spotify-client/spotify-client_1.1.72.439.gc253025e_amd64.deb")
spotify_package_manager_override="apt-get"
spotify_packagedependencies=("libgconf-2-4")
spotify_readmeline="| Spotify | Music streaming service | Command \`spotify\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

spreadsheets_arguments=("spreadsheets" "google_spreadsheets")
spreadsheets_name="Google Spreadsheets"
spreadsheets_version="Google dependent"
spreadsheets_systemcategories=("Documentation" "Spreadsheet")
spreadsheets_commentary="spreadsheets editor online"
spreadsheets_tags=("google" "spreadsheets" "internet_shortcuts")
spreadsheets_bashfunctions=("spreadsheets.sh")
spreadsheets_launcherkeynames=("default")
spreadsheets_default_exec="xdg-open https://docs.google.com/spreadsheets"
spreadsheets_description="Google Spreadsheets opening in Chrome"

ssh_installationtype="packagemanager"
ssh_arguments=("ssh")
ssh_packagenames=("ssh-client")
ssh_downloads=("https://upload.wikimedia.org/wikipedia/commons/6/64/Human-folder-remote-ssh.svg;ssh_icon.svg")
ssh_bashfunctions=("ssh.sh")
ssh_packagedependencies=("openssh-sftp-server" "openssh-client")
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
ssh_readmeline="| ssh | SSH client | Using SSH connections ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

status_name="Function status"
status_description="Alias of git status"
status_version="1.0"
status_tags=("gitbashfunctions" "terminal")
status_systemcategories=("System" "Utility")
status_commentary="A terminal function"
status_arguments=("status")
status_bashfunctions=("status.sh")

steam_installationtype="packageinstall"
steam_arguments=("steam")
steam_launchernames=("steam")
steam_packagenames=("steam-launcher")
steam_packagedependencies=("curl")
steam_packageurls=("https://steamcdn-a.akamaihd.net/client/installer/steam.deb")
steam_package_manager_override="apt-get"
steam_readmeline="| Steam | Video game digital distribution service | Command \`steam\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

studio_installationtype="userinherit"
studio_arguments=("studio" "android_studio")
studio_bashfunctions=("studio.sh")
studio_binariesinstalledpaths=("bin/studio.sh;studio")
studio_compressedfileurl="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2020.3.1.24/android-studio-2020.3.1.24-linux.tar.gz"
studio_description="Development environment for Google's Android operating system"
studio_launchercontents=("
[Desktop Entry]
Categories=Development;IDE;
Comment=${studio_description}
Encoding=UTF-8
Exec=studio %F
GenericName=studio
Icon=${BIN_FOLDER}/studio/bin/studio.svg
Keywords=IDE;programming;android;studio;dev;
MimeType=
Name=Android Studio
StartupNotify=true
StartupWMClass=jetbrains-android-studio
Terminal=false
TryExec=studio
Type=Application
Version=1.0
")
studio_readmeline="| Android Studio | ${studio_description} | Command \`studio\`, alias \`studio\` and desktop and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

sublime_keybindings=("sublime;<Primary><Alt><Super>e;Sublime Text")
sublime_installationtype="userinherit"
sublime_arguments=("sublime" "sublime_text" "subl")
sublime_associatedfiletypes=("text/x-sh" "text/x-c++hdr" "text/x-c++src" "text/x-chdr" "text/x-csrc" "text/x-python" "text/x-python3")
sublime_bashfunctions=("sublime.sh")
sublime_binariesinstalledpaths=("sublime_text;sublime")
sublime_compressedfileurl="https://download.sublimetext.com/sublime_text_build_4113_x64.tar.xz"
sublime_description="Source code editor with an emphasis on source code editing"
sublime_launchercontents=("
[Desktop Entry]
Categories=;
Comment=${sublime_description}
Encoding=UTF-8
Exec=sublime %F
GenericName=Text Editor, programming...
Icon=${BIN_FOLDER}/sublime/Icon/256x256/sublime-text.png
Keywords=subl;sublime;
MimeType=
Name=Sublime Text
StartupNotify=true
StartupWMClass=Sublime
Terminal=false
TryExec=sublime
Type=Application
Version=1.0
")
sublime_readmeline="| Sublime | ${sublime_description} | Command \`sublime\`, silent alias for \`sublime\`, desktop launcher, dashboard launcher, associated with the mime type of \`.c\`, \`.h\`, \`.cpp\`, \`.hpp\`, \`.sh\` and \`.py\` files || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

synaptic_installationtype="packagemanager"
synaptic_arguments=("synaptic")
synaptic_packagenames=("synaptic")
synaptic_launchernames=("synaptic")
synaptic_description="Graphical installation manager to install, remove and upgrade software packages"
synaptic_readmeline="| Synaptic | ${synaptic_description} | Command \`synaptic\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "
synaptic_launchercontents=("
[Desktop Entry]
Name=Synaptic Package Manager
GenericName=Package Manager
Comment=${synaptic_description}
Exec=synaptic
Icon=synaptic
Terminal=false
Type=Application
Categories=PackageManager;GTK;System;Settings;
X-Ubuntu-Gettext-Domain=synaptic
StartupNotify=true
StartupWMClass=synaptic
")

sysmontask_installationtype="repositoryclone"
sysmontask_arguments=("sysmontask")
sysmontask_flagsoverride="0;;;;;"  # To install the cloned software it has to be run as root
sysmontask_bashfunctions=("sysmontask.sh")
sysmontask_launchernames=("SysMonTask")
sysmontask_manualcontentavailable="0;1;0"
sysmontask_readmeline="| Sysmontask | Control panel for linux | Command \`sysmontask\`, desktop launcher, dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "
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

system_fonts_installationtype="environmental"
system_fonts_arguments=("system_fonts")
system_fonts_bashinitializations=("
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
system_fonts_readmeline="| Change default fonts | Sets pre-defined fonts to desktop environment. | A new set of fonts is updated in the system's screen. || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

teamviewer_installationtype="packageinstall"
teamviewer_arguments=("teamviewer")
teamviewer_launchernames=("com.teamviewer.TeamViewer")
teamviewer_packageurls=("https://download.teamviewer.com/download/linux/teamviewer_amd64.deb")
teamviewer_package_manager_override="apt-get"
teamviewer_readmeline="| Team Viewer | Video remote pc control | Command \`teamviewer\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

teams_installationtype="packageinstall"
teams_arguments=("teams" "microsoftteams")
teams_launchernames=("teams")
teams_packagenames=("teams")
teams_packageurls=("https://go.microsoft.com/fwlink/p/?LinkID=2112886&clcid=0x40a&culture=es-es&country=ES")
teams_readmeline="| Microsoft Teams | Video Conference, calls and meetings | Command \`teams\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

# TODO @AleixMT wontfix
telegram_installationtype="userinherit"
telegram_arguments=("telegram")
telegram_binariesinstalledpaths=("Telegram;telegram")
telegram_bashfunctions=("telegram.sh")
telegram_compressedfileurl="https://telegram.org/dl/desktop/linux"
telegram_downloads=("https://telegram.org/img/t_logo.svg;telegram_icon.svg")
telegram_description="Cloud-based instant messaging software and application service"
telegram_launchercontents=("
[Desktop Entry]
Categories=Network;
Comment=${telegram_description}
Encoding=UTF-8
Exec=telegram -- %u
GenericName=Telegram
Icon=${BIN_FOLDER}/telegram/telegram_icon.svg
Keywords=telegram;
MimeType=x-scheme-handler/tg;
Name=Telegram
StartupNotify=true
StartupWMClass=Telegram
Terminal=false
TryExec=telegram
Type=Application
Version=1.0
")
telegram_readmeline="| Telegram | ${telegram_description} | Command \`telegram\`, desktop launcher and dashboard launcher || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> | "

templates_name="Templates"
templates_description="Different collection of templates for starting code projects: Python3 script (\`.py\`), Bash script (\`.sh\`), LaTeX document (\`.tex\`), C script (\`.c\`), C header script (\`.h\`), makefile example (\`makefile\`) and empty text file (\`.txt\`)"
templates_version="1.0"
templates_tags=("bashfunctions" "terminal")
templates_systemcategories=("System" "Utility")
templates_commentary="In the file explorer, right click on any folder to see the contextual menu of \"create document\", where all the templates are located"
templates_arguments=("templates")
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

terminal_background_installationtype="environmental"
terminal_background_arguments=("terminal_background")
terminal_background_bashinitializations=("terminal_background.sh")
terminal_background_readmeline="| Terminal background | Change background of the terminal to black | Every time you open a terminal || <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

terminator_installationtype="packagemanager"
terminator_arguments=("terminator")
terminator_launchernames=("terminator")
terminator_packagenames=("terminator")
terminator_readmeline="| Terminator | Terminal emulator for Linux programmed in Python | Command \`terminator\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

thunderbird_installationtype="packagemanager"
thunderbird_arguments=("thunderbird")
thunderbird_launchernames=("thunderbird")
thunderbird_packagenames=("thunderbird")
thunderbird_readmeline="| Thunderbird | Email, personal information manager, news, RSS and chat client | Command \`thunderbird\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
thunderbird_bashfunctions=("thunderbird.sh")

tilix_installationtype="packagemanager"
tilix_arguments=("tilix")
tilix_launchernames=("com.gexperts.Tilix")
tilix_packagenames=("tilix")
tilix_readmeline="| Tilix | Advanced GTK3 tiling terminal emulator | Command \`tilix\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

tmux_arguments=("tmux")
tmux_version="System dependent"
tmux_name="Terminal multiplexor"
tmux_description="Terminal multiplexor"
tmux_launcherkeynames=("defaultLauncher")
tmux_commentary="Increase productivity using terminal. Manage sessions, windows and panes."
tmux_systemcategories=("System" "Utility")
tmux_tags=("terminal" "sessions")
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
  :
  #crontab "${USR_BIN_FOLDER}/changebg/cronjob"
}

tomcat_arguments=("tomcat" "apache_tomcat" "tomcat_server" "apache")
tomcat_name="Apache Tomcat Server"
tomcat_description="Servlet container"
tomcat_version="9.0.43"
tomcat_tags=("server" "web")
tomcat_systemcategories=("System" "Utility" "Development" "Network")
tomcat_commentary="Basic tool for web development using Java servlets"
tomcat_downloadKeys=("bundle")
tomcat_bundle_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.43/bin/apache-tomcat-9.0.43.tar.gz"

tor_arguments=("tor" "tor_browser")
tor_name="The Onion Router browser"
tor_description="Browser focused on security and privacy. Can browse through the onion protocol"
tor_version="System dependent"
tor_tags=("security" "web" "browser")
tor_systemcategories=("System" "Utility" "Development" "Network" "WebBrowser" "Security")
tor_commentary="Browse the Internet with maximum privacy."
tor_launchernames=("torbrowser")
tor_packagenames=("torbrowser-launcher")

traductor_arguments=("traductor" "google_traductor")
traductor_name="Google Traductor"
traductor_version="Google dependent"
traductor_systemcategories=("Translation")
traductor_commentary="Traduce to any language"
traductor_tags=("google" "traductor" "internet_shortcuts")
traductor_bashfunctions=("traductor.sh")
traductor_launcherkeynames=("default")
traductor_default_exec="xdg-open https://translate.google.com"
traductor_description="Google Traductor opening in Chrome"

transmission_gtk_installationtype="packagemanager"
transmission_gtk_arguments=("transmission_gtk" "transmission")
transmission_gtk_launchernames=("transmission-gtk")
transmission_gtk_packagenames=("transmission")
transmission_gtk_readmeline="| Transmission | A set of lightweight Torrent client (in GUI, CLI and daemon form) | Executable \`transmission\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

trello_arguments=("trello")
trello_name="Trello"
trello_version="Google dependent"
trello_systemcategories=("ProjectManagement")
trello_commentary="Project administration"
trello_tags=("administration" "internet_shortcuts")
trello_bashfunctions=("trello.sh")
trello_launcherkeynames=("default")
trello_default_exec="xdg-open https://trello.com"
trello_description="Google trello opening in Chrome"

tumblr_arguments=("tumblr")
tumblr_name="Tumblr"
tumblr_version="Google dependent"
tumblr_systemcategories=("Feed")
tumblr_commentary="Blogs multimedia"
tumblr_tags=("internet_shortcuts")
tumblr_bashfunctions=("tumblr.sh")
tumblr_launcherkeynames=("default")
tumblr_default_exec="xdg-open https://www.tumblr.com/"
tumblr_description="Tumblr opening in Chrome"

twitch_arguments=("twitch")
twitch_name="Twitch"
twitch_version="Google dependent"
twitch_systemcategories=("VideoConference")
twitch_commentary="Online streaming platform"
twitch_tags=("streaming" "internet_shortcuts")
twitch_bashfunctions=("twitch.sh")
twitch_launcherkeynames=("default")
twitch_default_exec="xdg-open https://twitch.tv"
twitch_description="Twitch.tv opening in Chrome"

twitter_arguments=("twitter")
twitter_name="Twitter"
twitter_version="Google dependent"
twitter_systemcategories=("InstantMessaging" "Chat" "Feed")
twitter_commentary="Microblogging online social platform"
twitter_tags=("internet_shortcuts")
twitter_bashfunctions=("twitter.sh")
twitter_launcherkeynames=("default")
twitter_default_exec="xdg-open https://twitter.com"
twitter_description="twitter.tv opening in Chrome"

u_name="Function u"
u_description="Opens given link in default web browser"
u_version="1.0"
u_tags=("bashfunctions" "web" "browser")
u_systemcategories=("System" "Utility" "Network" "WebBrowser")
u_commentary="Terminal shortcut to open a URL from terminal"
u_arguments=("u")
u_bashfunctions=("u.sh")

uget_installationtype="packagemanager"
uget_arguments=("uget")
uget_launchernames=("uget-gtk")
uget_packagedependencies=("aria2")
uget_packagenames=("uget")
uget_readmeline="| uget | GUI utility to manage downloads | Command \`uget\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

upgrade_arguments=("upgrade")
upgrade_name="Function Upgrade"
upgrade_commentary="Update, upgrade and clean packages in a single command"
upgrade_version="1.0"
upgrade_tags=("system" "management" "apt" "update" "upgrade")
upgrade_systemcategories=("System" "Utility")
upgrade_bashfunctions=("upgrade.sh")

virtualbox_installationtype="packageinstall"
virtualbox_arguments=("virtual_box")
virtualbox_bashfunctions=("virtualbox.sh")
virtualbox_launchernames=("virtualbox")
virtualbox_packagedependencies=("make" "gcc" "perl" "python" "build-essential" "dkms" "libsdl1.2debian" "virtualbox-guest-utils" "libqt5printsupport5" "libqt5x11extras5" "libcurl4" "virtualbox-guest-dkms" "linux-headers-$(uname -r)" "libqt5opengl5" "linux-headers-generic" "linux-source" "linux-generic" "linux-signed-generic")
virtualbox_packagenames=("virtualbox-6.1")
virtualbox_packageurls=("https://download.virtualbox.org/virtualbox/6.1.28/virtualbox-6.1_6.1.28-147628~Ubuntu~eoan_amd64.deb")
virtualbox_package_manager_override="apt-get"
virtualbox_readmeline="| VirtualBox | Hosted hypervisor for x86 virtualization | Command \`virtualbox\`, desktop launcher and dashboard launcher ||  <ul><li>- [ ] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

vlc_installationtype="packagemanager"
vlc_arguments=("vlc")
vlc_launchernames=("vlc")
vlc_packagenames=("vlc")
vlc_readmeline="| VLC | Media player software, and streaming media server | Command \`vlc\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

vncviewer_installationtype="userinherit"
vncviewer_arguments=("vnc_viewer")
vncviewer_name="VNC Viewer"
vncviewer_commentary="Control of the server computer remotely through a cross-platform client."
vncviewer_version="6.21.1109"
vncviewer_tags=("remote" "control" "network")
vncviewer_systemcategories=("Utility" "Network" "Viewer" "Monitor" "RemoteAccess" "Accessibility")
vncviewer_launcherkeynames=("default")
vncviewer_binariesinstalledpaths=("vncviewer;vncviewer")
vncviewer_compressedfileurl=("https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-6.21.1109-Linux-x64-ANY.tar.gz")

vommit_arguments=("vommit")
vommit_name="Function vommit"
vommit_description="Function that do git add -a, git commit commit, git push"
vommit_version="1.0"
vommit_tags=("bashfunctions" "bash")
vommit_systemcategories=("System" "Utility")
vommit_commentary="Dummy commit"
vommit_bashfunctions=("vommit.sh")

whatsapp_arguments=("whatsapp" "whatsapp_web")
whatsapp_name="Whatsapp Web"
whatsapp_version="Google dependent"
whatsapp_systemcategories=("InstantMessaging" "Chat")
whatsapp_commentary="Whatsapp Web for messaging"
whatsapp_tags=("internet_shortcuts")
whatsapp_bashfunctions=("whatsapp.sh")
whatsapp_launcherkeynames=("default")
whatsapp_default_exec="xdg-open https://web.whatsapp.com"
whatsapp_description="Whatsapp Web opening in Chrome"

wikipedia_arguments=("wikipedia")
wikipedia_name="Wikipedia"
wikipedia_version="Google dependent"
wikipedia_systemcategories=("Documentation")
wikipedia_commentary="Free encyclopedia"
wikipedia_tags=("internet_shortcuts")
wikipedia_bashfunctions=("wikipedia.sh")
wikipedia_launcherkeynames=("default")
wikipedia_default_exec="xdg-open https://www.wikipedia.org"
wikipedia_description="Wikipedia opening in Chrome"

wikit_installationtype="environmental"
wikit_manualcontentavailable=";1;"
wikit_flagsoverride="1;;;;;"  # Install always as user
wikit_arguments=("wikit")
wikit_readmeline="| Wikit | Wikipedia search inside terminal | Command \`wikit\` || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"
install_wikit_mid() {
  npm install wikit -g
}
uninstall_wikit_mid() {
  npm remove wikit -g
}

wireshark_installationtype="packagemanager"
wireshark_arguments=("wireshark")
wireshark_launchercontents=("
[Desktop Entry]
# The format of this file is specified at
# https://specifications.freedesktop.org/desktop-entry-spec/1.0/
# The entries are in the order they are listed in version 1.0
Type=Application
# This is the version of the spec for this file, not the application version.
Version=1.0
Name=Wireshark
Name[vi]=Wireshark
GenericName=Network Analyzer
GenericName[af]=Netwerk Analiseerder
GenericName[az]=Şəbəkə Analiz Proqramı
GenericName[bg]=Анализатор на мрежови трафик
GenericName[bs]=Mrežni analizer
GenericName[ca]=Analitzador de xarxa
GenericName[cs]=Analyzátor sítě
GenericName[da]=Netværksanalyse
GenericName[de]=Programm für die Netzwerk-Analyse
GenericName[el]=Αναλυτής Δικτύων
GenericName[en_GB]=Network Analyser
GenericName[eo]=Retanalizilo
GenericName[es]=Analizador de redes
GenericName[et]=Võrguliikluse analüsaator
GenericName[eu]=Sare ikerketaria
GenericName[fa]=تحلیل‌گر شبکه
GenericName[fi]=Verkkoanalysaattori
GenericName[fr]=Analyseur réseau
GenericName[he]=מאבחן רשת
GenericName[hr]=Program za analiziranje mreža
GenericName[hu]=hálózatanalizáló
GenericName[id]=Analisis jaringan
GenericName[is]=Netskoðunartól
GenericName[it]=Analizzatore di rete
GenericName[ja]=ネットワークアナライザ
GenericName[ko]=네트워크 분석기
GenericName[lo]=ເຄື່ອງມືວິເຄາະເຄືອຂ່າຍ
GenericName[lt]=Tinklo analizatorius
GenericName[lv]=Tīkla Analizators
GenericName[mk]=Анализатор на мрежи
GenericName[mn]=Сүлжээ-шинжлэлийн програм
GenericName[mt]=Analizzatur tan-network
GenericName[nb]=Nettverksanalysator
GenericName[nl]=netwerkanalyseprogramma
GenericName[nn]=Nettverksanalysator
GenericName[nso]=Moahlaahli wa Kgokagano
GenericName[pl]=Analizator sieci
GenericName[pt]=Analisador de Redes
GenericName[pt_BR]=Analisador de rede
GenericName[ro]=Analizor de reţea
GenericName[ru]=Анализатор сетевого трафика
GenericName[se]=Fierbmeanalysa
GenericName[sk]=Analyzátor siete
GenericName[sl]=Analizator omrežij
GenericName[sr]=Analizatror mreže
GenericName[ss]=Sihlatiyi seluchungechunge
GenericName[sv]=Nätverksanalyserare
GenericName[ta]=Å¨Ä ¬öÅ¡Ç÷
GenericName[th]=เครื่องมือวิเคราะห์เครือข่าย
GenericName[tr]=Ağ Analiz Programı
GenericName[uk]=Аналізатор мережі
GenericName[ven]=Musengulusi wa Vhukwamani
GenericName[vi]=Trình phân tích  mạng
GenericName[xh]=Umcukucezi Womsebenzi womnatha
GenericName[zh_CN]=网络分析程序
GenericName[zh_TW]=網路分析程式
GenericName[zu]=Umhloli Woxhumano olusakazekile
Comment=Network traffic analyzer
Comment[fi]=Verkkoliikenne analysaattori
Comment[fr]=Analyseur de trafic réseau
Comment[sv]=Nätverkstrafikanalysator
Comment[af]=Netwerkverkeer analiseerder
Comment[sq]=Analizues i trafikut të rrjetit
Comment[ast]=Analizador de tráficu de rede
Comment[bn]=নেটওয়ার্ক ট্রাফিক বিশ্লেষক
Comment[bg]=Анализатор на мрежовия трафик
Comment[bs]=Analizator mrežnoga prometa
Comment[pt_BR]=Analisador de tráfego de rede
Comment[et]=Võrguliikluse analüüsija
Comment[nl]=Netwerkverkeer analyseren
Comment[da]=Netværkstrafikanalyse
Comment[cs]=Analyzátor síťového přenosu
Comment[gl]=Analizador do tráfico de rede
Comment[el]=Ανάλυση κίνησης δικτύου
Comment[de]=Netzwerkverkehr-Analyseprogramm
Comment[hu]=Hálózatiforgalom-elemző
Comment[it]=Analizzatore del traffico di rete
Comment[ja]=ネットワークトラフィックアナライザー
Comment[ko]=네트워크 트래픽 분석기
Comment[ky]=Тармактык трафикти анализдөө
Comment[lt]=Tinklo duomenų srauto analizatorius
Comment[ms]=Penganalisa trafik rangkaian
Comment[nb]=Nettverkstrafikk-analysator
Comment[oc]=Analisador de tramas de ret
Comment[pt]=Analisador de tráfego da rede
Comment[pl]=Analizator ruchu sieciowego
Comment[ro]=Analizator trafic de rețea
Comment[ru]=Анализ сетевого трафика
Comment[sk]=Analyzátor sieťovej premávky
Comment[es]=Analizador de tráfico de red
Comment[sl]=Preučevalnik omrežnega prometa
Comment[tr]=Ağ trafiği çözümleyicisi
Comment[vi]=Trình phân tích giao thông mạng
Comment[uk]=Аналізатор мережевого трафіку
Icon=/usr/share/icons/hicolor/scalable/apps/wireshark.svg
TryExec=wireshark
Exec=wireshark %f
Terminal=false
MimeType=application/vnd.tcpdump.pcap;application/x-pcapng;application/x-snoop;application/x-iptrace;application/x-lanalyzer;application/x-nettl;application/x-radcom;application/x-etherpeek;application/x-visualnetworks;application/x-netinstobserver;application/x-5view;application/x-tektronix-rf5;application/x-micropross-mplog;application/x-apple-packetlogger;application/x-endace-erf;application/ipfix;application/x-ixia-vwr;
# Category entry according to:
# https://specifications.freedesktop.org/menu-spec/1.0/
Categories=Network;Monitor;Qt;
")
wireshark_packagenames=("wireshark")
wireshark_readmeline="| Wireshark | Net sniffer | Command \`wireshark\`, desktop launcher and dashboard launcher ||  <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

x_name="Function x"
x_description="Function to extract from a compressed file, no matter its format"
x_version="1.0"
x_tags=("bashfunctions" "terminal")
x_systemcategories=("System" "Utility")
x_commentary="A terminal function"
x_arguments=("x" "extract" "extract_function")
x_packagedependencies=("libfile-mimeinfo-perl")
x_bashfunctions=("x.sh")

xclip_installationtype="packagemanager"
xclip_arguments=("x_clip")
xclip_packagenames=("xclip")
xclip_readmeline="| \`xclip\` | Utility for pasting. | Command \`xclip\` || <ul><li>- [x] Ubuntu</li><li>- [x] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

youtube_arguments=("youtube")
youtube_name="Youtube"
youtube_version="Google dependent"
youtube_systemcategories=("VideoConference")
youtube_commentary="Watch videos online"
youtube_tags=("internet_shortcuts")
youtube_bashfunctions=("youtube.sh")
youtube_launcherkeynames=("default")
youtube_default_exec="xdg-open https://www.youtube.com"
youtube_description="Youtube opening in Chrome"

# TODO @AleixMT refactor feature name
youtube_dl_installationtype="environmental"
youtube_dl_arguments=("youtube_dl")
youtube_dl_bashfunctions=("youtube_dl.sh")
youtube_dl_binariesinstalledpaths=("youtube-dl;youtube-dl")
youtube_dl_downloads=("https://yt-dl.org/downloads/latest/youtube-dl;youtube-dl")
youtube_dl_readmeline="| youtube-dl | Download manager for video and audio from YouTube and over 1000 other video hosting websites. | Command \`youtube-dl\` in the PATH and alias \`youtube-wav\` to scratch a mp3 from youtube || <ul><li>- [x] Ubuntu</li><li>- [ ] ElementaryOS</li><li>- [ ] Debian</li></ul> |"

ytmusic_arguments=("yt_music" "youtubemusic" "youtube_music")
ytmusic_name="YT Music"
ytmusic_version="Google dependent"
ytmusic_systemcategories=("Music")
ytmusic_commentary="Listen music and watch videoclips online"
ytmusic_tags=("internet_shortcuts")
ytmusic_bashfunctions=("ytmusic.sh")
ytmusic_launcherkeynames=("default")
ytmusic_default_exec="xdg-open https://music.youtube.com"
ytmusic_description="YT Music opening in Chrome"

####### LINE OF TRIMMING, BELOW IS TRIMMED ########

z_name="Function z"
z_description="Function to compress files given a format and a set of pats to files"
z_version="1.0"
z_tags=("utility" "system" "bashFunction")
z_systemcategories=("Utility" "System")
z_commentary="You may now forget all particular commands to compress a file"
z_arguments=("z" "z_function")
z_bashfunctions=("z.sh")

zoom_arguments=("zoom")
zoom_description="Live video streaming for meetings and productivity"
zoom_commentary="Yet another videochat application"
zoom_tags=("social" "videoCalls" "communication")
zoom_name="Zoom"
zoom_version="Vendor dependent"
zoom_systemcategories=("AudioVideo" "Network" "Education")
zoom_packagedependencies=("libglib2.0-0" "libxcb-shape0" "libxcb-shm0" "libxcb-xfixes0" "libxcb-randr0" "libxcb-image0" "libfontconfig1" "libgl1-mesa-glx" "libxi6" "libsm6" "libxrender1" "libpulse0" "libxcomposite1" "libxslt1.1" "libsqlite3-0" "libxcb-keysyms1" "ibus" "libxcb-xtest0" "libqt5quickwidgets5")
zoom_binariesinstalledpaths=("ZoomLauncher;ZoomLauncher" "zoom;zoom")
zoom_downloadKeys=("bundle")
zoom_bundle_URL="https://zoom.us/client/latest/zoom_x86_64.tar.xz"
zoom_launcherkeynames=("defaultLauncher")

####### LINE OF TESTING, BELOW IS TESTED ########

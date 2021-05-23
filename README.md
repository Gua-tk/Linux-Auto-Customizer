# Auto-Customizer

These `bash` scripts can automatize the installation and uninstallation of a batch of preset features in most Linux environments. These features include GNU software, programming languages, IDEs, text editors, media players, games, Internet applications, file templates, wallpapers, environment aliases, environment functions... All installations are cleaner, faster and fancier than a installation with the usual  .    

## Usage
The scripts `install.sh` and `uninstall.sh` have the same identical arguments, but behave in the opposite way: `install.sh` will install the features selected by the arguments while `uninstall.sh` will uninstall them, using the identical arguments. 

## Features
All features available follow a common behaviour:
* The permissions needed for the features to be installed are the minimum. As such, we have many installation available even if you do not have `root` permissions on your machine. 
* Software and command-line utilities are intended to appear as a valid binary in your `PATH`, so you can directly call the program as you would do with `cd` or `ls`.
* Software with GUI creates its own launcher in the desktop and in the dashboard.
* Software that reads or recognizes files are configured to be the default application for their recognized file types. 
* The installation of a feature will be skipped if the current privileges does not match the needed privileges for that feature.

![alt text](https://i.imgur.com/53QkidL.png)
The following features can be installed or uninstalled automatically and individually using one of the specified arguments:

| Name | Description | Execution | Arguments | Permissions | Testing | 
|-------------|----------------------|------------------------------------------------------|------------|---------|-------------|
| Android Studio | Development environment for Google's Android operating system | Command `studio`, alias `studio` and desktop and dashboard launcher | --studio | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Anydesk | Software to remote control other computers | Command `anydesk` | --anydesk | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Apache Ant | Software tool for automating software build processes | Command `ant` | --ant | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Alias `l` | Alias for `ls -lah` | Alias `l` | --l | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Alias `alert` | Alias to show a notification at the end of a command | Alias `alert`. Use it at the end of long running commands like so: `sleep 10; alert` | --alert | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Git aliases | Aliases and functions to work with git repositories | Function `dummycommit $1` and alias `gitk` | --git-aliases | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Audacity | Digital audio editor and recording | Command `audacity` and desktop and dashboard launcher | --audacity --Audacity | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Atom | Text and source code editor | Command `atom`, desktop and dashboard launcher | --atom --Atom | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Discord | VoIP, instant messaging and digital distribution | Command `discord` and desktop and dashboard launcher | --discord | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Dropbox | File hosting service | Command `dropbox`, desktop launcher and dashboard launcher | --dropbox --Dropbox --DropBox --Drop-box --drop-box --Drop-Box | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Docker | Containerization service | Command `docker`, `containerd`, `containerd-shim`, `containerd-shim-runc-v2`, `ctr`, `dockerd`, `docker-init`, `docker-proxy`, `runc` | --docker --Docker | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Document | Google Document opening in Chrome | Command `document` and desktop and dashboard launcher | --document --google-document | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GNU C Compiler | C compiler for GNU systems | Command `gcc` |--gcc | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Calibre | e-book reader| Commmand `calibre`, desktop launcher and dashboard launcher | --calibre --Calibre --cali | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Caffeine | Simple indicator applet on Ubuntu panel that allows to temporarily prevent the activation of the screensaver, screen lock, and the “sleep” power saving mode. | Commands `caffeine`, `caffeinate` and `caffeine-indicator`, desktop launcher for `caffeine`, dashboard launcher for `caffeine` and `caffeine-indicator` | --caffeine | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| cheat.sh | Provides access to community-driven cheat sheets and snippets for Linux/UNIX commands and many programming languages | Command `cheat` | --cheat | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Cheese | GNOME webcam application | Command `cheese`, desktop launcher and dashboard launcher | --cheese | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Chess | Plays a full game of chess against a human being or other computer program | Command `gnome-chess`, desktop launcher and dashboard launcher | --GNOME_Chess --gnome_Chess --gnomechess --chess | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Clementine | Modern music player and library organizer | Command `clementine`, desktop launcher and dashboard launcher | --clementine --Clementine | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Clion | Cross-platform C/C++ IDE | Command `clion`, silent alias `clion`, desktop launcher, dashboard launcher, associated with mimetypes `.c`, `.h` and `.cpp` | --clion --Clion --CLion | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Cmatrix | Terminal screensaver from The Matrix | Command `cmatrix`, desktop launcher and dashboard launcher | --cmatrix --Cmatrix | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Converters | Set of converter Python scripts that integrate in your environment as `bash` commands | Commands `bintodec`, `dectobin`, `dectohex`, `dectoutf`, `escaper`, `hextodec`, `to` and `utftodec` | --converters --Converters | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| CloneZilla | Disk cloning, disk imaging, data recovery, and deployment | Command `clonezilla`, desktop launcher and dashboard launcher | --clonezilla --CloneZilla --cloneZilla | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| copyq | A clipboard manager application that comes with extra features such as editing and scripting | Command `copyq`, desktop launcher and dashboard launcher | --copyq --copy-q --copy_q --copqQ --Copyq --copy-Q | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Curl | Curl is a CLI command for retrieving or sending data to a server | Command `curl` | --curl | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| DuckDuckGo | Opens DuckDuckGo in Chrome | Command `duckduckgo` | --duckduckgo --DuckDuckGo | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Eclipse | IDE for general purpose programming | Command `eclipse` <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Facebook| Opens Facebook in CHrome | Command `facebook`, desktop launcher and dashboard launcher | --f-irc --firc --Firc --irc | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| f-irc | CLI IRC client | Command `f-irc`, desktop launcher and dashboard launcher | --f-irc --firc --Firc --irc | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| ffmpeg | Super fast video / audio encoder | Command `ffmpeg` | --ffmpeg | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Firefox | Free web browser | Command `firefox`, desktop launcher, dashboard launcher | --firefox --Firefox | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fonts-firacode | Installs font | Install firacode font | --font-firacode --fonts-firacode | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fonts-hack | Installs font | Install hack font | --font-hack --fonts-hack | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fonts-hermit | Installs font | Install hermit font | --font-hermit --fonts-hermit | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fonts-roboto | Installs font| Install roboto font | --font-roboto --fonts-roboto | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Forms | Google Forms opening in Chrome | Command `forms`, desktop launcher, dashboard launcher | --forms --google-forms | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| FreeCAD | General-purpose parametric 3D computer-aided design modeler and a building information modeling | Command `freecad`, desktop launcher and dashboard launcher | --freecad --FreeCAD --freeCAD | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Function `--change-bg` | Function that changes the wallpaper using one random image from user images folder. It also downloads wallpapers and installs a cronjob to change the wallpaper every 5 minutes | Function `--change-bg` | --wallpapers | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `extract` | Function to extract from a compressed file, no matter its format | Function `extract "filename"` | --extract | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `s` | Function to execute any program silently and in the background | Function `s "command"` | --s | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `L` | Function that lists files in a directory, but listing the directory sizes | Function `L` | --L --L-function | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Gpaint | Raster graphics editor similar to Microsoft Paint | Command `gpaint`, desktop launcher and dashboard launcher | --gpaint --paint --Gpaint | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Geany | Lightweight GUI text editor using Scintilla and GTK, including basic IDE features | Command `geany`, desktop launcher and dashboard launcher | --geany --Geany | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GeoGebra | Geometry calculator GUI | Command `geogebra`, desktop launcher and dashboard launcher | --geogebra --geogebra-classic-6 --Geogebra-6 --geogebra-6 --Geogebra-Classic-6 --geogebra-classic | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| git | Software for tracking changes in any set of files, usually used for coordinating work among programmers collaboratively developing source code during software development | Command `git` and `gitk` | --git | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| git aliases | Set of customization features over git | Silent alias for `gitk`, special shell prompt on any git repository and function `dummycommit "commit_message"` to automatically, add, commit and push | --git-aliases | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GitHub | GitHub opening in Chrome | Command | --github --Github --GitHub | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GitLab | Gitlab opening in Chrome | Command | --gitlab --GitLab --git-lab | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Gimp | Raster graphics editor used for image manipulation and image editing, free-form drawing, transcoding between different image file formats. | Command `gimp`, desktop launcher and dashboard launcher | --GIMP --gimp --Gimp | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Mines | Implementation for GNU systems of the famous game mines | Command `gnome-mines`, desktop launcher and dashboard launcher | --mines | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GParted | Creating, deleting, resizing, moving, checking, and copying disk partitions and their file systems | Command `gparted`, desktop launcher and dashboard launcher | --GParted --gparted --GPARTED --Gparted | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Gvim | Vim with a built-in GUI | Command `gvim`, desktop launcher and dashboard launcher | --gvim --vim-gtk3 --Gvim --GVim | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Google Calendar | Google Calendar opening in Chrome | Command `googlecalendar`, desktop launcher and dashboard launcher | --google-calendar --Google-Calendar --googlecalendar | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Google Chrome | Cross-platform web browser | Command `google-chrome`, desktop launcher and dashboard launcher | --chrome --Chrome --google-chrome --Google-Chrome | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Gmail | Gmail opening in Chrome | Command `gmail`, desktop launcher and dashboard launcher | --gmail --Gmail | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Google Drive | Google Drive opening in Chrome | Command `drive`, desktop launcher and dashboard launcher | --drive --GoogleDrive --Drive --google-drive --Google-Drive | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Google Keep | Google Keep opening in Chrome | Command `keep`, desktop launcher and dashboard launcher | --keep --google-keep --Keep --Google-Keep --googlekeep | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GNUparallel | Command-line driven utility for Linux and other Unix-like operating systems which allows the user to execute shell scripts or commands in parallel | Command `parallel` | --parallel --gnu_parallel --GNUparallel --GNUParallel --gnu-parallel | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| history optimization | Increased the size of bash history, store multiline commands in just one line, force append and not overwrite to history, ignore repeated commands when appending to history, deleted tracking history of some simple commands: `ls`, `cd`, `gitk`... | --history-optimization | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| IQmol | Program to visualize molecular data | Command `iqmol`, silent alias, desktop launcher and dashboard launcher | --iqmol | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Inkscape | Vector graphics editor used to create vector images, primarily in Scalable Vector Graphics format | Command `inkscape`, desktop launcher and dashboard launcher | --inkscape --ink-scape --Inkscape --InkScape | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Instagram | Opens Instagram in Chrome | Command `instagram`, desktop launcher, dashboard launcher | --instagram --Instagram | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| intelliJ Community | Integrated development environment written in Java for developing computer software | Command `ideac`, silent alias for `ideac`, desktop launcher, dashboard launcher and association to `.java` files | --intellijcommunity --intelliJCommunity --intelliJ-Community --intellij-community | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| intelliJ Ultimate | Integrated development environment written in Java for developing computer software | Command `ideau`, silent alias for `ideau`, desktop launcher, dashboard launcher and association to `.java` files | --intellijultimate --intelliJUltimate --intelliJ-Ultimate --intellij-ultimate | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| ipe function | Returns the public IP | Command `ipe` | --ipe --ipe-function | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Java Development Kit 8 | Implementation of version 8 of the Java (programming language) SE Platform | Commands `java`, `javac` and `jar` | --java --javadevelopmentkit --java-development-kit --java-development-kit-11 --java-development-kit11 --jdk --JDK --jdk11 --JDK11 | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| LaTeX | Software system for document preparation | Command `tex` (LaTeX compiler) and `texmaker` (LaTeX IDE), desktop launchers for `texmaker` and LaTeX documentation | --latex --LaTeX --tex --TeX | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| libxcb-xtest0 | Zoom dependency | Used when Zoom is run | --libxcb-xtest0 | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| nvidia-drivers | Auto-install nvidia drivers in ubuntu | Drivers | --nvidia-drivers --ubuntu-drivers --autoinstall | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Maven | Build automation tool used primarily for Java projects | Command `mvn` | --maven --mvn | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| MegaSync | Synchronises folders between your computer and your MEGA Cloud Drive | Command `megasync`, desktop launcher, dashboard launcher and integration with `nemo` file explorer | --mega --Mega --MEGA --MegaSync --MEGAsync --MEGA-sync --megasync | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Mahjongg | Implementation for GNU systems of the famous popular chinese game Mahjongg | Command `gnome-mahjongg`, desktop launcher and dashboard launcher | --mahjongg | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| MendeleyDependencies | Installs Mendeley Desktop dependencies `gconf2`, `qt5-default`, `qt5-doc`, `qt5-doc-html`, `qtbase5-examples` and `qml-module-qtwebengine` | Used when installing Mendeley and other dependent software | --MendeleyDependencies --mendeleydependencies --mendeleydesktopdependencies --mendeley-desktop-dependencies --Mendeley-Desktop-Dependencies | <ul><li>- [ ] root</li><li>- [ ] user</li></ul> | <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |   
| Mendeley | It is most known for its reference manager which is used to manage and share research papers and generate bibliographies for scholarly articles | Command `mendeley`, desktop launcher and dashboard launcher | --Mendeley --mendeley --mendeleyDesktop --mendeley-desktop --Mendeley-Desktop | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Nemo Desktop Manager | File and dekstop manager, usually with better options and less bugs than nautilus. *We recommend this explorer to view correctly the launchers* | Command `nemo` for the file manager, and `nemo-desktop` for the desktop manager service. Desktop launcher and dashboard launcher for the file manager | --nemo --nemo-desktop --Nemo-Desktop --Nemodesktop --nemodesktop --Nemo --Nemodesk --NemoDesktop | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Netflix | Netflix opening in Chrome | Command `netflix`. Desktop launcher and dashboard launcher for the file manager | --netflix --Netflix | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| net-tools | GUI network interfaces. *We recommend this explorer to view correctly the launchers* | Command `net-tools` | --net-tools --nettools | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Notepadqq | Text editor that is designed by developers for the developers. It supports more than 100 programming languages | Command `notepadqq`, desktop launcher and dashboard launcher | --notepadqq --Notepadqq --notepadQQ --NotepadQQ --notepadQq --notepadQq --NotepadQq --NotepadqQ | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| OneDrive | Microsoft OneDrive opening in Chrome | Command `onedrive`, desktop launcher and dashboard launcher | --onedrive --OneDrive --one-drive --One-Drive | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| OpenOffice | Office suite for open-source systems | Command `openoffice4` in PATH, desktop launchers for `base`, `calc`, `draw`, `math` and `writer` | --office --Openoffice --OpenOffice --openOfice --open_office --Office | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Outlook | Microsoft Outlook e-mail opening in Chrome | Command `outlook`, desktop launcher and dashboard launcher | --outlook --Outlook | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| OBS | Streaming and recording program | Command `obs`, desktop launcher and dashboard launcher. | --OBS --obs --obs-studio --obs_studio --obs_Studio --OBS_studio --obs-Studio --OBS_Studio --OBS-Studio | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Okular | PDF viewer | Command `okular`, desktop launcher and dashboard launcher | --okular --Okular --okularpdf |  <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Overleaf | Online LaTeX editor opening in Chrome | Command `overleaf`, desktop launcher and dashboard launcher | overleaf --Overleaf |  <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Pac-man | Implementation of the classical arcade game | Command `pacman`, desktop launcher and dashboard launcher | --pacman | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| pdfgrep | CLI utility that makes it possible to search for text in a PDF file without opening the file | Command `pdfgrep` | --pdfgrep --findpdf --pdf | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| pluma | Fork of gedit 2.0 that supports many plugins and new features |  | --pluma | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Presentation | Google Presentation opening in Chrome | Command `presentation`, desktop launcher and dashboard launcher| --presentation --google-presentation | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| prompt | Installs a new colourful prompt on terminal window including and upgrading the default ones in Ubuntu | Adds a personalized prompt that shows the date, return code of last executed program, user, group and working directory. It also changes the prompt colour of introduced text to green. It changes the terminal windows title, adds colourful aliases and ensures completion | --prompt | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Pycharm Pro | Integrated development environment used in computer programming | Command `pycharm-pro`, silent alias for `pycharm-pro`, desktop launcher, dashboard launcher, associated to the mime type of `.py` files | --pycharmpro --pycharmPro --pycharm_pro --pycharm-pro --Pycharm-Pro --PyCharm-pro | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Pycharm Community | Integrated development environment used in computer programming | Command `pycharm`, silent alias for `pycharm-pro`, desktop launcher, dashboard launcher, associated to the mime type of `.py` files  | --pycharmcommunity --pycharmCommunity --pycharm_community --pycharm --pycharm-community | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Python3 | Interpreted, high-level and general-purpose programming language | Commands `python`, `python3` and `pip3` in the PATH | --python --python3 --Python3 --Python | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| pypy3 | Faster interpreter for the Python3 programming language | Commands `pypy3` and `pypy3-pip` in the PATH | --pypy --pypy3 --PyPy3 --PyPy | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| pypy3_dependencies | Dependencies to run pypy3 | Libraries `pkg-config`, `libfreetype6-dev`, `libpng-dev` and `libffi-dev` used when deploying `pypy` | --pypy3_dependencies --pypy3Dependencies --PyPy3Dependencies --pypy3dependencies --pypy3-dependencies | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Reddit | Opens Reddit in Chrome | Commands `reddit`| --reddit --Reddit | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  
| Screenshots | Takes a screenshot and saves it to custom ~/Images/screenshots folder | Commands `screenshot-full` `screenshot-window` `screenshot-area`| --screenshots --Screenshots | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  
| Steam | Video game digital distribution service | Command `steam`, desktop launcher and dashboard launcher | --steam --Steam --STEAM | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  
| ShotCut | Cross-platform video editing | Command `shotcut`, desktop launcher and dashboard launcher | --shotcut --ShotCut --Shotcut --shot-cut --shot_cut | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Skype | Call & conversation tool service |  | --slack | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Slack | Platform to coordinate your work with a team |  | --slack | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Solitaire aisleriot | Implementation of the classical game solitaire | Command `aisleriot`, desktop launcher and dashboard launcher | --solitaire --aisleriot | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Sublime | Source code editor with an emphasis on source code editing | Command `sublime`, silent alias for `sublime`, desktop launcher, dashboard launcher, associated with the mime type of `.c`, `.h`, `.cpp`, `.hpp`, `.sh` and `.py` files | --sublime --sublimeText --sublime_text --Sublime --sublime-Text --sublime-text | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| sudoku | Implementation for GNU systems of the famous popular mathematical game sudoku | Command `gnome-sudoku`, desktop launcher and dashboard launcher | --sudoku | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Spotify | Music streaming service | Command `spotify`, desktop launcher, dashboard launcher | --spotify --Spotify | <ul><li>- [x] root</li><li>- [] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Spreadsheets | Google Spreadsheets opening in Chrome | Command `spreadsheets`, desktop launcher, dashboard launcher | --spreadsheets --google-spreadsheets | <ul><li>- [x] root</li><li>- [] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Microsoft Teams | Video Conference, calls and meetings | Command `teams`, desktop launcher and dashboard launcher | --teams --Teams --MicrosoftTeams | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Telegram | Cloud-based instant messaging software and application service | Command `telegram`, desktop launcher and dashboard launcher | --Telegram --telegram | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Templates | Different collection of templates for starting code projects: Python3 script (`.py`), Bash script (`.sh`), LaTeX document (`.tex`), C script (`.c`), C header script (`.h`), makefile example (`makefile`) and empty text file (`.txt`) | In the file explorer, right click on any folder to see the contextual menu of "create document", where all the templates are located | --templates | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Terminal background | Change background of the terminal to black | Every time you open a terminal | --terminal-background | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Terminator | Terminal emulator for Linux programmed in Python | Command `terminator`, desktop launcher and dashboard launcher | --Terminator --terminator | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Tilix | Advanced GTK3 tiling terminal emulator | Command `tilix`, desktop launcher and dashboard launcher | --Tilix --tilix | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Tmux | Terminal multiplexer for Unix-like operating systems | Command `tmux`, desktop launcher and dashboard launcher | --tmux --Tmux | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Thunderbird | Email, personal information manager, news, RSS and chat client | Command `thunderbird`, desktop launcher and dashboard launcher | --thunderbird --mozillathunderbird --mozilla-thunderbird --Thunderbird --thunder-bird | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Tor browser | Software for enabling anonymous communication by directing Internet traffic. | Command `tor`, desktop launcher and dashboard launcher | --tor --torbrowser --tor_browser --TOR --TOR-browser --TOR-BROSWER --TORBROWSER --TOR_BROWSER --TOR_browser | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Transmission | A set of lightweight Torrent client (in GUI, CLI and daemon form) | Executable `transmission`, desktop launcher and dashboard launcher | --transmission --transmission-gtk --Transmission | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Tumblr | Tumblr web opens in Chrome | Command `tumblr`, desktop launcher and dashboard launcher | --tumblr --Tumblr | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Twitch | Twitch web opens in Chrome | Command `twitch`, desktop launcher and dashboard launcher | ---twitch --Twitch | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Twitter | Twitter web opens in Chrome | Command `twitter`, desktop launcher and dashboard launcher | ---twitter --Twitter | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| uget | GUI utility to manage downloads | Command `uget`, desktop launcher and dashboard launcher | --uget | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| VirtualBox | Hosted hypervisor for x86 virtualization | Command `virtualbox`, desktop launcher and dashboard launcher | --virtualbox --virtual-box --VirtualBox --virtualBox --Virtual-Box --Virtualbox | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Visual Studio Code | Source-code editor | Command `code`, desktop launcher, dashboard launcher | --visualstudiocode --visual-studio-code --code --Code --visualstudio --visual-studio1 | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| VLC | Media player software, and streaming media server | Command `vlc`, desktop launcher and dashboard launcher | --vlc --VLC --Vlc | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Youtube| YouTube opens in Chrome | Command `youtube`, desktop launcher and dashboard launcher | --youtube --Youtube --YouTube | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Youtube Music | YouTube music opens in Chrome. | Command `youtubemusic`, desktop launcher and dashboard launcher | --youtubemusic --YouTubeMusic --YouTube-Music --Youtube-Music --youtube-music | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| youtube-dl | Download manager for video and audio from YouTube and over 1000 other video hosting websites. | Command `youtube-dl` in the PATH and alias `youtube-wav` to scratch a mp3 from youtube | --youtube-dl | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Whatsapp Web | Whatsapp web opens in Chrome | Command `whatsapp`, desktop launcher and dashboard launcher | --whatsapp --Whatsapp | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Wikipedia | Wikipedia web opens in Chrome | Command `wikipedia`, desktop launcher and dashboard launcher | --wikipedia --Wikipedia | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Wireshark | Net sniffer | Command `wireshark`, desktop launcher and dashboard launcher | --wireshark | <ul><li>- [x] root</li><li>- [ ] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Zoom | Video Stram Calls | Command `zoom`, desktop launcher and dashboard launcher | --wireshark | <ul><li>- [ ] root</li><li>- [x] user</li></ul> | <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |


## Usage
### Download
To install this software you must begin cloning this repository to you computer. You can either download a `.zip` file containing the repository from github from [here](https://github.com/AleixMT/Linux-Auto-Customizer/archive/master.zip), or you can clone the repository using a terminal. To do the last option, you must have installed `git`. If you don't have it, you can install it opening a terminal and typing the following:
```
sudo apt-get install git
```
Then, navigate to the directory where you want to clone the repository using `cd`. Anywhere in your user folder will be fine. 
Then clone the repository with `git clone`:
```
git clone https://github.com/AleixMT/Linux-Auto-Customizer
```
Navigate to the interior of the repository with cd:
```
cd Linux-Auto-Customizer  
```
Now that the current directory is the repository we can call the main scripts directly without specifying an absolute path. This will be the expected situation in the following explanations.
We need to check if the program needs root or user permision, if it is needed use sudo at the start of the command.
### Installing individual features
```
bash install --name_of_feature
```
### Installing sets of features
```
bash install --name_of_set_of_custom_features
```
Example:
```
bash install -v --discord
```
### Behavioural arguments
Verbose mode
Examples:
```
bash install -v --telegram
```
Quiet mode
```
sudo bash install -q --firefox --gpaint
```
Alternation
```
sudo bash install -q --firefox -v --gpaint
```
Silent Desktop icons for apps of the system
```
sudo bash install -q -o --cheese
```

### Full installation / uninstallation
To install ALL the features available for the root user in the script you must type in a terminal:
```
sudo bash install.sh
```
To install ALL the features available for the normal user in the script you must type in a terminal:
```
bash install.sh
```
Summarizing: to install ALL the features available in the script you must type in a terminal:
```
sudo bash install.sh && bash install.sh
```
This command will install all root features first and then it will install all the local user features. 

To uninstall ALL the possible installed features you must type in a terminal:
```
sudo bash uninstall.sh
```
### Help
Command for showing a helping menu -h
with the list of programs we can install.
```
bash install.sh -h
```
### 
## Progression and original idea
This repository is a partial fork from my repo [TrigenicInteractionPredictor](https://github.com/AleixMT/TrigenicInteractionPredictor). 

In that repository I started programming a script to auto-configurate an Ubuntu machine with the dependencies of that project. At first the script was short and simple, but every time I made a change to my machines I added the corresponding auto-configuration lines to my script.

Sooner, the script grew in complexity and my autoconfigurated machines had more and more extra features. I even added heavier software that I was using, and the execution time of the script became much larger.

Since it was working well (but slow) and is a script that could be reused in other projects, I decided to give to the script more interaction with the user using parameters. In that way, you can choose exactly which features you want to install, making it easier and faster for the final user.

So I decided to do a major refactor of the code and implement argument processing to be able to install the different features selectively. Because of that I had to wrap each feature within a function, extracted all the "common" code to the main and also started to code the dependency of some features to certain permissions. 

For example: Manually installed software usually needs to be executed as normal user, and automatic installed software (`apt-get`, `dpkg -i`) needs to be executed as superuser. 

I also used the [Google Bash Style Guide](https://google.github.io/styleguide/shellguide.html) to standarize the code.

The last major change include the creation of a "complementary" uninstallation script, that allows to selectively uninstall the features that you desire using arguments. Arguments in `uninstall.sh` are identical to the arguments in `install.sh`.

Also the script `common_data.sh` have been created. This script contains declared variables that are used in one or both scripts. Most of the variables are long strings that specify a certain version of a software. Those variables are used to know which is the targeted version of a certain software. By changing those variables you can easily change the targeted version of a certain software (easier to update script).

## Author and Acknowledgements
* Author: **Aleix Mariné** - [AleixMT](https://github.com/AleixMT) [aleix.marine@estudiants.urv.cat](aleix.marine@estudiants.urv.cat)
* Tester: **Axel Fernández** - [Axlfc](https://github.com/Axlfc) [axelfernandezcurros@gmail.com](axelfernandezcurros@gmail.com)




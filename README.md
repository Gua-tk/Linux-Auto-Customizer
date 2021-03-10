# Linux-Customizer

This software is an automatization script for Ubuntu/Debian machines. The `install.sh` script can apply some custom features (depending on the received arguments) to the current user console and to the Ubuntu-Linux environment, such as local functions, file templates and global variables. Also, third-party software can be installed too, including its dependencies.

The `uninstall.sh` script can be used to uninstall features previously installed by the install script by giving it arguments, too.

## Features
### General features
* Most of the software and command-line utilities installed are intended to appear as a valid binary in your `PATH`, so you can directly call the program without the path to the binary. This script forces `~/.local/bin` to be under your `PATH`, so the symlinks to the binaries will be created in there.
* Most of the software (except the software that does not have UI) has its own launcher in the desktop and in the dashboard (user launchers are located in `~/.local/share/applications`). It also creates a launcher for each in the Desktop.
* Software that reads or recognizes files (specially IDEs) are configured to be default apautomatically apply some custom settings and application installation to Ubuntu Linuxplication when opening certain type of files. For example, associate PyCharm to open `.py` by default.
* The script will change its behaviour (be able to install some features and not others) depending on the given privileges when executing the script. 
* Both behaviors of the script use the file `~/.config/user-dirs.dirs` to set some language-independent environment variables (for example, to get an independent system-language path to the Desktop), so the script will fail if this file does not exist.
* Each feature is expected to be executed with certain permissions (root / normal user). So the script will fail if the asked features to be installed have different permissions requirements than the given.

### Local user features 
This section enumerates which features can be installed without root permissions in the context of the normal user running the script.

Software that needs to be "manually" installed as normal user is stored under `~/.bin`.

#### Console features
* Increased the size of bash history.
* Store multiline commands in just one line.
* Force append and not overwrite to history.
* Ignore repeated commands when appending to history.
* Deleted tracking history of some simple commands: `ls`, `cd`, `gitk`...
* Added a user global alias `dummycommit` to add, commit and push to github.
* Added a non-language dependent user global variable `DESK` to point to the path of the desktop of the current user.
* Added a user global function `extract` that extracts from any type of compressed file.
* Added alias to `l` as `ls -lAh --color=auto`
* Added a user alias `gitk` as `gitk --all --date-order`.
* Creates a copy of the file `~/.bashrc` to `~/.bashrc.bak` that is restored when uninstalling this feature.

#### Templates
Creates the new file templates in the Templates folder of the current user, allowing to create new files in the "new file" context menu:
* Python3 script (`.py`)
* Bash script (`.sh`)
* LaTeX script (`.tex`)
* C script (`.c`)
* C headers (`.h`)
* makefile (`makefile`)
* text file (`.txt`)

#### Software
* Android Studio (193.6514223-linux)
* Audacity 
* Atom 
* Caffeine 
* cheat 
* Clementine
* CLion 2020.1 
* Cmatrix 
* CloneZilla 
* converters (bintodec, dectohex, utftobin...) 
* copyq
* Discord (0.0.10) 
* Firefox 
* f-irc 
* Geany 
* GIMP 
* gpaint 
* Gparted 
* Gvim 
* Inkscape
* IntelliJ Community
* IntelliJ Ultimate
* Mendeley Desktop 
* Notepadqq 
* OBS Studio 
* Office 
* okular
* PyCharm professional 2020.1
* PyCharm community 2019.1
* PyPy3 (pypy3.6-v7.3.1-linux64). Setting up its own `pip` and installing `cython` and `numpy`. 
* Shotcut 
* Slack
* Sublime Text 3 (build 3211 x64)
* Telegram 
* Terminator 
* tilix
* tmux
* VirtualBox
* Visual Studio Code


### Root features
##### Software
* Dropbox 
* Google Chrome 
* Google Play Music
* gcc 
* git suite: Git binaries, graphic interface `gitk` git-LFS 
* GNU games 
* Java Development Kit (`jdk11`)  
* LaTeX suite 
* Python3 
* GNU parallel 
* pdfgrep 

* Steam
* PyPy3 dependencies. *PyPy is "split" because we need root for dependencies but not for the main installation.*
* MEGAand MEGAsync desktop integration.
* Nemo Desktop
* Thunderbird 
* Transmission
* VLC 
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

### Partial installation / uninstallation

Both `install.sh` and `uninstall.sh` accept arguments to selectively choose which feature we want to install or uninstall, respectively.
The argument list is the following with its own description:

| Parameter                 |`install.sh`   | `uninstall.sh` |
| :------------------------ | :-------------| :--------------|
| --android --AndroidStudio --androidstudio --studio --android-studio --android_studio --Androidstudio
| --audacity --Audacity | | |
| --atom --Atom | | |
| --discord --Discord --disc| Installs Discord manually creating its own folder under `~/.bin`. Creates launcher of Discord in the dashboard and in the current user desktop. Makes Discord executable accessible with the command `discord` |  Uninstalls Discord by deleting its launchers, soft-links and the Discord folder |
| --dropbox --Dropbox --DropBox --Drop-box --drop-box --Drop-Box | | |
| --gcc | Installs the GNU C Compiler via `apt-get` | Uninstalls the GNU C Compiler via `apt-get purge` | 
| --caffeine --Caffeine --cafe --coffee | | |
| --calibre --Calibre --cali | | |
| --cheat --cheat.sh --Cheat.sh --che | | |
| --clementine --Clementine | | |
| --clion --Clion --CLion | Installs CLion manually creating its own folder under `~/.bin`. Creates launcher of CLion in the dashboard and in the current user desktop. Makes CLion executable accessible with the command `clion`. Associate CLion to the mime type of `.c`, `.h`, `.cpp` and `.hpp` files |  Uninstalls CLion by deleting its launchers, soft-links, defaults and the CLion folder |
| --cmatrix --Cmatrix | | |
| --converters --Converters | | |
| --clonezilla --CloneZilla --cloneZilla | | |
| --copyq --copy-q --copy_q --copqQ --Copyq --copy-Q | | |
| --f-irc --firc --Firc --irc | | |
| --firefox --Firefox | | |
| --google-play-music --musicmanager --music-manager --MusicManager --playmusic --GooglePlayMusic --play-music --google-playmusic --playmusic --google-music
| --gpaint --paint --Gpaint | | |
| --geany --Geany | | |
| --git | Installs `git-all` via `apt-get` which includes all the features of `git`, including the graphical git viewer `gitk`  | Uninstalls `git-all` via `apt-get` |
| --GIMP --gimp --Gimp | | |
| --GParted --gparted --GPARTED --Gparted | | |
| --gvim --vim-gtk3 --Gvim --GVim | | |
| --chrome --Chrome --google-chrome --Google-Chrome| Installs Google Chrome by downloading manually the software from Google official page but installing it via `apt`. Creates its own launcher in the current user desktop | Uninstalls Google Chrome via `apt-get purge` |
| --parallel --gnu_parallel --GNUparallel --GNUParallel --gnu-parallel| Installs GNU parallel via `apt-get` | Uninstalls GNU parallel via `apt-get purge` |
| --inkscape --ink-scape --Inkscape --InkScape | | |
| --intellijcommunity --intelliJCommunity --intelliJ-Community --intellij-community | Installs IntelliJ Community manually creating its own folder under `~/.bin`. Creates launcher of IntelliJ Community in the dashboard and in the current user desktop. Makes IntelliJ Community executable accessible with the command `ideac`. Associate IntelliJ Community to the mime type of `.java` files |  Uninstalls IntelliJ Community by deleting its launchers, soft-links, defaults and the IntelliJ Community folder |
| --intellijultimate --intelliJUltimate --intelliJ-Ultimate --intellij-ultimate | Installs IntelliJ Ultimate manually creating its own folder under `~/.bin`. Creates launcher of IntelliJ Ultimate in the dashboard and in the current user desktop. Makes IntelliJ Ultimate executable accessible with the command `ideau`. Associate IntelliJ Ultimate to the mime type of `.java` files |  Uninstalls IntelliJ Ultimate by deleting its launchers, soft-links, defaults and the IntelliJ Ultimate folder |
| --java --javadevelopmentkit --java-development-kit --java-development-kit-11 --java-development-kit11 --jdk --JDK --jdk11 --JDK11 
| --latex --LaTeX --tex --TeX
| --mega --Mega --MEGA --MegaSync --MEGAsync --MEGA-sync --megasync| Installs MEGAsync and MEGAsync desktop integration via `dpkg -i` and creates launcher for MEGAsync in the current user desktop | Uninstalls MEGAsync and MEGAsyn desktop integrator via `dpkg -P` |
| --MendeleyDependencies --mendeleydependencies --mendeleydesktopdependencies --mendeley-desktop-dependencies --Mendeley-Desktop-Dependencies | Installs Mendeley Desktop dependencies `gconf2`, `qt5-default`, `qt5-doc`, `qt5-doc-html`, `qtbase5-examples` and `qml-module-qtwebengine` via `apt-get` | Uninstalls Mendeley Desktop dependencies `gconf2`, `qt5-default`, `qt5-doc`, `qt5-doc-html`, `qtbase5-examples` and `qml-module-qtwebengine` via `apt-get` |  
| --Mendeley --mendeley --mendeleyDesktop --mendeley-desktop --Mendeley-Desktop | Installs Mendeley Desktop manually creating its own folder under `~/.bin`. Creates launcher of Mendeley Desktop in the dashboard and in the current user desktop. Makes Mendeley Desktop executable accessible with the command `mendeley`. |  Uninstalls Mendeley Desktop by deleting its launchers, soft-links, defaults and the CLion folder |
| --nemo --nemo-desktop --Nemo-Desktop --Nemodesktop --nemodesktop --Nemo --Nemodesk --NemoDesktop | | |
| --notepadqq --Notepadqq --notepadQQ --NotepadQQ --notepadQq --notepadQq --NotepadQq --NotepadqQ | | |
| --office --Openoffice --OpenOffice --openOfice --open_office --Office | | |
| --OBS --obs --obs-studio --obs_studio --obs_Studio --OBS_studio --obs-Studio --OBS_Studio --OBS-Studio | | |
| --okular --Okular --okularpdf | | |
| --pdfgrep --findpdf --pdf| Installs `pdfgrep` via `apt-get` | Uninstalls `pdfgrep` via `apt-get purge` |
| --pycharmpro --pycharmPro --pycharm_pro --pycharm-pro --Pycharm-Pro --PyCharm-pro | Installs PyCharm Pro manually creating its own folder under `~/.bin`. Creates launcher of Pycharm Pro in the dashboard and in the current user desktop. Makes Pycharm Pro executable accessible with the command `pycharm-pro` |  uninstalls PyCharm Pro by deleting its launchers, soft-links and the Pycharm Pro folder |
| --pycharmcommunity --pycharmCommunity --pycharm_community --pycharm --pycharm-community| Installs PyCharm Community manually creating its own folder under `~/.bin`. Creates launcher of PyCharm Community in the dashboard and in the current user desktop. Makes PyCharm Community executable accessible with the command `pycharm`. Associate PyCharm Community to the mime type of `.py` files |  Uninstalls PyCharm Community by deleting its launchers, soft-links, defaults and the PyCharm Community folder |
| --python --python3 --Python3 --Python| Installs Python 2 and Python 3 by installing `python3-dev`, `python-dev` and `python3-pip` via `apt` | Uninstalls Python3 and Python2 interpreter by uninstalling `python3-dev`, `python-dev` and `python3-pip` via `apt` |
| --dependencies --pypy3_dependencies --pypy3Dependencies --PyPy3Dependencies --pypy3dependencies --pypy3-dependencies| Installs PyPy3 dependencies via `apt-get`: `pkg-config`, `libfreetype6-dev`, `libpng-dev`, `libffi-dev` | Uninstalls PyPy3 dependencies via `apt-get`: `pkg-config`, `libfreetype6-dev`, `libpng-dev`, `libffi-dev` |
| --pypy --pypy3 --PyPy3 --PyPy| Installs PyPy3 Python3 interpreter manually by downloading the software and placing it under `~/.bin`. Makes PyPy3 executable and PyPy3/pip accessible with the commands `pypy3` and `pypy3-pip`. |  Uninstalls PyPy3 by deleting the PyPy3 folder |
| --shell --shellCustomization --shellOptimization --environment --environmentaliases --environment_aliases --environmentAliases --alias --Aliases| Backups your `$HOME/.bashrc` to `$HOME/.bashrc.bak` and installs shell features in `$HOME/.bashrc` including: history optimization, environament aliases, functions and global variables. See *Shell customization* section for more information. | Uninstalls the feature by restoring `$HOME/.bashrc.bak` to `$HOME/.bashrc` if present. |
| --steam --Steam --STEAM | Installs Steam by downloading its installer and installing it via `dpkg -i` and creates a launcher in the current user desktop | Uninstalls Steam via `dpkg -P` and deleting its launchers. |
| --shotcut --ShotCut --Shotcut --shot-cut --shot_cut | | |
| --sublime --sublimeText --sublime_text --Sublime --sublime-Text --sublime-text | Installs Sublime Text manually creating its own folder under `~/.bin`. Creates launcher of Sublime Text in the dashboard and in the current user desktop. Makes Sublime Text executable accessible with the command `sublime`. Associate Sublime Text to the mime type of `.c`, `.h`, `.cpp`, `.hpp`, `.sh`, `.py` files |  Uninstalls Sublime Text by deleting its launchers, soft-links, defaults and the CLion folder |
| --Telegram --telegram | 
| --templates
| --Terminator --terminator | | |
| --Tilix --tilix | | |
| --tmux --Tmux | | |
| --thunderbird --mozillathunderbird --mozilla-thunderbird --Thunderbird --thunder-bird | Installs thunderbird email client via `apt-get` and creates its launcher in the current user desktop | Uninstalls thunderbird via `apt-get purge` and remove its launchers |
| --transmission --transmission-gtk --Transmission | Installs Transmission torrent downloader via `apt-get` and creates its launcher in the current user desktop | Uninstalls transmission via `apt-get purge` and remove its launchers |
| --virtualbox --virtual-box --VirtualBox --virtualBox --Virtual-Box --Virtualbox 
| --visualstudiocode --visual-studio-code --code --Code --visualstudio --visual-studio
| --vlc --VLC --Vlc | Installs VLC via `apt` and creates its own launcher in the current user desktop. | Uninstalls VLC media player via `apt purge` and deletes its launchers. |










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

Also the script `common_variables.sh` have been created. This script contains declared variables that are used in one or both scripts. Most of the variables are long strings that specify a certain version of a software. Those variables are used to know which is the targeted version of a certain software. By changing those variables you can easily change the targeted version of a certain software (easier to update script).

## Coming features
- [ ] Automount available drives.*
- [ ] Create high-level wrappers for a set of features, such as "minimal", "custom", "" etc.
- [ ] Split multiplying lines into functions
- [ ] Create source in bashrc with file bash_functions.sh with all sources calls
- [x] Create argument (! or --not) for deselecting installed or uninstalled features.
- [x] -v --verbose Verbose mode (make the software not verbose by default)
- [ ] -h --help to show help to use the program.
- [x] Solve bug of `PATH` addition in shell features. (it works, but it appends the export many times)
- [ ] Program function to unregister default opening applications on `uninstall.sh`
- [x] Delete / rearrange arguments of one letter
- [ ] nettools*
- [ ] SublimeText-Markdown, WordPress, GnuCash, Rosegarden, Freeciv, Shotwell, Handbrake, fslint, CMake, Tor browser, unrar, rar, evolution, guake, Brasero, Remastersys, UNetbootin, Blender3D, Skype, Ardour, Spotify, TeamViewer, Remmina, WireShark, PacketTracer, LMMS...
- [ ] Rsync, Axel, GNOME Tweak, Wine 5.0, Picasa, Synaptic, Bacula, Docker, kubernetes, youtube-dl, Agave, apache2, Moodle, Oracle SQL Developer, Mdadm, PuTTY, MySQL Server instance, glpi*, FOG Server*, Proxmox*, Nessus*, PLEX Media Server
- [ ] nmap, gobuster, metasploit, Firewalld, Hydra, Ghidra, THC Hydra, Zenmap, Snort, Hashcat, Pixiewps, Fern Wifi Cracker, gufw, WinFF, chkrootkit, rkhunter, Yersinia, Maltego, GNU MAC Changer, Burp Suite, BackTrack, John the Ripper, aircrack-ng
- [ ] Repair broken desktop icons
- [ ] Fonts
- [ ] Download wallpapers
- [ ] Desktop wallpapers
- [x] To add more useful directory path variables in common_data.sh
- [x] Make sure USR_BIN_FOLDER is present in any user roll
## Author and Acknowledgements
* Author: **Aleix Mariné** - [AleixMT](https://github.com/AleixMT) [aleix.marine@estudiants.urv.cat](aleix.marine@estudiants.urv.cat)
* Tester: **Axel Fernández** - [Axlfc](https://github.com/Axlfc) [axelfernandezcurros@gmail.com](axelfernandezcurros@gmail.com)




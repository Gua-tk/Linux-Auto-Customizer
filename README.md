# Linux-Customizer

This software is an automatization script for Ubuntu/Debian machines. The `install.sh` script can apply some custom features (depending on the received arguments) to the current user console and to the Ubuntu-Linux environment, such as local functions, file templates and global variables. Also, third-party software can be installed too, including its dependencies.

The `uninstall.sh` script can be used to uninstall features previously installed by the install script by giving it arguments, too.

## Features
### General features
* All software installed is intended to appear as a valid binary in your `PATH`, so you can directly call the program without the path to the binary. This script forces `~/.local/bin` to be under your `PATH`, so we will create the symlinks to the binaries in there.
* Most of all software (except the software that does not have UI) puts its own launcher in the dashboard (user launchers are located in `~/.local/share/applications`). It also creates a launcher for each in the Desktop.
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
* PyCharm professional 2020.1
* PyCharm community 2019.1
* CLion 2020.1
* Sublime Text 3 (build 3211 x64)
* Android Studio (193.6514223-linux)
* Discord (0.0.10)
* PyPy3 (pypy3.6-v7.3.1-linux64). Setting up its own `pip` and installing `cython` and `numpy`.

### Root features
##### Software
* Google Chrome (includes Google Drive Desktop client, Google Play Music, Google Remote Desktop)(using `dpkg -i`)
* gcc (using `apt-get`)
* git suite (using `apt-get`): Git binaries, graphic interface `gitk` git-LFS (using `apt-get`)
* LaTeX suite (using `apt-get`)
* Python3 (using `apt-get`)
* GNU parallel (using `apt-get`)
* pdfgrep (using `apt-get`)
* VLC (using `apt-get`)
* Steam (using `dpkg -i`)
* PyPy3 dependencies (using `apt-get`). PyPy is "split" because we need root for dependencies but not for the main installation.
* Mega-sync and Mega-sync desktop integration (using `dpkg -i`).
* Thunderbird (using `apt-get`)
* Transmission (using `apt-get`)

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

### Full installation
To install ALL the features available for the root user in the script you must type in a terminal:
```
sudo bash install.sh
```
To install ALL the features available for the normal user in the script you must type in a terminal:
```
bash install.sh
```
So, to install ALL the features available in the script you must type in a terminal:
```
sudo bash install.sh && bash install.sh
```
This command will install all root features first and then it will install all the local user features. 

### Partial installation

Both `install.sh` and `uninstall.sh` accept arguments to selectively choose which feature we want to install or uninstall, respectively.
The argument list is the following:

| Parameter                 | Description   |	
| :------------------------ | :-------------|
| -c --gcc|Installs / uninstalls the GNU C Compiler
| -d --dependencies --pypy3_dependencies --pypy3Dependencies --PyPy3Dependencies --pypy3dependencies --pypy3-dependencies| Installs / uninstalls PyPy3 dependencies
| -e --shell --shellCustomization --shellOptimization --environment --environmentaliases --environment_aliases --environmentAliases --alias --Aliases| Installs / uninstalls shell history optimization, environament aliases, functions and variables.
| -f --pdfgrep --findpdf --pdf| Installs / uninstalls pdfgrep
| -g --git| Installs / uninstalls all git suite, including `gitk`
| -h --pycharmpro --pycharmPro --pycharm_pro --pycharm-pro --Pycharm-Pro --PyCharm-pro|Installs / uninstalls PyCharm Pro
| -i --discord --Discord --disc| Installs / uninstalls Discord
| -l --parallel --gnu_parallel --GNUparallel --GNUParallel --gnu-parallel| Installs / uninstalls GNU parallel
| -m --pycharmcommunity --pycharmCommunity --pycharm_community --pycharm --pycharm-community| Installs / uninstalls PyCharm Community
| -n --clion --Clion --CLion| Installs / uninstalls CLion C IDE
| -o --chrome --Chrome --google-chrome --Google-Chrome| Installs / uninstalls Google Chrome, Google Drive, Google Play Music, Google Remote Desktop
| -p --python --python3 --Python3 --Python| Installs / uninstalls Python3 and Python2 interpreter
| -s --sublime --sublimeText --sublime_text --Sublime --sublime-Text --sublime-text| Installs / uninstalls Sublime Text 3
| -v --vlc --VLC --Vlc| Installs / uninstalls VLC media player
| -w --steam --Steam --STEAM| Installs / uninstalls Steam
| -y --pypy --pypy3 --PyPy3 --PyPy| Installs / uninstalls PyPy3 Python3 interpreter
| --mega --Mega --MEGA --MegaSync --MEGAsync --MEGA-sync --megasync| Installs / uninstalls MEGAsync and MEGAsync desktop integration
| --transmission --transmission-gtk --Transmission | Installs / uninstalls Transmission torrent downloader
| --thunderbird --mozillathunderbird --mozilla-thunderbird --Thunderbird --thunder-bird| Installs / uninstalls thunderbird email client

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
- [ ] Automount available drives.
- [ ] Solve bug of `PATH` addition in shell features. (it works, but it appends the export many times)
- [ ] Program function to unregister default opening applications on `uninstall.sh`
- [ ] Add IntelliJ IDE from Jetbrains
- [ ] Add JDK and global variables to JDK
- [ ] Telegram


## Author and Acknowledgements
* Author: **Aleix Mariné** - [AleixMT](https://github.com/AleixMT) [aleix.marine@estudiants.urv.cat](aleix.marine@estudiants.urv.cat)
* Tester: **Axel Fernández** - [Axlfc](https://github.com/Axlfc) [axelfernandezcurros@gmail.com](axelfernandezcurros@gmail.com)




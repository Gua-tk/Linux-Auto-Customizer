[![Codacy grade](https://img.shields.io/codacy/grade/9d77f6c73bab4a11b847d131146fc243?style=plastic&logo=codacy)](https://www.codacy.com/gh/AleixMT/Linux-Auto-Customizer/dashboard?utm_source=github.com)
[![GitHub top language](https://img.shields.io/github/languages/top/AleixMT/Linux-Auto-Customizer?style=plastic&color=green&logo=gnu)](https://www.gnu.org/software/bash)
[![Lines of code](https://img.shields.io/tokei/lines/github/AleixMT/Linux-Auto-Customizer?style=plastic&logo=gitlab)](https://gitlab.com/AleixMT/Linux-Auto-Customizer)
[![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/m/AleixMT/Linux-Auto-Customizer?style=plastic&logo=github)](https://github.com/AleixMT/Linux-Auto-Customizer/commits/master)
![GitHub Repo stars](https://img.shields.io/github/stars/AleixMT/Linux-Auto-Customizer?style=social)

# Auto-Customizer

`bash` scripts to automatize the installation and uninstallation of a batch of precoded features in a Linux environment.

## Description

These `bash` scripts can automatize the installation and uninstallation of a batch of preset 
features in most Linux environments. These features include GNU software, programming languages, 
IDEs, text editors, media players, games, Internet applications, file templates, wallpapers, 
environment aliases, environment functions, terminal personalization... All installations are
cleaner, faster and fancier than a manual installation.

If you are a developer and use a lot of software this tool can save you a lot of time: Usually 
we need to set up new programming environments in Linux and we lose a lot of time installing 
manually all of our programs and personal customization. This can happen often, so with this
tool you can automatize all this set up.

There are many good reasons for which you would prefer to execute a script that installs the 
exact features that you want, instead of having environment scripts such as `.bashrc` or `.bash_aliases`
where you have all your customizations:
- Optimizing your time because you can install them in a batch without needing any posterior input. 
  Completely automatic.
- Be able to select which features you desire, instead of having them all at once.
- Not all the features that we could desire can be activated using an environment script, or is 
  actually not desirable to execute some type of code in those scripts.


## Usage
The scripts `install.sh` and `uninstall.sh` have the same identical arguments, but behave in 
the opposite way: 
`install.sh` will install the features selected by the arguments while `uninstall.sh` will
uninstall them, using
the identical arguments. 

### Download
To install this software you must begin cloning this repository to you computer. You can either
download a `.zip`
file containing the repository from github from [here](https://github.com/AleixMT/Linux-Auto-Customizer/archive/master.zip), 
or you can clone the repository using a terminal. To do the last option, you must have installed 
`git`. If you don't have it, you can install it opening a terminal and typing the following:
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
bash install name_of_feature
```
### Installing sets of features
```
bash install name_of_set_of_custom_features
```
Example:
```
bash install -v discord
```
### Behavioural arguments
Verbose mode
Examples:
```
bash install -v telegram
```
Quiet mode
```
sudo bash install -q firefox gpaint
```
Alternation
```
sudo bash install -q firefox -v gpaint
```
Silent Desktop icons for apps of the system
```
sudo bash install -q -o cheese
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

## Features
All features available follow a common behaviour:
* The permissions needed for the features to be installed are the minimum. As such, we have many installation available even if you do not have `root` permissions on your machine. 
* Software and command-line utilities are intended to appear as a valid binary in your `PATH`, so you can directly call the program as you would do with `cd` or `ls`.
* Software with GUI creates its own launcher in the desktop and in the dashboard.
* Software that reads or recognizes files are configured to be the default application for their recognized file types. 
* The installation of a feature will be skipped if the current privileges does not match the needed privileges for that feature.

![alt text](https://i.imgur.com/53QkidL.png)
The following features can be installed or uninstalled automatically and individually using one of the specified arguments:

#### User programs
| Name | Description | Execution | Arguments | Testing |
|-------------|----------------------|------------------------------------------------------|------------|-------------|
| Android Studio | Development environment for Google's Android operating system | Command `studio`, alias `studio` and desktop and dashboard launcher |studio android_studio| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Anydesk | Software to remote control other computers | Command `anydesk` |any_desk| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Apache Ant | Software tool for automating software build processes | Command `ant` |ant apache_ant| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |
| Apache Tomcat 9.0.43 | Open-source server to run web apps written in Jakarta Server Pages | Tomcat available in ${USER_BIN_FOLDER} to deploy web apps |tomcat apache_tomcat tomcat_server| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li>|
| bashcolors | bring color to terminal | Command `bashcolors` |bash_colors| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Change default fonts | Sets pre-defined fonts to desktop environment. | A new set of fonts is updated in the system's screen. |system_fonts| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| cheat.sh | Provides access to community-driven cheat sheets and snippets for Linux/UNIX commands and many programming languages | Command `cheat` |cheat cht.sh| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Clion | Cross-platform C/C++ IDE | Command `clion`, silent alias `clion`, desktop launcher, dashboard launcher, associated with mimetypes `.c`, `.h` and `.cpp` |clion| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Converters | Set of converter Python scripts that integrate in your environment as `bash` commands | Commands `bintodec`, `dectobin`, `dectohex`, `dectoutf`, `escaper`, `hextodec`, `to` and `utftodec` |converters| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Discord | All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone. | Command `discord` and desktop and dashboard launcher |discord| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Docker | Containerization service | Command `docker`, `containerd`, `containerd-shim`, `containerd-shim-runc-v2`, `ctr`, `dockerd`, `docker-init`, `docker-proxy`, `runc` |docker| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| DuckDuckGo | Opens DuckDuckGo in Chrome | Command `duckduckgo` |duckduckgo| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Eclipse | IDE for Java | Command `eclipse` |eclipse| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Facebook | Desktop app to facebook from Chrome | Command `facebook`, desktop launcher and dashboard launcher |facebook| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fetch| `git fetch`| Command `fetch` |fetch| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fonts-alegreya_sans | Installs font | Install alegreya font |fonts_alegreya_sans| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fonts-lato | Installs font | Install lato font |fonts_lato| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fonts-noto_sans | Installs font| Install noto_sans font |fonts_noto_sans| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fonts-oswald | Installs font| Install oswald font |fonts_oswald| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fonts-oxygen | Installs font | Install oxygen font |fonts_oxygen| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Forms | Google Forms opening in Chrome | Command `forms`, desktop launcher, dashboard launcher |forms google_forms|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `a` | Prints a list of aliases using `compgen -a` | Command `a` |a|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `add` | alias for `git add` | Command `add` |add add_function|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `alert` | Alias to show a notification at the end of a command | Alias `alert`. Use it at the end of long running commands like so: `sleep 10; alert` |alert alert_alias alias_alert| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `b` | Alias for `bash` | Alias `b` |b| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `branch` | alias for `git branch -vv` | Command `branch` |branch| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `c` | Function `c` that changes the directory or clears the screen | Function `c ` |c| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `changebg` | Function that changes the wallpaper using one random image from user images folder. It also downloads wallpapers and installs a cronjob to change the wallpaper every 5 minutes | Function `changebg` |change_bg wallpaper wallpapers| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `checkout` | alias for `git checkout` | Command `checkout` |checkout|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `clean` | Remove files and contents from the trash bin and performs `sudo apt-get -y autoclean` and `sudo apt-get -y autoremove`. | Command `clean` |clean| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `commit` | Function `commit` that makes `git commit -am "$1"` | Function `commit` |commit| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> 
| Function `dummycommit` | Do the following commands `git add -a` `git commit -am $1` `git push` | Command `dummycommit`|dummycommit| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `e` | Multi Function `e` to edit a file or project in folder | Function `e` |e| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `h` | Search in your history for previous commands entered, stands by `history | grep "$@"` | Command `h` h Command `h` ||  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `hard` | alias for `git reset HEAD --hard` | <-- |hard| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `j` | alias for jobs -l | Commands `j` |j| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `l` | alias for `ls` | command `l` |l| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `L` | Function that lists files in a directory, but listing the directory sizes | Function `L` |L| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `o` | Alias for `nemo-desktop` | Alias `o` |o| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `s` | Function to execute any program silently and in the background | Function `s "command"` |s| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `u` | Opens given link in default web browser | Command `u` |u|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Function `x` | Function to extract from a compressed file, no matter its format | Function `x "filename"` |x extract| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GeoGebra | Geometry calculator GUI | Command `geogebra`, desktop launcher and dashboard launcher |geogebra geogebra_classic_6 geogebra_6| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GitHub | GitHub opening in Chrome | Command `github` |github| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GitLab | Gitlab opening in Chrome | Command |gitlab| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| gitprompt | Special prompt in git repositories | Command `gitprompt`|git_prompt| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Gmail | Gmail opening in Chrome | Command `gmail`, desktop launcher and dashboard launcher |gmail|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Google Calendar | Google Calendar opening in Chrome | Command `googlecalendar`, desktop launcher and dashboard launcher |google_calendar|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Google Documents | Google Documents opening in Chrome | Command `document` and desktop and dashboard launcher |documents google_document google_documents document|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Google Drive | Google Drive opening in Chrome | Command `drive`, desktop launcher and dashboard launcher |drive google_drive|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Google Keep | Google Keep opening in Chrome | Command `keep`, desktop launcher and dashboard launcher |keep google_keep|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| history optimization | Increased the size of bash history, store multiline commands in just one line, force append and not overwrite to history, ignore repeated commands when appending to history, deleted tracking history of some simple commands: `ls`, `cd`, `gitk`... | <-- |history_optimization| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Instagram | Opens Instagram in Chrome | Command `instagram`, desktop launcher, dashboard launcher |instagram| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| intelliJ Community | Integrated development environment written in Java for developing computer software | Command `ideac`, silent alias for `ideac`, desktop launcher, dashboard launcher and association to `.java` files |ideac intellij_community| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |
| intelliJ Ultimate | Integrated development environment written in Java for developing computer software | Command `ideau`, silent alias for `ideau`, desktop launcher, dashboard launcher and association to `.java` files |ideau intellij_ultimate| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |
| ipe function | Returns the public IP | Command `ipe` |ipe| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| ipi function | Returns the private IP | Command `ipi` |ipi| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Java Development Kit 8 | Implementation of version 8 of the Java (programming language) SE Platform | Commands `java`, `javac` and `jar` |java javadevelopmentkit java_development_kit java_development_kit_11 jdk jdk11| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Julia and IJulia| High-level, high-performance dynamic language for technical computing | Commands `julia`, desktop launcher and dashboard launcher |julia| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Jupyter Lab | IDE with a lot of possible customization and usable for different programming languages. | alias `lab`, commands `jupyter-lab`, `jupyter-lab`, `ipython`, `ipython3`, desktop launcher and dashboard launcher. Recognized programming languages: Python, Ansible, Bash, IArm, Kotlin, PowerShell, Vim. |jupyter_lab jupyter| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Linux Auto Customizer | Program and function management and automations | Command `customizer-install` |customizer linux_auto_customizer auto_customizer linux_customizer|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Maven | Build automation tool used primarily for Java projects | Command `mvn` |mvn| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul><li>- [x] Fedora</li> |
| Mendeley | It is most known for its reference manager which is used to manage and share research papers and generate bibliographies for scholarly articles | Command `mendeley`, desktop launcher and dashboard launcher |mendeley|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Netflix | Netflix opening in Chrome | Command `netflix`. Desktop launcher and dashboard launcher for the file manager | --netflix --Netflix netflix --netflix --Netflix |  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| NodeJS npm | JavaScript packagemanager for the developers. | Command `node` |npm|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| OneDrive | Microsoft OneDrive opening in Chrome | Command `onedrive`, desktop launcher and dashboard launcher |onedrive|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Outlook | Microsoft Outlook e-mail opening in Chrome | Command `outlook`, desktop launcher and dashboard launcher |outlook|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Overleaf | Online LaTeX editor opening in Chrome | Command `overleaf`, desktop launcher and dashboard launcher |overleaf|   <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| pgAdmin | PostgreSQL Tools | Command `pgadmin4` |pgadmin pgadmin4|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Postman | Application to maintain and organize collections of REST API calls | Command `postman`, desktop launcher and dashboard launcher  |postman|  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Presentation | Google Presentation opening in Chrome | Command `presentation`, desktop launcher and dashboard launcher|presentation google_presentation|  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| prompt | Installs a new colourful prompt on terminal window including and upgrading the default ones in Ubuntu | Adds a personalized prompt that shows the date, return code of last executed program, user, group and working directory. It also changes the prompt colour of introduced text to green. It changes the terminal windows title, adds colourful aliases and ensures completion |prompt| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| `pull` | Alias for `git pull`|  Command `pull` |pull|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| `push` | Alias for `git push`|  Command `push` |push|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Pycharm Community | Integrated development environment used in computer programming | Command `pycharm`, silent alias for `pycharm-pro`, desktop launcher, dashboard launcher, associated to the mime type of `.py` files  |pycharm pycharm_community| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Pycharm Pro | Integrated development environment used in computer programming | Command `pycharm-pro`, silent alias for `pycharm-pro`, desktop launcher, dashboard launcher, associated to the mime type of `.py` files |pycharm_pro| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| pypy3 | Faster interpreter for the Python3 programming language | Commands `pypy3` and `pypy3-pip` in the PATH |pypy3 pypy| <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Reddit | Opens Reddit in Chrome | Commands `reddit`|reddit| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| RStudio | Default application for .R files  | Commands `rstudio`, desktop launcher, dashboard launcher |r_studio| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  
| Screenshots | Takes a screenshot and saves it to custom ~/Images/screenshots folder and save it to the clipboard for pasting | Commands `screenshot-full` `screenshot-window` `screenshot-area`|screenshots|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| shortcuts | Installs custom key commands | variables... ($DESK...) |shortcuts| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Spreadsheets | Google Spreadsheets opening in Chrome | Command `spreadsheets`, desktop launcher, dashboard launcher |spreadsheets google_spreadsheets| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| status | `git status` | Command `status` |status| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Sublime | Source code editor with an emphasis on source code editing | Command `sublime`, silent alias for `sublime`, desktop launcher, dashboard launcher, associated with the mime type of `.c`, `.h`, `.cpp`, `.hpp`, `.sh` and `.py` files |sublime sublime_text| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Sysmontask | Control panel for linux | Command `sysmontask`, desktop launcher, dashboard launcher |sysmontask| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Telegram | Cloud-based instant messaging software and application service | Command `telegram`, desktop launcher and dashboard launcher |telegram| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Templates | Different collection of templates for starting code projects: Python3 script (`.py`), Bash script (`.sh`), LaTeX document (`.tex`), C script (`.c`), C header script (`.h`), makefile example (`makefile`) and empty text file (`.txt`) | In the file explorer, right click on any folder to see the contextual menu of "create document", where all the templates are located |templates| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Terminal background | Change background of the terminal to black | Every time you open a terminal |terminal_background| <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Trello | Trello web opens in Chrome | Command `trello`, desktop launcher and dashboard launcher |trello| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Tumblr | Tumblr web opens in Chrome | Command `tumblr`, desktop launcher and dashboard launcher |tumblr| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Twitch | Twitch web opens in Chrome | Command `twitch`, desktop launcher and dashboard launcher |twitch twitch_tv| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Twitter | Twitter web opens in Chrome | Command `twitter`, desktop launcher and dashboard launcher |twitter| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Visual Studio Code | Source-code editor | Command `code`, desktop launcher, dashboard launcher |code visual_studio_code visual_studio| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Whatsapp Web | Whatsapp web opens in Chrome | Command `whatsapp`, desktop launcher and dashboard launcher |whatsapp| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Wikipedia | Wikipedia web opens in Chrome | Command `wikipedia`, desktop launcher and dashboard launcher |wikipedia| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Youtube Music | YouTube music opens in Chrome. | Command `youtubemusic`, desktop launcher and dashboard launcher |youtube_music|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Youtube| YouTube opens in Chrome | Command `youtube`, desktop launcher and dashboard launcher |youtube|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| youtube-dl | Download manager for video and audio from YouTube and over 1000 other video hosting websites. | Command `youtube-dl` in the PATH and alias `youtube-wav` to scratch a mp3 from youtube |youtube_dl| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Zoom | Live Video Streaming for Meetings | Command `zoom`, desktop launcher and dashboard launcher |zoom| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
#### Root Programs
| Name | Description | Execution | Arguments | Testing |
|-------------|----------------------|------------------------------------------------------|------------|-------------|
| Ansible | Automation of software | Command `ansible` |ansible| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Aspell | Spell checker | Command `aspell` |aspell|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Atom | Text and source code editor | Command `atom`, desktop and dashboard launcher |atom|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Audacity | Digital audio editor and recording | Command `audacity` and desktop and dashboard launcher |audacity| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| AutoFirma | Electronic signature recognition | Command `AutoFirma` and desktop and dashboard launcher |auto_firma|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Axel | Download manager | Command `axel` |axel|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Brasero | Software for image burning | Command `brasero`, desktop launcher and dashboard launcher |brasero| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Caffeine | Simple indicator applet on Ubuntu panel that allows to temporarily prevent the activation of the screensaver, screen lock, and the “sleep” power saving mode. | Commands `caffeine`, `caffeinate` and `caffeine-indicator`, desktop launcher for `caffeine`, dashboard launcher for `caffeine` and `caffeine-indicator` |caffeine coffee cafe|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Calculator | GUI calculator| Commmand `calculator`, desktop launcher and dashboard launcher |gnome_calculator|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Calibre | e-book reader| Commmand `calibre`, desktop launcher and dashboard launcher |calibre|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Cheese | GNOME webcam application | Command `cheese`, desktop launcher and dashboard launcher |cheese|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Chess | Plays a full game of chess against a human being or other computer program | Command `gnome-chess`, desktop launcher and dashboard launcher |gnome_chess|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Clementine | Modern music player and library organizer | Command `clementine`, desktop launcher and dashboard launcher |clementine|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| CloneZilla | Disk cloning, disk imaging, data recovery, and deployment | Command `clonezilla`, desktop launcher and dashboard launcher |clonezilla|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Cmatrix | Terminal screensaver from The Matrix | Command `cmatrix`, function `matrix`, desktop launcher and dashboard launcher |cmatrix|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Code::Blocks | IDE for programming  | Command `codeblocks`, desktop launcher, dashboard launcher |codeblocks code::blocks| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| copyq | A clipboard manager application that comes with extra features such as editing and scripting | Command `copyq`, desktop launcher and dashboard launcher |copyq|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Curl | Curl is a CLI command for retrieving or sending data to a server | Command `curl` |curl|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| DBeaver | SQL Client IDE | Command `dbeaver` desktop and dashboard launcher |dbeaver|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| dconf-editor | Editor settings | Command `dconf-editor` and desktop and dashboard launcher |dconf_editor dconf|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Dia | Graph and relational  | Command `dia` and desktop and dashboard launcher |dia| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Dropbox | File hosting service | Command `dropbox`, desktop launcher and dashboard launcher |dropbox|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| evolution | User calendar agend, planning | Command `evolution` |evolution|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Fdupes| Searches for duplicated files within given directories | Command `fdupes`|fdupes| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| ffmpeg | Super fast video / audio encoder | Command `ffmpeg` |ffmpeg youtube_dl_dependencies|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| f-irc | CLI IRC client | Command `f-irc`, desktop launcher and dashboard launcher |f_irc|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Firefox | Free web browser | Command `firefox`, desktop launcher, dashboard launcher |firefox|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| font Msttcorefonts | Windows classic fonts | Install mscore fonts |msttcorefonts|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| fonts-firacode | Installs font | Install firacode font |fonts_firacode|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fonts-hack | Installs font | Install hack font |fonts_hack|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fonts-hermit | Installs font | Install hermit font |fonts_hermit|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| fonts-roboto | Installs font| Install roboto font |fonts_roboto|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| FreeCAD | General-purpose parametric 3D computer-aided design modeler and a building information modeling | Command `freecad`, desktop launcher and dashboard launcher |freecad|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Geany | Lightweight GUI text editor using Scintilla and GTK, including basic IDE features | Command `geany`, desktop launcher and dashboard launcher |geany|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GhostWriter | Text editor without distractions. | Command `ghostwriter, desktop launcher and dashboard launcher |ghostwriter|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Gimp | Raster graphics editor used for image manipulation and image editing, free-form drawing, transcoding between different image file formats. | Command `gimp`, desktop launcher and dashboard launcher |gimp|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| git | Software for tracking changes in any set of files, usually used for coordinating work among programmers collaboratively developing source code during software development | Command `git` and `gitk` |git|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GitHub Desktop | GitHub Application | Command `github-desktop` |github_desktop| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Gitk | GUI for git | Command `gitk` |gitk|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GNAT | Programming Studio for Ada and C | Command `gnat-gps`, desktop launcher and dashboard launcher |gnat_gps|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GNOME terminal | Terminal of the system | Command `gnome-terminal` |gnome_terminal|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GNOME Tweaks | GUI for system customization | command and desktop launcher... |gnome_tweak_tool tweaks gnome_tweak gnome_tweak_tools gnome_tweaks|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GNU C Compiler | C compiler for GNU systems | Command `gcc` |gcc|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GNUparallel | Command-line driven utility for Linux and other Unix-like operating systems which allows the user to execute shell scripts or commands in parallel | Command `parallel` |parallel gnu_parallel|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Google Chrome | Cross-platform web browser | Command `google-chrome`, desktop launcher and dashboard launcher |google_chrome|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Gpaint | Raster graphics editor similar to Microsoft Paint | Command `gpaint`, desktop launcher and dashboard launcher |gpaint|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| GParted | Creating, deleting, resizing, moving, checking, and copying disk partitions and their file systems | Command `gparted`, desktop launcher and dashboard launcher |gparted|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Grsync | Software for file/folders synchronization | Commands `grsync`, desktop launcher and `rsync` |rsync grsync| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Gvim | Vim with a built-in GUI | Command `gvim`, desktop launcher and dashboard launcher |gvim vim_gtk3|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Handbrake | Video Transcoder | Command `handbrake`, Desktop and dashboard launchers |handbrake| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Hardinfo | Check pc hardware info | Command `hardinfo` |hardinfo| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Inkscape | Vector graphics editor used to create vector images, primarily in Scalable Vector Graphics format | Command `inkscape`, desktop launcher and dashboard launcher |ink_scape|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| IQmol | Program to visualize molecular data | Command `iqmol`, silent alias, desktop launcher and dashboard launcher |iqmol| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| LaTeX | Software system for document preparation | Command `tex` (LaTeX compiler) and `texmaker` (LaTeX IDE), desktop launchers for `texmaker` and LaTeX documentation |latex|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| libgtkglext1 | Anydesk dependency | Used when Anydesk is run |libgtkglext1 anydesk_dependencies|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| libkrb5-dev | Kerberos dependency | Used when Jupiter Lab is run |libkrb5_dev kerberos_dependencies|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| libxcb-xtest0 | Zoom dependency | Used when Zoom is run |libxcb_xtest0|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| lolcat | Same as the command `cat` but outputting the text in rainbow color and concatenate string | command `lolcat`, alias `lol` |lolcat|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Mahjongg | Implementation for GNU systems of the famous popular chinese game Mahjongg | Command `gnome-mahjongg`, desktop launcher and dashboard launcher |gnome_mahjongg|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| mdadm | Manage RAID systems | Command `mdadm` |mdadm|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| MegaSync | Synchronises folders between your computer and your MEGA Cloud Drive | Command `megasync`, desktop launcher, dashboard launcher and integration with `nemo` file explorer |megasync mega|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| MendeleyDependencies | Installs Mendeley Desktop dependencies `gconf2`, `qt5-default`, `qt5-doc`, `qt5-doc-html`, `qtbase5-examples` and `qml-module-qtwebengine` | Used when installing Mendeley and other dependent software |mendeley_dependencies mendeley_desktop_dependencies| <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Microsoft Teams | Video Conference, calls and meetings | Command `teams`, desktop launcher and dashboard launcher |teams microsoftteams|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Mines | Implementation for GNU systems of the famous game mines | Command `gnome-mines`, desktop launcher and dashboard launcher |gnome_mines|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Nautilus | Standard file and desktop manager | Command `nautilus` Desktop launcher and dashboard launcher for the file manager |nautilus|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| NEdit | Multi-purpose text editor and source code editor | Command `nedit` desktop launcher, dashboard launcher |nedit|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Nemo Desktop | Access and organise files | Command `nemo` for the file manager, and `nemo-desktop` for the desktop manager service. Desktop launcher and dashboard launcher for the file manager |nemo nemo_desktop|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| net-tools | GUI network interfaces. *We recommend this explorer to view correctly the launchers* | Command `net-tools` |net_tools|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Notepadqq | Text editor that is designed by developers for the developers. It supports more than 100 programming languages | Command `notepadqq`, desktop launcher and dashboard launcher |notepad_qq|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| OBS | Streaming and recording program | Command `obs`, desktop launcher and dashboard launcher. |obs_studio obs|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Okular | PDF viewer | Command `okular`, desktop launcher and dashboard launcher |okular|   <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| OpenOffice | Office suite for open-source systems | Command `openoffice4` in PATH, desktop launchers for `base`, `calc`, `draw`, `math` and `writer` |open_office|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| openssl1.0 | RStudio dependency | Used for running rstudio |openssl102|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Pac-man | Implementation of the classical arcade game | Command `pacman`, desktop launcher and dashboard launcher |pacman|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| pdfgrep | CLI utility that makes it possible to search for text in a PDF file without opening the file | Command `pdfgrep` |pdfgrep|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| php | Programming language | Command `php` |php|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| pluma | Fork of gedit 2.0 that supports many plugins and new features | Command `pluma`, desktop launcjer and dashboard launcher |pluma|  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| PostGreSQL | Installs `psql`|  Command `psql` |psql postgresql|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| pypy3_dependencies | Dependencies to run pypy3 | Libraries `pkg-config`, `libfreetype6-dev`, `libpng-dev` and `libffi-dev` used when deploying `pypy` |pypy3_dependencies pypy_dependencies|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Python3 | Interpreted, high-level and general-purpose programming language | Commands `python`, `python3`, `pip3` and Function `v` is for activate/deactivate python3 virtual environments (venv) can be used as default `v` as a command creates the /venv/ environment we can activate/deactivate new or existing virtual environments, command `v namevenv` creates /namevenv/ we can activate the virtual environment again using `v namenv` or deactivate same again, using `v namenv` |python_3 python v|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| R | Programming language | Commands `R`, Dashboard Launcher, Desktop Launcher|R r_base| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  
| Remmina | Remote Desktop Contol | Commands `remmina`, Desktop launcher and Icon |remmina| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |  
| Rust | Programming Language | Installs `rustc` |rustc| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Scala | Programming language | Command `scala` |scala| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| ShotCut | Cross-platform video editing | Command `shotcut`, desktop launcher and dashboard launcher |shotcut|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Shotwell | Cross-platform video editing | Command `shotwell`, desktop launcher and dashboard launcher |shotwell|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Skype | Call & conversation tool service | Icon Launcher... |skype|  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Slack | Platform to coordinate your work with a team | Icon Launcher |slack|  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Solitaire aisleriot | Implementation of the classical game solitaire | Command `aisleriot`, desktop launcher and dashboard launcher |aisleriot solitaire gnome_solitaire|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Sonic Pi | programming language that ouputs sounds as compilation product | Command `sonic-pi`, desktop launcher, dashboard launcher |sonic_pi| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Spotify | Music streaming service | Command `spotify`, desktop launcher, dashboard launcher |spotify| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Steam | Video game digital distribution service | Command `steam`, desktop launcher and dashboard launcher |steam|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| sudoku | Implementation for GNU systems of the famous popular mathematical game sudoku | Command `gnome-sudoku`, desktop launcher and dashboard launcher |gnome_sudoku| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Synaptic | Graphical installation manager to install, remove and upgrade software packages | Command `synaptic`, desktop launcher, dashboard launcher |synaptic| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Team Viewer | Video remote pc control | Command `teamviewer`, desktop launcher and dashboard launcher |teamviewer|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Terminator | Terminal emulator for Linux programmed in Python | Command `terminator`, desktop launcher and dashboard launcher |terminator|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Thunderbird | Email, personal information manager, news, RSS and chat client | Command `thunderbird`, desktop launcher and dashboard launcher |thunderbird|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Tilix | Advanced GTK3 tiling terminal emulator | Command `tilix`, desktop launcher and dashboard launcher |tilix|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Tmux | Terminal multiplexer for Unix-like operating systems | Command `tmux`, desktop launcher and dashboard launcher |tmux|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> | 
| Tor browser | Software for enabling anonymous communication by directing Internet traffic. | Command `tor`, desktop launcher and dashboard launcher |tor tor_browser|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Transmission | A set of lightweight Torrent client (in GUI, CLI and daemon form) | Executable `transmission`, desktop launcher and dashboard launcher |transmission_gtk transmission|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| uget | GUI utility to manage downloads | Command `uget`, desktop launcher and dashboard launcher |uget|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| VirtualBox | Hosted hypervisor for x86 virtualization | Command `virtualbox`, desktop launcher and dashboard launcher |virtual_box|  <ul><li>- [ ] Ubuntu</li><li>- [ ] Debian</li></ul> |
| VLC | Media player software, and streaming media server | Command `vlc`, desktop launcher and dashboard launcher |vlc|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| Wireshark | Net sniffer | Command `wireshark`, desktop launcher and dashboard launcher |wireshark|  <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
| `xclip` | Utility for pasting. | Command `xclip` |x_clip| <ul><li>- [x] Ubuntu</li><li>- [ ] Debian</li></ul> |
Customizer currently has available 99 user features and 106 root features, 205 in total


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




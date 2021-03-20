### Business rules

* Both behaviors of the script use the file `~/.config/user-dirs.dirs` to set some language-independent environment variables (for example, to get an independent system-language path to the Desktop), so the script will fail if this file does not exist.
* Each feature is expected to be executed with certain permissions (root / normal user). So the script will fail if the asked features to be installed have different permissions requirements than the given.

### Local user features 
This section enumerates which features can be installed without root permissions in the context of the normal user running the script.

Software that needs to be "manually" installed as normal user is stored under `~/.bin`.


| shell | | Backups your `$HOME/.bashrc` to `$HOME/.bashrc.bak` and installs shell features in `$HOME/.bashrc` including: history optimization, environament aliases, functions and global variables. See *Shell customization* section for more information. Uninstalls the feature by restoring `$HOME/.bashrc.bak` to `$HOME/.bashrc` if present. | --shell --shellCustomization --shellOptimization --environment --environmentaliases --environment_aliases --environmentAliases --alias --Aliases | 

 without the path to the binary. This script forces `~/.local/bin` to be under your `PATH`, so the symlinks to the binaries will be created in there.
  (user launchers are located in `~/.local/share/applications`). It also creates a launcher for each in the Desktop.
 
## Developed features
#### Aleix
- [x] Create argument (! or --not) for deselecting installed or uninstalled features.
- [x] -v --verbose Verbose mode (make the software not verbose by default)
- [x] Solve bug of `PATH` addition in shell features. (it works, but it appends the export many times)
- [x] To add more useful directory path variables in common_data.sh
- [x] Make sure USR_BIN_FOLDER is present in any user roll
- [x] Create file and directory structure to add features to `.bashrc` without actually writing anything on it by using the wrapper in `.bash_functions`  
#### Axel
- [x] Delete / rearrange arguments of one letter 
- [x] Initial refactor of data table in README.md
## Currently developing/refactoring features

## TO-DO
- [ ] Name refactor of functions to make it coincide with what command is being thrown in order to determine if it is installed using which
- [ ] Add aliases topycharm, clion, etc  
- [ ] Installations must be done by argument order apparition (add another column to installation_data to sort an integer that determines the order)
- [ ] try refactoring the point above by using type, which recognizes alias and functions too
- [ ] refactor installation bit to be installation order, which contains an integer that if it is greater than 0 means selected for install, and the integer determines the installation order
- [ ] declare variables like DESK, GIT, etc
- [ ] Create high-level wrappers for a set of features, such as "minimal", "custom", "" etc.
- [ ] Split multifeatures in one function into different functions
- [ ] Create source in bashrc with file bash_functions.sh with all sources calls
- [ ] [ ] Create generic version for the function output_proxy_exec to integrate with a feature ready to be installed
- [ ] Desktop wallpapers
- [ ] Create escape function, which returns an escaped sequence of characters, depending on the programming languages
- [ ] Add argument to dummy commit
- [ ] Refine extract function
- [ ] Create generic version for the function output_proxy_exec, to integrate with a bash feature to be installed
- [ ] Replicate most of the necessary structures and data to adapt `uninstall.sh` to the new specs
- [ ] Add special func in uninstall (--reset|-r) that uninstalls the file structures that the customizer creates (~/.bash_functions, ~/.bin, etc.) That cannot be removed directly using uninstall

## Coming features
- [ ] create a unique endpoint for all the code in customizer customizer.sh which accepts the arguments install uninstall for the recognized features and make the corresponding calls to sudo uninstall.sh ..., sudo install.sh ... And Install.sh ... 
- [ ] make `customizer.sh` 
- [ ] Automount available drives.*
- [ ] Create or integrate loc function bash feature which displays the lines of code of a script  
- [ ] Program function to unregister default opening applications on `uninstall.sh`
- [ ] nettools* 
- [ ] GnuCash, Rosegarden, Remmina, Freeciv, Shotwell, Handbrake, fslint, CMake, unrar, rar, evolution, guake, Brasero, Remastersys, UNetbootin, Blender3D, Skype, Ardour, Spotify, TeamViewer, Remmina, WireShark, PacketTracer, LMMS...
- [ ] LAMP stack web server, Wordpress
- [ ] Rsync, Axel, GNOME Tweak, Wine 5.0, Picasa, Synaptic, Bacula, Docker, kubernetes, youtube-dl, Agave, apache2, Moodle, Oracle SQL Developer, Mdadm, PuTTY, MySQL Server instance, glpi*, FOG Server*, Proxmox*, Nessus*, PLEX Media Server
- [ ] nmap, gobuster, metasploit, Firewalld, sysmontask, sherlock, Hydra, Ghidra, THC Hydra, Zenmap, Snort, Hashcat, Pixiewps, Fern Wifi Cracker, gufw, WinFF, chkrootkit, rkhunter, Yersinia, Maltego, GNU MAC Changer, Burp Suite, BackTrack, John the Ripper, aircrack-ng
- [ ] SublimeText-Markdown, & other plugins for programs...
- [ ] Repair broken desktop icons (VLC...
- [ ] Fonts

## asjko
  #lsdisplay=$(ls -lhA | tr -s " ")
  #dudisplay=$(du -shxc .[!.]* * | sort -h | tr -s "\t" " ")
  #IFS=$'\n'
  #for linels in ${lsdisplay}; do
  #  if [[ $linels =~ ^d.* ]]; then
  #    foldername=$(echo $linels | cut -d " " -f9)
  #    for linedu in ${dudisplay}; do
  #      if [[ "$(echo ${linedu} | cut -d " " -f2)" = ${foldername} ]]; then
  #        # Replace $lsdisplay with values in folder size 
  #        break
  #      fi
  #    done
  #  fi
  #done

  #alias a="echo '---------------Alias----------------';alias"
  #alias c="clear"
  #alias h="history | grep $1"
  #du -shxc .[!.]* * | sort -h

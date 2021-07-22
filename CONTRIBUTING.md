## Business rules

###### Environmental
- [x] Both behaviors of the script use the file `~/.config/user-dirs.dirs` to set some language-independent environment variables (for example, to get an independent system-language path to the Desktop), so some functions of this script will fail if this file does not exist. The variables declared in this file that are used in the customizer are `XDG_DESKTOP_DIR=/home/username/Desktop`, `XDG_PICTURES_DIR=/home/username/Images`, `XDG_TEMPLATES_DIR=/home/username/Templates`.
- [x] Customizer must not rely ever on the working directory, that is why relative paths are completely avoided (only allowed in necessary cases in . In the same vein, files must not be downloaded in the working directory, they should be deleted in a controlled location. In most cases, this location is `USR_BIN_FOLDER`.
- [ ] All variables should be declared with the needed scope and its write/read permissions (local-r)

###### Structural
- [x] The software that is manually installed is put under `USR_BIN_FOLDER`, which by default points to `~/.bin`. `~/.bin` and is always **present** during the execution of `install.sh`.
- [x] Shell features are not installed directly into `~/.bashrc`, instead, there is always present during the runtime of `install sh` the file `$USR_BIN_FOLDER/bash_functions/.bash_functions`, which is a file imported by `~/.bashrc`. In `~/.bash_functions`, you can write imports to individual scripts that provide a feature to the shell environment. Usually those scripts are stored under `~/.bin/bash_functions/`, which is a location always present. So the generic way to include new content to `~/.bashrc` is writing a script to `~/.bin/bash_functions` and including it in `~/.bash_functions/`.
- [ ] Soft links to include a program in the PATH are created under `DIR_IN_PATH` which by default points to `~/.local/bin` a directory that is usually already in the PATH. If not, `install.sh` will add it at the beginning of the installation
- [ ] Files or folders created as root need to change their permissions and also its group and owner to the `${SUDO_USER}` using chgrp and chown
- [ ] console features are not installed directly in bashrc; instead use the structure provided by the customizer using .bash_functions
- [ ] Code lines length is 120 maximum. Lines with more characters need to be split in many. Some exceptions may apply, for example when defining vars that contain links.
- [ ] help lines in 80 characters.
- [ ] The tests used in the conditional ifs must be with [ ] instead of [[ ]] when possible. The last one is a bash exclusive feature that we can not find in other shells.

###### Behavioural
- [x] Each feature is expected to be executed with certain permissions (root / normal user). So the script will skip a feature that needs to be installed with different permissions from the ones that currently has.
- [x] No unprotected `cd` commands. `cd` must be avoided and never change the working directory given from the outside, that is why they must be called from the inside of a subshell if present.
- [x] Relative PATHs are forbidden. We must not rely or modify the working directory of the environment of the script. `cd` can be used safely inside a subshell: `$(cd ${USR_BIN_FOLDER} && echo thing`  
- [x] no `apt`, the default way to install package in script is `apt-get`
- [x] Only in special cases use echo directly to print to stdout. In most cases you need to use `output_proxy_executioner`
- [x] desktop launchers created manually have to be created in the desktop and also in the user launchers folder
- [x] desktop launchers created manually as root have to be in the desktop and also in the all users launchers folder
- [ ] All `ln`s are created with the option -f, to avoid collision problems.
- [ ] wget is always used with the `-O` flag, which is used to change the name of the file and / or select a destination for the download.
- [ ] tar is always used in a subshell, cd'ing into an empty directory before the tar, so the working directory of the script is never filled with temporary files.

###### Syntactical
- [ ] All variables must be expanded by using `${VAR_NAME}` (include the brackets) except for the special ones, like `$#`, `$@`, `$!`, `$?`, etc.
- [ ] There is one blankline between functions in the same block. There is two blanklines between blocks.
- [ ] using ~ or $HOME instead of HOME_FOLDER
- [ ] All variables must be protected by using "" to avoid resplitting because of spaces, despite, customizer is not emphasized to work with spaces in its variables. Spaces are *evil* in some paths are not considered.
- [ ] Indent is always 2 spaces and never TAB.
- [ ] Categories in each desktop launcher: Name, GenericName, Type, Comment, Version, StartupWMClass, Icon, Exec, Terminal, Categories=IDE;Programming;, StartupNotify, MimeType=x-scheme-handler/tg;, Encoding=UTF-8

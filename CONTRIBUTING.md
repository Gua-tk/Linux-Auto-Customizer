# Git
Git is the version system used to maintain the programming part of this project. Some git specific guidelines of use have been adopted due to the increasing complexity of the code.

## Tagging

We will use tags to statically point to commits that define a version. By definition each commit in the master branch will be tagged and will represent a version of our software, but we will explain how it is done manually.

First we need to explain how to tag a certain commit. We need to use:
`git tag -a "TAGNAME" -m "brief message explaining what this version does" SHA1ID_OF_THE_TAGGED_COMMIT`

This will tag the commit referenced by the SHA1ID with TAGNAME and the brief message.

To push the tags to the repo we use:
`git push origin --tags`

We can remove tags from teh local repository with:
`git tag -d TAGNAME`

We can also delete tags from the remote server easily:
`git push origin --delete TAGNAME`


## Commit message format:
This guideline is originally defined in [here](https://keepachangelog.com/en/1.1.0/). It defines a set of tags to be included in the commit message with a meaning regarding the evolution of the source code. This allows us to create a `CHANGELOG.md` file easily, by using own-defined tags in the commit message.

We adapt this guideline by defining:

### Types of changes
- **ADDED**: For commits that progresses towards a feature but do not complete it. 
- **FINISHED**: For commits that finish a feature, when is tested and ready to use.
- **UPDATED**: For commits that updates a finished feature such as a version update or changing a fallen link.
- **CHANGED**: For commits that change the implementation of a functionality but not the functionality itself.
- **REMOVED**: For removed features or deprecations.
- **FIXED**: For changes in the code that fix a bug or issue.

### Format
For a short message that only includes tag and title we can use:
`git commit -am "TYPE_OF_CHANGE: Commit title with a complete sentence."`

Notice the ":" and the space after the initial tag in the commit message: `git commit -am "FIXED: Title after : and the space"`

For a long message that includes tag, title and extended description we will use the command:

```
git commit -am "TYPE_OF_CHANGE: Commit title with a complete sentence. 

Optionally tell other things in this extended description that you want to explain about this commit. 
It can be many lines. Even an enumeration:
- like this.
- and this.
"
```
Notice the blankline in the long format between the title and the extended description.

For a non-changelog commit that only has extended description use:
```
git commit -am "
Message in commit that do not have a tag because we do not want to include them in the changelog
"
```

Notice how the first line is blank in order to not include it in the changelog because it does not have a tag.

For each commit:
- [ ] Commit often. 
- [ ] Commit following these rules. 
- [ ] In case of doubt reread these guidelines. 
- [ ] If you did not, you can ammend your commits locally by using `git commit --ammend -am "FORMAT"`. This can not be done when the commit has already been pushed to the server. 
- [ ] **Check the format of the commit message before pushing**
- [ ] Each commit has to be simple and reflect its title. Is preferable doing many ADDED commits than one single FINISHED.
- [ ] Do not repeat the commit message. If you have nothing to say is preferrable that you upload an empty commit or a non-changelog commit as defined above.
- [ ] Each commit needs a limited scope. Try to keep the number of modified files to the minimum for each commit. Changes withing a commit have to be related to each other. If unrelated changes have to be performed, commit your changes and put these unrelated changes in a new commit.
- [ ] Keep lines of commit messages under 120 characters. 

## CHANGELOG.md generation

Let's define two arbitrary consecutive tags, `tag_A` and `tag_B`. In each release we would like to obtain the commit messages with the right format that have been pushed to the server between `tag_A` and `tag_B`. We can do this by using the command:

```
git log 'tag_A'...'tag_B' 
```

By adding other modifiers and specifying the tags we can use this command to generate a changelog:

```
git log --color --decorate --oneline --pretty=format:"%C(auto)%h %d %s (%aN)" 'v0.11.0'...'HEAD' --grep="CHANGED: " --grep="ADDED: " --grep="UPDATED: " --grep="FIXED: " --grep="REMOVED: "
```

With a little more tweaking we could integrate this line in a CI to generate the CHANGELOG.md file on each commit into the master branch, prepending a changelog of this version to all the previous changelogs:


```
echo -e "CHANGES IN ACTUALVERSION: \n $(git log --color --decorate --oneline --pretty=format:"%C(auto) %d %s" 'PREVIOUSVERSION'...'ACTUALVERSION' --grep="CHANGED: " --grep="ADDED: " --grep="UPDATED: " --grep="FIXED: " --grep="REMOVED: ")\n$(cat CHANGELOG.md)" > CHANGELOG.md 
```

We obtain a text similar to this:
```
d282d22  (HEAD -> master, origin/master, origin/HEAD) ADDED: Dependencies of zoom and meld, (in the end i had to recompile lib gtk source view 3 in order to make meld work) (AleixMT)
cd32379  UPDATED: A table of contents have been added to README.md (Axlfc)
43fefc3  UPDATED: gitk new dependency (unifont) (Axlfc)
5111b0d  UPDATED: Prettifying README.md Updating Tux image (Axlfc)
85bff3d  UPDATED: Dependency of meld libgtkviewsource (AleixMT)
8952f7d  ADDED: gitk to the iochem wrapper (AleixMT)
88cf80c  CHANGED: Added autostart behaviour to copyq and guake (AleixMT)
49dd754  FIXED: Missing packagename property in nemo feature, also removed wikit and npm from iochem wrapper (AleixMT)
283d273  UPDATED: Dependencies of virtualbox. added fix broken before usages of package managers (AleixMT)
e40bfe3  FIXED: Bug in clonerepository installation type. There was an rm missing for avoiding collisions (AleixMT)
```

## Git Large File-System support
We are using git-lfs to track binary data on our repository like data from images which do not need to be indexed as
a normal file in git. Instead, we use git-lfs, a utility to upload binary files to git in a more optimized way, so it
does not conflict with our pull, push, checkout and clone speeds.

First you need to install git-lfs in your computer. You can use the customizer for this matter if you already have it installed:
```
sudo apt-get install -y git-lfs
```
or
```
sudo customizer-install -v -o git
```

Then, every time you clone the repository, you need to navigate to the project folder and execute:
```
git-lfs install
```
You will see sentences similar to these:
```
Updated git hooks.
Git LFS initialized.
```

Now you can work transparently and uploading binary content. The rules for `git-lfs` to distinguish between indexable
files (source code) and no-indexable files (binary data) are in the `.gitattributes` file in the root of the project.
You can include rules there to mark as no-indexable file any type of files regarding its name (and extension). For example:
``` 
*.svg filter=lfs diff=lfs merge=lfs -text
*.png filter=lfs diff=lfs merge=lfs -text
```

Which are two rules that make all the files with `.svg` and `.png` extension trackable by git-lfs. These rules are already
in the repository. 

## Semantic versioning

We do use semantic versioning as defined in [here](https://semver.org/). 

Given a version number MAJOR.MINOR.PATCH, increment the:

MAJOR version when you make incompatible API changes,
MINOR version when you add functionality in a backwards compatible manner, and
PATCH version when you make backwards compatible bug fixes.
Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.


## Git hooks
Commits on develop branch and master branch are forbidden. Merge in develop and master branch hasve to be forcibly with the option --no-ff 

# Business Rules
These are a set of rules that are used to build the installation of each feature in the customizer environment to 
maximize the usability and fanciness of each of them and the different capabilities and subsystems available.

###### Environmental
- [x] Both behaviors of the script use the file `~/.config/user-dirs.dirs` to set some language-independent environment 
variables (for example, to get an independent system-language path to the Desktop), so some functions of this script 
will fail if this file does not exist. The variables declared in this file that are used in the customizer are
`XDG_DESKTOP_DIR=/home/username/Desktop`, 
`XDG_PICTURES_DIR=/home/username/Images`, 
`XDG_TEMPLATES_DIR=/home/username/Templates`.
- [x] Customizer must not rely ever on the working directory, that is why relative paths are completely avoided 
(only allowed in necessary cases in . In the same vein, files must not be downloaded in the working directory, they 
should be deleted in a controlled location. In most cases, this location is `BIN_FOLDER`.
- [ ] All variables should be declared with the needed scope and its write/read permissions (local-r)

###### Structural
- [x] The software that is manually installed is put under `BIN_FOLDER`, which by default points to `~/.bin`. `~/.bin` 
and is always **present** during the execution of `install.sh`.
- [x] Shell features are not installed directly into `~/.bashrc`, instead, there is always present during the runtime 
of `install sh` the file `$BIN_FOLDER/bash_functions/.bash_functions`, which is a file imported by `~/.bashrc`. 
In `~/.bash_functions`, you can write imports to individual scripts that provide a feature to the shell environment. 
Usually those scripts are stored under `~/.bin/bash_functions/`, which is a location always present. So the generic 
way to include new content to `~/.bashrc` is writing a script to `~/.bin/bash_functions` and including it in 
`~/.bash_functions/`.
- [ ] Soft links to include a program in the PATH are created under `DIR_IN_PATH` which by default points to
`~/.local/bin` a directory that is usually already in the PATH. If not, `install.sh` will add it at the beginning of 
the installation
- [ ] Files or folders created as root need to change their permissions and also its group and owner to the 
`${SUDO_USER}` using `chgrp` and `chown`
- [ ] console features are not installed directly in bashrc; instead use the structure provided by the customizer using
.bash_functions
- [ ] Code lines length is 120 maximum. Lines with more characters need to be split in many. Some exceptions may apply, 
for example when defining vars that contain links.
- [ ] help lines in 80 characters.
- [ ] The tests used in the conditional ifs must be with [ ] instead of [[ ]] when possible. The last one is a bash 
exclusive feature that we can not find in other shells.

###### Behavioural
- [x] Each feature is expected to be executed with certain permissions (root / normal user). So the script will skip a 
feature that needs to be installed with different permissions from the ones that currently has.
- [x] No unprotected `cd` commands. `cd` must be avoided and never change the working directory given from the outside, 
that is why they must be called from the inside of a subshell if present.
- [x] Relative PATHs are forbidden. We must not rely or modify the working directory of the environment of the script. 
`cd` can be used safely inside a subshell: `$(cd ${BIN_FOLDER} && echo thing`  
- [x] no `apt`, the default way to install package in script is `apt-get`
- [x] Only in special cases use echo directly to print to stdout. In most cases you need to use 
`output_proxy_executioner`
- [x] desktop launchers created manually have to be created in the desktop and also in the user launchers folder
- [x] desktop launchers created manually as root have to be in the desktop and also in the all users launchers folder
- [ ] All `ln`s are created with the option -f, to avoid collision problems.
- [ ] wget is always used with the `-O` flag, which is used to change the name of the file and / or select a destination
for the download.
- [ ] tar is always used in a subshell, cd'ing into an empty directory before the tar, so the working directory of the 
script is never filled with temporary files.

###### Syntactical
- [ ] All variables must be expanded by using `${VAR_NAME}` (include the brackets) except for the special ones, like
`$#`, `$@`, `$!`, `$?`, etc.
- [ ] There is one blankline between functions in the same block. There is two blanklines between blocks.
- [ ] using ~ or $HOME instead of HOME_FOLDER
- [ ] All variables must be protected by using "" to avoid resplitting because of spaces, despite, customizer is not 
emphasized to work with spaces in its variables. Spaces are *evil* in some paths are not considered.
- [ ] Indent is always 2 spaces and never TAB.
- [ ] Categories in each desktop launcher: Name, GenericName, Type, Comment, Version, StartupWMClass, Icon, Exec, 
Terminal, Categories=IDE;Programming;, StartupNotify, MimeType=x-scheme-handler/tg;, Encoding=UTF-8

# Installation folder structure
The folder used to install customizer functionalities has the following structure by default:
```bash
~/.customizer/  # Installation folder, where ~ is the HOME folder of the user invoking sudo
  bin/  # Contains a directory for each feature that has to keep a download, create a virtual env, decompress a file, etc.
    studio/
    clion/
    ...
  temp/  # Downloads will happen here but will be moved afterwards to the destiny location; thus, we will only find failed downloads here
    clion_downloading.1  # Failed download. It can be safely deleted
  cache/  # All downloads will be moved here before moving them to its final destination. If a required file to download is already here, it will use the one already in the cache and will ommit the download
    clion_downloading  # cached file
    mendeley_downloading
    studio_downloading
    ...
  data/  # Contains the files that are used as a database of the used keybindings, active functions, active favorite launchers in the dash... 
    favorites.txt
    keybinds.txt
    bash_functions.sh
    bash_initializations.sh
  functions/  # Contains the bash files that can be included in the bash environment by using the file data/bash_functions.sh
    a.sh
    b.sh
    ...
  initializations/  # Contains the bash files that can be included at the beginning of the session by using the file data/bash_initializations.sh 
    keybinds.sh
```

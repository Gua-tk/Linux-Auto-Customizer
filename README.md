[![Codacy grade](https://img.shields.io/codacy/grade/9d77f6c73bab4a11b847d131146fc243?style=plastic&logo=codacy&color=blue)](https://www.codacy.com/gh/AleixMT/Linux-Auto-Customizer/dashboard?utm_source=github.com)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/7e05bb0ed08b4d57ac2f46de3f4f0c56)](https://app.codacy.com/gh/AleixMT/Linux-Auto-Customizer?utm_source=github.com&utm_medium=referral&utm_content=AleixMT/Linux-Auto-Customizer&utm_campaign=Badge_Grade_Settings)
[![GitHub top language](https://img.shields.io/github/languages/top/AleixMT/Linux-Auto-Customizer?style=plastic&color=blue&logo=gnu)](https://www.gnu.org/software/bash)
[![Lines of code](https://img.shields.io/tokei/lines/github/AleixMT/Linux-Auto-Customizer?style=plastic&logo=gitlab)](https://gitlab.com/AleixMT/Linux-Auto-Customizer)
![GitHub commits since tagged version](https://img.shields.io/github/commits-since/AleixMT/Linux-Auto-Customizer/v0.1.0?style=plastic&logo=github)
[![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/m/AleixMT/Linux-Auto-Customizer?style=plastic&logo=linux)](https://github.com/AleixMT/Linux-Auto-Customizer/commits/master)
![GitHub last commit](https://img.shields.io/github/last-commit/AleixMT/Linux-Auto-Customizer?&style=plastic&color=blue)
![GitHub Repo stars](https://img.shields.io/github/stars/AleixMT/Linux-Auto-Customizer?style=social)


`bash` scripts to automatize the installation and uninstallation of a batch of precoded features in a Linux environment.

![alt text](https://i.imgur.com/53QkidL.png)


# Customizer
Customizer is a software to automatize installations and customizations in a Linux environment. It is purely written in
[`bash`](https://www.gnu.org/software/bash) and already contains more than 200 pre-coded automatic features ready to be 
installed. Enjoy! 🤖


## Description
These `bash` scripts can automatize the installation and uninstallation of a batch of preset 
features in most Linux environments. These features include GNU software, programming languages, 
IDEs, text editors, media players, games, Internet applications, file templates, wallpapers, 
environment aliases, environment functions, terminal personalization... 

All installations are cleaner, faster and fancier than a manual installation, 
and of course all installations are **completely unattended**.
You just need to specify via arguments the features that you want, and they will
be installed without requiring any more prompt.

Also, many behavioural arguments are available, allowing extra flexibility on the installation
of each feature such as verbosity, error tolerance, skipping already installed features,
autorun programs at system start, add automatically a program to dashboard or associate keybindings 
for a command.


## Configuration
To install this software you must begin cloning this repository to you computer. You can either
download a `.zip`
file containing the repository from github clicking [here](https://github.com/AleixMT/Linux-Auto-Customizer/archive/master.zip).
Decompress the file and open a terminal in that directory.

You can also clone the repository using directly terminal. To do the last option, you must have installed 
`git`. If you don't have it, you can install it if you have `sudo` access by opening a terminal and typing the 
following:
```
sudo apt install git
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
Now that the current directory is the repository we can call the main scripts directly without specifying an absolute 
path. This will be the expected situation in the following explanations.

You can also install the customizer by using:
```
sudo bash install.sh customizer
```
This will give you the global command `customizer-install` that you can use anywhere in your system to access the 
features in `install.sh`. This command has autocompletion features.


## Usage
The scripts `install.sh` and `uninstall.sh` have the same identical arguments, but behave in 
the opposite way: 
`install.sh` will install the features selected by the arguments while `uninstall.sh` will
uninstall them, using the same identical arguments. They also share their vast majority of behavioural arguments, 
used to modify the way in which one or more features are installed.

See [`FEATURES.md`](https://github.com/AleixMT/Linux-Auto-Customizer/blob/master/FEATURES.md) to see a full list of all
the already pre-coded features in customizer ready to install / uninstall. You can also issue the command to show the 
full help, which contains a table with all the available arguments and its corresponding features.
``` 
bash install.sh -H
```


#### Feature arguments
You can install or uninstall features easily by passing the feature keynames by argument:
```
bash install.sh discord
bash uninstall.sh discord
```
You can install or uninstall multiple features at once:
```
bash install.sh pycharm intellij wallpapers
bash uninstall.sh pycharm intellij wallpapers
```
You will need to use `sudo` to install or uninstall some features, since elevated privileges are required:
```
sudo bash install.sh skype steam parallel lolcat dia
sudo bash uninstall.sh skype steam parallel lolcat dia
```
Features that do not require elevated privileges can also be installed or uninstalled with elevated privileges:
``` 
bash install.sh pycharmpro intellijultimate
bash uninstall.sh pycharmpro intellijultimate
```


#### Wrapper arguments (for selecting multiple features)
There are some special arguments called wrappers that select the installation / uninstallation of a set of features:
```
bash install.sh gitbashfunctions bashfunctions
bash uninstall.sh gitbashfunctions bashfunctions
```
This is equivalent to:
``` 
bash install.sh pull push dummycommit commit checkout clone branch status add hard fetch a b c e f h j k L l o q s u x
bash uninstall.sh pull push dummycommit commit checkout clone branch status add hard fetch a b c e f h j k L l o q s u x
```


#### Behavioural arguments
You can use different arguments to change the way in which each installation behaves, including verbosity, error 
tolerance, checking if the installation is already present.

###### Verbosity
Installs Telegram showing all the output from the internal commands:
```
bash install.sh -v telegram
```
Installs firefox and gpaint without showing any output.
```
sudo bash install.sh -q firefox gpaint
```
Each behaviour is maintained until the end of the execution or until it is changed by another behavioural argument.
In this case the program cheese and the program dia are installed without showing any output, but spotify is on full 
verbose mode. 
```
sudo bash install.sh -q cheese dia -v spotify
```

#### Full installation / uninstallation
To install ALL the features available for the root user in the script you must type in a terminal:
```
sudo bash install.sh --root
```
To install ALL the features available for the normal user in the script you must type in a terminal:
```
bash install.sh --user
```
Summarizing: to install ALL the features available in the script you must type in a terminal:
```
sudo bash install.sh --root && bash install.sh --user  
```
This command will install all root features first while asking for elevated privileges,
and then it will install all the local user features. 

To uninstall ALL the features available for the root user in the script you must type in a terminal:
```
sudo bash uninstall.sh --root
```
To uninstall ALL the features available for the normal user in the script you must type in a terminal:
```
bash uninstall.sh --user
```
Summarizing: to uninstall ALL the features available in the script you must type in a terminal:
```
sudo bash uninstall.sh --root && bash uninstall.sh --user  
```
This command will uninstall all root features first while asking for elevated privileges,
and then it will uninstall all the local user features. 


## Capabilities
All features available follow a common behaviour:
* The permissions needed for the features to be installed are the minimum. As such, we have many installation 
  available even if you do not have `root` permissions on your machine. 
* All installations are completely unattended and do not require any extra prompt.
* Software and command-line utilities are intended to appear as a valid binary in your `PATH`, so you can directly 
  call the program as you would do with the commands `cp` or `ls`.
* Software with GUI creates its own launcher in the desktop and in the dashboard.
* Most of the software with GUI contains also a decorator `bash` function to call directly the program in the
  terminal without seeing any annoying output.
* Software that reads or recognizes files are configured to be the default application for their recognized file types. 
* The installation of a feature will be skipped if the current privileges does not match the needed privileges 
  for that feature.
* The code is written following the [Google Bash Style Guide](https://google.github.io/styleguide/shellguide.html) to standardize the code.


## Motivation 
If you are a developer that uses a lot of software (most of us do) this tool can save you a lot of time: Usually 
we need to set up new programming or production environments in Linux losing a lot of time installing 
manually all of our programs and personal customizations. With this software you just need to write your
scripts once, and they will be ready to install in any new machine forever.

There are many good reasons for which you would prefer to execute a software that installs the 
exact features that you want automatically, instead of saving environment scripts such as `.bashrc` or `.bash_aliases`
where you have all your customizations:
- Optimizing your time because you can install them in a batch without needing any posterior input. 
- Programs and functions ready to use by resolving automatically dependencies.
- Be able to select which features you desire, instead of having them all at once.
- Flexibility, since not all the features that we could desire can be activated using an environment script, or is 
  actually not desirable to execute some type of code in those scripts because our environment gets cluttered.
- Easy and clean uninstallation to avoid cluttering and disk space consumption.


## Credits
* Author & Maintainer: **Aleix Mariné** - [AleixMT](https://github.com/AleixMT) [aleix.marine@estudiants.urv.cat](aleix.marine@estudiants.urv.cat)
* Tester & Feature requester: **Axel Fernández** - [Axlfc](https://github.com/Axlfc) [axelfernandezcurros@gmail.com](axelfernandezcurros@gmail.com)


## Licensing
- You can use this software **for free**.
- You can not sell or redistribute this software.
- You may fork this software, but you have to maintain the same therms stated in this license and give credit to the original author(s).
- We do not take any responsibility of the usage of this software or any harm that could be derived from it.


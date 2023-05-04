<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Code quality][codacy-shield]][codacy-url]
[![Top language][language-shield]][language-url]
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![GNU GPL v3 License][license-shield]][license-url]
[![Lines of code][loc-shield]][loc-url]
[![Number of commits since v0.1][commit-shield]][commit-url]
[![Commit activity][activity-shield]][activity-url]
[![Last commit on][last-shield]][last-url]
[![But me a coffee][coffee-shield]][coffee-url]
[![number of stars][stars-shield]][stars-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/AleixMT/Linux-Auto-Customizer">
    <img src=".github/logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">Linux-Auto-Customizer</h3>

  <p align="center">
    The Linux-Auto-Customizer project is a bash framework to automate the installation and uninstallation of a batch of 
preset installations in a bash environment.
    <br />
    <a href="https://github.com/AleixMT/Linux-Auto-Customizer"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/AleixMT/Linux-Auto-Customizer">View Demo</a>
    ·
    <a href="https://github.com/AleixMT/Linux-Auto-Customizer/issues">Report Bug</a>
    ·
    <a href="https://github.com/AleixMT/Linux-Auto-Customizer/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
    <li><a href="#credits">Credits</a></li>
    <li><a href="#donations">Donations</a></li>
   </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://autocustomizer.github.io/)

Customizer is a software to automatize installations and customizations in a bash environment. It is purely written in
[`bash`](https://www.gnu.org/software/bash) and already contains more than 200 pre-coded automatic installations ready 
to be installed. 

These installations include programming languages, IDEs, text editors, media players, games, file templates, wallpapers, 
environmental aliases, environmental functions, terminal customizations...

Installations in the customizer are:
* **Cleaner**: Temporal files are taken care after the installation.
* **Faster**: Installations are automated, so you do not need to waste time searching, downloading or decompressing 
files.
* **Fancier**: Most installations include specific customizations. 
* **Completely unattended**: Installations never stop to require information while they are being installed.
* **Multi-platform**: If the machine has BASH running, the core functionalities of the project will work. 
* **Flexible**: Many behavioural arguments are available allowing extra flexibility on the installation
of each feature such as verbosity, error tolerance, re-installation of features...

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

Major frameworks/libraries used to build this project:

* [![GIT][git-shield]][git-url]
* [![Bash][bash-shield]][bash-url]
* [![Python][python-shield]][python-url]
* [![Free Desktop org][freedesktopdotorg-shield]][freedesktopdotorg-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple example steps.

### Prerequisites

1. Install `git`: 
   * In Ubuntu / Debian systems you can do so by issuing the command `sudo apt install -y git`.
   * In Fedora / Red Hat systems you can do so by issuing the command `sudo dnf install -y git`.
   * In Windows you can install `git` by downloading and executing [this](https://git-scm.com/download/win) file.
   * For other systems you will need to follow [this](https://git-scm.com/download/linux) instructions. 

2. Obtain the repository code:
   * Clone the repository. With this option you can easily update your installation. Issue the command: 
     ```shell
     git clone https://github.com/AleixMT/Linux-Auto-Customizer
     ```
   * Download a zip with the code from 
     [here](https://github.com/AleixMT/Linux-Auto-Customizer/archive/master.zip). Decompress it anywhere in your 
     computer. You can do so programmatically with these commands:
     ```shell
     wget https://github.com/AleixMT/Linux-Auto-Customizer/archive/master.zip
     unzip master.zip
     ```

### Installation

You can install the main scripts in order to use them globally in your system and obtain autocompletion features for 
them.

1. Get a terminal in the folder where you cloned or decompressed the repository.  
2. Use `sudo bash src/core/install.sh customizer` in order to install the `customizer-install` and 
   `customizer-uninstall` commands.


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

### Main scripts

There are two scripts that you can use:
* `./src/core/install.sh` to install installations.
* `./src/core/uninstall.sh` to uninstall installations.

But if you installed the `customizer` installation you will have available the commands `customizer-install` and 
`customizer-uninstall`, which are links to the scripts `./src/core/install.sh` and `./src/core/uninstall.sh`, 
respectively. These commands also have autocompletion features.

### Installing / uninstalling installations

The commands `customizer-install` and `customizer-uninstall` have the same identical arguments, but behave in 
the opposite way: 
* `customizer-install` will install the installations selected by the arguments.
* `customizer-uninstall` will uninstall the installations selected by the arguments.

For example, to install an installation we can issue the command:
```shell
customizer-install NAME_OF_THE_FEATURE
```

Equivalently, to uninstall an installation we can issue the command:
```shell
customizer-uninstall NAME_OF_THE_FEATURE
```

See [`FEATURES.md`](https://github.com/AleixMT/Linux-Auto-Customizer/blob/master/doc/FEATURES.md) to see a full list of 
all the already pre-coded installations. You can also issue this command to show the installations available:
```shell
customizer-install --commands
```

### Multiple installations at once
You can add many installations in one run. For example, to install the installation `pycharm` and the installation 
`sublime` you can use:
```shell
customizer-install pycharm changebg
```

### Installing / uninstalling with / without privileges

To install a single installation without privileges you can use:
```shell
customizer-install NAME_OF_THE_FEATURE
```

To install a single feature with privileges you can use:
```shell
sudo customizer-install NAME_OF_THE_FEATURE
```

* Some features need normal privileges, other features need special privileges and there are features where the 
  privileges do not matter (most of them). 
* We always recommend installing the features without privileges (without `sudo`). 
* If you need to add `sudo` to get special privileges, do not worry, the customizer will complain in order for you to 
  add it. 

### Behavioural arguments

There are arguments used to change the behaviour of the project when installing installations called *behavioural
arguments*. This change in behaviour includes 
verbosity, error tolerance, skipping already installed features and many others. The change in behaviour is conserved 
in a single execution, and is propagated to the installations following the behavioural argument. 

For example, the argument `-v` sets the verbosity level to maximum, `-q` sets it to default and `-Q` sets it to minimum 
(no output).

If you issue the command:
```shell
customizer-install -v java ideac -Q mvn
```

The installations `java` and `ideac` will be installed showing its full output, but the installation `mvn` will be 
installed with no output shown. 

Another interesting behavioural argument is `-o`. This argument forces the installation even if the installations are 
already installed. This argument is useful to update or reinstall installations, since the customizer refuses to do so 
without this flag.

You can also combine behavioural arguments and multiple features:
```shell
customizer-install changebg -v visual_studio -o clion -q android_studio 
```

The previous command will install the installation `changebg` with defaults, `visual_studio` with full verbose mode, 
`clion` with full verbose mode and in overwrite installation mode and finally `android_studio` will be installed in 
overwrite installation mode and with default verbose mode. 

_For more examples, please refer to the [Wiki](https://github.com/AleixMT/Linux-Auto-Customizer/wiki)_.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [x] Update documentations.
- [ ] Testing of installations.
- [ ] Build final endpoint `customizer`.
- [ ] Transform feature data into JSONs.

See the [open issues](https://github.com/AleixMT/Linux-Auto-Customizer/issues) for a full list of proposed features 
(and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any 
contributions you make are **greatly appreciated**. Take a look at 
[CONTRIBUTING.md](https://github.com/AleixMT/Linux-Auto-Customizer/blob/master/CONTRIBUTING.md) for a small guide on how
to present contributions.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also 
simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Do your changes in the project
4. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the Branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request [here](https://github.com/AleixMT/Linux-Auto-Customizer/pulls) 

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the GNU GPL v3 License. See `LICENSE` [here](https://github.com/AleixMT/Linux-Auto-Customizer/blob/master/LICENSE) for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Aleix Mariné-Tena - [@viejo_senil](https://twitter.com/viejo_senil) - [aleix.marine@estudiants.urv.cat](aleix.marine@estudiants.urv.cat)

Project Link - [https://github.com/AleixMT/Linux-Auto-Customizer](https://github.com/AleixMT/Linux-Auto-Customizer)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Resources that we used to make this project possible:

* [Choose an Open Source License](https://choosealicense.com)
* [GitHub Emoji Cheat Sheet](https://www.webpagefx.com/tools/emoji-cheat-sheet)
* [Img Shields](https://shields.io)
* [GitHub Pages](https://pages.github.com)
* [Font Awesome](https://fontawesome.com)
* [React Icons](https://react-icons.github.io/react-icons/search)
* [Google Bash Style Guide](https://google.github.io/styleguide/shellguide.html)
* [Script Server](https://github.com/bugy/script-server)


<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CREDITS -->
## Credits

###### Main developer
* **Aleix Mariné-Tena** - [AleixMT](https://github.com/AleixMT) [aleix.marine@estudiants.urv.cat](aleix.marine@estudiants.urv.cat)

###### Tester
*  **Axel Fernandez** - [Axlfc](https://github.com/Axlfc) [axelfernandezcurros@gmail.com](axelfernandezcurros@gmail.com)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Donations

Donations are greatly appreciated. If each person using the customizer donated 1 $ we could maintain the project 
actively.

You can make donations to the team through:

* [Buy me a coffee](https://www.buymeacoffee.com/VidWise):

<img src="https://user-images.githubusercontent.com/23342150/220342749-832faa51-9adb-459f-bee1-28e4aee3a90e.png" width="350" height="350"/>


* [Stripe](https://donate.stripe.com/28o15be6H8xlgyQ000)

<img src="https://user-images.githubusercontent.com/23342150/220337258-8dad1721-4dc1-4852-9a64-67705847fa6b.png" width="350" height="350"/>


* Cardano: addr1v92psazv75ycy3h9kmnpe55swx3f8y027ur42lnzvzaz5cqve45h4

<img src="https://user-images.githubusercontent.com/23342150/220339490-64a50d59-f7b1-46e9-b980-d095b4bc64c2.png" width="350" height="350"/>


* Ethereum: 0x23CD3287E100e485B85d8BAE1676ad9068F909a5

<img src="https://user-images.githubusercontent.com/23342150/220340085-6427cc3b-5111-4b2e-a4f7-e59116868398.png" width="350" height="350"/>


* Bitcoin: 342XF1x7wYU9R1VdKhVFAXsBvcYsUdemka

<img src="https://user-images.githubusercontent.com/23342150/220340345-2fd9854b-1669-44f6-a962-d2b0eb6dae04.png" width="350" height="350"/>

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/AleixMT/Linux-Auto-Customizer/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/AleixMT/Linux-Auto-Customizer/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/AleixMT/Linux-Auto-Customizer/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/AleixMT/Linux-Auto-Customizer/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/AleixMT/Linux-Auto-Customizer/blob/master/LICENSE.txt

[product-screenshot]: .github/screenshot.png

[git-shield]: https://img.shields.io/badge/git-2.25.1+-black?style=for-the-badge&logo=git
[git-url]: https://git.com
[bash-shield]: https://img.shields.io/badge/bash-4.0+-black?style=for-the-badge&logo=gnubash
[bash-url]: https://www.gnu.org/software/bash/
[python-shield]: https://img.shields.io/badge/python-3.7+-black?style=for-the-badge&logo=python
[python-url]: https://www.python.org/
[freedesktopdotorg-shield]: https://img.shields.io/badge/freedesktop.org-1.5+-black?style=for-the-badge&logo=freedesktopdotorg
[freedesktopdotorg-url]: https://specifications.freedesktop.org/desktop-entry-spec/latest/

[codacy-shield]: https://app.codacy.com/project/badge/Grade/9d77f6c73bab4a11b847d131146fc243
[codacy-url]: https://app.codacy.com/gh/AleixMT/Linux-Auto-Customizer/dashboard
[language-shield]: https://img.shields.io/github/languages/top/AleixMT/Linux-Auto-Customizer?style=for-the-badge&color=blue&logo=gnu
[language-url]: https://www.gnu.org/software/bash
[loc-shield]: https://img.shields.io/tokei/lines/github/AleixMT/Linux-Auto-Customizer?style=for-the-badge&logo=gitlab
[loc-url]: https://gitlab.com/AleixMT/Linux-Auto-Customizer
[commit-shield]: https://img.shields.io/github/commits-since/AleixMT/Linux-Auto-Customizer/v0.1.0?style=for-the-badge&logo=github
[commit-url]: https://github.com/AleixMT/Linux-Auto-Customizer/issues
[activity-shield]: https://img.shields.io/github/commit-activity/m/AleixMT/Linux-Auto-Customizer?style=for-the-badge&logo=linux
[activity-url]: https://github.com/AleixMT/Linux-Auto-Customizer/graphs/commit-activity
[last-shield]: https://img.shields.io/github/last-commit/AleixMT/Linux-Auto-Customizer?&style=for-the-badge&color=blue
[last-url]: https://github.com/AleixMT/Linux-Auto-Customizer/commits/master
[coffee-shield]: https://img.shields.io/badge/-buy_me_a%C2%A0coffee-gray?logo=buy-me-a-coffee&style=for-the-badge
[coffee-url]: https://www.buymeacoffee.com/VidWise
[stars-shield]: https://img.shields.io/github/stars/AleixMT/Linux-Auto-Customizer?style=for-the-badge
[stars-url]: https://github.com/AleixMT/Linux-Auto-Customizer/stargazers

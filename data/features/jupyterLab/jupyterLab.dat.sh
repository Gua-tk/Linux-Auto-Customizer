#!/usr/bin/env bash
jupyterLab_name="Jupyter Lab"
jupyterLab_description="High-level, high-performance dynamic language for technical computing"
jupyterLab_version="jupyter dependent"
jupyterLab_tags=("customDesktop")
jupyterLab_systemcategories=("IDE" "Development")

jupyterLab_bashfunctions=("silentFunction")
jupyterLab_binariesinstalledpaths=("bin/jupyter-lab;jupyter-lab" "bin/jupyter;jupyter" "bin/ipython;ipython" "bin/ipython3;ipython3")
jupyterLab_packagedependencies=("libkrb5-dev")
jupyterLab_flagsoverride=";;1;;;"  # Ignore Errors to check dependencies. This is a patch
jupyterLab_launcherkeynames="defaultLauncher"
jupyterLab_defaultLauncher_exec="jupyter-lab &"
jupyterLab_manualcontentavailable="1;1;0"
jupyterLab_pipinstallations=("jupyter jupyterlab jupyterlab-git jupyterlab_markup" "bash_kernel" "pykerberos pywinrm[kerberos]" "powershell_kernel" "iarm" "ansible-kernel" "kotlin-jupyter-kernel" "vim-kernel" "theme-darcula")
jupyterLab_pythoncommands=("bash_kernel.install" "iarm_kernel.install" "ansible_kernel.install" "vim_kernel.install")  # "powershell_kernel.install --powershell-command powershell"  "kotlin_kernel fix-kernelspec-location"

#!/usr/bin/env bash

scilab_name="Scilab"
scilab_description="Scientific software package for numerical computations"
scilab_version="System dependent"
scilab_tags=("customDesktop")
scilab_systemcategories=("Math" "Science")
scilab_bashfunctions=("scilab.sh")
scilab_binariesinstalledpaths=("bin/scilab;scilab" "bin/scilab-cli;scilab-cli" "bin/scinotes;scinotes")
scilab_associatedfiletypes=("application/x-scilab-sci" "application/x-scilab-sce" "application/x-scilab-tst" "application/x-scilab-dem" "application/x-scilab-sod" "application/x-scilab-xcos" "application/x-scilab-zcos" "application/x-scilab-bin" "application/x-scilab-cosf" "application/x-scilab-cos")
scilab_packagedependencies=("openjdk-8-jdk-headless" "libtinfo5")
scilab_downloadKeys=("bundle")
scilab_bundle_URL="https://www.scilab.org/download/6.1.0/scilab-6.1.0.bin.linux-x86_64.tar.gz"
scilab_packagenames=("scilab")
scilab_launcherkeynames=("defaultLauncher")
scilab_defaultLauncher_exec="bash "${CURRENT_INSTALLATION_FOLDER}/bin/scilab""

#!/usr/bin/env bash

ghrunner_name="GitHub self-hosted runner"
ghrunner_description="Program that configures a machine to run GitHub actions workflows"
ghrunner_version="linux-x64-2.314.1"
ghrunner_tags=("customServer")
ghrunner_systemcategories=("Office" "Qt" "TextEditor" "WordProcessor")

ghrunner_downloadKeys=("bundle")
ghrunner_bundle_doNotInherit="yes"
ghrunner_bundle_downloadPath="${BIN_FOLDER}/ghrunner/"
ghrunner_bundle_URL="https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz"
ghrunner_binariesinstalledpaths=("config.sh;gh-config" "run.sh;gh-run")
ghrunner_bashfunctions=("ghrunner.sh")

#!/usr/bin/env bash

DIR=$(dirname "$(realpath "$0")")
export CUSTOMIZER_PROJECT_FOLDER="$(cd "${DIR}/.." &>/dev/null && pwd)"

featureKeynamesWithLauncher="$(cat "${CUSTOMIZER_PROJECT_FOLDER}/data/core/feature_data.sh" | grep -Eo "[a-Z]+_launchernames" | cut -d '_' -f1 | tr $'\n' ' ' | cut -d ' ' -f2-)"

rm -Rf Linux-Auto-Customizer
git clone https://github.com/AleixMT/Linux-Auto-Customizer
cd Linux-Auto-Customizer

mkdir -p "oldLaunchers"
cd "oldLaunchers"

for keyName in ${featureKeynamesWithLauncher}; do
  sudo customizer-install -v -o "${keyName}"
  cp "${HOME}"/Desktop/"${keyName}"*.desktop .
done


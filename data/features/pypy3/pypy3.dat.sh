# Installs pypy3 dependencies, pypy3 and basic subsystems (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
install_pypy3_mid() {
  # Install subsystems using pip
  "${BIN_FOLDER}/pypy3/bin/pypy3" -m ensurepip

  # Forces download of pip and of subsystems
  "${BIN_FOLDER}/pypy3/bin/pip3.6" --no-cache-dir -q install --upgrade pip
  "${BIN_FOLDER}/pypy3/bin/pip3.6" --no-cache-dir install cython numpy
  # Currently not supported
  # ${BIN_FOLDER}/${pypy3_version}/bin/pip3.6 --no-cache-dir install matplotlib
}
# Installs pypy3 dependencies, pypy3 and basic subsystems (cython, numpy, matplotlib, biopython) using pip3 from pypy3.
uninstall_pypy3_mid() {
  :
}
pypy3_name="pypy3"
pypy3_description="Faster interpreter for the Python3 programming language"
pypy3_version="System dependent"
pypy3_tags=("python3")
pypy3_systemcategories=("Development")
pypy3_binariesinstalledpaths=("bin/pypy3;pypy3" "bin/pip3.6;pypy3-pip")
pypy3_downloadKeys=("bundle")
pypy3_bundle_URL="https://downloads.python.org/pypy/pypy3.6-v7.3.1-linux64.tar.bz2"
pypy3_manualcontentavailable="0;1;0"
pypy3_packagedependencies=("pkg-config" "libfreetype6-dev" "libpng-dev" "libffi-dev")

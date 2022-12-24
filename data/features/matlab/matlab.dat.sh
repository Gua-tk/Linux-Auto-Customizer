install_matlab_mid()
{
  "${TEMP_FOLDER}/matlab/install"  # Execute installer
  rm -Rf "${TEMP_FOLDER}/matlab"
}
uninstall_matlab_mid()
{
  :
}

matlab_name="Matlab R2021a"
matlab_description="IDE + programming language specialized in matrix operations"
matlab_version="R2021a"
matlab_tags=("matlab")
matlab_systemcategories=("Science")
matlab_downloadKeys=("bundle")
matlab_bundle_URL="https://es.mathworks.com/downloads/web_downloads"
matlab_bundle_downloadPath="${TEMP_FOLDER}"
matlab_binariesinstalledpaths=("bin/matlab;matlab" "bin/mex;mex")
matlab_launcherkeynames=("defaultLauncher")
matlab_defaultLauncher_exec="matlab -desktop"

matlab_defaultLauncher_name="MATLAB R2021a"
matlab_manualcontentavailable="0;1;0"
matlab_bashfunctions=("silentFunction")

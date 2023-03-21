#!/usr/bin/env bash
AutoFirma_name="AutoFirma"
AutoFirma_description="Electronic signature application"
AutoFirma_version="1.0"
AutoFirma_tags=("customDesktop")
AutoFirma_systemcategories=("GNOME" "Application" "Office")

AutoFirma_launcherkeynames=("default")
AutoFirma_default_exec="/usr/bin/AutoFirma %u"
AutoFirma_default_windowclass="autofirma"
AutoFirma_associatedfiletypes=("x-scheme-handler/afirma")
AutoFirma_bashfunctions=("silentFunction")
AutoFirma_downloadKeys=("bundle")
AutoFirma_bundle_URL="https://estaticos.redsara.es/comunes/autofirma/1/6/5/AutoFirma_Linux.zip"
AutoFirma_bundle_type="package"
AutoFirma_bundle_installedPackages=("AutoFirma")
AutoFirma_packagedependencies=("libnss3-tools")

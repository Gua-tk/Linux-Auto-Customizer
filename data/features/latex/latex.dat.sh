#!/usr/bin/env bash

latex_name="LaTeX"
latex_description="LaTeX Editor"
latex_version="1.0"
latex_tags=("editor" "language" "customDesktop")
latex_systemcategories=("Office" "Publishing" "Qt" "X-SuSE-Core-Office" "X-Mandriva-Office-Publishing" "X-Misc")
latex_launcherkeynames=("defaultLauncher" "documentationLauncher")
latex_documentationLauncher_exec="texdoctk"

latex_documentationLauncher_name="TeXdoctk"
latex_documentationLauncher_categories=("Settings")
latex_documentationLauncher_icon="latex_doc"
latex_defaultLauncher_exec="texmaker %F"
latex_defaultLauncher_notify="false"
latex_packagedependencies=("perl-tk" )
latex_packagenames=("texlive-latex-extra" "texmaker" "perl-tk")
latex_associatedfiletypes="text/x-tex"
latex_filekeys=("template")
latex_template_path="${XDG_TEMPLATES_DIR}"
latex_template_content="latex_document.tex"

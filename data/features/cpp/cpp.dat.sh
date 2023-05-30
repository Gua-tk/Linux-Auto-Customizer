#!/usr/bin/env bash

cpp_name="cpp"
cpp_description="Debugger and compiler for GNU systems for C (and C++)"
cpp_version="System dependent"
cpp_tags=("language" "customDesktop")
cpp_systemcategories=("Languages")

cpp_packagenames=("gdb" "g++")
cpp_filekeys=("template")
cpp_template_path="${XDG_TEMPLATES_DIR}"
cpp_template_content="cpp_script.cpp"

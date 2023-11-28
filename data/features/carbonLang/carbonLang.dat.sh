#!/usr/bin/env bash
carbonLang_name="Carbon Language"
carbonLang_description="Successor of C++"
carbonLang_version="System dependent"
carbonLang_tags=("")
carbonLang_systemcategories=("Languages")

carbonLang_bashfunctions=("carbonLang_function.sh")
carbonLang_gpgSignatures=("https://bazel.build/bazel-release.pub.gpg")
carbonLang_sources=("deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8")
carbonLang_dependencies=("apt-transport-https" "gnupg" "clang" "lldb" "lld" "openjdk-8-jdk" "llvm" "build-essential" "libc++-dev")
carbonLang_packagenames=("bazel")
carbonLang_bashinitializations=("carbonLang.sh")
carbonLang_repositoryurl="https://github.com/carbon-language/carbon-lang"
carbonLang_flagsoverride="0;;;;;"  # Install always as root

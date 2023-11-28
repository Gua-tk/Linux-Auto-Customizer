#!/usr/bin/env bash

export PATH="/usr/local/opt/llvm/bin:$PATH"
export LDFLAGS="-L /usr/local/opt/llvm/lib"
export CPPFLAGS="-I /usr/local/opt/llvm/include"
export CC=$(which clang)

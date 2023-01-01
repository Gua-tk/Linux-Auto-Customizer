#!/usr/bin/env bash

go_name="go language"
go_description="google programming language"
go_version="1.17.linux-amd64"
go_systemcategories=("Languages")
go_tags=("search")
go_downloadkeys=("bundle")
go_bundle_URL="https://golang.org/dl/go1.17.linux-amd64.tar.gz"
go_bundle_downloadPath="/usr/local"
go_flagsoverride="0;;;;;"  # Install always as root
go_bashinitializations=("go.sh")

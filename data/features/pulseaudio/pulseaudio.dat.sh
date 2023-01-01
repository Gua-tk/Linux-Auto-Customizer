#!/usr/bin/env bash

pulseaudio_name="Pulseaudio"
pulseaudio_description="PulseAudio is a cross-platform, network-capable sound server."
pulseaudio_version="1.0"
pulseaudio_tags=("audioServer" "audio")
pulseaudio_systemcategories=("System" "Audio")
pulseaudio_bashfunctions=("pulseaudio.sh")
pulseaudio_packagedependencies=("libpulse0" "pkgconfig" "intltool" "libtool" "libsndfile1-dev" "libjson-c-dev" "build-essential" "dbus-x11" "pulseaudio-module-jack" "")
pulseaudio_packagenames=("pulseaudio")

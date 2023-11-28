#!/usr/bin/env bash
clementine_name="Clementine"
clementine_description="Clementine Music Player"
clementine_version="System dependent"
clementine_tags=("customDesktop")
clementine_systemcategories=("Audio" "AudioVideo" "Music" "Player" "Qt")

clementine_bashfunctions=("silentFunction")
clementine_associatedfiletypes=("application/ogg" "application/x-ogg" "application/x-ogm-audio" "audio/aac" "audio/mp4" "audio/mpeg" "audio/mpegurl" "audio/ogg" "audio/vnd.rn-realaudio" "audio/vorbis" "audio/x-flac" "audio/x-mp3" "audio/x-mpeg" "audio/x-mpegurl" "audio/x-ms-wma" "audio/x-musepack" "audio/x-oggflac" "audio/x-pn-realaudio" "audio/x-scpls" "audio/x-speex" "audio/x-vorbis" "audio/x-vorbis+ogg" "audio/x-wav" "video/x-ms-asf" "x-content/audio-player" "x-scheme-handler/zune" "x-scheme-handler/itpc" "x-scheme-handler/itms" "x-scheme-handler/feed")
clementine_launcherkeynames=("defaultLauncher")
clementine_defaultLauncher_exec="clementine %U"
clementine_defaultLauncher_notify="false"
clementine_defaultLauncher_actions=("Play" "Pause" "Stop" "StopAfterCurrent" "Previous" "Next")
clementine_defaultLauncher_Play_name="Play"
clementine_defaultLauncher_Play_exec="clementine --play"
clementine_defaultLauncher_Pause_name="Pause"
clementine_defaultLauncher_Pause_exec="clementine --pause"
clementine_defaultLauncher_Stop_name="Stop"
clementine_defaultLauncher_Stop_exec="clementine --stop"
clementine_defaultLauncher_StopAfterCurrent_name="StopAfterCurrent"
clementine_defaultLauncher_StopAfterCurrent_exec="clementine --stop-after-current"
clementine_defaultLauncher_Previous_name="Previous"
clementine_defaultLauncher_Previous_exec="clementine --previous"
clementine_defaultLauncher_Next_name="Next"
clementine_defaultLauncher_Next_exec="clementine --next"
clementine_packagenames=("clementine")

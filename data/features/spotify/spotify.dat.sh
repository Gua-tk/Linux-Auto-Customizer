
spotify_name="Spotify"
spotify_description="Music streaming service"
spotify_version="1.1.72"
spotify_tags=("music" "stream")
spotify_systemcategories=("Music" "Audio")
spotify_bashfunctions=("silentFunction")
spotify_downloadKeys=("bundle")
spotify_bundle_URL="https://repository-origin.spotify.com/pool/non-free/s/spotify-client/spotify-client_1.1.72.439.gc253025e_amd64.deb"
spotify_package_manager_override="apt-get"
spotify_packagedependencies=("libgconf-2-4")
spotify_launcherkeynames=("launcher")
spotify_launcher_exec="spotify %U"
spotify_launcher_actionkeynames=("Playpause" "Next" "Previous" "Stop")

spotify_launcher_Playpause_name="⏯"
spotify_launcher_Playpause_exec="dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"

spotify_launcher_Next_name="⏭"
spotify_launcher_Next_exec="dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"

spotify_launcher_Previous_name="⏮"
spotify_launcher_Previous_exec="dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous"

spotify_launcher_Stop_name="⏹"
spotify_launcher_Stop_exec="dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop"

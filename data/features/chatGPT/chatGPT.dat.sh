chatGPT_name="chatGPT"
chatGPT_description="artificial intelligence chatbot"
chatGPT_version="3.5"
chatGPT_tags=("chat" "bot" "help" "nlp")
chatGPT_systemcategories=("Accessibility" "Network")
chatGPT_repositoryurl="https://github.com/Axlfc/UE5-Python"

chatGPT_packagedependencies=("python3" "git" "build-essential" "portaudio19-dev" "python3-venv")
chatGPT_pipinstallations=("openai" "python-dotenv" "transformers" "colorama" "git+https://github.com/openai/whisper.git" "jiwer" "gitpython" "gdown" "pathlib" "setuptools" "pyaudio" "soundfile" "pathlib" "numpy" "librosa" "SpeechRecognition" "langdetect" "googletrans==4.0.0-rc1")

# chat_bashfunctions=("silentFunction")
chatGPT_launcherkeynames=("default")
chatGPT_default_terminal="true"
# TODO: protect the exec command with if condition to check if .env file exists with the API key as functioning in chatGPT.sh
chatGPT_default_exec="gnome-terminal -- bash -c '${BIN_FOLDER}/chatGPT/bin/python3 ${BIN_FOLDER}/chatGPT/Content/Python/chatBot/conversate.py; exec bash'"
chatGPT_bashfunctions=("chatGPT.sh")

chatGPT_name="chatGPT"
chatGPT_description="artificial intelligence chatbot"
chatGPT_version="3.5"
chatGPT_tags=("chat" "bot" "help" "nlp")
chatGPT_systemcategories=("Accessibility" "Network")
chatGPT_repositoryurl="https://github.com/Axlfc/UE5-Python"

chatGPT_packagedependencies=("python3.10" "git" "build-essential" "portaudio19-dev" "python3-venv")
chatGPT_pipinstallations=("openai" "python-dotenv" "colorama" "git+https://github.com/openai/whisper.git" "jiwer" "gitpython" "gdown" "pathlib" "setuptools" "pyaudio" "soundfile" "pathlib" "numpy" "librosa" "SpeechRecognition" "langdetect" "googletrans==4.0.0-rc1" "python-magic")

# chat_bashfunctions=("silentFunction")
chatGPT_launcherkeynames=("default")
chatGPT_default_terminal="true"

chatGPT_default_exec="bash ${BIN_FOLDER}/chatGPT/chatgpt_exec.sh"
chatGPT_manualcontentavailable="0;1;0"
chatGPT_bashfunctions=("chatGPT.sh")
chatGPT_filekeys=("executionscript")
chatGPT_executionscript_path="chatgpt_exec.sh"
chatGPT_executionscript_content="chatgpt_exec.sh"
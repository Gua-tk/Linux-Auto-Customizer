chatGPT_name="chatGPT"
chatGPT_description="artificial intelligence chatbot"
chatGPT_version="3.5"
chatGPT_tags=("search")
chatGPT_systemcategories=("Accessibility" "Network")

chatGPT_packagedependencies=("python3.10" "python3-venv")
chatGPT_pipinstallations=("openai" "python-dotenv" "colorama")

chatGPT_launcherkeynames=("default")
chatGPT_default_terminal="true"

chatGPT_default_exec="bash ${BIN_FOLDER}/chatGPT/chatgpt_exec.sh"
chatGPT_manualcontentavailable="0;1;0"
chatGPT_bashfunctions=("chatGPT.sh")
chatGPT_filekeys=("executionscript" "bot" "conversate")
chatGPT_executionscript_path="chatgpt_exec.sh"
chatGPT_executionscript_content="chatgpt_exec.sh"
chatGPT_bot_path="bot.py"
chatGPT_bot_content="bot.py"
chatGPT_conversate_path="conversate.py"
chatGPT_conversate_content="conversate.py"
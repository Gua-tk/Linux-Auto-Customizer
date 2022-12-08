install_chatGPT_mid() {
  if [ ! -f "${BIN_FOLDER}/chatGPT/Content/Python/chatBot/conversations" ]; then
    mkdir "${BIN_FOLDER}/chatGPT/Content/Python/chatBot/conversations"
  fi
  ln -s "${BIN_FOLDER}/chatGPT/Content/Python/chatBot/conversations" "${XDG_DOCUMENTS_DIR}/chatGPT_conversations"
}

uninstall_chatGPT_mid() {
  :
}
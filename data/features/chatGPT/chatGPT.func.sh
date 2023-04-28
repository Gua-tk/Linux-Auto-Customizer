install_chatGPT_mid() {
  if [ ! -f "${BIN_FOLDER}/chatGPT/conversations" ]; then
    mkdir "${BIN_FOLDER}/chatGPT/conversations"
  fi
  ln -s "${BIN_FOLDER}/chatGPT/conversations" "${XDG_DOCUMENTS_DIR}/chatGPT_conversations"
}

uninstall_chatGPT_mid() {
  :
}
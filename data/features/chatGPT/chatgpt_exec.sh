#!/usr/bin/env bash
if [ ! -f "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot/.env" ]; then
  echo "You need to enter a valid API key in the file €{BIN_FOLDER}/chatGPT/.env"
  echo "Go to https://beta.openai.com/account/api-keys to get yours."
  echo "Edit or create the .env file and write inside the file:"
  echo "OPENAI_API_KEY=your_open_ai_api_key_code"
  read error_val
else
  "€{BIN_FOLDER}/chatGPT/bin/python3" "€{BIN_FOLDER}/chatGPT/conversate.py"
fi
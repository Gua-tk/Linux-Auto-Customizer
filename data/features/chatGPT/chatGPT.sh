#!/usr/bin/env bash


chatGPT()
{
  if [ ! -f "€{BIN_FOLDER}/chatGPT/.env" ]; then
    echo "You need to enter a valid API key in the file €{BIN_FOLDER}/chatGPT/.env"
    echo "Go to https://beta.openai.com/account/api-keys to get yours."
    echo "Edit or create the .env file and write inside the file:"
    echo "OPENAI_API_KEY=your_open_ai_api_key_code"
  else
    if [ ! "$1" ]; then
      (
      cd "€{BIN_FOLDER}/chatGPT"
      "€{BIN_FOLDER}/chatGPT/bin/python3" "€{BIN_FOLDER}/chatGPT/conversate.py"
      )
    else
      (
      cd "€{BIN_FOLDER}/chatGPT"
      "€{BIN_FOLDER}/chatGPT/bin/python3" "€{BIN_FOLDER}/chatGPT/conversate.py" "$1"
      )
    fi
  fi
}

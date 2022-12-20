#!/usr/bin/env bash


chatGPT()
{
  if [ ! -f "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot/.env" ]; then
    echo "You need to enter a valid API key in the file €{BIN_FOLDER}/chatGPT/Content/Python/chatBot/.env"
    echo "Go to https://beta.openai.com/account/api-keys to get yours."
    echo "Edit or create the .env file and write inside the file:"
    echo "OPENAI_API_KEY=your_open_ai_api_key_code"
  else
    if [ ! "$1" ]; then
      (
      cd "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot"
      "€{BIN_FOLDER}/chatGPT/bin/python3" "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot/conversate.py"
      )
    else
      (
      cd "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot"
      "€{BIN_FOLDER}/chatGPT/bin/python3" "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot/conversate.py" "$1"
      )
    fi
  fi
}

talkGPT()
{
  if [ ! -f "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot/.env" ]; then
    echo "You need to enter a valid API key in the file €{BIN_FOLDER}/chatGPT/Content/Python/chatBot/.env"
    echo "Go to https://beta.openai.com/account/api-keys to get yours."
    echo "Edit or create the .env file and write inside the file:"
    echo "OPENAI_API_KEY=your_open_ai_api_key_code"
  else
    if [ ! "$1" ]; then
      (
      cd "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot"
      "€{BIN_FOLDER}/chatGPT/bin/python3" "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot/talk.py"
      )
    else
      (
      cd "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot"
      "€{BIN_FOLDER}/chatGPT/bin/python3" "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot/talk.py" "$1"
      )
    fi
  fi
}

codeGPT()
{
  if [ ! -f "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot/.env" ]; then
    echo "You need to enter a valid API key in the file €{BIN_FOLDER}/chatGPT/Content/Python/chatBot/.env"
    echo "Go to https://beta.openai.com/account/api-keys to get yours."
    echo "Edit or create the .env file and write inside the file:"
    echo "OPENAI_API_KEY=your_open_ai_api_key_code"
  else
    "€{BIN_FOLDER}/chatGPT/bin/python3" "€{BIN_FOLDER}/chatGPT/Content/Python/chatBot/code.py" "$1"
  fi
}
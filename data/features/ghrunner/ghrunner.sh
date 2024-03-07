#!/usr/bin/env bash

gh-config()
{
  if [ $# != 4 ]; then
    echo "ERROR: gh-config expects 4 arguments: --url GITHUB_REPO_URL --token SECRET_TOKEN"
    exit 1
  fi

  gh-config "$@"
}

gh-run()
{
  nohup gh-run &>/dev/null &
}

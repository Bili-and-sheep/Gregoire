#!/bin/bash
# Auto commit & push when files change

# Change directory to repo
cd "$(dirname "$0")"

# Watch for file changes using inotifywait (Linux) or fswatch (Mac)
# Make sure inotify-tools or fswatch is installed
while true; do
  # Wait until any file in the repo changes
  inotifywait -r -e modify,create,delete . >/dev/null 2>&1
  git add .
  git commit -m "Auto commit on $(date '+%Y-%m-%d %H:%M:%S')"
  git push origin main
done


#!/usr/bin/env bash
# Stages everything, commits, and pushes to the current branch's remote.
# Usage: ./update.sh ["commit message"]   (default message: "update")
set -euo pipefail
cd "$(dirname "$0")"

git add .
if git diff --cached --quiet; then
  echo "Nothing new to commit."
else
  git commit -m "${1:-update}"
fi
git push

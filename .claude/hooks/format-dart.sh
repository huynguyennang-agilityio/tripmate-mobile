#!/usr/bin/env bash
# PostToolUse hook: format the .dart file Claude just wrote or edited.
# Reads the hook's JSON on stdin; does nothing for any other file.
set -euo pipefail

file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
case "$file" in
  *.dart) ;;
  *) exit 0 ;;
esac
[ -f "$file" ] || exit 0
command -v dart >/dev/null || exit 0

dart format "$file" >/dev/null

#!/bin/sh

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  IFS='
'
  if command -v batcat > /dev/null 2>&1; then
    files=$(fzf --query="$1" --multi --select-1 --exit-0 --preview "batcat --theme Dracula --color=always {}")
  elif command -v bat > /dev/null 2>&1; then
    files=$(fzf --query="$1" --multi --select-1 --exit-0 --preview "bat --theme Dracula --color=always {}")
  else
    files=$(fzf --query="$1" --multi --select-1 --exit-0)
  fi
  [ -n "$files" ] && ${EDITOR} "${files}"
}

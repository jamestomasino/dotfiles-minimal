#!/bin/sh

# Leverage SGPT to produce intelligent and context-sensitive git commit messages
# - Runs only on staged content
# - Aborts if there is no diff content
gsum() {
  diff="$(git --no-pager diff --cached)"
  if [ -n "$diff" ]; then
    query="Generate a descriptive git commit message based on the following code changes: \n\n${diff}"
    commit_message="$(sgpt "${query}")"
    printf "%s\n" "$commit_message"
    read -rp "Do you want to commit your changes with this commit message? [y/N] " response
    if [[ $response =~ ^[Yy]$ ]]; then
      git commit -m "$commit_message"
    else
      echo "Commit cancelled."
    fi
  fi
}

## git summarize ##
# Leverage SGPT to produce intelligent and context-sensitive git commit messages.
# By providing one argument, you can define the type of semantic commit (e.g. feat, fix, chore).
# When supplying two arguments, the second parameter allows you to include more details for a more explicit prompt.
gsum() {
  query="Generate git commit message using semantic versioning. My changes: $(git --no-pager diff --cached)"
  commit_message="$(sgpt txt "$query")"
  printf "%s\n" "$commit_message"
  read -rp "Do you want to commit your changes with this commit message? [y/N] " response
  if [[ $response =~ ^[Yy]$ ]]; then
    git add . && git commit -m "$commit_message"
  else
    echo "Commit cancelled."
  fi
}

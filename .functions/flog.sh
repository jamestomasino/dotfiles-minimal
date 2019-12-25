#!/bin/sh

# fshow - git commit browser (enter for show, ctrl-d for diff, ` toggles sort)
flog() {
  while out=$(
    git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --multi --no-sort --reverse --query="$q" \
      --print-query --expect=ctrl-d --toggle-sort=\`); do
    q=$(echo "$out" | head -1)
    k=$(echo "$out" | head -2 | tail -1)
    shas=$(echo "$out" | sed '1,2d;s/^[^a-z0-9]*//;/^$/d' | awk '{print $1}')
    [ -z "$shas" ] && continue
    if [ "$k" = ctrl-d ]; then
      git diff --color=always "$shas" | less -R
    else
      for sha in $shas; do
        git show --color=always "$sha" | less -R
      done
    fi
  done
}

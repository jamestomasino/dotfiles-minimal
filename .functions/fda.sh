#!/bin/sh
fda() {
  dir=$(find "${1:-.}" -type d 2> /dev/null | fzf +m) && cd "$dir" || return
}

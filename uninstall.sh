#!/usr/bin/env bash

shopt -s dotglob

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

tryfiles () {
  local path="$1"
  if [ -d "${HOME}/${path}" ]; then
    cd "${DIR}/${path}"
    for f in *; do
      local newpath="${path}/${f}"
      if [ -d "${HOME}/${newpath}" ]; then
        tryfiles "${newpath}"
      else
        if [ -L "${HOME}/${newpath}" ]; then
          unlink "${HOME}/${newpath}"
          printf "Removing: %s\\n" "${HOME}/${newpath}"
        fi
      fi
    done
    cd ..
  else
    if [ -L "${HOME}/${path}" ]; then
      unlink "${HOME}/${path}"
      printf "Removing: %s\\n" "${HOME}/${path}"
    fi
  fi
}

for x in *; do
  if [ "$x" != ".git" ] && [ "$x" != "." ] && [ "$x" != ".." ] && [ "$x" != "install.sh" ]&& [ "$x" != "uninstall.sh" ] && [ "$x" != "README.md" ]; then
    tryfiles "$x"
  fi
done

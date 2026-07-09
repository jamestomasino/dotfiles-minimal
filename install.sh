#!/usr/bin/env bash

# allow globs to see dotfiles
shopt -s dotglob

# get reference to script directory as starting point
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# suppress echos from pushd and popd for clean output
pushd () {
  command pushd "$@" > /dev/null
}

popd () {
  command popd "$@" > /dev/null
}

# parse flags
DESKTOP=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --desktop) DESKTOP=true; shift ;;
    *) shift ;;
  esac
done

# list of desktop-only top-level entries (local machines only)
DESKTOP_ONLY="kitty imwheel"

# recursive loop over files, creating mirrored directories and linking
# only files. Avoids accidentally adding new files to dotfiles repo
# if they are created and inserted into a symlinked directory later
tryfiles () {
  local path="$1"
  if [ -d "${DIR}/${path}" ]; then
    pushd "${DIR}/${path}" || return
    mkdir -p "${HOME}/${path}"
    for f in *; do
      local newpath="${path}/${f}"
      tryfiles "${newpath}"
    done
    popd || return
  else
    if [ -e "${HOME}/${path}" ]; then
      printf "File Exists, Skipping: %s\\n" "${HOME}/${path}"
    else
      ln -sfn "${DIR}/${path}" "$HOME/${path}"
      printf "Linking: %s/%s\\n" "${DIR}" "${path}"
    fi
  fi
}

# main loop, ignoring some key files
for x in *; do
  # skip internal / meta files
  if [ "$x" = ".git" ] || [ "$x" = ".gitignore" ] || [ "$x" = "." ] || [ "$x" = ".." ] ||
     [ "$x" = "install.sh" ] || [ "$x" = "uninstall.sh" ] || [ "$x" = "README.md" ] || [ "$x" = "PLAN.md" ]; then
    continue
  fi

  # skip desktop-only entries unless --desktop was passed
  if ! $DESKTOP; then
    for d in $DESKTOP_ONLY; do
      if [ "$x" = "$d" ]; then
        printf "Skipping (desktop-only): %s\\n" "$x"
        continue 2
      fi
    done
  fi

  tryfiles "$x"
done

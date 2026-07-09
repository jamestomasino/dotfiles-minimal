#!/usr/bin/env bash

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

tryfiles () {
  local path="$1"
  if [ -d "${DIR}/${path}" ]; then
    pushd "${DIR}/${path}" || return
    for f in *; do
      local newpath="${path}/${f}"
      tryfiles "${newpath}"
    done
    popd || return
    if [ -z "$(ls -A "${HOME}/${path}")" ]; then
      rmdir "${HOME}/${path}"
      printf "Removing empty directory: %s\\n" "${HOME}/${path}"
    fi
  else
    if [ -L "${HOME}/${path}" ]; then
      unlink "${HOME}/${path}"
      printf "Removing: %s\\n" "${HOME}/${path}"
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

#!/usr/bin/env bash

shopt -s dotglob

# get reference to script directory as starting point
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# suppress echos from pushd and popd for clean output
pushd () {
  command pushd "$@" > /dev/null
}

popd () {
  command popd > /dev/null
}

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

for x in *; do
  if [ "$x" != ".git" ] && [ "$x" != "." ] && [ "$x" != ".." ] && [ "$x" != "install.sh" ]&& [ "$x" != "uninstall.sh" ] && [ "$x" != "README.md" ]; then
    tryfiles "$x"
  fi
done

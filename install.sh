#!/usr/bin/env bash

shopt -s dotglob

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

tryfiles () {
  local path="$1"
  if [ -d "${HOME}/${path}" ]; then
    cd "${DIR}/${path}"
    mkdir -p "${HOME}/${path}"
    for f in *; do
      local newpath="${path}/${f}"
      if [ -d "${DIR}/${newpath}" ]; then
        tryfiles "${newpath}"
      else
        if [ -e "${HOME}/${newpath}" ]; then
          printf "File Exists, Skipping: %s\\n" "${HOME}/${newpath}"
        else
          ln -sfn "${DIR}/${newpath}" "${HOME}/${newpath}"
          printf "Linking: %s/%s\\n" "${DIR}" "${newpath}"
        fi
      fi
    done
    cd ..
  else
    if [ -e "${HOME}/${path}" ]; then
      printf "File Exists, Skipping: %s\\n" "${HOME}/${path}"
    else
      ln -sfn "${DIR}/${path}" "$HOME/${path}"
      printf "Linking: %s/%s\\n" "${DIR}" "${path}"
    fi
  fi
}

for x in *; do
  if [ "$x" != ".git" ] && [ "$x" != "." ] && [ "$x" != ".." ] && [ "$x" != "install.sh" ]&& [ "$x" != "uninstall.sh" ] && [ "$x" != "README.md" ]; then
    tryfiles "$x"
  fi
done

if [ ! -e "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
  curl -sfLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

if [ ! -e "$HOME/.local/share/vim/autoload/plug.vim" ]; then
  curl -sfLo "$HOME/.local/share/vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

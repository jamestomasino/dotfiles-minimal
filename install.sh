#!/usr/bin/env bash

shopt -s dotglob

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

for x in *; do
  if [ "$x" != ".git" ] && [ "$x" != "." ] && [ "$x" != ".." ] && [ "$x" != "install.sh" ]&& [ "$x" != "uninstall.sh" ] && [ "$x" != "README.md" ]; then
    if [ -d "$x" ]; then
      cd "$x"
      mkdir -p "$HOME/$x"
      for y in *; do
        if [ -d "${DIR}/$x/$y" ]; then
          cd "$y"
          mkdir -p "$HOME/$x/$y"
          for z in *; do
            if [ -e "$HOME/$x/$y/$z" ]; then
              printf "File Exists, Skipping: %s\\n" "$HOME/$x/$y/$z"
            else
              ln -sfn "${DIR}/$x/$y/$z" "$HOME/$x/$y/$z"
              printf "Linking: %s/%s/%s/%s\\n" "${DIR}" "$x" "$y" "$z"
            fi
          done
          cd ..
        else
          if [ -e "$HOME/$x/$y" ]; then
            printf "File Exists, Skipping: %s\\n" "$HOME/$x/$y"
          else
            ln -sfn "${DIR}/$x/$y" "$HOME/$x/$y"
            printf "Linking: %s/%s/%s\\n" "${DIR}" "$x" "$y"
          fi
        fi
      done
      cd ..
    else
      if [ -e "$HOME/$x" ]; then
        printf "File Exists, Skipping: %s\\n" "$HOME/$x"
      else
        ln -sfn "${DIR}/$x" "$HOME/$x"
        printf "Linking: %s/%s\\n" "${DIR}" "$x"
      fi
    fi
  fi
done

if [ ! -e "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
  curl -sfLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

if [ ! -e "$HOME/.local/share/vim/autoload/plug.vim" ]; then
  curl -sfLo "$HOME/.local/share/vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

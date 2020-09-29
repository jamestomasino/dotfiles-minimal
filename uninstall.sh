#!/usr/bin/env bash

shopt -s dotglob

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

for x in *; do
  if [ "$x" != ".git" ] && [ "$x" != "." ] && [ "$x" != ".." ] && [ "$x" != "install.sh" ]&& [ "$x" != "uninstall.sh" ] && [ "$x" != "README.md" ]; then
    if [ -d "$x" ]; then
      cd "$x"
      for y in *; do
        if [ -d "${DIR}/$x/$y" ]; then
          cd "$y"
          for z in *; do
            if [ -L "$HOME/$x/$y/$z" ]; then
              unlink "$HOME/$x/$y/$z"
              printf "Removing: %s\\n" "$HOME/$x/$y/$z"
            fi
          done
          cd ..
        else
          if [ -L "$HOME/$x/$y" ]; then
            unlink "$HOME/$x/$y"
            printf "Removing: %s\\n" "$HOME/$x/$y"
          fi
        fi
      done
      cd ..
    else
      if [ -L "$HOME/$x" ]; then
        unlink "$HOME/$x"
        printf "Removing: %s\\n" "$HOME/$x"
      fi
    fi
  fi
done

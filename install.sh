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

function silentSsh {
    local connectionString="$1"
    local commands="$2"
    if [ -z "$commands" ]; then
        commands=`cat`
    fi
    ssh -T $connectionString "$commands"
}

if [ "$1" = "push" ]; then
  if [ -n "$2" ]; then
    rsync -rvhe ssh --progress "${DIR}/" --exclude 'README.md' --exclude 'install.sh' --exclude 'uninstall.sh' --exclude '.git' "$2":~
    silentSsh $2 <<'EOC'
    curl -sfLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    curl -sfLo "$HOME/.config/vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    mkdir -p "$HOME/.cache"
    mkdir -p "$HOME"/.local/share/vim/{undo,swap,backup}
EOC
  else
    printf "push requires a destination: './install push someserver.com'\\n"
  fi
else
  for x in *; do
    if [ "$x" != ".git" ] && [ "$x" != "." ] && [ "$x" != ".." ] && [ "$x" != "install.sh" ]&& [ "$x" != "uninstall.sh" ] && [ "$x" != "README.md" ]; then
      tryfiles "$x"
    fi
  done

  if [ ! -e "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    curl -sfLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi

  if [ ! -e "$HOME/.config/vim/autoload/plug.vim" ]; then
    curl -sfLo "$HOME/.config/vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
fi

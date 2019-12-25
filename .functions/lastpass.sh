#!/bin/sh
lastpass() {
  if command -v lpass > /dev/null; then
    while ! lpass status -q; do
      if [ -z "${LASTPASS_USER}" ]; then
        printf "Lastpass Username: "
        read -r lpass_user
        lpass login --trust "${lpass_user}"
      else
        lpass login --trust "${LASTPASS_USER}"
      fi
    done
    if command -v fzf > /dev/null; then
      lpass show -c --password "$(lpass ls | fzf | awk '{print $(NF)}' | sed 's/\]//g')"
    else
      lpass show -c --password "$(lpass $1)"
    fi
  fi
}

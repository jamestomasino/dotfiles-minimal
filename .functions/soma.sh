#!/bin/sh
soma() {
  if [ -z "$1" ]; then
    station="$(curl -s https://somafm.com/listen/ | \
      awk -F '[<>]' '/MP3:/ { print $4 }' | \
      awk -F '"' '{print $2}' | \
      tr -d \\/ | \
      sed 's|.pls$||' | \
      fzf \
      --multi \
      --select-1 \
      --exit-0)"
    mplayer -playlist "http://somafm.com/${station}.pls"
  else
    mplayer -playlist "http://somafm.com/${1}.pls"
  fi
}

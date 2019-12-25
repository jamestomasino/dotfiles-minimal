#!/bin/sh
soma() {
  if [ "$1" = "list" ]; then
    curl -s https://somafm.com/listen/ | awk -F '[<>]' '/MP3:/ { print $4 }' | awk -F '"' '{print $2}' | tr -d \\/ | sed 's|.pls$||'
  else
    mplayer -playlist "http://somafm.com/${1}.pls"
  fi
}

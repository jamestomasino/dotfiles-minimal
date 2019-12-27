#!/bin/sh
soma() {
  if [ -z "$1" ]; then
    tempfile="${XDG_CACHE_HOME}/soma-stations.txt" || return
    if test "$(find "$tempfile" -mmin +$((60*24)) 2> /dev/null)"; then
      rm "$tempfile"
    fi

    if [ ! -f "$tempfile" ]; then
      curl -s https://somafm.com/listen/ | awk -F '[<>]' '/MP3:/ { print $4 }' | awk -F '"' '{print $2}' | tr -d \\/ | sed 's|.pls$||' > "$tempfile"
    fi

    station="$(fzf \
      --multi \
      --select-1 \
      --exit-0 < "$tempfile")"
    if [ -n "$station" ]; then
      mplayer -playlist "http://somafm.com/${station}.pls"
    fi
  else
    mplayer -playlist "http://somafm.com/${1}.pls"
  fi
}

#!/bin/sh

# This function handles the directory tracking for z.sh
_cd_track() {
  # Don't track the home folder
  p=$(pwd -P 2>/dev/null)
  [ "$p" = "$HOME" ] && return

  datafile="$XDG_CACHE_HOME/z.dat"
  random=$(hexdump -n 2 -e '/2 "%u"' /dev/urandom)
  tempfile="$datafile.$random"

  while read -r line; do
    [ -d "${line%%\|*}" ] && echo "$line"
  done < "$datafile" | awk -v path="$p" -v now="$(date +%s)" -F"|" '
    BEGIN {
        rank[path] = 1
        time[path] = now
    }
    $2 >= 1 {
        # drop ranks below 1
        if( $1 == path ) {
            rank[$1] = $2 + 1
            time[$1] = now
        } else {
            rank[$1] = $2
            time[$1] = $3
        }
        count += $2
    }
    END {
        if( count > 6000 ) {
            # aging
            for( x in rank ) print x "|" 0.99*rank[x] "|" time[x]
        } else for( x in rank ) print x "|" rank[x] "|" time[x]
    }
  ' 2>/dev/null >| "$tempfile"
  # do our best to avoid clobbering the datafile in a race condition
  if [ $? -ne 0 -a -f "$datafile" ]; then
      env rm -f "$tempfile"
  else
      env mv -f "$tempfile" "$datafile" || env rm -f "$tempfile"
  fi
}

# Everything below is necessary to override 'cd' builtin successfully in dash
_cd() {
  \cd "$@" || return
  _cd_track
}
alias cd="_cd"
if hash complete 2>/dev/null; then
  complete -d cd
fi

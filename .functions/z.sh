[ -d "$XDG_CACHE_HOME/z.dat" ] && {
    echo "ERROR: z.sh's datafile ($XDG_CACHE_HOME/z.dat}) is a directory."
}

substr() {
  index="$1"
  len="$2"
  shift
  shift
  if [ "$len" = "-1" ]; then
    printf "%s" "$@" | awk -v i="$index" '{print substr($0, i);}'
  else
    printf "%s" "$@" | awk -v i="$index" -v l="$len" '{print substr($0, i, l);}'
  fi
}

_z() {
    local datafile="$XDG_CACHE_HOME/z.dat"

    # bail if we don't own ~/.z (we're another user but our ENV is still set)
    [ -f "$datafile" ] && [ ! -O "$datafile" ] && return

      # list/go
      while [ "$1" ]; do 
        case "$1" in
          --) 
            while [ "$1" ]; do
              shift
              local fnd="$fnd${fnd:+ }$1"
            done
            ;;
          -*) local opt=${1:1};
              while [ "$opt" ]; do
                case "${opt:0:1}" in
                  c)
                    local fnd="^$PWD $fnd"
                    ;;
                  h) 
                    echo "${_Z_CMD:-z} [-chlrtx] args" >&2
                    return
                    ;;
                  x)
                    sed -i -e "\:^${PWD}|.*:d" "$datafile"
                    ;;
                  l) 
                    local list=1
                    ;;
                  r)
                    local typ="rank"
                    ;;
                  t) 
                    local typ="recent"
                    ;;
                esac
                opt=${opt:1}
              done
              ;;
           *) local fnd="$fnd${fnd:+ }$1";;
        esac
        local last=$1
        shift
      done

      ( [ -n "$fnd" ] && [ "$fnd" != "^$PWD " ] ) || local list=1

      # if we hit enter on a completion just go there
      case "$last" in
        # completions will always start with /
        /*)
          [ -z "$list" ] && [ -d "$last" ] && cd "$last" && return
          ;;
      esac

      # no file yet
      [ -f "$datafile" ] || return

      local cd
      cd="$(while read -r line; do
          [ -d "${line%%\|*}" ] && echo "$line"
      done < "$datafile" | awk -v t="$(date +%s)" -v list="$list" -v typ="$typ" -v q="$fnd" -F"|" '
          function frecent(rank, time) {
              # relate frequency and time
              dx = t - time
              if( dx < 3600 ) return rank * 4
              if( dx < 86400 ) return rank * 2
              if( dx < 604800 ) return rank / 2
              return rank / 4
          }
          function output(files, out, common) {
              # list or return the desired directory
              if( list ) {
                  cmd = "sort -n >&2"
                  for( x in files ) {
                      if( files[x] ) printf "%-10s %s\n", files[x], x | cmd
                  }
                  if( common ) {
                      printf "%-10s %s\n", "common:", common > "/dev/stderr"
                  }
              } else {
                  if( common ) out = common
                  print out
              }
          }
          function common(matches) {
              # find the common root of a list of matches, if it exists
              for( x in matches ) {
                  if( matches[x] && (!short || length(x) < length(short)) ) {
                      short = x
                  }
              }
              if( short == "/" ) return
              # use a copy to escape special characters, as we want to return
              # the original. yeah, this escaping is awful.
              clean_short = short
              gsub(/[\(\)\[\]\|]/, "\\\\&", clean_short)
              for( x in matches ) if( matches[x] && x !~ clean_short ) return
              return short
          }
          BEGIN { split(q, words, " "); hi_rank = ihi_rank = -9999999999 }
          {
              if( typ == "rank" ) {
                  rank = $2
              } else if( typ == "recent" ) {
                  rank = $3 - t
              } else rank = frecent($2, $3)
              matches[$1] = imatches[$1] = rank
              for( x in words ) {
                  if( $1 !~ words[x] ) delete matches[$1]
                  if( tolower($1) !~ tolower(words[x]) ) delete imatches[$1]
              }
              if( matches[$1] && matches[$1] > hi_rank ) {
                  best_match = $1
                  hi_rank = matches[$1]
              } else if( imatches[$1] && imatches[$1] > ihi_rank ) {
                  ibest_match = $1
                  ihi_rank = imatches[$1]
              }
          }
          END {
              # prefer case sensitive
              if( best_match ) {
                  output(matches, best_match, common(matches))
              } else if( ibest_match ) {
                  output(imatches, ibest_match, common(imatches))
              }
          }
      ')"
  [ $? -gt 0 ] && return
  [ "$cd" ] && cd "$cd" || return
}

z() {
  if command -v fzf > /dev/null; then
    if [ -z "$*" ]; then
      cd "$(_z -l 2>&1 | fzf +s --tac | sed 's/^[0-9,.]* *//')" || return
    else
      _z "$@"
    fi
  fi
}

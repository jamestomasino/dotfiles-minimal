#!/bin/sh

# This function handles the directory tracking for z.sh
_cd_track() {
  # Don't track the home folder
  p=$(pwd -P 2>/dev/null)
  [ "$p" = "$HOME" ] && return

  datafile="$XDG_CACHE_HOME/z.dat"
  random=$(hexdump -n 2 -e '/2 "%u"' /dev/urandom)
  tempfile="$datafile.$random"

  if [ ! -f "$datafile" ]; then
    mkdir -p "$(basename "$datafile")"
    touch "$datafile"
  fi

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

# This checks for .nvmrc and sets nvm if appropriate
_cdnvm() {
    nvm_path="$(nvm_find_up .nvmrc | command tr -d '\n')"

    # If there are no .nvmrc file, use the default nvm version
    if [[ ! $nvm_path = *[^[:space:]]* ]]; then

        declare default_version
        default_version="$(nvm version default)"

        # If there is no default version, set it to `node`
        # This will use the latest version on your machine
        if [ $default_version = 'N/A' ]; then
            nvm alias default node
            default_version=$(nvm version default)
        fi

        # If the current version is not the default version, set it to use the default version
        if [ "$(nvm current)" != "${default_version}" ]; then
            nvm use default
        fi
    elif [[ -s "${nvm_path}/.nvmrc" && -r "${nvm_path}/.nvmrc" ]]; then
        declare nvm_version
        nvm_version=$(<"${nvm_path}"/.nvmrc)

        declare locally_resolved_nvm_version
        # `nvm ls` will check all locally-available versions
        # If there are multiple matching versions, take the latest one
        # Remove the `->` and `*` characters and spaces
        # `locally_resolved_nvm_version` will be `N/A` if no local versions are found
        locally_resolved_nvm_version=$(nvm ls --no-colors "${nvm_version}" | command tail -1 | command tr -d '\->*' | command tr -d '[:space:]')

        # If it is not already installed, install it
        # `nvm install` will implicitly use the newly-installed version
        if [ "${locally_resolved_nvm_version}" = 'N/A' ]; then
            nvm install "${nvm_version}";
        elif [ "$(nvm current)" != "${locally_resolved_nvm_version}" ]; then
            nvm use "${nvm_version}";
        fi
    fi
}

# Everything below is necessary to override 'cd' builtin successfully in dash
_cd() {
  \cd "$@" || return
  _cd_track
  _cdnvm
}

alias cd="_cd"
if complete >/dev/null 2>&1; then
  complete -d cd
fi

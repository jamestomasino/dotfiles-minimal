#!/bin/sh

# Swap 2 filenames around, if they exist
swap() {
  TMPFILE=$(mktemp -t "swap.XXXXXXX")
  [ $# -ne 2 ] && printf "swap: 2 arguments needed\\n" && return 1
  [ ! -e "$1" ] && printf "swap: $1 does not exist\\n" && return 1
  [ ! -e "$2" ] && printf "swap: $2 does not exist\\n" && return 1
  mv "$1" $TMPFILE
  mv "$2" "$1"
  mv $TMPFILE "$2"
}

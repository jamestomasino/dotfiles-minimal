#!/bin/sh
imgsz() {
  if command -v identify >/dev/null 2>&1; then
    size=$(identify -format "%wx%h" "$1")
  else
    size=$(file "$1" | perl -pe 's/^.*, ?([0-9]+ ?x ?[0-9]+) ?,.*$/\1/p')
  fi
  printf "%s\\n" "$size"
}

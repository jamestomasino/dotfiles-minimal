#!/bin/bash

julian () {
  d=$(date +%s)
  todayJd=$( echo "x = $d; scale=5; x / 86400 + 2440587.5" | bc)
  printf "%s\n" "$todayJd"
}

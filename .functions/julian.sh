#!/bin/bash

julian () {
  d=$(date +%s)
  todayJd=$( echo "x = $d; x / 86400 + 2440587" | bc)
  timeJd="$(echo "x = ($d - 43200 ) % 86400; scale=5; x / 86400" | bc)"
  printf "%s%s\n" "$todayJd" "$timeJd"
}

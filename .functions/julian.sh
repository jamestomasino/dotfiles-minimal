#!/bin/bash

julian () {
  todayJd=$( echo "x = $(date +%s); x / 86400 + 2440587" | bc)
  timeJd="$(echo "x = ($(date +%s) - 43200 ) % 86400; scale=5; x / 86400" | bc)"
  printf "%s%s\n" "$todayJd" "$timeJd"
}

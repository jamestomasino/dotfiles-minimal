#!/bin/bash

function GetJulianDay # year, month, day
{
  year=$1
  month=$2
  day=$3
  jd=$((day - 32075 + 1461 * (year + 4800 - (14 - month) / 12) / 4 + 367 * (month - 2 + ((14 - month) / 12) * 12) / 12 - 3 * ((year + 4900 - (14 - month) / 12) / 100) / 4))
  printf "%s" "$jd"
}

function GetJulianTime
{
  mil="$(echo "x = ($(date +%s) - 43200 ) % 86400; scale=5; x / 86400" | bc)"
  printf "%s" "$mil"
}

function julian
{
  year=$(date +"%Y")
  month=$(date +"%m")
  day=$(date +"%d")

  todayJd=$(GetJulianDay "$year" "$month" "$day")
  timeJd=$(GetJulianTime)

  printf "%s%s\n" "$todayJd" "$timeJd"
}
function julianFormatted
{
  printf "%'.3f\n" "$(julian)"
}

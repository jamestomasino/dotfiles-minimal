#!/bin/sh

html=${1:-index.html}
to=${2:-${MAILGUN_TEST_TO}}
subject=${3:-Test Email}

curl -s --user "api:${MAILGUN_API}" \
https://api.eu.mailgun.net/v3/mg.tomasino.is/messages \
-F from="${MAILGUN_TEST_FROM}" \
-F to="${to}" \
-F subject="${subject}" \
-F html="<-" < "${html}"

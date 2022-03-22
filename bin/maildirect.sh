#!/bin/sh

if [ -z "${MAILGUN_API}" ]; then
    echo "Must provide MAILGUN_API in environment" 1>&2
    exit 1
fi

if [ -z "${MAILGUN_API_ENDPOINT}" ]; then
    echo "Must provide MAILGUN_API_ENDPOINT in environment" 1>&2
    exit 1
fi

to=${1:-${MAILGUN_TEST_TO}}

if [ -z "${to}" ]; then
    echo "Must provide email destination" 1>&2
    exit 1
fi

html=${2:-index.html}
subject=${3:-Test Email}

curl -s --user "api:${MAILGUN_API}" \
"${MAILGUN_API_ENDPOINT}" \
-F from="${MAILGUN_TEST_FROM}" \
-F to="${to}" \
-F subject="${subject}" \
-F html="<-" < "${html}"

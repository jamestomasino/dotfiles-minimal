#!/bin/sh

# source this to add the function, then call with 'rr'
rr() {
	RAND=$(hexdump -n 2 -e '/2 "%u"' /dev/urandom)
	CHAMBERS=${CHAMBERS:-6}
	if [ $(( RAND % CHAMBERS )) -eq 0 ]; then 
	  printf "BANG!\\n"
	  export CHAMBERS=6
	else 
	  printf "*Click*\\n"
	  export CHAMBERS=$(( CHAMBERS - 1))
	fi
}

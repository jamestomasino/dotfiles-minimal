#!/usr/bin/awk -f

BEGIN {
	FS = "\t"
	RS = "\n" # techincally \r\n, but servers mess this up
	OFS = " "
	ORS = "\n"
	links = ""
	linknum = 0
}

{
	gsub(/\r/,"") # handle trailing windows line endings from GOOD servers
	type=substr($1,1,1)
	label=substr($1,2)
	path=$2
	server=$3
	port=$4

	if ( type == "." ) {} # end of file, don't display
	else if ( type == "i" ) # label only
	{
		print label
	}
	else if ( type == "h") # html links
	{
		gsub(/^\[[0-9]+\][^\ ]+?\ /,"",label)
		printf("[%02d]", linknum)
		printf(" %s\n", label)
		url = substr(path, 5)
		links = links sprintf("[%02d] %s\n",linknum, url)
		linknum++
	}
	else if ( type == "T") # telnet links
	{
		gsub(/^\[[0-9]+\][^\ ]+?\ /,"",label)
		printf("[%02d]", linknum)
		printf(" %s\n", label)
		links = links sprintf("[%02d] telnet://%s/%s%s:%s\n",linknum, server, type, path, port)
		linknum++
	}
	else # any other gopher type
	{
		gsub(/^\[[0-9]+\][^\ ]+?\ /,"",label)
		printf("[%02d]", linknum)
		printf(" %s\n", label)
		links = links sprintf("[%02d] gopher://%s/%s%s:%s\n",linknum, server, type, path, port)
		linknum++
	}
}

END {
	if (links != "") {
		print "\nLinks:"
		print links
	}
}

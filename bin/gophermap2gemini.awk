#!/usr/bin/awk -f

BEGIN {
	FS = "\t"
	RS = "\n" # techincally \r\n, but servers mess this up
	OFS = " "
	ORS = "\n"
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
		gsub(/^\[[0-9]+\][^ ]+? /,"",label)
		url = substr(path, 5)
		printf("=> %s %s\n", url, label)
	}
	else if ( type == "T") # telnet links
	{
		gsub(/^\[[0-9]+\][^ ]+? /,"",label)
		printf("=> telnet://%s:%s/%s%s %s\n", server, port, type, path, label)
	}
	else # any other gopher type
	{
		gsub(/^\[[0-9]+\][^ ]+? /,"",label)
		printf("=> gopher://%s:%s/%s%s %s\n", server, port, type, path, label)
	}
}

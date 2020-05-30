#!/usr/bin/awk -f

BEGIN {
	FS = "\t"
	RS = "\n" # techincally \r\n, but servers mess this up
	OFS = " "
	ORS = "\n"
	isFenced = 0
}

{
	gsub(/\r/,"") # handle trailing windows line endings from GOOD servers
	type=substr($1,1,1)
	label=substr($1,2)
	path=$2
	server=$3
	port=$4
	gsub(/\ /,"%20", path)

	if ( type == "." ) {} # end of file, don't display
	else if ( type == "i" ) # label only
	{
		if (!(isFenced))  {
			print "```"
			isFenced=1
		}
		print label
	}
	else if ( type == "h") # html links
	{
		if (isFenced)  {
			print "```"
			isFenced=0
		}
		url = substr(path, 5)
		printf("=> %s %s\n", url, label)
	}
	else if ( type == "T") # telnet links
	{
		if (isFenced)  {
			print "```"
			isFenced=0
		}
		printf("=> telnet://%s:%s/%s%s %s\n", server, port, type, path, label)
	}
	else # any other gopher type
	{
		if (isFenced)  {
			print "```"
			isFenced=0
		}
		printf("=> gopher://%s:%s/%s%s %s\n", server, port, type, path, label)
	}
}

END {
	if (isFenced)  {
		print "```"
	}
}

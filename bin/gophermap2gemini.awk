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
	gsub(/\ /,"%20", path) # spaces in URLs work in gopher, but not gemini

	if ( type == "." ) {} # end of file, don't display
	else if ( type == "i" ) {
		# print label only
		if (label ~ /^#{1,3}[^#]/ ) {
			# In a heading, end fence
			if (isFenced)  {
				print "```"
				isFenced=0
			}
		} else if (label ~ /^\*[^\*]/) {
			# In a bullet list, end fence
			if (isFenced)  {
				print "```"
				isFenced=0
			}
		} else {
			# not in special line, fence it
			if (!(isFenced))  {
				print "```"
				isFenced=1
			}
		}
		print label
	} else if ( type == "h") {
		# html links
		if (isFenced)  {
			# end fences for links
			print "```"
			isFenced=0
		}
		url = substr(path, 5)
		printf("=> %s %s\n", url, label)
	} else if ( type == "T") {
		# telnet links
		if (isFenced)  {
			# end fences for links
			print "```"
			isFenced=0
		}
		printf("=> telnet://%s:%s/%s%s %s\n", server, port, type, path, label)
	} else {
		# any other gopher type
		if (isFenced)  {
			# end fences for links
			print "```"
			isFenced=0
		}
		printf("=> gopher://%s:%s/%s%s %s\n", server, port, type, path, label)
	}
}

END {
	if (isFenced)  {
		# properly end fences if we're in one
		print "```"
	}
}

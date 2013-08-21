import re

str = "field.txt"

if re.search( ".txt$", str ):
	print "File name matched\n"
else:
	print "File name doesn't match\n"

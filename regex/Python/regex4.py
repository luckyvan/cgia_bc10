import re

def rep( match ):
	name = match.group( 1 )
	if ( name == "name" ):
		return "Jack"
	if ( name == "cost" ):
		return "$20"
	return ""

print re.sub( "<(.*?)>", rep, "Dear <name>, You owe us <cost>." )

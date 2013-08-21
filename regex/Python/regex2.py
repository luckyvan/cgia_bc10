import re

myre = re.compile( "(.*?)=(.*?);" )

for item in myre.findall( "a=1;b=2;c=3;" ): 
		print item[0], ":", item[1]

str = "Dear <name>, You owe us <cost>"

str.gsub!( /<(.*?)>/ ) { 

  if ( $1 == "name" )
	"jack"
  elsif ( $1 == "cost" )
	"$20"
  else
	""
  end

}

print "#{str}\n"

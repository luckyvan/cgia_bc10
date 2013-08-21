name = 'Jack'
cost = '$20'

template = 'Dear <%= name %>, You owe us <%= cost %>'

output = template
output.gsub!( /<%=\s*(.*?)\s*%>/ ) {
  eval( $1 )
}

print "#{output}\n"

name = 'Jack'
cost = '$20'

template = 'Dear <name>, You owe us <cost>'

output = template
output.gsub!( /<(.*?)>/ ) {
  eval( $1 )
}

print "#{output}\n"

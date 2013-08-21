print "#{ARGV[0]}(1) : munged\n";

text = ""
File.open( ARGV[0] ) { |fh|
  text = fh.read
}

File.open( ARGV[0], "w" ) { |fh|
  fh.print "Hi there!\n"
  fh.print text
}


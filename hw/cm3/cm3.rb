# File: cm3.rb
# Purpose: Simple code munger example.  Creates HTML versions of all of the
# files specified on the comment line.
# Date: 01/06/02

unless ARGV[0]
  print "cm3 usage: cm3 files ...\n"
  exit
end

ARGV.each { |file|

  # Read in the file

  text = File.open( file ).read()

  # Turn special characters into entities

  text.gsub!( /\&/, "&amp;" )
  text.gsub!( /\</, "&lt;" )
  text.gsub!( /\>/, "&gt;" )

  # Make sure whitespace is preserved
  
  text.gsub!( / /, "&nbsp;" )
  text.gsub!( /\t/, "&nbsp;&nbsp;&nbsp;" )

  # Add <br> on the new-lines
  
  text.gsub!( /\n/m, "<br>\n" )

  # Create the new file name and open it

  html_file_name = "#{file}.html"
  print "Creating #{html_file_name}\n"
  File.open( html_file_name, "w" ) { |fh|

	# Write out the text with HTML preamble and postamble
	
	fh.print "<html>\n<head>\n<title>#{file}</title>\n</head>\n"
	fh.print "<body>\n<font face=\"Courier\">\n"

  	fh.print text

	fh.print "</font>\n</body>\n</html>\n"

  }

}

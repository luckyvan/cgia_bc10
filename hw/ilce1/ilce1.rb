# File: ilce1.rb
# Purpose: Inline code expander example.
# Date: 01/06/02

# Check the arguments

unless ARGV[0]
  print "ilce1 usage: ilce1 file.cx\n"
  exit
end

# Read the file

fh = File.open( ARGV[0] )
text = fh.read()
fh.close

# Turn <text> into print statements

text.gsub!( /<(.*?)>/ ) { "printf(\"#{$1}\");" }

# Create the new file name

new_file_name = ARGV[0]
new_file_name.gsub!( /[.]cx$/, ".c" )

# Create the new file

print "Creating #{new_file_name}\n"
File.open( new_file_name, "w" ).write( text )

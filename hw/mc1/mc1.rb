# File: mc1.rb
# Purpose: Mixed code generation example. This code reads comments from a C
# file, creates some code within the C file to build the strings in the
# comments and then replaces the original file. 
# Date: 01/06/02

# Bring in ftools to get File.copy

require "ftools"

# Check the arguments

unless ARGV[0]
  print "mc1 usage: mc1 file.c\n"
  exit
end

# Read the file

fh = File.open( ARGV[0] )
text = fh.read()
fh.close

# Add in the new code

text.gsub!( /(\/\/\s*print\s+)(.*?)\n(.*?)(\/\/\s*print-end\n)/m ) {

  code = "printf(\"#{$2}\");\n"

  $1 + $2 + "\n" + code + $4

}

# Make a backup of the file

File.copy( ARGV[0], "#{ARGV[0]}.bak" )

# Create the new file

File.open( ARGV[0], "w").write( text )

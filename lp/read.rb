# File: read.rb
# Author: Jack Herrington
# Purpose: Reads a file and prints out the the language elements that were
#    found.
# Data: 12/21/02

require "CTokenizer"
require "CLanguageScanner"
require "CPPLanguageScanner"
require "JavaLanguageScanner"
require "SQLTokenizer"
require "SQLLanguageScanner"

require "ftools"

# read_file( file_name )
#
# file_name - The name of the file
#
# This reads and parses the file.

def read_file( file_name )

  # Read the file contents

  fh = File.open( file_name )
  in_text = fh.read()
  fh.close()

  # Get the extension

  file_name =~ /.(\w+)$/;
  extension = $1.downcase

  # Use the extension to run the correct tokenizer and set up the language
  # scanner

  tokenizer = nil
  languagescanner = nil

  case ( extension )

  when "java"

	print "Parsing #{file_name} as Java...\n\n"

  	tokenizer = CTokenizer.new( )
  	tokenizer.parse( in_text )

	languagescanner = JavaLanguageScanner.new()

  when "hpp" || "h"

	print "Parsing #{file_name} as C++...\n\n"

  	tokenizer = CTokenizer.new( )
  	tokenizer.parse( in_text )

	languagescanner = CPPLanguageScanner.new()

  when "c"

	print "Parsing #{file_name} as C...\n\n"

  	tokenizer = CTokenizer.new( )
  	tokenizer.parse( in_text )

	languagescanner = CLanguageScanner.new()

  when "sql"

	print "Parsing #{file_name} as SQL...\n\n"

  	tokenizer = SQLTokenizer.new( )
  	tokenizer.parse( in_text )

	languagescanner = SQLLanguageScanner.new()

  else

	$stderr.print( "Extension '#{extension}' unknown.\n" )
	exit

  end

  # Analyze the tokens

  languagescanner.parse( tokenizer.tokens )

  # Output into the output file

  base = File.basename( file_name )

  out_fh = File.new( "output/#{base}", "w" )
  out_fh.write( languagescanner.to_s )
  out_fh.close()

end


# Check the arguements.  If a file has been specified then run it,
# otherwise tell the user they need to specify a file.

if ARGV[0]

  read_file( ARGV[ 0 ] )

else

  print "Must specify an input C file\n"

end

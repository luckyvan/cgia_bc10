# File: read_psql.rb
# Author: Jack Herrington
# Purpose: Reads a Postgres SQL file and prints the names of the stored
#     procedures.
# Data: 12/21/02

require "SQLTokenizer"
require "SQLLanguageScanner"

File.open( ARGV[0] ) { |fh|

  in_text = fh.read()

  tokenizer = SQLTokenizer.new( )
  tokenizer.parse( in_text )

  languagescanner = PostgreSQLScanner.new()
  languagescanner.parse( tokenizer.tokens )

  languagescanner.prototypes.each{ |proto|
     print "#{proto.method_name}\n"
  }

} 

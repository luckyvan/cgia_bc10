# File: read_sql.rb
# Author: Jack Herrington
# Purpose: Reads an SQL file and prints the names of the tables.
# Data: 12/21/02

require "SQLTokenizer"
require "SQLLanguageScanner"

File.open( ARGV[0] ) { |fh|

  in_text = fh.read()

  tokenizer = SQLTokenizer.new( )
  tokenizer.parse( in_text )

  languagescanner = SQLLanguageScanner.new()
  languagescanner.parse( tokenizer.tokens )

  languagescanner.tables.each{ |table|
     print "#{table.name}\n"
  }

} 

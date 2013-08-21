# File: read_c.rb
# Author: Jack Herrington
# Purpose: Reads a C file and prints the function names found.
# Data: 12/21/02

require "CTokenizer"
require "CLanguageScanner"

File.open( ARGV[0] ) { |fh|

  in_text = fh.read()

  tokenizer = CTokenizer.new( )
  tokenizer.parse( in_text )

  languagescanner = CLanguageScanner.new()
  languagescanner.parse( tokenizer.tokens )

  languagescanner.prototypes.each{ |proto|
    print "#{proto.method_name}\n"
  }

} 

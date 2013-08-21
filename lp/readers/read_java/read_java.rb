# File: read_java.rb
# Author: Jack Herrington
# Purpose: Reads a Java file and prints the class names found.
# Data: 12/21/02

require "CTokenizer"
require "JavaLanguageScanner"

File.open( ARGV[0] ) { |fh|

  in_text = fh.read()

  tokenizer = CTokenizer.new( )
  tokenizer.parse( in_text )

  languagescanner = JavaLanguageScanner.new()
  languagescanner.parse( tokenizer.tokens )

  languagescanner.classes.each{ |jclass|
     print "#{jclass.name}\n"
  }

} 

# File: read_cpp.rb
# Author: Jack Herrington
# Purpose: Reads a C++ file and prints the class names.
# Data: 12/21/02

require "CTokenizer"
require "CPPLanguageScanner"

File.open( ARGV[0] ) { |fh|

  in_text = fh.read()

  tokenizer = CTokenizer.new( )
  tokenizer.parse( in_text )

  languagescanner = CPPLanguageScanner.new()
  languagescanner.parse( tokenizer.tokens )

  languagescanner.classes.each{ |cpp_class|
     print "#{cpp_class.name}\n"
  }

} 

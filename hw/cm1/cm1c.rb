# File: cm1c.rb
# Purpose: Simple code munger example.  This code pulls out the symbol names and
# values from the #defines in a C file.
# Date: 01/06/02

require "CTokenizer"
require "CLanguageScanner"

unless ARGV[0]
  print "cm1c usage: cm1c file.c\n"
  exit
end

File.open( "out.txt", "w" ) { |out_fh|

  tokenizer = CTokenizer.new( )
  tokenizer.parse( File.open( ARGV[0] ).read() )

  languagescanner = CLanguageScanner.new()
  languagescanner.parse( tokenizer.tokens )

  languagescanner.defines.each{ |key,value|
    out_fh.print "#{key},#{value}\n"
  }

}

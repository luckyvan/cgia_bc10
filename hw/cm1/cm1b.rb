# File: cm1b.rb
# Purpose: Simple code munger example.  This code reads a directory that is
# specified.  It pulls out the symbols and values from the #defines in a C file
# it finds.
# Date: 01/06/02

File.open( "out.txt", "w" ) { |out_fh|

  $stdin.each_line { |line|
    next unless ( line =~ /^#define\s+(.*?)\s+(.*?)$/ )
    out_fh.print "#{$1},#{$2}\n"
  }

}

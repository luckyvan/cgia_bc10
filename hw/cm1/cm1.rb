# File: cm1.rb
# Purpose: Simple code munger example.  This code pulls out the symbol and
# value from the #defines in a C file.
# Date: 01/06/02

unless ARGV[0]
  print "cm1 usage: cm1 file.c\n"
  exit
end

File.open( "out.txt", "w" ) { |out_fh|
  File.open( ARGV[0] ).each_line { |line|
    next unless ( line =~ /^#define\s+(.*?)\s+(.*?)$/ )
    out_fh.print "#{$1},#{$2}\n"
  }
}

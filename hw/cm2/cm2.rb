# File: cm2.rb
# Purpose: Simple code munger example.  This code pulls out special comments from a C
# file.
# Date: 01/06/02
#
# The special comments look like this:
#
# // @important some text

unless ARGV[0]
  print "cm2 usage: cm2 file.c\n"
  exit
end

File.open( "out.txt", "w" ) { |out_fh|
  File.open( ARGV[0] ).each_line { |line|
    next unless ( line =~ /^\/\/\s+@important\s+(.*?)$/ )
    out_fh.print "#{$1}\n"
  }
}

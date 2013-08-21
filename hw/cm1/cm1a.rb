# File: cm1a.rb
# Purpose: Simple code munger example.  This code reads a directory that is
# specified.  It pulls out the symbols and values from the #defines in a C file
# it finds.
# Date: 01/06/02

unless ARGV[0]
  print "cm1a usage: cm1a dir\n"
  exit
end

File.open( "out.txt", "w" ) { |out_fh|

  Dir.open( ARGV[0]).each { |file|

    next unless ( file =~ /[.]c$/ )

	print "Reading #{file}\n"

    File.open( file ).each_line { |line|
      next unless ( line =~ /^#define\s+(.*?)\s+(.*?)$/ )
      out_fh.print "#{$1},#{$2}\n"
    }

  }

}

# File: pc1.rb
# Purpose: Partial class generator example. This generator reads a fields file
# and generates the specified Java base classes.
# Date: 01/06/02

require "erb/erb"

File.open( "fields.txt" ).each_line { |line|

  ( class_name, field_text ) = line.split( ":" )
  fields = field_text.strip.split( "," )

  erb = ERb.new( File.open( "field_class.template.java" ).read )
  new_code = erb.result( binding )

  print "Creating #{class_name}Base.java\n"
  File.open( "#{class_name}Base.java", "w" ).write( new_code )

}

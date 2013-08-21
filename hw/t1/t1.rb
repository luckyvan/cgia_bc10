# File: t1.rb
# Purpose: Tier class generator example. This generator reads a fields file
# and generates the specified Java files.
# Date: 01/06/02

require 'rexml/document'
require "erb/erb"

doc = REXML::Document.new( File.open( "fields.xml" ) )
doc.root.each_element( "class" ) { |class_obj|

  class_name = class_obj.attributes()[ "name" ]

  fields = []
  class_obj.each_element( "field" ) { |field| fields.push( field.text.strip ) }

  erb = ERb.new( File.open( "field_class.template.java" ).read )
  new_code = erb.result( binding )

  print "Creating #{class_name}.java\n"
  File.open( "#{class_name}.java", "w" ).write( new_code )

}

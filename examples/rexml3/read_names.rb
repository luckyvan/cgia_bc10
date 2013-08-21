# File: update_names.rb
# Purpose: An example use of Rexml to read an XML file, and alter some of the
# contents.
# Date: 01/14/02

require 'rexml/document'

doc = REXML::Document.new( File.open( "names.xml" ) )
doc.root.each_element( "name" ) { |name_obj|

  first = name_obj.attributes[ "first" ]
  last = name_obj.attributes[ "last" ]

  fullname = REXML::Attribute.new( "fullname", "#{first} #{last}" )

  name_obj.add_attribute( fullname )

}

print doc.root

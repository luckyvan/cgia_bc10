# File: read_names.rb
# Purpose: An example use of Rexml to read an XML file.
# Date: 01/14/02

require 'rexml/document'

doc = REXML::Document.new( File.open( "names.xml" ) )
doc.root.each_element( "name" ) { |name_obj|

  first = name_obj.elements[ "first" ].text
  last = name_obj.elements[ "last" ].text

  print "#{first} #{last}\n"

}

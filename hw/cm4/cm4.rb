# File: cm4.rb
# Purpose: Simple code munger example. This code takes an XML file as input
# then performs some simple permutation on it and creates a new file with the
# permuted XML.
# Date: 01/06/02

require "rexml/document"

# Check the command line

unless ARGV[0]
  print "cm4 usage: cm4 files ...\n"
  exit
end

# Read in the document

doc = REXML::Document.new( File.open( ARGV[0] ).read )

# Perform some permutation.  In this case add a 'type' attribute to each of
# the fields in the XML document.

doc.root.each_element( "class/field" ) { |field|

  field.attributes.add( REXML::Attribute.new( "type", "integer" ) )

}

# Create the new XML file by building a new file and writing the XML document
# into it.

new_file_name = "#{ARGV[0]}.new"
print "Creating #{new_file_name}\n"
File.open( new_file_name, "w" ).write( doc.to_s )

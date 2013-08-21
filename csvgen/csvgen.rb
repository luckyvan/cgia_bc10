# File: csvgen.rb
# Author: Jack Herrington
# Purpose: See below
# Data: 12/21/02
#
# This Partial Class generator reads an XML definition file and creates
# Java base classes. The intention is for this new class to handle CSV
# (comma separated value) file.  Then the original class can extend this
# generated class to override any specific data handling.
#
# An example XML definition looks like this:
# 
# <spec>
#   <entity name="Name">
#     <field name="first_name" type="String" user="First Name" />
#     <field name="middle_initial" type="String" user="Middle Initial" />
#     <field name="last_name" type="String" user="Last Name" />
#     <field name="age" type="Integer" user="Age" />
#   </entity>
# </spec>
#
# The definition contains one or more entity definitions.  Each definition
# defines 'name', which is the name of the entity.
#
# Then the fields are defined using the 'field' tag.  Each field, in order,
# defines the Java field name, the type and a user friendly name for the
# field.
#

require "rexml/document"
require "erb/erb"

require "ftools"

Field = Struct.new( "Field", :java_name, :java_type, :user_name )

# read_def_file( file_name )
#
# file_name - The name of the file
#
# This reads and parses the file.

def read_def_file( file_name )

  doc = REXML::Document.new( File.open( file_name ) )

  doc.root.each_element( "entity" ) { |entity_node|

    entity = entity_node.attributes[ "name" ].to_s
    class_name = "#{entity}Reader"
    fields = []

    entity_node.each_element( "field" ) { |field_node|

      field = Field.new();
      field.java_name = field_node.attributes[ "name" ].to_s
      field.java_type = field_node.attributes[ "type" ].to_s
      field.user_name = field_node.attributes[ "user" ].to_s
      fields.push( field )
    }

    # Build the java class using the ERb template

    template_result = run_template( "Reader.java.template", binding )

    # Write out the new Java class

    dir = File.dirname( file_name )
    out_file_name = "#{dir}/#{class_name}.java"

    print "Creating #{out_file_name}...\n"

    fh = File.open( "#{out_file_name}", "w" )
    fh.print template_result
    fh.close()

  }

end

def run_template( template_name, bind )

  erb = ERb.new( File.new( "templates/#{template_name}" ).read )
  return erb.result( bind )

end

# Check the arguements.  If a file has been specified then run it,
# otherwise tell the user they need to specify a file.

if ARGV[0]

  read_def_file( ARGV[ 0 ] )

else

  print "Must specify an input C file\n"

end

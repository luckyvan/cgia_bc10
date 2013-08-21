# File: cm6.rb
# Purpose: Code munger example. This generator looks for special
# comments in the specified Java file.  These comments specify field names
# that are to be created in a Java base class.
# Date: 01/06/02
#
# The special comment format is:
#
# // @field field_name
#

require "erb/erb"

# Check the arguments

unless ARGV[0]
  print "cm6 usage: cm6 file.java\n"
  exit
end

# Read the file

fh = File.open( ARGV[0] )
text = fh.read()
fh.close

# Get the class name

class_name = ARGV[0]
class_name.gsub!( /[.]java$/, "" )

# Create the new class name

new_class_name = "#{class_name}Base"

# Get the field names

fields = []
text.scan( /\/\/\s+@field\s+(.*?)\n/m ) { fields.push( $1 ) }

# Build the new Java file contents from a template

erb = ERb.new( File.open( "base.template.java" ).read )
new_code = erb.result( binding )

# Create the new Java File

print "Creating #{new_class_name}.java\n"
File.open( "#{new_class_name}.java", "w" ).write( new_code )

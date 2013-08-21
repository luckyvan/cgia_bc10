# File: cm5.rb
# Purpose: Code Munger example. This generator reads a data file
# and generates a C file.
# Date: 01/06/02

require "erb/erb"

# Create a new class to hold a name

Name = Struct.new( "Name", :first, :last )

# Read in the data file

names = []

File.open( "data.txt" ).each_line { |line|
  name = Name.new()
  ( name.first, name.last ) = line.split( "," ).map{ |val| val.chomp }
  names.push( name )
}

# Run the template on the data

erb = ERb.new( File.open( "data.template.c" ).read )
new_code = erb.result( binding )

# Create the C file with the output of the template

file_name = "data.c"
print "Creating #{file_name}\n"
File.open( file_name, "w" ).write( new_code )

# File: docgen.rb
# Author: Jack Herrington
# Purpose: Builds HTML documentation for SQL schema files.
# Data: 12/21/02
#
# This generator takes and SQL file containing table definitions and uses
# special comments in the file to build HTML files that document the tables.
#
# Below is an example of the markup that can be attached before a table:
#
# -- Book contains information about each book, the title,
# -- the author, the publisher, etc.
# --
# -- @field bookID The primary key id
# -- @field title The title of the book
# -- @field ISBN The ISBN number of the book
# -- @field authorID The author (as a foreign key relation)
# -- @field publisherID The publisher (as a foreign key relation)
# -- @field status The active or inactive state of the record
# -- @field numCompies The number of copies in the library
# -- @relates_to Author
# -- @relates_to Publisher
# --
# create table Book ( ...
#
# This is basically JavaDoc with different tags.  The new tags are:
#
# @field      : This adds a comment to a field.  The first value is
#               the field name, the description follows after that.
# @relates_to : Adds a reference to another table
#

require "SQLTokenizer"
require "SQLLanguageScanner"
require "JavaDoc"

require "erb/erb"

# run_template( template_name, bind )
#
# template_name - The name of the template file
# bind - The binding to pass to the template
#
# This runs the specified template with the bindings and returns the text
# output.

def run_template( template_name, bind )

  erb = ERb.new( File.new( "templates/#{template_name}" ).read )
  erb.result( bind )

end

# convert_comment( comment )
#
# comment - An SQL Comment
#
# This converts and SQL comment into a JavaDoc style comment

def convert_comment( comment )

  # First clean off all of the '--' markers

  cleaned = ""

  comment.each_line { |line|
    line.sub!( /\s*\-\-\s*/, "" )
    line.strip!
    cleaned += "#{line}\n" if ( line.length > 0 )
  }

  # Now create a new buffer with the proper JavaDoc formatting
  # around it

  converted = "/**\n"

  cleaned.each_line { |line| converted += " * #{line}" }

  converted += " */\n"

  converted

end

# class : ExtendedJavaDoc
#
# An extension to JavaDoc to look for our specific JavaDoc markup

class ExtendedJavaDoc < JavaDoc

  # initialize()
  #
  # Constructor
  
  def initialize()

    super()

    @tableDescription = ""
    @fieldDescriptions = {}
    @relatesTo = []

  end

  attr_reader :tableDescription   # The table description string
  attr_reader :fieldDescriptions  # The hash of descriptions for each field
  attr_reader :relatesTo          # The array of tables this table relates to

  # add_to_tag( key, text )
  #
  # key - The JavaDoc key
  # text - The text associated with the key
  #
  # An override of the JavaDoc handler to look for our markup

  def add_to_tag( key, text )

    # Strip any whitespace off the text

    text.strip!

    if ( key == "@desc" )

      # Add to the description any @desc data

      @tableDescription += text

    elsif ( key == "@field" )

      # Parse any @field description data

      text =~ /(.*?)\s/
      field = $1

      text.sub!( /^#{field}\s*/, "" )

      @fieldDescriptions[ field.downcase.strip ] = text

    elsif ( key == "@relates_to" )
  
      # Parse any @relates_to data

      @relatesTo.push( text )

    end

  end

end

# read_sql_file( file_name )
#
# file_name - The name of the file
#
# This reads and parses the file.

def read_sql_file( file_name )

  # Read the file contents

  print "Parsing #{file_name}...\n"

  fh = File.open( file_name )
  in_text = fh.read()
  fh.close()

  # Tokenize the Java

  tokenizer = SQLTokenizer.new( )
  tokenizer.parse( in_text )

  # Run it through the language parser

  languagescanner = SQLLanguageScanner.new()
  languagescanner.parse( tokenizer.tokens )

  # Get the tables

  tables = languagescanner.tables

  # Iterate over each table and make the HTML file for it
  
  tables.each { |table|

  # Tell the user what we are building

  print "Building #{table.name}.html\n"

  # Parse the JavaDoc in the comments attached to the table

  jd = ExtendedJavaDoc.new()
  jd.parse( convert_comment( table.comment ) )

  # Fill the field comment value with the appropriate comment from the
  # JavaDoc

  table.fields.each { |field|
    field.comment = jd.fieldDescriptions[ field.name.to_s.downcase.strip ]
  }

  # Setup other locals that the template will use

  table_comment = jd.tableDescription
  relates_to = jd.relatesTo

  # Create the HTML file and use the template to build it

  fh = File.new ("output/#{table.name}.html", "w" )
    fh.print run_template( "table_page.html.template", binding )
    fh.close()
  }

  # Build the table index

  print "Building tables.html\n"
  fh = File.new ("output/tables.html", "w" )
  fh.print run_template( "tables.html.template", binding )
  fh.close()

  # Build the main index page

  print "Building index.html\n"
  fh = File.new ("output/index.html", "w" )
  fh.print run_template( "index.html.template", binding )
  fh.close()

end


# Check the arguements.  If a file has been specified then run it,
# otherwise tell the user they need to specify a file.

if ARGV[0]

  read_sql_file( ARGV[ 0 ] )

else

  print "Must specify an input SQL file\n"

end

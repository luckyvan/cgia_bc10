# File: testgen.rb
# Author: Jack Herrington
# Purpose: The main entry point for the test generator
# Data: 12/21/02

# Bring in 'ftools' for File.copy

require "ftools"

# Bring in the C Tokenizer and Prototype scanner

require "CTokenizer"
require "CLanguageScanner"

# Bring in REXML and ERb

require "rexml/document"
require "erb/erb"

# class : PrototypeWithTests
#
# This class extends the basic Prototype class with space to specify
# an array of tests against the prototype.

class PrototypeWithTests < Prototype

  # initialize()
  #
  # Initializes the object

  def initialize()

    # Initialize the base class
    super()

    # Create the array of tests
    @tests = []

  end

  attr_reader :tests   # The array of tests

  # add_tests( tests )
  #
  # tests - An array of TestData objects
  #
  # Adds an array of tests to the prototype

  def add_tests( tests )

    tests.each { |test| @tests.push( test ); }

  end

end

# class : TestData
#
# Objects of type TestData hold the data for a single test

class TestData

  # initialize()
  #
  # Constructs the TestData object

  def initialize()

    @name = ""
    @result = ""
    @arguments = {}

  end

  attr_accessor :name      # The name of the test
  attr_accessor :result    # The expected result
  attr_reader :arguments   # The test data (a hash)

  # add_argument( name, value )
  #
  # name - The name of the argument
  # value - The test data value
  #
  # This adds data to the test

  def add_argument( name, value )
    @arguments[ name ] = value
  end

end

# parse_data( text )
#
# text - The text of the comment
#
# This builds a TestData object from a text string

def parse_data( text )

  begin

    # Create the new test data

    data = TestData.new()

    # Parse the XML of the comment 

    doc = REXML::Document.new( text )

    # Get the result and name

    data.result = doc.root.attributes[ 'result' ]
    data.name = doc.root.attributes[ 'name' ]

    # Get the test data

    doc.root.elements.each { |elem|
      data.add_argument( elem.name, elem.text.strip )
    }

    # Return the new TestData object

    data

  rescue

    nil

  end

end

# find_tests( comments )
#
# comments - The array of comments returned from the Prototype object
#
# This finds all of the tests in all of the comments and returns
# an array of TestData objects. One for each test.

def find_tests( comments )

  tests = []

  # Iterate through the comments

  comments.each { |comment|

    # Search for the test data block XML

    found = comment.to_s.scan( /(<test.*?<\/test>)/ )

    # If we found some then use them to create the TestData objects

    if ( found )

      found.each { |items|

        data = parse_data( items[0] )

        tests.push( data ) if ( data )

      }

    end

  }

  # Return the comments

  tests

end


# generate_tests( file_name )
#
# file_name - The name of the file to scan and alter
#
# This generates test case running code from test case comments around
# the function prototypes.

def generate_tests( file_name )

  # Read the file contents

  fh = File.open( file_name )
  c_text = fh.read()
  fh.close()

  # Tokenize the file
  tokenizer = CTokenizer.new( )
  tokenizer.parse( c_text )

  # Build the language scanner
  languagescanner = CLanguageScanner.new()

  # Use our prototype class when prototypes are built instead
  # of the base class
  languagescanner.prototypeClass = PrototypeWithTests

  # Get the prototypes
  languagescanner.parse( tokenizer.tokens )

  # Iterate through the prototypes and turn the comments
  # into tests

  count = 0

  languagescanner.prototypes.each { |proto|

    # Parse the comments into tests and add them

    tests = find_tests( proto.comments )

    proto.add_tests( tests )

    # Create unique names for the tests that don't
    # have them

    index = 1

    proto.tests.each { |item|

      name = "#{proto.method_name}_#{index}"
      item.name = name unless ( item.name )

      index += 1
      count += 1

    }
  }

  # Create the testing code by calling the template.  The
  # templates reference 'prototypes'.  They can do this because
  # we pass 'binding' into ERb so that the template is evaluated
  # in our context so that it has access to our locals.

  prototypes = languagescanner.prototypes

  erb = ERb.new( File.new( "templates/c.template" ).read )
  template_result = erb.result( binding )

  # Add in the prefix

  template_result = "// <test_start>\n#{template_result}\n// </test_start>"

  # Backup the original file

  File.copy file_name, "#{file_name}.bak"

  # Insert the new template result

  if ( c_text =~ /\/\/ <test_start>.*?\/\/ <\/test_start>/m )
    c_text.sub!( /\/\/ <test_start>.*?\/\/ <\/test_start>/m, template_result )
  else
    c_text += template_result
  end

  # Output the finished code
  File.open( file_name, "w" ).write( c_text )

  # Tell the user what we did
  print "#{file_name}: #{count} tests found\n"

end

# Check the arguements.  If a file has been specified then run it,
# otherwise tell the user they need to specify a file.

if ARGV[0]

  generate_tests( ARGV[ 0 ] )

else

  print "Must specify an input C file\n"

end

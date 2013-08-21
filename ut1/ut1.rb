#!/usr/bin/ruby

# File: ut1.rb
# Purpose: Simple file based unit test checker
# Instructions:
#
# ut1 takes an XML definition file that describes a series of tests to be
# run.  Each test is a simple command line.  The expectation is that this command
# line will produce a file in a known location (also specified by the test.)
#
# Here is an example XML file:
#
#   <ut kgdir="kg">
#     <test cmd="ruby uigen.rb definitions/form1.def" out="output/form1.jsp" />
#     <test cmd="ruby uigen.rb definitions/form2.def" out="output/form2.jsp" />
#     <test cmd="ruby uigen.rb definitions/table1.def" out="output/table1.jsp" />
#   </ut>
#
# This file specifies three tests, each a ruby invocation, with their corresponding
# output files.
#
# There are two modes to this program, the first stores the outputs as known goods.
# The second compares the current outputs against previously stored known goods. These
# known goods are stored in the direct specified by the 'kgdir' attribute on the 'ut'
# tag.  (This directory must exist before the this utility is run.)
#
# To run the unit test framework, first generate the known goods, like this:
#
#  ruby ../ut1/ut1.rb -m -f ut.def
#
# -m means make the known goods, and -f specifies the file name of the XML definition
# file.
#
# After generating the known goods you can test against them using the '-t'
# test flag:
#
#  ruby ../ut1/ut1.rb -t -f ut.def
#
# -t means test against the known goods, and -f specifies the file name of the XML
# definition
#

# Include rexml and the command line option handler

require 'rexml/document'
require 'getoptlong'
require 'ftools'
require 'ostruct'

# Define the module global parameters that will take the command line
# parameters

@@xml_file = ""
@@is_making = false

# Parse the command line parameters

begin

  # Setup the command line parser

  opts = GetoptLong.new(
    [ "--test", "-t", GetoptLong::NO_ARGUMENT ],
    [ "--make", "-m", GetoptLong::NO_ARGUMENT ],
    [ "--file", "-f", GetoptLong::REQUIRED_ARGUMENT ]
  )

  # Look through the options we found

  opts.each_option do |name, arg|
    @@xml_file = arg if ( name == "--file" )
    @@is_making = true if ( name == "--make" )
  end

rescue

  # If we failed then print out the usage

  print "ut1 usage:\n";
  print "  ruby ut1.rb -f xml_def_file - To run the tests against the known goods\n"
  print "  ruby ut1.rb -m -f xml_def_file - To regenerate the known goods\n"
  exit

end

# Read and process the XML definition file

begin

  doc = REXML::Document.new( File.open( @@xml_file ) )

rescue

  print "Could not open or parse #{@@xml_file}"
  exit

end

# Get the known good directory

kgdir = doc.root.attributes[ 'kgdir' ]

# Exit if one was not defined

unless kgdir

  print "No known good directory defined on the 'ut' tag.\n"
  exit

end

# Go through the XML nodes and pull out all of the tests

tests = []

doc.root.elements.each( "test" ) { |test_node|

  # Add a hash to the tests array that contains the command line,
  # the output file and a generated value which is the path to
  # the known good file

  files = []
  files.push( test_node.attributes[ 'out' ] ) if ( test_node.attributes[ 'out' ] )

  # Look for any interior <out></out> nodes. Using this method a test can
  # specify multiple output files.

  test_node.elements.each( "out" ) { |out_node|

	out = out_node.text.strip

  	files.push( out ) if ( out )

  }

  tests.push ( OpenStruct.new( {
    'command' => test_node.attributes[ 'cmd' ],
    'output_files' => files
  } ) )

}

# Initialize the failures array which will store the failures we encounter

failures = []

# Iterate through the tests and execute them

tests.each { |test|

  # Run the command

  print "#{test.command}\n"

  system( test.command )

  # Get the results from the file output 

  test.output_files.each { |file|

    known_good_name = kgdir + "/" + File.basename( file )

    begin

      current_result = File.open( file ).read()

    rescue

      print "Failure: No output file - #{file}\n"
      next
  
    end
  
    if ( @@is_making )

	  print "Storing #{file} to #{known_good_name}\n"

      # If we are making known goods then simply copy the output
      # file into the known good folder
  
      File.syscopy( file, known_good_name )
  
      print "Known good #{known_good_name} stored\n"

    else

	  print "Checking #{file} against #{known_good_name}\n"

      # If we are doing a comparison then we need to read the known
      # good file

      begin

        good_result = File.open( known_good_name ).read()

        # And compare it to the current result.  If you have a
        # specific way of comparing files, this is where you 
        # would put it.

        if ( good_result != current_result )
  
          print "Failure: Known good comparison failed\n"
  
          failures.push test.command
  
        end

      rescue

        print "Failure: No known good file - #{known_good_name}\n"

        failures.push test.command

      end

    end

  }

  print "\n"
}

# Unless we are making known goods, describe any failures (or lack there of).

unless ( @@is_making )

  if ( failures.length > 0 )

    print "\n\nTests failed:\n\n"
    failures.each { |test| print "  #{test}\n" }
    exit -1

  else

    print "\n\nNo test failures\n"

  end

end

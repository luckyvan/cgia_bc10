# File: rpcgen.rb
# Author: Jack Herrington
# Purpose: Reads a Java file with special JavaDoc and creates XML-RPC handlers
#          and stubs.
# Data: 1/5/03
#
# This generator looks at Java files to find JavaDoc that indicates which
# methods should be exported via XML-RPC.  The JavaDoc markup that specifies a
# method to be exported is:
#
# @rpcgen export
#
# This generator will build both a "Handler" file that is to be used with
# Apache's XML-RPC WebServer.  It also creates a "Stub" file which has just
# the exported interface and presents exactly the same API to the client. This
# simple client stub makes using the XML-RPC server a snap.
#
# For more information about the Apache XML-RPC classes go to:
#
# http://xml.apache.org/xmlrpc/index.html
#

require "CTokenizer"
require "JavaLanguageScanner"

require "erb/erb"
require "ftools"

# read_java_file( file_name )
#
# file_name - The name of the file
#
# This reads and parses the file.

def read_java_file( file_name )

  # Read the file contents

  print "Parsing #{file_name}...\n"

  fh = File.open( file_name )
  in_text = fh.read()
  fh.close()

  # Tokenize the Java

  tokenizer = CTokenizer.new( )
  tokenizer.parse( in_text )

  # Run it through the language parser

  languagescanner = JavaLanguageScanner.new()
  languagescanner.parse( tokenizer.tokens )
 
  file_prefix = file_name.sub( /[.]java$/, "" )

  class_name = File.basename( file_name )
  class_name.sub!( /[.]java$/, "" )

  # Create the methods for both the handler and the stub Java files

  handler_methods = ""
  stub_methods = ""

  languagescanner.classes.each { |jclass|

    jclass.methods.each { |proto|

      next unless proto.javadoc != nil
      next unless proto.javadoc.tags[ '@rpcgen' ]  != nil
      next unless proto.javadoc.tags[ '@rpcgen' ] =~ /export/
    
      method_name = proto.method_name
      method_type = proto.method_type
      arguments = proto.arguments

      handler_methods += run_template( "HandlerMethod.java", binding )
      stub_methods += run_template( "StubMethod.java", binding )
  
    }

  }

  # Create the handler Java file

  handler_name = "#{file_prefix}Handler.java"
  print "Creating #{handler_name}\n"

  fh = File.open( handler_name, "w" )
  methods = handler_methods
  fh.print run_template( "Handler.java.template", binding )
  fh.close()

  # Create the stubs Java file

  stubs_name = "#{file_prefix}Stubs.java"
  print "Creating #{stubs_name}\n"

  fh = File.open( stubs_name, "w" )
  methods = stub_methods
  fh.print run_template( "Stubs.java.template", binding )
  fh.close()

end

# rpc_type( type )
#
# type - The Java type
#
# This returns the XML-RPC type that supports the specified Java type

def rpc_type( type )

  return "Double" if ( type == "double" )
  return "Integer" if ( type == "int" )
  return "Boolean" if ( type == "boolean" )
  return type

end

# run_template( template_name, bind )
#
# template_name - The file name for the template
# bind - The binding to run the template within
#
# Simple helper function to run an ERb template

def run_template( template_name, bind )

  erb = ERb.new( File.new( "templates/#{template_name}" ).read )

  return erb.result( bind )

end


# Check the arguements.  If a file has been specified then run it,
# otherwise tell the user they need to specify a file.

if ARGV[0]

  read_java_file( ARGV[ 0 ] )

else

  print "Must specify an input C file\n"

end

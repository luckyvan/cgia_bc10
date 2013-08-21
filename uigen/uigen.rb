#!/usr/bin/ruby

# File: uigen.rb
# Purpose: Code Generator for JSP pages
# Instructions:
#
# On the command line invoke this program using Ruby and pass it the path to the definition
# file. For example:
#
# ruby uigen.rb definitions/form1.def
#
# Output files go into the output directory.

# Include rexml and ERb

require 'rexml/document'
require 'erb/erb'

class UIBuilder

  def initialize
    # Instance variables for the output file.

    @out_file = nil
    @output_file_name = nil
    @output_full_name = nil

    # The names of the output and templates directories

    @output_directory = "output"
    @templates_directory = "templates"

    # The stack for the context

    @context_stack = []

    # stack of nodes

    @node_stack = []
  end

  # process_file ( file_name )
  #
  # file_name - The path name of the definition file

  def process_file( file_name )

    # Read and process the XML file

    begin

      doc = REXML::Document.new( File.open( file_name ) )

    rescue

      raise "Could not open or parse #{file_name}"

    end

    # Get the file name from the top node
  
    @output_file_name = doc.root.attributes[ 'name' ]
    unless( @output_file_name )
      print "#{file_name}: No name attached to the file element.\n"
      exit -1
    end

    # Put together the output file name

    @output_full_name = "#{@output_directory}/#{@output_file_name}"

    # Create the output file

    begin

      @out_file = File.open( @output_full_name, "w")

    rescue

      raise "Could not create #{@output_full_name}"

    end

    # Start the context stack

    push_context( doc.root )

    # Iterate through the container elements and process them
  
    nodes = doc.root.elements
    nodes.each() { |node|
      if ( node.name() == "container" )
        @out_file.write( process_container( node ) )
      end
    }

    # Clean up the context

    pop_context()

    # Close up the output file

    @out_file.close()

    # Output the file name so that the user will know what we have created

    print "#{file_name}\n"

  end

private

  # process_container( container )
  #
  # container: The rexml node of the container
  #
  # Processes a container.  The name of the template is taken from the name
  # attribute of the XML node.

  def process_container( container )

    process_template( container.attributes[ 'name' ], container )

  end

  # process_template( name, node )
  #
  # name - The name of the template
  # node - The node to use as the context

  def process_template( name, node )

    # Get the context

    context = push_context( node )

    # Put together the path name of the template 

    template_full_name = "#{@templates_directory}/#{name}"

    # Read the template

    begin

      fh = File.new( template_full_name )
      erb_script = fh.read
      fh.close()

    rescue

      raise "Could not read template #{name}"

    end

    # Compile the ERb script and run it

    begin

      erb = ERb.new( erb_script )

      erb_result = erb.result( binding )

    rescue => err

      raise err #, "There was a problem interpreting template #{name}"

    end

    # Pop the context

    pop_context()

    # Return the result

    erb_result

  end

  # each_node()
  #
  # This is an iterator for templates to use to iterate through each of the nodes
  # contained within themselves.  For example, a container could use this to handle
  # each of the field definitions within itself.
  #
  # An example use in ERb is:
  #
  #    <% print each_node() { |node,text| %>
  #    <th><%= node.attributes[ 'title' ] %></th>
  #    <% } %>
  # 
  # The output from the each_node call is printed back into the host container so that
  # the output is captured.
  #
  # Each node 'yields' two items for each item.  The first is the node itself, which is
  # a reference to the rexml node. The second is the text that is returned from invoking
  # the template.
  #
  # It is the responsibilty of the 'yielded' code to return a string which is the 'result'
  # of each node.  These strings are concatonated together to create the complete result.
  # Which is then 'printed' into the current template result.

  def each_node()

    # Get the current node

    current_node = get_current_node()

    # Keep a cache of the results

    result = ""

    # Get the nodes

    nodes = current_node.elements

    # Iterate through each node

    nodes.each() { |node|

      # Get the text of the node by processing the template or container

      text = ""

      if ( node.name == "container" )

        text = process_container( node )

      else

        text = process_template( node.name, node )

      end

      # Yield to the block the node and the text.  We are using ERb's
      # standard IO capture mechanism to capture the output of the interior
      # ERb code.

      result += ERbStrIO.as_stdout { yield( node, text ) }

    }

    # Return the combined output text

    result

  end

  # process_nodes()
  #
  # This is the simpler alternative to each_node.  If all you want to do is simply place the
  # value of the interior nodes within your page use 'process_nodes'.  Here is an example in
  # ERb:
  #
  # <html><body>
  # <%= process_nodes() %>
  # </body></html>

  def process_nodes()

    # Use each_node to gather up all of the text

    result = ""

    each_node() { |node, text|
      result += text
    }

    result

  end

  # build_context()
  #
  # Returns a hash of the current context

  def build_context()

    # Flatten the array of hashes which is the context into a single
    # hash.  Since the array runs from oldest to newest, flattening it
    # forward gives us the right result of the most recent values taking
    # precedence over the older values

    context = {}

    @context_stack.each { |values|

      values.each { |key,value|

        context[ key ] = value;

      }

    }

    context

  end

  # get_current_node()
  #
  # Returns the top most node

  def get_current_node()

    # Simply return the last value of the stack

    @node_stack.last

  end

  # push_context( node )
  #
  # node: The node to add to the context
  #
  # Adds a context to the stack.

  def push_context( node )

    # Add the node to the stack

    @node_stack.push( node )

    # Create a simple hash of the attributes on this XML node

    values = {}

    node.attributes.each() { |key,value|
      values[ key ] = value;
    }

    # Add that simple values has to the context stack

    @context_stack.push( values )

    # Return the built context

    build_context()

  end

  # pop_context()
  #
  # Pops the top-most context.

  def pop_context()

    # Pop the top elements off the node and context stacks

    @node_stack.pop
    @context_stack.pop()

  end
end

# Get the input file name from the command line

if ( ARGV[0] )

  # Create the UIBuilder class

  proc = UIBuilder.new()

  begin 

    # Process the file

    proc.process_file( ARGV[0] )

  rescue => problem

    # Print out the exception if there was one

    print "#{problem}\n"
    exit -1

  end

  exit 0
else

  # The user forgot to specify an input file

  print "No input file specified\n"
  exit -1

end

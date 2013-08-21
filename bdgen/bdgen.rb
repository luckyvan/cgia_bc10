# File: bdgen.rb
# Author: Jack D. Herrington
# Purpose: Reads equations embedded in Java files and turns creates
# implementations of the equations using BigDecimal.
# Date: 12/31/02
#
# Inside your Java file you can specify an equation using this syntax:
#
# // bdgen_start <a=b+c>
# // bdgen_end
#
# The equation goes in between the < and > marks.  The BigDecimal
# implementation is then put between the two comments.  Here is an example
# output:
#
# // bdgen_start <a=b+c>
# BigDecimal v1 = new BigDecimal( b );
# BigDecimal v2 = new BigDecimal( c );
# BigDecimal v3 = new BigDecimal( 0 );
# v3 = v1.add( v2 );
# a = v3;
# // bdgen_end
#
# In this case the Java code will need to define 'a' and 'b' as most likely
# doubles.  And then define 'a' as a BigDecimal.
#

require "ftools"

# Globals

@@vindex = 0     # The variable number index

# class : EqNode
#
# The equation node base class. This just holds a string which is the text of
# the node.

class EqNode

  def initialize( str )
    @str = str
  end

  def to_s()
    @str
  end

end

# class : Variable
#
# Variable is a specialization of EqNode. It doesn't define any new
# functionality but the equation parser will use the type to decide what to do
# with the node.

class Variable < EqNode
end

# class : Operand
#
# Represents an operation within an equation (e.g. +, -, *, /) or a function.

class Operand < EqNode

  # initialize( str, func = nil )
  #
  # str - The token string
  # func - The name of the function as a string (if it is defined)
  #
  # Constructor which takes the operand as a string and in the case of a
  # function it takes the function name.

  def initialize( str, func = nil )

    super( str )

    @op = str
    @left = nil
    @right = nil
    @function = func

  end

  attr_accessor :left   # The left node in the binary tree

  attr_accessor :right  # The right node in the binary tree

  attr_reader :function # The name of the function

  # op()
  #
  # Returns the name of the operand (or the function if it's a function)

  def op()

    @function ? @function : @op

  end

  # to_s()
  #
  # A helpful string converter for debugging

  def to_s()

    if ( @left || @right )

      if ( @function && @left ) 
    
        "<op:#{op}><#{@left}>"

      elsif ( @function && @right )
  
        "<op:#{op}><#{@right}>"

      else
    
        "<#{@left}>#{@str}<#{@right}>"

      end

    else

      super()

    end

  end

end

# class : TokenStream
#
# A derivation of Array that models a stream of tokens and adds some helpful
# methods for developing and maintaining the token stream.

class TokenStream < Array

  # add_literal( str )
  #
  # str - The string of the token
  #
  # Adds a literal (either a variable or a constant) to the token list

  def add_literal( str )

    push( Variable.new( str ) )

  end

  # add_op( str, func )
  #
  # str - The operand string
  # func - The function name (nil if it is not defined)
  #
  # Adds an operand to the token stream.

  def add_op( str, func )

    push( Operand.new( str, func ) )

  end

  # to_s()
  #
  # Handy token stream to string coverter to output the equation as it has
  # been tokenized.

  def to_s()

    str = ""

    each { |node| str += node.to_s() }

    str 

  end

end

# build_tokens( eq )
#
# eq - The equation as a string
#
# A simple tokenizer for equation strings

def build_tokens( eq )

  # Create the new token stream
  tokens = TokenStream.new()

  # The operand characters to look for

  specials = { '=' => 1, '(' => 1, ')' => 1, '+' => 1, '-' => 1, '*' => 1, '/' => 1 }

  # Remove any whitespace

  eq.gsub!( /\s+/, "" )

  # Iterate through each byte
  
  token = ""

  eq.each_byte { |ch| ch = ch.chr()

    if ( specials[ ch ] )

    # Handle operand characters

    if ( ch == "(" && token.length > 1 )

      # In the case of a '(' look for a function name before the paren open

      tokens.add_op( ch, token )

    else

      tokens.add_literal( token ) if ( token.length > 0 )
      tokens.add_op( ch, nil )

    end

      token = ""

  else

    # If this is not an operand then just add the character to the token

    token += ch

  end

  }

  # Add any remaining token

  tokens.add_literal( token ) if ( token.length > 0 )

  # Return the TokenStream

  tokens

end

# relate_tokens( eq, start = 0 )
#
# eq - The token stream
# start - The starting index
#
# This looks through the token stream and sets the left and right values of
# the operands to create an evaluation hierarchy.

def relate_tokens( eq, start = 0 )

  # Look ahead for parens

  ( ( eq.length - start ) - 1 ).times { |index|

    ind = ( start + 1 ) + index

    if ( eq[ ind ].to_s == "(" )

      relate_tokens( eq, ind )
  
    end
  }

  # Check to see if we were started on a parent

  if ( eq[ start ].to_s == '(' )

    # If we are then recurse for the interior of the parens

    relate_tokens( eq, start + 1 )

    # Handle the case where we are a function

    if ( eq[ start ].function )

      eq[ start ].right = eq[ start + 1 ]
      eq.delete_at( start + 1 )

    else

      eq.delete_at( start )

    end

    # Delete the corresponding paren

    ( eq.length - start ).times { |index|

      if ( eq[ start + index ].to_s == ")" )

        eq.delete_at( start + index )

        break

      end
    }

  else

    # Search for operators within the token stream and handle those tokens
    # that do not already have their left or right values assigned

    found = true

    operators = [ '/', '*', '+', '-' ]

    while( found )

      found = false

      operators.each { |op|

        ( eq.length - start ).times { |index|
  
          node = eq[ start + index ]
  
          break if ( node.to_s == ")" )
          next unless ( node.is_a?( Operand ) )
  
          if ( node.to_s == op )
  
            left = eq[ ( start + index ) - 1 ]
            right = eq[ ( start + index ) + 1 ]
      
            node.left = left
            node.right = right
      
            eq.delete_at( ( start + index ) + 1 )
            eq.delete_at( ( start + index ) - 1 )
  
            found = true
  
            break
  
          end

        }
  
      }

    end

  end

end

# new_varname()
#
# Returns a new Java variable name

def new_varname()

  @@vindex += 1

  "v#{@@vindex}"

end

# new_equate_command( commands, token )
#
# commands - The command stack
# token - The token to use as a the initializer of the BigDecimal
#
# Adds a command to create a new BigDecimal and returns the new variable name.

def new_equate_command( commands, token )

  var = new_varname()

  commands.push( "BigDecimal #{var} = new BigDecimal( #{token} );" )

  var

end

# final_equate_command( commands, var1, var2 )
#
# commands - The command stack
# var1 - The primary variable
# var2 - The variable to equate it to
#
# This builds the final command which equates the output variable with the
# final value of the equation.

def final_equate_command( commands, var1, var2 )

  commands.push( "#{var1} = #{var2};" )

end

# new_op_command( commands, op, var1, var2 )
#
# commands - The command stack
# op - The operand or function
# var1 - The primary variable
# var2 - The secondary varible
#
# Builds the Java expression to implement either a basic operand (+,-,*,/) or
# a function.

def new_op_command( commands, op, var1, var2 )

  var = new_varname()

  if ( op.length > 1 )

  # Handle a function invocation

  if ( var1 && var2 )

    commands.push( "BigDecimal #{var} = #{op}( #{var1}, #{var2} );" )

  elsif ( var1 )

    commands.push( "BigDecimal #{var} = #{op}( #{var1} );" )

  elsif ( var2 )

    commands.push( "BigDecimal #{var} = #{op}( #{var2} );" )

  end

  else

    if ( op == "/" )

      # Handle the divide case

      str = "BigDecimal #{var} = new BigDecimal( 0 );\n"
      str += "#{var} = #{var1}.divide( #{var2}, BigDecimal.ROUND_DOWN );"

      commands.push( str )

    else
  
    # Handles the other operands
    
      method = "add" if ( op == "+" )
      method = "subtract" if ( op == "-" )
      method = "multiply" if ( op == "*" )
  
      str = "BigDecimal #{var} = new BigDecimal( 0 );\n"
      str += "#{var} = #{var1}.#{method}( #{var2} );"

      commands.push( str )

    end

  end

  var

end

# create_commands( commands, token )
#
# commands - The commands stack
# token - The token to create
#
# Recursively creates a command stack to implement the equation specified in
# the token stream

def create_commands( commands, token )

  if ( token.is_a?( Variable ) )

    new_equate_command( commands, token )

  else

    v1 = token.left ? create_commands( commands, token.left ) : nil
    v2 = token.right ? create_commands( commands, token.right ) : nil
    new_op_command( commands, token.op, v1, v2 )

  end

end

# parse_equation( eq )
#
# eq - The equation as text
#
# Parses the equation and returns a Java string that will implement the
# equation

def parse_equation( eq )

  # Get the tokens

  tokens = build_tokens( eq )

  # Check the stack

  raise( "Invalid equation" ) if ( tokens.length <= 2 ) 
  raise( "Invalid equation" ) unless ( tokens[0].is_a?( Variable ) ) 
  raise( "Invalid equation" ) unless ( tokens[1].is_a?( Operand ) && tokens[1].to_s == "="  ) 

  # The the output variable name

  output_name = tokens.shift.to_s
  tokens.shift

  tokens_left = true

  # Turn the token stream into a binary tree by relating the tokens together

  while( tokens_left )
  
    relate_tokens( tokens )

    tokens_left = false

    tokens.each { |tok|

      next unless ( tok.is_a?( Operand ) )

      tokens_left = true unless ( tok.left || tok.right )

    }

  end

  # This is the name of variable that holds the result of the equation
  
  out_var = nil

  # This is the commands stack

  commands = []

  # Iterated through the tokens and use create_commands to build the Java

  tokens.each { |tok|

    next unless ( tok.is_a?( Operand ) )

    if ( tok.left || tok.right )

      out_var = create_commands( commands, tok )

    end

  }

  # Add the final command to get the completed equation value into the
  # variable where the user wants it

  final_equate_command( commands, output_name, out_var )

  # Join together the command stack

  commands.join( "\n" )

end

# process_java_file( file_name )
#
# file_name - The name of the Java file
#
# This takes a Java file, reads it, processes the equation sections, backs up
# the original file and replaces the file with the new Java code where the
# equations have been implemented.

def process_java_file( file_name )

  # Read the file

  fh = File.open( file_name )
  text = fh.read()
  fh.close()

  # Maintain a count of the number of equations we have processed

  count = 0

  # Find the equations

  text.gsub!( /\/\/\s+bdgen_start\s+<(.*?)>(.*?)\/\/\s+bdgen_end/m ) {

    # Get the equation

    eq = $1

    # Increment the count

    count += 1

    # Create the new section with the equation implemented in the interior

    out = "// bdgen_start <#{eq}>\n"
    out += parse_equation( eq )
    out += "\n// bdgen_end"

    # Return it as a the new text within that section
  
    out

  }

  # Back up the file

  File.copy( file_name, "#{file_name}.bak" )

  # Build the new file
 
  File.open( file_name, "w" ).write( text )

  # Tell the user what we have done
  
  print "Built #{count} equations in #{file_name}\n"

end


# Process the file name on the command line if there is one.  Complain if
# there is no file name specified.

if ( ARGV[0] )

  process_java_file( ARGV[ 0 ] )

else

  print "Usage: bdgen myfile.java\n"

end

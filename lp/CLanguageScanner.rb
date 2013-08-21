# File: CLanguageScanner.rb
# Author: Jack Herrington
# Purpose: The CLanguageScanner object specialized to look for C prototypes
# Date: 12/21/02

require "Tokenizer"
require "Language"

# class : CLanguageScanner
#
# This is the CLanguageScanner specialized to read prototypes for C
# functions.

class CLanguageScanner < LanguageScanner

  # initialize()
  #
  # Constructs the C language scanner class

  def initialize()
  
    # Create the prototype array
  
    @prototypes = []

  # Create the defines array
  
  @defines = {}

    # Set the prototype class to build to the default
    # prototype class
  
    @prototypeClass = Prototype
  
  end

  attr_reader :prototypes        # The array of prototypes found
  attr_accessor :prototypeClass  # The prototype class to build
  attr_reader :defines           # The array of '#defines' found

  def to_s()

    text = "Prototypes:\n"

    @prototypes.each { |proto|
      text += "  #{proto}\n"
    }

  text += "\nDefines:\n"

    @defines.each { |key,value|
      text += "  #{key} = '#{value}'\n"
    }

    text

  end

  # parse( tokens )
  #
  # tokens - An array of tokens built by a Tokenizer
  # 
  # This method reads the stream of tokens built by a Tokenizer
  # and fills the @prototypes array with the prototypes 
  # that are found.

  def parse( tokens )

    # This is the code fragment leading up to the interior
    # of the function

    codefrag = TokenStream.new()

    # 'level' is the level of bracket nesting.

    level = 0

    # This will be true if we are looking at precompiler tokens

    hold_until_return = false
  
  # This will be true if we are looking for a '#define'

  parsing_define = false
  define_name = nil
  define_value = nil

    # Look through each token
  
    tokens.each { |tok|

      if ( parsing_define )

  	    unless ( define_name )
  	
  	      define_name = tok.to_s if ( tok.is_a?( CodeToken ) )

  	    else

          if ( tok.to_s =~ /^\n/ )

  		    define_value.strip!
  		    @defines[ define_name ] = define_value.to_s

  		    parsing_define = false
  		    define_name = nil
  		    define_value = nil

  	      else

  		    define_value.push( tok )

  	      end

        end

        next

      elsif ( hold_until_return )

        hold_until_return = false if ( tok.to_s =~ /^\n/ )
        next

      end
  
      if tok.to_s =~ /^#define$/

		# This is a #define macro, so we need to start parsing
		# it
		
  	    parsing_define = true
  	    define_name = nil
        define_value = TokenStream.new()

      elsif tok.to_s =~ /^#/

        # This is a precompiler directive, so
        # we should ignore all of the tokens
        # until a return

        hold_until_return = true
      
      elsif tok.to_s == "{"

        # If we are at level zero then we are
        # opening a function for code, so we
        # should interpret what we have
        # up until now.
  
        if level == 0
  
          parse_prototype( codefrag )

          codefrag = TokenStream.new()
  
        end

        # Now increment the level
  
        level += 1
  
      elsif tok.to_s == "}"

        # Decrement the level
  
        level -= 1
  
      elsif tok.to_s == ";"

        # If we see a ";" and we are at level
        # zero then we have a constant
        # declaration 
  
        codefrag = TokenStream.new() if ( level == 0 )
  
      else

        # Otherwise push the fragment
  
        codefrag.push( tok ) if level == 0
  
      end
  
    }
  
  end

protected

  # clean_comment( comment )
  #
  # comment - The comment text
  #
  # This removes the actual comment prefixes from the comment
  # text (e.g. /*, */, //)

  def clean_comment( comment )

    if ( comment =~ /^\/\*/ )
  
      comment.sub!( /^\/\*/, "" )
      comment.sub!( /\*\/$/, "" )
  
    else
  
      comment.gsub!( /^\/\//, "" )
  
    end
  
    comment.strip!()
    comment

  end

  # parse_declaration( codefrag )
  #
  # codefrag - The code token array
  #
  # This turns the set of tokens that represent a declaration
  # ("int *a[]") into a name ("a"), a type "int *", and an
  # array boolean (true).

  def parse_declaration( codefrag )

    code = codefrag.code_only

    # Check for an equals with a value

    value = nil

    if ( code.find( "=" ) )

      value = code.pop
      code.pop

    end

    # By default this will not be an array
  
    array = false

    # Here we are backtracking from the end to find the name
    # within the declaration
  
    while( code.length > 0 )
  
      frag = code.last
  
      array = true if ( frag == "[" )
  
      break unless ( frag == "[" || frag == "]" )
  
      code.delete_at( code.length - 1 )
  
    end

    # We assume that the name is the last non-whitespace,
    # non-array token
  
    name = code.last
  
    code.delete_at( code.length - 1 )

    # Then we build the type from the remainder
  
    type = ""
  
    type = code.map { |tok| tok.to_s }.join( " " )

    type.strip!

    # Look for special cases

    if name.to_s == "void"

      name = CodeToken.new( "" )
      type = "void"

    end

    if name.to_s == "*" || name.to_s == "&"

      type += " #{name.to_s}"
      name = CodeToken.new( "" )

    end

    # Then we return a structure that contains the declaration
    # data
  
    return { 'name' => name, 'type' => type, 'array' => array, 'value' => value }
  
  end

  # parse_prototype( codefrag, comment )
  #
  # codefrag - The tokens leading up to a function definition
  # comment - A comment if one was found
  #
  # This turns the series of tokens leading up to the function
  # definition and turns it into a prototype object which it
  # adds to the prototype list.
  
  def parse_prototype( codefrag, comment = nil )

    # Contains any comments found within the tokens

    comments = TokenStream.new()

      # Add the comment if there is one
    
    comments.push( clean_comment( comment.to_s() ) ) if ( comment )

    # This will be true when we have found the first
    # code token

    found_code = false

    # True when our iterator is within the arguments tokens
  
    in_arguments = false

    # Start contains the tokens before the arguments
  
    start = TokenStream.new()

    # args contains the sets of arguments tokens

    args = TokenStream.new()

    # cur_arg contains the tokens of the argument
    # currently being parsed

    cur_arg = TokenStream.new()

    # Iterate through the codefrag tokens

    codefrag.each { |tok|
  
      # Set found_code to true when we find a CodeToken

      found_code = true if ( tok.is_a?( CodeToken ) )

      # Add the comment if the token is a comment
  
      if tok.is_a?( CommentToken )
  
        comments.push( clean_comment( tok.to_s() ) )
        next
  
      end

      # Go to the next token if we have not found code
  
      next unless ( found_code )

      if tok.to_s == "("

        # Look for the start of the arguments
  
        in_arguments = true
        cur_arg = TokenStream.new()
  
      elsif tok.to_s == ")"

        # Look for the end of the arguments, when
        # we find it we dump out of the iterator
  
        args.push( cur_arg ) if cur_arg.length > 0
        break
  
      elsif in_arguments == false

        # If we are not in the arguments then
        # push these code tokens into the start
        # fragment list
  
        start.push( tok )
  
      else

        # We are in the arguments, so look for
        # the comments that seperate the arguments
  
        if tok.to_s == ","
  
          args.push( cur_arg ) if cur_arg.length > 0
          cur_arg = TokenStream.new()
  
        else
  
          cur_arg.push( tok )
        end
  
      end
  
    }

    # Have the base class build the new prototype
  
    proto = build_prototype()

    # Parse the starting declaration and set the prototype

    start_decl = parse_declaration( start )

    proto.method_name = start_decl['name']
    proto.method_type = start_decl['type']

    # Parse the arguments and add them to the prototype

    args.each { |arg|

      arg_decl = parse_declaration( arg )

      proto.add_argument( arg_decl[ 'name' ], arg_decl['type'] )

    }

    # Add the comments

    comments.each { |comment| proto.add_comment( comment.to_s ) }

    # Add this prototype to the array of found prototypes

    if ( proto.method_type != "class" )

      @prototypes.push( proto )

    end

    proto

  end

  # build_prototype()
  #
  # Builds and returns a prototype object

  def build_prototype()
	@prototypeClass.new()
  end

end

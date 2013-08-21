# File: JavaLanguageScanner.rb
# Author: Jack Herrington
# Purpose: The JavaLanguageScanner object specialized to read Java token streams (from Java files)
# Date: 12/21/02

require "Tokenizer"
require "Language"
require "JavaDoc"

# class : JavaVariable
#
# A specialized ClassVariable that includes the JavaDoc for the class

class JavaVariable < ClassVariable

  # initialize()
  # 
  # Constructor

  def initialize()

    super()

    @javadoc = nil
    @javadocClass = JavaDoc

  end

  attr_reader :javadoc         # The JavaDoc object

  attr_accessor :javadocClass  # The class to use to creat the JavaDoc object

  # comment=( text )
  #
  # text - The comment text
  #
  # Override of the comment set method to not only set the comment but also
  # to parse it into the JavaDoc

  def comment=( text )

  super( text )

    @javadoc = @javadocClass.new() unless ( @javadoc )
    @javadoc.parse( text )

  end

end

# class : JavaClass
#
# A specialization for LanguageClass to handle the JavaDoc markup on a Java
# class declaration

class JavaClass < LanguageClass

  # initialize()
  #
  # Constructor
  
  def initialize()

    super()

    @javadoc = nil
    @javadocClass = JavaDoc

  end

  attr_reader :javadoc          # The JavaDoc attached to the class

  attr_accessor :javadocClass   # The class to use to build the JavaDoc object

  # comments=( text )
  #
  # text - The comment text
  #
  # Overrides the comment text setter to build the JavaDoc as well as setting
  # the comment

  def comments=( text )

  super( text )

    @javadoc = @javadocClass.new() unless ( @javadoc )
    @javadoc.parse( text )

  end

end

# class : JavaPrototype
#
# A derived class of Prototype to account for the JavaDoc attached to the
# prototype

class JavaPrototype < Prototype

  # initialize()
  #
  # Constructor for the class

  def initialize()

    super()

    @javadoc = nil
    @javadocClass = JavaDoc

  end

  attr_reader :javadoc         # The JavaDoc attached to the method

  attr_accessor :javadocClass  # The class to build the JavaDoc object

  # add_comment( text )
  #
  # text - The comment text
  #
  # Overrides the add_comment method to account for the JavaDoc as well as
  # adding the comment.

  def add_comment( text )

    super( text )

    @javadoc = @javadocClass.new() unless ( @javadoc )
    @javadoc.parse( text.to_s )

  end

end

# class : JavaLanguageScanner
#
# This is the JavaLanguageScanner specialized to read prototypes for Java
# functions.

class JavaLanguageScanner < LanguageScanner

  # initialize()
  #
  # Constructs the C language scanner class

  def initialize()

    super()

    @classes = []

    @prototypeClass = JavaPrototype
    @variableClass = JavaVariable
    @classClass = JavaClass
    @javadocClass = JavaDoc

  end

  attr_accessor :prototypeClass # The prototype class to build

  attr_reader :classes          # An accessor for the array of classes found

  attr_accessor :javadocClass   # The class to use when build JavaDoc objects
  
  attr_accessor :variableClass  # The class to use when building variables

  attr_accessor :classClass     # The class to use when building classes

  # to_s()
  #
  # Pretty printer

  def to_s()

  text = ""

  text += "Classes:\n" 

  @classes.each { |jclass|

    text += jclass.to_s

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

    tokens.each_index { |index|

      if ( tokens[ index ].to_s == "class" || tokens[ index ].to_s == "interface" )

        parse_class( tokens, index )

        break;

      end

    }

  end

protected

  # parse_class( tokens, start, base_class = nil )
  #
  # tokens - The full array of tokens in the file
  # start - The start of our class definition
  # base_class - The name of the base class (nil if none)
  #
  # Parses the class and adds it to the class list.

  def parse_class( tokens, start, base_class = nil )

    # Build the class and add it

    class_data = build_class()
    class_data.javadocClass = @javadocClass
    @classes.push( class_data )

    # Backtrack to get the class comment
    
    index = start
    while( index >= 0 )

      break if ( tokens[ index ].to_s == "public" )
      break if ( tokens[ index ].to_s == "private" )
      break if ( tokens[ index ].to_s == "class" )

      index -= 1

    end

    # Add the comments to the class

    comment = tokens.get_comments( index )
    class_data.comments = comment
    class_data.comments.strip!

    # Make sure the name is set to nil, we use nil as a marker in the state
    # machine

    class_data.name = nil

    # This is the code fragment leading up to the interior
    # of the function

    codefrag = TokenStream.new

    # 'level' is the level of bracket nesting.

    level = 0

    # This will be true if we are looking at precompiler tokens

    hold_until_return = false

    # Look through each token

    index = start

    while( index < tokens.length )

      tok = tokens[ index ]

      # Handles parsing the class name

      if ( class_data.name == nil && tok.is_a?( CodeToken ) && tok.to_s != "class" )

        class_name = tok.to_s

        class_name = "#{base_class}.#{class_name}" if ( base_class )

        class_data.name = class_name
        class_data.type = tokens[ start ].to_s

      end

      # Handles parsing the parents of the class

      if ( level == 0 && tok.is_a?( CodeToken ) && class_data.name != nil )

        if ( tok.to_s != "{" && tok.to_s != class_data.name &&
           tok.to_s != "implements" && tok.to_s != "extends" )

        class_data.add_parent( tok.to_s )

        end

      end

      # For imports we wait until a return

      if ( hold_until_return )

        hold_until_return = false if ( tok.to_s =~ /^\n/ )
        next

      end
  
      if tok.to_s == "class" || tok.to_s == "interface"

        # Waiting for the class name

        index = parse_class( tokens, index, class_data.name ) if ( index != start )

        codefrag = TokenStream.new()
      
      elsif tok.to_s == "{"

        # If we are at level zero then we are
        # opening a function for code, so we
        # should interpret what we have
        # up until now.
  
        if level == 1
  
          parse_prototype( class_data, codefrag )

          codefrag = TokenStream.new()
  
        end

        # Now increment the level
  
        level += 1
  
      elsif tok.to_s == "}"

        # Decrement the level
  
        level -= 1

        break if ( level == 0 )
  
      elsif tok.to_s == ";"

        # If we see a ";" and we are at level
        # zero then we have a constant
        # declaration 
  
        if level == 1

          parse_variable( class_data, codefrag )
        
          codefrag = TokenStream.new()

        end

  
      else

        # Otherwise push the fragment
  
        codefrag.push( tok ) if level == 1
  
      end

      index += 1
  
    end

    index
  
  end

  # parse_declaration( codefrag )
  #
  # codefrag - The code token array
  #
  # This turns the set of tokens that represent a declaration
  # ("int *a[]") into a name ("a"), a type "int *", and an
  # array boolean (true).

  def parse_declaration( codefrag )

    # Get just the code
  
    code = codefrag.code_only

    # If we are an assignment declaration then parse that 

    if ( code.find( "=" ) )

      value = code.pop
      code.pop

    end

    # See if we are private, public or protected

    visibility = ""
    visibility = "private" if code.find_and_remove( "private" )
    visibility = "public" if code.find_and_remove( "public" )
    visibility = "protected" if code.find_and_remove( "protected" )

    # Get the static and final values

    static = code.find_and_remove( "static" )
    final = code.find_and_remove( "final" )

    # By default this will not be an array
  
    array = false

    # Here we are backtracking from the end to find the name
    # within the declaration
  
    while( code.length > 0 )
  
      frag = code.last
  
      array = true if ( frag.to_s == "[" )
  
      break unless ( frag.to_s == "[" || frag.to_s == "]" )
  
      code.delete_at( code.length - 1 )
  
    end

    # We assume that the name is the last non-whitespace,
    # non-array token
  
    name = code.last
  
    code.delete_at( code.length - 1 )

    # Then we build the type from the remainder
  
    type = code.map { |tok| tok.to_s }.join( " " )

    # Then we return a structure that contains the declaration
    # data
  
    return {
      'name' => name,
      'type' => type,
      'array' => array,
      'value' => value,
      'visibility' => visibility,
      'static' => static,
      'final' => final
    }
  
  end

  # parse_prototype( class_data, codefrag )
  #
  # class_data - The class object
  # codefrag - The tokens leading up to a function definition
  #
  # This turns the series of tokens leading up to the function
  # definition and turns it into a prototype object which it
  # adds to the prototype list.
  
  def parse_prototype( class_data, codefrag )

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

    # Contains any comments found within the tokens

    comments = TokenStream.new()

    # Iterate through the codefrag tokens

    codefrag.each { |tok|
  
      # Set found_code to true when we find a CodeToken

      found_code = true if ( tok.is_a?( CodeToken ) )

      # Add the comment if the token is a comment
  
      if tok.is_a?( CommentToken )
  
        comments.push( tok.to_s() )
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
        cur_arg = TokenStream.new()
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
    proto.javadocClass = @javadocClass

    # Parse the starting declaration and set the prototype

    start_decl = parse_declaration( start )

    proto.class_name = class_data.name
    proto.method_name = start_decl['name']
    proto.method_type = start_decl['type']
    proto.static = start_decl['static']
    proto.visibility = start_decl['visibility']

    # Parse the arguments and add them to the prototype

    args.each { |arg|

      arg_decl = parse_declaration( arg )

      proto.add_argument( arg_decl[ 'name' ], arg_decl['type'] )

    }

    # Add the comments

    comments.each { |comment| proto.add_comment( comment.to_s ) }

    # Add this prototype to the array of found prototypes

    class_data.add_method( proto )

  end

  # parse_variable( class_data, codefrag )
  #
  # class_data - The class to which we add the variable declaration
  # codefrag - The code fragmen that describes the variable
  #
  # Parses a variable declaration and adds it to the class

  def parse_variable( class_data, codefrag )

    # Get the comments

    comment = codefrag.comments_only.to_s

    # Get the declaration

    varData = parse_declaration( codefrag )

    # Build the variable object and populate it

    varObj = build_variable()
    varObj.javadocClass = @javadocClass
    varObj.name = varData[ 'name' ]
    varObj.type = varData[ 'type' ]
    varObj.value = varData[ 'value' ]
    varObj.visibility = varData[ 'visibility' ]
    varObj.static = varData[ 'static' ]
    varObj.comment = comment

    # Add it to our class

    class_data.add_variable( varObj )

  end

  # build_variable()
  #
  # Builds a new variable object

  def build_variable()

    @variableClass.new()

  end

  # build_class()
  #
  # Builds a new class object

  def build_class()

    @classClass.new()

  end

  # build_prototype()
  #
  # Builds and returns a prototype object

  def build_prototype()
  
    @prototypeClass.new()

  end

end

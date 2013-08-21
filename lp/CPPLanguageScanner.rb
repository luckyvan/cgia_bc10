# File: CPPLanguageScanner.rb
# Author: Jack Herrington
# Purpose: The CPPLanguageScanner object specialized to look for C++ language
#          features.
# Date: 12/21/02

require "Tokenizer"
require "CLanguageScanner"

# Class : CPPLanguageScanner
# 
# The scanner specialized for processing C++ headers.

class CPPLanguageScanner < CLanguageScanner

  # initialize()
  #
  # Constructs the scanner object

  def initialize()

    super()

    @classes = []

    @prototypeClass = Prototype
    @variableClass = ClassVariable
    @languageClass = LanguageClass

  end

  attr_reader :classes            # The classes found

  attr_accessor :languageClass    # The class to use when building class objects

  attr_accessor :variableClass    # The class to use when building variable objects

  # parse( tokens )
  #
  # tokens - Tokens returned from CTokenizer
  #
  # Parses the tokens read from the CTokenizer

  def parse( tokens )

    # Handle the function prototypes in the base class
  
    super( tokens )

    # Set up the code buffer
  
    codefrag = TokenStream.new()

    # Set up the state machine flags

    has_class = false
    found_open = false
    level = 0
    comments = ""

    # Look through the tokens for classes, and build up the full class bodies
    # in codefrag.  Then send the codefrags on to parse_class

    tokens.each_index { |index|

      tok = tokens[ index ]

      if ( has_class )

        comments = tokens.get_comments( index )

        codefrag.push( tok )

        if ( tok.to_s == "{" )

          level += 1

          found_open = true

        end

        level -= 1 if ( tok.to_s == "}" )

        if ( tok.to_s == ";" && level == 0 )

          parse_class( codefrag, comments ) if ( codefrag.length > 0 && found_open )

          codefrag = TokenStream.new()

          has_class = false
          found_open = false

        end

      end

      has_class = true if ( tok.to_s.downcase == "class" && level == 0 )

    }

    parse_class( codefrag, comments ) if ( codefrag.length > 0 && found_open )

  end

  # to_s()
  #
  # A pretty printer for the object

  def to_s()

    text = ""

    classes.each { |cpp_class| text += cpp_class.to_s }

    text

  end

protected

  # parse_class( codefrag, comments )
  # 
  # codefrag - The class tokens
  # comments - The comments before the class
  #
  # Parse the class tokens to find methods, instance variables, constants,
  # etc.
  
  def parse_class( codefrag, comments )

    class_data = build_class()

    proto = TokenStream.new()

    level = 0

    visibility = "public"

    comments = TokenStream.new()

    codefrag.each { |tok|

      break if ( tok.to_s == "}" && level == 1 )

      if ( level == 0 )

        next if tok.to_s == ":" || tok.to_s == "public"
        next if tok.to_s == "private" || tok.to_s == ","

        next unless tok.is_a?( CodeToken )

        if ( class_data.name.length == 0 )

          class_data.name = tok.to_s

        else

          class_data.add_parent( tok.to_s ) unless ( tok.to_s == "{" )

        end

      else

        if ( tok.to_s =~ /^public$/ )

          visibility = "public"
          comments = TokenStream.new()
          proto = TokenStream.new()

        elsif ( tok.to_s =~ /^private$/ )

          visibility = "private"
          comments = TokenStream.new()
          proto = TokenStream.new()

        elsif ( tok.to_s =~ /^protected$/ )

          visibility = "protected"
          comments = TokenStream.new()
          proto = TokenStream.new()

        elsif ( tok.is_a?( CommentToken ) )
          
            comments.push( tok ) if ( level == 1 )

        elsif ( tok.to_s == ":" && level == 1 )

        elsif ( tok.to_s == ";" && level == 1 )
          
          parse_method_prototype( class_data, visibility, proto, comments ) if proto.length > 0
          comments = TokenStream.new()
          proto = TokenStream.new()

        elsif ( level ==  1 )

            proto.push( tok )

        end

      end

      if ( tok.to_s == "{" )

        parse_method_prototype( class_data, visibility, proto, comments ) if proto.length > 0
        comments = TokenStream.new()
      
        level += 1

      end

    }

    @classes.push( class_data )

  end

  # parse_method_prototype( class_data, visibility, codefrag, comment )
  #
  # class_data - The current class object
  # visibility - 'private', 'protected', or 'public'
  # codefrag - The tokens of the prototype
  # comment - The comments before the method declaration
  
  def parse_method_prototype( class_data, visibility, codefrag, comment )

    # Get down to just the code, no comments or whitespace

    code = codefrag.code_only

    # The primary switch is whether this is a method or an instance variable.
    # That's decided on the existence of the paren.

    if ( code.find( "(" ) )

      # Get the prototype

      proto = parse_prototype( codefrag, comment )

      # Add in the visibility

      proto.visibility = visibility

      # Check for a static method

      if ( proto.method_type =~ /^static/ )

        proto.method_type.sub!( /^static\s+/, "" )
        proto.static = true
     
      end

      # Add this method into the class

      class_data.add_method( proto )

    else

      # Build the variable object
    
      varItem = build_class_variable()

      # Parse the declaration
    
      varSpec = parse_declaration( codefrag )

      # Look for static

      static = false
      if ( varSpec[ 'type' ] =~ /^static/ )

        varSpec[ 'type' ].sub!( /^static\s+/, "" )
        static = true
     
      end

      # Look for const

      if ( varSpec[ 'type' ] =~ /^const/ )

        varSpec[ 'type' ].sub!( /^const\s+/, "" )
        const = true
     
      end

      # Fill the fields of the object mainly with the return from
      # parse_declaration

      varItem.name = varSpec[ 'name' ]
      varItem.type = varSpec[ 'type' ]
      varItem.value = varSpec[ 'value' ]
      varItem.static = static
      varItem.const = const
      varItem.visibility = visibility
      varItem.comment = comment

      # Add the variable to the class

      class_data.add_variable( varItem )

    end

  end

  # build_class_variable()
  #
  # Returns a new class variable object

  def build_class_variable

    @variableClass.new()

  end

  # build_class()
  #
  # REturns a new class object

  def build_class

    @languageClass.new()

  end

end

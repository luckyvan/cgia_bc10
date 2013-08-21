# File: SQLLanguageScanner.rb
# Author: Jack Herrington
# Purpose: The SQLLanguageScanner object specialized to look for SQL language elements
# Date: 12/21/02

require "Tokenizer"
require "Language"

# class : SQLField
#
# Represents a field in a table.

class SQLField

  # initialize()
  #
  # The constructor

  def initialize()

    @name = ""
    @type = ""
    @not_null = false
    @unique = false
    @primary_key = false
    @comment = ""

  end

  attr_accessor :name         # The name of the field
  attr_accessor :type         # The type of the field
  attr_accessor :unique       # True if the field is unique
  attr_accessor :not_null     # True if the field is non-null
  attr_accessor :primary_key  # True if the field is the primary key
  attr_accessor :comment      # Any comment associated with the field

  # to_s()
  #
  # Pretty prints the field as text

  def to_s()

    attributes = []
    attributes.push( "not null" ) if ( @not_null )
    attributes.push( "unique" ) if ( @unique )
    attributes.push( "primary key" ) if ( @primary_key )

    "#{@name} - #{@type} - #{attributes.join(',')}"

  end

end

# class : SQLTable
#
# Represents an SQL table definition

class SQLTable

  # initialize()
  #
  # Constructor

  def initialize()

    @name = ""
    @fields = []
    @field_hash = {}
    @comment = ""

  end

  attr_accessor :name    # The name of the table
  attr_reader :fields    # The fields of the table
  attr_accessor :comment # The comment associated with the table

  # add_field( field )
  #
  # field - The field object
  #
  # Adds a field to the table
  
  def add_field( field )

    @fields.push( field )
    @field_hash[ field.name.to_s.downcase ] = field

  end

  # get_field( name )
  #
  # name - The name of the field
  #
  # Fetchs a field object based on it's name

  def get_field( name )
    @field_hash[ name.downcase ]
  end

end

# class : SQLLanguageScanner
#
# This is the SQLLanguageScanner which is an object specialized to read the important language
# elements of an SQL file.

class SQLLanguageScanner < LanguageScanner

  # initialize()
  #
  # Constructs the SQL language scanner class

  def initialize()

    @tables = []
    @table_hash = {}
    @tableClass = SQLTable
    @fieldClass = SQLField

  end

  attr_reader :tables           # The array of tables
  attr_accessor :tableClass     # The class to use to build Table objects
  attr_accessor :fieldClass     # The class to use to build Field objects

  # to_s()
  #
  # Pretty printer for this object

  def to_s()

    text = ""

    tables.each { |table|

      text += "#{table.name}:\n"

      table.fields.each { |field|
        text += "  #{field}\n"
      }

      text += "Comment:\n#{table.comment.strip}\n"
      text += "\n"

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
  
    has_create = false

    building_table = false

    # Look through each token

    comment = ""

    tokens.each_index { |index|

      tok = tokens[ index ]

      if tok.to_s =~ /^create$/i

        comment = tokens.get_comments( index )

        has_create = true
      
      elsif tok.to_s =~ /^table$/i && has_create

        building_table = true
        has_create = false
  
      elsif tok.to_s == ";" && building_table

        parse_table( codefrag, comment )

        codefrag = TokenStream.new()

        building_table = false
        has_create = false
        comment = ""
      
      elsif has_create && tok.is_a?( CodeToken ) 

        has_create = false
  
      elsif building_table

        codefrag.push( tok )
  
      end
  
    }
  
  end

protected

  # parse_table( codefrag, comment )
  #
  # codefrag - The table tokens
  # comment - The associated comment
  #
  # Parses table tokens into a table object

  def parse_table( codefrag, comment )

    codefrag.strip!

    table_name = codefrag[ 0 ].to_s

    start_table( table_name, comment )
    
    field_def = TokenStream.new()

    in_parens = 0

    codefrag.each { |tok|

      if ( tok.to_s == ")" )

        if ( field_def.length > 0 && in_parens == 1 )
  
          parse_field( table_name, field_def )

          field_def = TokenStream.new()

        end

        in_parens -= 1

      end

      if ( tok.to_s == "," )

        parse_field( table_name, field_def ) if ( field_def.length > 0 )
        field_def = TokenStream.new()

      elsif ( in_parens > 0 )

        field_def.push( tok ) unless ( tok.is_a?( CommentToken ) )

      end

      if ( tok.to_s == "(" )

        in_parens += 1 

      end

    }

  end

  # The field_attributes class constant defines series of patterns that
  # trigger specific modifications to field objects.  For examples the 'not
  # null' keywords set the not_null variable in the field object if they are
  # found.

  @@field_attributes = [
    { :strings => [ "not", "null" ], :found => lambda { |field| field.not_null = true } },
    { :strings => [ "unique" ], :found => lambda { |field| field.unique = true } }
    ]

  # get_field_attributes()
  #
  # Returns the the array of field_attributes.  This method could be
  # overridden if there we extra field attributes for a specific SQL syntax.

  def get_field_attributes()

    @@field_attributes

  end

  # parse_field( table_name, codefrag )
  #
  # table_name - The table being parsed
  # codefrag - The field definition
  #
  # Parses a field definition associated with a table

  def parse_field( table_name, codefrag )

    # Get just the code tokens from the fragment

    codefrag.strip!
    code_stream = codefrag.code_only

    # Get the field name

    field = build_field()
    field.name = code_stream.shift

    # Build the field type

    type = code_stream.shift.to_s

    inParen = false

    while( code_stream.length > 0 )

      if code_stream.first.to_s == "[" || code_stream.first.to_s == "("

    inParen = true
        type += code_stream.shift.to_s

    elsif code_stream.first.to_s == "]" || code_stream.first.to_s == ")"

    inParen = false
        type += code_stream.shift.to_s

    elsif ( inParen )

        type += code_stream.shift.to_s

      else

        break

      end

    end

    field.type = type

    # Look for special field attributes (e.g. not null, unique)

    begin

      found = false

      get_field_attributes.each { |field_attr|

        strings = field_attr[ :strings ]

        found_lambda = field_attr[ :found ]

        if ( code_stream.length >= strings.length )

          found = true

          strings.each_index { |index|

            found = false unless ( code_stream[ index ].to_s.downcase == strings[ index ].to_s.downcase )

          }

        end

        if found

          strings.each_index { code_stream.shift }

          found_lambda.call( field )

          break

        end

      }

    end while ( found )

    add_field( table_name, field )

    field

  end

  # start_table( table_name, comment )
  #
  # table_name - The name of the table
  # comment - The associated comment
  #
  # Builds a new table and gets it ready for fields

  def start_table( table_name, comment )

    unless @table_hash[ table_name ]

      table = build_table
      table.name = table_name
      table.comment = comment

      @table_hash[ table_name ] = table

      @tables.push( table )

    end

  end

  # add_field( table_name, field )
  #
  # table_name - The name of the table
  # field - The field object
  #
  # Adds a field to the specified table

  def add_field( table_name, field )
    @table_hash[ table_name ].add_field( field )
  end

  # build_table()
  #
  # Builds a new table

  def build_table()
    @tableClass.new()
  end

  # build_field()
  #
  # Builds a new field

  def build_field()
    @fieldClass.new()
  end

end

# class : PostgreSQLScanner
#
# An SQLLanguageScanner specialized to read PostgreSQL.

class PostgreSQLScanner < SQLLanguageScanner

  # initialize()
  #
  # Constuctor

  def initialize()
  
    # Create the prototype array

    @prototypes = []

    # Set the prototype class to build to the default
    # prototype class

    @prototypeClass = Prototype

    super()

  end

  attr_reader :prototypes        # The array of prototypes found
  attr_accessor :prototypeClass  # The prototype class to build

  # to_s()
  #
  # Pretty prints the result

  def to_s()

    text = "Prototypes:\n"

    @prototypes.each { |proto|
      text += "  #{proto}\n"
    }

    text += "\nPrototypes:\n"

    @prototypes.each { |proto|
      text += "  #{proto}\n"
    }

    text += "\n"
    text

  end

  # parse( tokens )
  #
  # tokens - Tokens returned from SQLTokenizer
  #
  # An override of the parser to add parsing of stored procedure prototypes

  def parse( tokens )

    super( tokens )

    # This is the code fragment leading up to the interior
    # of the function

    codefrag = TokenStream.new()
  
    has_create = false

    building_function = false

    waiting_for_language = false

    # Look through each token

    comment = ""

    tokens.each_index { |index|

      tok = tokens[ index ]

      if tok.to_s =~ /^create$/i

        comment = tokens.get_comments( index )

        has_create = true

      elsif waiting_for_language

        waiting_for_language = false if tok.to_s =~ /^language$/
      
      elsif tok.to_s =~ /^function$/i && has_create

        building_function = true
  
      elsif tok.to_s =~ /^declare$/i && building_function

        parse_function( codefrag, comment )

        codefrag = TokenStream.new()

        building_function = false
        has_create = false
        waiting_for_language = true
        comment = ""
  
      elsif building_function

        codefrag.push( tok )
  
      end
  
    }

  end

protected

  # parse_field( table_name, codefrag )
  #
  # table_name - The table name
  # codefrag - The tokens of the field definition
  #
  # Overrides field parsing to handle PostgreSQL specific syntax

  def parse_field( table_name, codefrag )

    # Dump any leading or trailing whitespace tokens

    codefrag.strip!

    # Look for the constraint keyword.  If you find it look for the primary
    # key identifier

    if ( codefrag[0].to_s =~ /^constraint$/i )

      id_field = nil

      codefrag.find_pattern(
        [ "primary", "key", "(", lambda { |value| id_field = value }, ")" ]
      )

      # If we found it then id_field will be set to the name of the id field

      if ( id_field )

        field = @table_hash[ table_name ].get_field( id_field )
        field.primary_key = true

      end

    else

      # If this is not a constraint then let the base class handle the field
      # parsing

      super( table_name, codefrag )

    end

  end

  # parse_argument( proto, arg )
  #
  # proto - The prototype object
  # arg - The argument
  #
  # Adds an argument name to the prototype

  def parse_argument( proto, arg )

    proto.add_argument( arg[0].to_s() )

  end

  # parse_function( codefrag, comment )
  #
  # codefrag - The tokens of the function
  # comment - The preceding comment
  #
  # Parses a stored procedure prototype

  def parse_function( codefrag, comment )

    # Create the prototype object

    proto = build_prototype()

    # Get just the code tokens

    code = codefrag.code_only

    # Get the method name

    proto.method_name = code.shift.to_s()
    proto.add_comment( comment.strip )

    # Build token sets of the arguments and then pass them on
    # to parse_argument

    in_parens = false

    arg = TokenStream.new()

    code.each { |tok|

      in_parens = false if ( tok.to_s == ")" )

      if ( in_parens )

        if ( tok.to_s == "," )

          parse_argument( proto, arg ) if ( arg.length > 0 )
          arg = TokenStream.new()

        else

          arg.push( tok )

        end

      end

      in_parens = true if ( tok.to_s == "(" )

    }

    parse_argument( proto, arg ) if ( arg.length > 0 )

    # Get the return type

    index = code.find( "returns" )
    proto.method_type = code[ index + 1 ].to_s()

    # Add the prototype

    @prototypes.push( proto )

  end

  # build_prototype()
  #
  # Builds and returns a prototype object

  def build_prototype()
    @prototypeClass.new()
  end

end

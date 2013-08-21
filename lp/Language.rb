# File: Language.rb
# Author: Jack Herrington
# Purpose: The basic language classes
# Date: 12/21/02

# class : ClassVariable
#
# A data structure class to store all of the information about the variables
# associated with a class

class ClassVariable

  # initialize()
  #
  # Constructor
  
  def initialize()

    @name = nil
    @type = nil
    @static = false
    @const = false
    @visibility = nil
    @value = nil
    @comment = ""

  end

  attr_accessor :name         # The name of the variable

  attr_accessor :type         # The type of the variable

  attr_accessor :static       # True if it's static

  attr_accessor :const        # True if it's const

  attr_accessor :visibility   # "public", "private" or "protected"

  attr_accessor :value        # The value of the variable 

  attr_accessor :comment      # The comment surrounding the variable

  # to_s()
  #
  # Pretty printing the variable

  def to_s()

    text = "#{name} - #{type}"

    text += " - #{@visibility}" if ( @visibility )
    text += " - const" if ( @const )
    text += " - static" if ( @static )
    text += " = #{@value}" if ( @value )

    text

  end

end

# class : LanguageClass
#
# This is a simple data structure that defines what we know about a given
# class.  Ruby already has a class named 'Class', so we called this one
# 'LanguageClass' to avoid collisions.

class LanguageClass

  # initialize()
  #
  # Constructor

  def initialize()

    @type = "class"
    @name = ""
    @comments = ""
    @parents = []
    @methods = []
    @variables = []

  end

  attr_accessor :type     # The type of class (could be interface, or struct)
  attr_accessor :name     # The name of the class
  attr_reader :methods    # The array of methods
  attr_reader :variables  # The array of instance variables (or constants)
  attr_accessor :comments # The text of any comments
  attr_reader :parents    # An array of parent class names

  # add_method( method )
  #
  # method - The method object
  #
  # Adds a method

  def add_method( method )
    @methods.push( method )
  end

  # add_parent( parent )
  #
  # parent - The parent name as text 
  #
  # Adds a parent class

  def add_parent( parent )
    @parents.push( parent )
  end

  # add_variable( variable )
  #
  # variable - The variable object
  #
  # Adds a variable to the class definition

  def add_variable( variable )
    @variables.push( variable )
  end

  # to_s()
  #
  # Pretty printing string converter

  def to_s()

    text = "class : #{@name} - "
    text += @parents.join( ", " )
    text += "\n"

    text += "Methods:\n"

    methods.each { |method|
      text += "  #{method}\n"
    }

    text += "Variables:\n"

    variables.each { |var|
      text += "  #{var}\n"
    }

    text

  end

end

# class : PrototypeComment
#
# The class represents a comment in the prototype.

class PrototypeComment

  # initialize()
  #
  # Constructs the object

  def initialize() @text = ""; end

  attr_accessor :text   # The text of the comment

  # to_s()
  #
  # Turns this object into text

  def to_s() @text; end

end

# class : PrototypeArgument
#
# This class represents arguments on the prototype.

class PrototypeArgument

  # initialie()
  #
  # Constucts the argument object

  def initialize()

    @name = nil
    @type = nil

  end

  attr_accessor :name    # The argument name
  attr_accessor :type    # The argument type

  # to_s()
  #
  # Turns this argument into a string

  def to_s() @type ? "#{@name} - #{@type}" : @name; end

end

# class : Prototype
#
# This class stores all of the information about a prototype

class Prototype

  # initialize()
  #
  # Constructs the Prototype object

  def initialize()

    @class_name = nil
    @method_name = nil
    @method_type = nil
    @arguments = []
    @comments = []
    @static = false
    @visibility = nil

  end

  attr_accessor :visibility    # Visibility of the method (public, private, etc.)
  attr_accessor :static        # True if the method is static
  attr_accessor :class_name    # The class name
  attr_accessor :method_name   # The name of the method
  attr_accessor :method_type   # The return type of the method
  attr_reader :arguments       # The method arguments
  attr_reader :comments        # Comments associated with the method

  # to_s()
  #
  # Returns the object pretty printed as a string

  def to_s()

    text = "#{method_name} - #{method_type} - "
    text += "( #{@arguments.map{ |arg| arg.to_s }.join(', ')} )"

    text += " - #{@visibility}" if ( @visibility )
    text += " - static" if ( @static )

    text

  end

  # add_argument( name, type )
  #
  # name - The name of the argument
  # type - The type of the argument
  #
  # Adds an argument to the ordered argument list

  def add_argument( name, type = nil )

    arg = PrototypeArgument.new()
    arg.name = name
    arg.type = type
    @arguments.push( arg )

  end

  # add_comment( text )
  #
  # text - The text of the comment
  #
  # Adds a comment to the prototype

  def add_comment( text )

    comment = PrototypeComment.new()
    comment.text = text 
    @comments.push( comment )

  end

end

# class : LanguageScanner
#
# This is the base class for scanners which turn tokens streams
# into prototypes and other language specific elements.  
# It is meant to be overridden for each language.

class LanguageScanner

  def parse( tokens )

  end

end

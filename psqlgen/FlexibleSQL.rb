# File: FlexibleSQL.rb
# Author: Jack D. Herrington
# Purpose: Handles SQL strings marked up with replacement variable names
# Date: 01/30/03

class FlexibleSQL

  # initialize( sql, type )
  #
  # sql - The original SQL string
  # type - Either insert, update, delete or select
  #
  # Constructs a FlexibleSQL object
  
  def initialize( sql, type )

    @type = type
    @original_sql = sql

    @perl_sql = ""
    @bound_variables = {}
    @perl_mapped = []

    parse()

  end

  attr_reader :perl_sql   # The SQL string as a Perl string

  # perl_binds()
  #
  # Returns the finished bind method calls

  def perl_binds()

    str = ""

    @bound_variables.keys.each() { |item|

      str += "#{$sth_prefix}#{$next_sth}->bind_param"
      str += "( \"#{item}\", #{@bound_variables[item]} );\n";

    }

    str

  end

  # perl_mapped()
  #
  # Returns the mapped variables as a string of comma seperated values
  
  def perl_mapped()

    @perl_mapped.join( ", " )

  end

private

  # parse()
  #
  # Parse the original SQL string
  
  def parse()

    repIndex = 0

    # Handle and replacement variables

    @perl_sql = @original_sql.gsub( /<<\s*(.*?)\s*>>/ ) {

      # Add a replacement bound variable
      
      repIndex += 1

      repName = "repvar" + repIndex.to_s()

      @bound_variables[ repName ] = $1

      ":" + repName

    }

    # Handle an in-place Perl variables

    @perl_sql.gsub!( /<\$\s*(.*?)\s*\$>/ ) {

      # Build the field name and Perl variable name

      field = $1
      field.strip!

      name = field
      perl_name = "$" + field

      field.scan( /(\w+)\(([^)]*)\)/ )
      if ( $1 && $2 )
        name = $1
        perl_name = $2
      end

      name.strip!
      perl_name.strip!

      # Add those into the mapped array

      @perl_mapped.push( perl_name )

      name

    }

    # Handle replacement syntax for insert and update
    
    @perl_sql.gsub!( /\*\*\s*(.*?)\s*\*\*/ ) {

      # Get the field list

      field_list = $1
      field_list.strip!()

      fields = []
      boundRealNames = []

      # Iterate through the field list

      field_list.split( "," ).each { |field|

        # Get the field name and the Perl variable name

        field.strip!

        name = field
        perl_name = "$"+field

        md = field.scan( /(\w+)\(([^)]*)\)/ )

        if ( defined? md[0][0] && defined? md[0][1] )

          name = md[0][0]

          perl_name = md[0][1]

        end

        name.strip!
        perl_name.strip!

        # Add that to the bound variables

        repIndex += 1
        repName = "repvar#{repIndex}"
        @bound_variables[ repName ] = perl_name

        boundRealNames.push( ":" + repName )
        fields.push( name )

      }

      # Manage the field name to bound variables differently depending on whether we 
      # are building an update or an insert operation

      if ( @type == "insert" )

        fieldNames = fields.join( ", " )

        boundNames = boundRealNames.join( ", " )

        "( #{fieldNames} ) values ( #{boundNames} ) "

      elsif ( @type == "update" )

        joinedItems = []

        index = 0

        fields.each { |field|

          joinedItems.push( field + "=" + boundRealNames[ index ] )

          index += 1

        }

        joinedItems.join( ", " )

      else

        ""

      end

      }

  end

end

#!/usr/bin/ruby   

# File: ejbgenDefs.rb
# Author: Eric Rollins 2002
# Purpose: Helper classes and constants for the EJB generator

# SQL datatypes

SQL_INTEGER = "integer"
SQL_VARCHAR = "varchar"

# Java datatypes

JAVA_INTEGER = "Integer"
JAVA_STRING = "String"

# File names and paths

DEF_DIR = "definitions/"
OUT_DIR = "output/"
TEMPLATE_DIR = "templates/"
SCHEMA_FILE = DEF_DIR + "schema.xml"
EXTENSIONS_FILE = DEF_DIR + "extensions.xml"
SAMPLES_FILE = DEF_DIR + "samples.xml"
SQL_TEMPLATE = TEMPLATE_DIR + "tables.sql.template"
ENTITY_TEMPLATE = TEMPLATE_DIR + "Entity.java.template"
ENTITY_HOME_TEMPLATE = TEMPLATE_DIR + "EntityHome.java.template"
ENTITY_BEAN_TEMPLATE = TEMPLATE_DIR + "EntityBean.java.template"
VALUE_TEMPLATE = TEMPLATE_DIR + "Value.java.template"
SS_TEMPLATE = TEMPLATE_DIR + "SS.java.template"
SS_HOME_TEMPLATE = TEMPLATE_DIR + "SSHome.java.template"
SS_BEAN_TEMPLATE = TEMPLATE_DIR + "SSBean.java.template"
EJB_JAR_TEMPLATE = TEMPLATE_DIR + "ejb-jar.xml.template"
JBOSS_XML_TEMPLATE = TEMPLATE_DIR + "jboss.xml.template"
JBOSS_CMP_TEMPLATE = TEMPLATE_DIR + "jbosscmp-jdbc.xml.template"
LIST_JSP_TEMPLATE = TEMPLATE_DIR + "List.jsp.template"
ADD_JSP_TEMPLATE = TEMPLATE_DIR + "Add.jsp.template"
UPDATE_JSP_TEMPLATE = TEMPLATE_DIR + "Update.jsp.template"
DELETE_JSP_TEMPLATE = TEMPLATE_DIR + "Delete.jsp.template"
INDEX_JSP_TEMPLATE = TEMPLATE_DIR + "index.jsp.template"
CUSTOM_JSP_TEMPLATE = TEMPLATE_DIR + "Custom.jsp.template"
SS_FACTORY_TEMPLATE = TEMPLATE_DIR + "SSFactory.java.template"
TESTS_TEMPLATE = TEMPLATE_DIR + "Tests.java.template"
SQL_OUT_FILE = OUT_DIR + "tables.sql"
JAVA_OUT_DIR = OUT_DIR + "gen/"
TESTS_OUT_DIR = OUT_DIR + "tests/"
JSP_OUT_DIR = OUT_DIR + "jsp/"
XML_OUT_DIR = OUT_DIR + "META-INF/"
VALUE_SUFFIX = "Value"

#============================================================================
# Globals
#============================================================================

$tables = {}      # Hash of all Table objects, hashed by table name
$table = nil      # current table used by ERB
$package = nil    # name of java package
$jndiPrefix = nil # prefix for bean jndi names
$valueObjs = {}   # Hash of all Value objects, hashed by value name
$valueObj = nil   # current value used by ERB
$sampleRows = []  # Array of all SampleRow objects
        
# Class: Table
#
# This class models a database table. The Generator creates a EntityBean
# and Stateless Session Facade bean for each table, so this Class also
# contains information about these.

class Table

  attr_reader :name           # String name of Table in database

  attr_reader :columns        # Hash of Column objects belonging to this Table,
                              # hashed by column name

  attr_reader :columnsArray   # Array of Column objects belonging to this Table
                              # (used to maintain columns in same order as database)

  attr_reader :referredBy     # Array of Column objects belonging to other
                              # Tables which point to this Table (useful for CMR)

  attr_reader :hasSequence    # should a sequence be generated (TRUE or FALSE)

  attr_reader :primaryKey     # Column (1st) of primary key (used by sequence)

  attr_reader :valueObjs      # Hash of Value objects based on this
                              # table, hashed by value object name

  attr_reader :fmethods       # Hash of Stateless Session Bean Facade 
                              # methods for this table; hashed on name

  attr_reader :fmethodsArray  # Array of Stateless Session Bean
                              # Facade methods for this table

  # initialize( name )
  #
  # name - The name of the table
  #
  # Constructs the object

  def initialize( name )

    @name = name
    @columns = {}
    @referredBy = []
    @columnsArray = []
    @valueObjs = {}
    @fmethods = {}
    @fmethodsArray = []
    $tables[name] = self
    m = FMethod.new(self, "findAll")
    m.ejbQL = "SELECT OBJECT(o) FROM " + name + " o "

  end

  # addColumn( column )
  #
  # column - A column object
  #
  # Adds a column to the table

  def addColumn( column )

    @columns[column.name] = column
    @columnsArray.push(column)

  end

  # addFMethod( fmethod )
  #
  # fmethod - The facade method
  #
  # Adds a facade to the table

  def addFMethod( fmethod )

    @fmethods[fmethod.name] = fmethod
    @fmethodsArray.push(fmethod)

  end

  # addForeignKey( fkCol, fkRefTable )
  #
  # fkCol - The foreign key column
  # fkRefTable - The foreign key table
  #
  # Adds a foreign key reference to this table

  def addForeignKey( fkCol, fkRefTable )

    # find primary key col of referenced table
    pk = nil

    fkRefTable.columnsArray.each { |col|

      if col.isPrimaryKey
        pk = col
        break
      end

    }

    if !pk
      raise "ERROR:  primary key not found for table [#{fkRefTable.name}] " +
        "referenced by [#{@name}][#{fkCol.name}]"
    end

    fkCol.references = pk
    fkRefTable.referredBy.push(fkCol)

  end

  # addSequence()
  #
  # Adds a sequence generator to the table

  def addSequence()

    @columnsArray.each { |column|

      if column.isPrimaryKey

        if !@primaryKey
          @primaryKey = column
        end

        if column.sqlType != SQL_INTEGER
          @hasSequence = FALSE
          break
        end

        if @hasSequence
          @hasSequence = FALSE
          break
        end

        @hasSequence = TRUE

      end

    }

  end

  # getSequenceName()
  #
  # Returns name of sequence generator

  def getSequenceName()

    "#{@name}_#{@primaryKey.name}_seq"

  end

  # downfirstName()
  #
  # Returns table name with first letter lowercase

  def downfirstName

    first = "" << @name[0]
    rest = @name[1..@name.length]
    first.downcase + rest

  end

end

# Class: Column
#
# This class models a column of database table.

class Column

  attr_reader :table          # Table object this column belongs to

  attr_reader :sqlName        # String name of Column in database

  attr_reader :name           # String name of Column in Java
                              # equals sqlName except in column added to ValueObj
                              # then name is of form table_Column

  attr_reader :sqlType        # String name of database type 

  attr_reader :javaType       # String name of java type 

  attr_reader :charLength     # String length of character column
  attr_writer :charLength

  attr_reader :isUnique       # is column unique (TRUE or FALSE)
  attr_writer :isUnique

  attr_reader :isPrimaryKey   # is column primary key (TRUE or FALSE)
  attr_writer :isPrimaryKey

  attr_reader :isNotNull      # is column not null (TRUE or FALSE)
  attr_writer :isNotNull

  attr_reader :references     # Column object this column as a foreign
  attr_writer :references     # key points to, or nil

  # initialize( table, name )
  #
  # table - The table object
  # name - The column name
  #
  # Initialized the column with a table and a name

  def initialize( table, name )

    @table = table
    @sqlName = name
    @name = name
    table.addColumn(self)

  end

  # expandName()
  #
  # Expands column name to table_Column, for use in expanded Value Object
  # where this column has been added via SQL join

  def expandName()

    @name = @table.downfirstName + "_" + upfirstName

  end

  # setDatatype( sqlType )
  # 
  # sqlType - The SQL type ( as a constant )
  #
  # Controls mappings between SQL and java datatypes

  def setDatatype( sqlType )

    @sqlType = sqlType

    case sqlType
      # add mappings for additional datatypes here
      when SQL_INTEGER
        @javaType = JAVA_INTEGER
      when SQL_VARCHAR
        @javaType = JAVA_STRING
      else
        raise "ERROR:  invalid datatype [#{sqlType}] for column " +
          "[#{@name}] of table [#{@table.name}]"
    end

  end

  # upfirstName()
  # 
  # Return column name with first letter uppercase (for use in getXxx) names

  def upfirstName()

    first = "" << @name[0]
    rest = @name[1..@name.length]
    return first.upcase + rest

  end

  # stringConverter()
  #
  # Returns the java function used to convert a java String 
  # to this java datatype.

  def stringConverter()

    return strConverter(@javaType)

  end

end

# strConverter( javaType )
#
# javaType - The Java type constant
#
# Returns the java function used to convert a java String to this java datatype.

def strConverter( javaType )

  case javaType
    when JAVA_INTEGER
      return "Integer.valueOf"
    when JAVA_STRING
      return ""
    else
      raise "ERROR:  missing stringConverter for javaType [" + javaType + "]"
  end

end

# Class: FMethod
#
# Models a Method of Stateless Session Bean Facade (and Entity Home finders).

class FMethod

  attr_reader :name         # String name of method

  attr_reader :table        # Table this method is part of Stateless Session facade of

  attr_reader :params       # Array of MethodParam

  attr_reader :returnType   # String name of return type
  attr_writer :returnType

  attr_reader :valueObj     # ValueObj used by method (nil for business
  attr_writer :valueObj     # or CUD method)

  attr_reader :where        # String where fragment of SQL select statement 
  attr_writer :where        # (nil for business or CUD method)

  attr_reader :ejbQL        # String ejb-ql for EntityHome finder
  attr_writer :ejbQL

  attr_reader :body         # String body of business method
  attr_writer :body

  # initialize( table, name )
  #
  # table - The table object
  # name - The name of the method
  # 
  # Constructs a Facade Method object

  def initialize( table, name )

    @table = table
    @name = name
    @params = []
    @returnType = "void"
    table.addFMethod(self)

  end

end

# Class: MethodParam
#
# A single parameter of a FMethod.

class MethodParam

  attr_reader :name      # String name of parameter

  attr_reader :javaType  # String type of parameter
  attr_writer :javaType

  attr_reader :fmethod   # FMethod this parameter belongs to

  # initialize( fmethod, name )
  #
  # fmethod - The Facade Method
  # name - The parameter name
  #
  # Constructs the MethodParam object

  def initialize( fmethod, name )

    @fmethod = fmethod
    @name = name
    fmethod.params.push(self)

  end

end

# Class: ValueObj
#
# Value objects are used as value objects to move data across Stateless
# Session Bean Facade.

class ValueObj

  attr_reader :name           # String name of value object

  attr_reader :table          # Table value object is based on

  attr_reader :columns        # Hash of Column objects belonging to this
                              # Table, hashed by column name

  attr_reader :columnsArray   # Array of Column objects belonging to
                              # this Table (used to maintain columns in order)

  attr_reader :isExtended     # TRUE or FALSE have cols from other tables been added? 
                              # (already has "where" clause)

  # initialize( table, name )
  #
  # table - The table
  # name - The name of the value object
  #
  # Constructs a ValueObj.
        
  def initialize( table, name ) 

    @table = table
    @name = name
    @columns = {}
    @columnsArray = [] 
    $valueObjs[name] = self 
    table.valueObjs[name] = self
    @isExtended = FALSE

  end     

  # addColumn( column )
  # 
  # column - The column object
  #
  # Adds a column to the value object
    
  def addColumn( column )

    @columns[column.name] = column
    @columnsArray.push(column)

    if column.table != table
      @isExtended = TRUE
    end

  end 

  # addGetMethods()
  #
  # Add get and getAll methods for this Value Object to Stateless Session Facade.

  def addGetMethods()

    m = FMethod.new(@table, "get" + @name)
    m.valueObj = self
    m.returnType = @name
    p = MethodParam.new(m,@table.primaryKey.name)
    p.javaType = @table.primaryKey.javaType
    m.where = @table.name + "." + @table.primaryKey.name + " = ? "

    m = FMethod.new(@table, "getAll" + @name)
    m.valueObj = self
    m.returnType = "java.util.Collection"

  end

  # addCUDMethods()
  #
  # Add add, update, delete  methods for this Value Object 
  # to Stateless Session Facade.

  def addCUDMethods()

    m = FMethod.new(@table, "add")
    m.returnType = @table.primaryKey.javaType
    p = MethodParam.new(m, "value")
    p.javaType = @name

    m = FMethod.new(@table, "update")
    p = MethodParam.new(m, "value")
    p.javaType = @name

    m = FMethod.new(@table, "delete")
    p = MethodParam.new(m, @table.primaryKey.name)
    p.javaType = @table.primaryKey.javaType

  end

end

# Class: SampleRow
#
# Stores sample data for a row in table

class SampleRow

  attr_reader :table     # Table this row is for

  attr_reader :columns   # Array of sampleColumn

  # initialize( table )
  #
  # table - The table object
  #
  # Intializes a SampleRow against a table

  def initialize( table )

    @table = table
    @columns = []
    $sampleRows.push(self)

  end

end

# Class: SampleColumn
#
# The sample data column values

class SampleColumn

  attr_reader :row     # SampleRow this SampleColumn belongs to

  attr_reader :column  # Column this sampleColumn is for

  attr_reader :value   # String value of column

  # initialize( row, column, value )
  #
  # row - The row object
  # column - The column object
  # value - The value  for the sample data
  #
  # Construct a value object

  def initialize( row, column, value )

    @row = row
    @column = column
    @value = value
    row.columns.push(self)

  end

end


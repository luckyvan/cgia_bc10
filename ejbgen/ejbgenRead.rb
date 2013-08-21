#!/usr/bin/ruby

# File: ejbgenRead.rb
# Author: Eric Rollins 2002
# Purpose: EJB Generator Definition File Reader

# getXMLAttr( elem, attrName )
#
# elem - The XML element
# attrName - The attribute name
#
# Return String attribute of element

def getXMLAttr( elem, attrName )

  attr = elem.attributes[attrName]
 
  if !attr
    raise "ERROR:  missing attribute [#{attrName}]"
  end

  return attr

end

# getXMLElemText( baseElem, elemName )
#
# baseElem - The base element
# elemName - The element within the base element to get the text from
#
# Returns text of base element.

def getXMLElemText( baseElem, elemName )

  elem = baseElem.elements[ elemName ]

  if !elem
    raise "ERROR:  missing element [#{elemName}]"
  end

  elemText = elem.text

  if !elemText
    raise "ERROR:  element [#{elemName}] empty"
  end

  return elemText

end

# readSchema()
#
# reads schema.xml, creating Tables, etc. and filling globals $tables, etc.

def readSchema()

  $stderr.print "processing #{SCHEMA_FILE}...\n"

  doc = REXML::Document.new( File.open(SCHEMA_FILE))

  # Parse the schema tag

  doc.elements.each("schema") { |schema|

    $package = getXMLAttr(schema, "package")
    $jndiPrefix = getXMLAttr(schema, "jndi-prefix")

  }

  # Parse each table tag

  doc.elements.each("schema/table") { |table|

    tableName = getXMLAttr(table, "name")
    tbl = Table.new(tableName)
    val = ValueObj.new(tbl, tableName + VALUE_SUFFIX)

    # Read each column

    table.elements.each("column") { |column|

      columnName = getXMLAttr(column, "name")
      col = Column.new(tbl, columnName)
      val.addColumn(col)
      dataType = getXMLAttr(column, "datatype")
      col.setDatatype(dataType)
      col.charLength = column.attributes["length"]
      col.isNotNull = TRUE if column.attributes["not-null"]
      col.isPrimaryKey = TRUE if column.attributes["primary-key"]
      col.isUnique = TRUE if column.attributes["unique"]

    }

    tbl.addSequence
    val.addGetMethods
    val.addCUDMethods

  }

  # Read the foreign-key declarations

  doc.elements.each("schema/foreign-key") { |fk|

    fkTableName = getXMLElemText(fk, "fk-table")
    fkTbl = $tables[fkTableName]

    if !fkTbl
      raise "ERROR:  foreign-key fk-table [#{fkTableName}] not found"
    end

    fkColumnName = getXMLElemText(fk, "fk-column")
    fkCol = fkTbl.columns[fkColumnName]

    if !fkCol
      raise "ERROR:  foreign-key fk-table [#{fkTableName}] " +
        "does not contain fk-column [#{fkColumnName}]"
    end

    fkReferencesName = getXMLElemText(fk, "fk-references")
    fkRef = $tables[fkReferencesName]

    if !fkRef
      raise "ERROR:  foreign key fk-table [#{fkTableName}] " +
        "fk-column [#{fkColumnName}] fk-references [#{fkReferencesName}] " +
        "table not found"
    end

    fkTbl.addForeignKey( fkCol,fkRef )

  }

end

# loadParams( elem, fmethod )
#
# elem - The base XML element
# fmethod - The method to attach the parameters to
#
# Loads all parameters of method

def loadParams( elem, fmethod )

  elem.elements.each("parameter") { |param|

    name = getXMLAttr(param, "name")
    javaType = getXMLAttr(param, "java-type")
    p = MethodParam.new(fmethod, name)
    p.javaType = javaType

  }

end

# readExtensions()
#
# Reads extensions.xml, adding additional FMethods, etc to existing Tables

def readExtensions()

  $stderr.print "processing #{EXTENSIONS_FILE}...\n"

  doc = REXML::Document.new( File.open(EXTENSIONS_FILE))

  # Read each value-object from the extensions file
  
  doc.elements.each("extensions/value-object") { |valueObject|

    name = getXMLAttr(valueObject, "name") 
    baseTableName = getXMLAttr(valueObject, "base-table")
    baseTable = $tables[baseTableName] 

    if !baseTable
      raise "ERROR:  value-object [#{name}] base-table [#{baseTableName}] " +
        "not found"
    end

    val = ValueObj.new(baseTable,name)

    # add all columns of base table

    baseTable.columnsArray.each { |c|

      val.addColumn(c)

    }

    # Parse the 'add-column' tags to add in columns

    valueObject.elements.each("add-column") { |column|

      tableName = getXMLAttr(column, "table")
      table = $tables[tableName]

      if !table
        raise "ERROR:  add-column table [#{tableName}] not found"
      end

      columnName = getXMLAttr(column, "column-name")
      col = table.columns[columnName]

      if !col
        raise "ERROR:  add-column column [#{columnName}] of table " +
          "[#{tableName}] not found"
      end

      newCol = col.clone
      newCol.expandName
      val.addColumn(newCol)

    }

    val.addGetMethods
  }

  # Parse the sql-query-method tags

  doc.elements.each("extensions/sql-query-method") { |method|

    name = getXMLAttr(method, "name")
    valueObjName = getXMLAttr(method, "value-object")
    valueObj = $valueObjs[valueObjName]

    if !valueObj
      raise "ERROR:  in sql-query-method [#{name}] " +
        "value-object [#{valueObjName}] not found"
    end

    m = FMethod.new(valueObj.table, name)
    m.valueObj = valueObj
    m.returnType = "java.util.Collection"
    loadParams(method, m)
    m.where = getXMLElemText(method, "where")

  }

  # Parse the finder-method

  doc.elements.each("extensions/finder-method") { |method|

    name = getXMLAttr(method, "name")
    tableName = getXMLAttr(method, "table")
    table = $tables[tableName]

    if !table
      raise "ERROR:  in finder-method [#{name}] " +
        "[table #{tableName}] not found"
    end

    m = FMethod.new(table, name)
    loadParams(method, m)
    m.ejbQL = getXMLElemText(method, "ejb-ql")

  } 

  # Parse and 'custom-method' tags

  doc.elements.each("extensions/custom-method") { |method|

    name = getXMLAttr(method, "name")
    tableName = getXMLAttr(method, "table")
    table = $tables[tableName]

    if !table
      raise "ERROR:  in custom-method [#{name}] " +
        "[table #{tableName}] not found"
    end

    m = FMethod.new(table, name)
    m.returnType = getXMLAttr(method, "return-type")
    loadParams(method, m)
    m.body = getXMLElemText(method, "body")

  } 

end

# readSamples
#
# Reads samples.xml, creating SampleRow, etc.

def readSamples()

  $stderr.print "processing #{SAMPLES_FILE}...\n"

  doc = REXML::Document.new( File.open(SAMPLES_FILE))

  # Parse the row tags
  
  doc.elements.each("samples/row") { |row|

    tableName = getXMLAttr(row, "table")
    table = $tables[tableName]

    if !table
      raise "ERROR:  table [#{tableName}] not found"
    end

    sampleRow = SampleRow.new(table)

    # Parse the column tags

    row.elements.each("column"){ |column|

      columnName = getXMLAttr(column, "name")
      col = table.columns[columnName]

      if !col
        raise "ERROR:  column [#{columnName}] not found"
      end

      value = getXMLAttr(column, "value")
      sampleColumn = SampleColumn.new(sampleRow,col,value)

    }

  }

end


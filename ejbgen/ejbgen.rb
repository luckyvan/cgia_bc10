#!/usr/bin/ruby 

# File: ejbgen.rb
# Author: Eric Rollins 2002
# Purpose: Code Generator for EJBs
# Instructions:
#
# On the command line invoke this program using Ruby:
#
# ruby ejbgen.rb
#
# Output files go into the output directory.

# Bring in rexml and ERb

require 'rexml/document'
require 'erb/erb'

# Bring in our helper classes

require 'ejbgenDefs'
require 'ejbgenRead'


# processTemplate( templateName, outfileName )
#
# templateName - The file name of the template
# outfileName - The name of the output file to store the result 
#
# This runs an ERb template, which in turn has access to the globals.
# The result is stored in the specified output file.

def processTemplate( templateName, outfileName )

  $stderr.print "generating #{outfileName} using #{templateName}\n"

  begin

    templateFile = File.new( templateName )
    erbScript = templateFile.read
    templateFile.close

  rescue

    print "Could not open #{templateName}\n"
    exit

  end

  erb = ERb.new(erbScript)
  erbResult = erb.result

  begin

    outfile = File.open( outfileName, "w" )
    outfile.write( erbResult )
    outfile.close

  rescue

    print "Could not write to #{outfileName}\n"
    exit

  end

end

#============================================================================
#============================================================================
# Main body of ejbgen
#============================================================================
#============================================================================

# Read the schema

readSchema()

# Create table SQL

processTemplate(SQL_TEMPLATE, SQL_OUT_FILE)

# Read the extesions

readExtensions()

# Read the sample data

readSamples()

# Iterate over each table

$tables.values.each { |table|

  # Store a table reference in a global

  $table = table

  # Write Entity Bean java

  processTemplate(ENTITY_TEMPLATE, JAVA_OUT_DIR + table.name + "Entity.java")
  processTemplate(ENTITY_HOME_TEMPLATE, JAVA_OUT_DIR + table.name + 
    "EntityHome.java")
  processTemplate(ENTITY_BEAN_TEMPLATE, JAVA_OUT_DIR + table.name + 
    "EntityBean.java") 

  # Write the data transfer objects

  table.valueObjs.values.each{ |valueObj|

    $valueObj = valueObj

    # Write Value Object java and jsp

    processTemplate(VALUE_TEMPLATE, JAVA_OUT_DIR + valueObj.name + ".java")
    processTemplate(LIST_JSP_TEMPLATE, JSP_OUT_DIR + valueObj.name + "List.jsp")

  }

  # Write Stateless Session Facade java and jsp

  processTemplate(SS_TEMPLATE, JAVA_OUT_DIR + table.name + "SS.java")
  processTemplate(SS_HOME_TEMPLATE, JAVA_OUT_DIR + table.name +
    "SSHome.java")
  processTemplate(SS_BEAN_TEMPLATE, JAVA_OUT_DIR + table.name +
    "SSBean.java") 
  processTemplate(ADD_JSP_TEMPLATE, JSP_OUT_DIR + table.name + "Add.jsp")
  processTemplate(UPDATE_JSP_TEMPLATE, JSP_OUT_DIR + table.name + "Update.jsp")
  processTemplate(DELETE_JSP_TEMPLATE, JSP_OUT_DIR + table.name + "Delete.jsp")

  # Process any custom facade methods

  table.fmethodsArray.each{ |fmethod|

    next if !fmethod.body 

    $fmethod = fmethod

    # write Stateless Session Facade custom method test jsp

    processTemplate(CUSTOM_JSP_TEMPLATE, 
      JSP_OUT_DIR + table.name + fmethod.name + "Custom.jsp")

  }
}

# Build the JSP index page

processTemplate(INDEX_JSP_TEMPLATE, JSP_OUT_DIR + "index.jsp")

# Build the Stateless Session Facade factory java

processTemplate(SS_FACTORY_TEMPLATE, JAVA_OUT_DIR + "SSFactory.java")

# Build the XML deployment descriptors

processTemplate(EJB_JAR_TEMPLATE, XML_OUT_DIR + "ejb-jar.xml")
processTemplate(JBOSS_XML_TEMPLATE, XML_OUT_DIR + "jboss.xml")
processTemplate(JBOSS_CMP_TEMPLATE, XML_OUT_DIR + "jbosscmp-jdbc.xml")

# Build the sample data loader

processTemplate(TESTS_TEMPLATE, TESTS_OUT_DIR + "Tests.java")


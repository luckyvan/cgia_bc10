# File: perlsqlgen.rb
# Author: Jack Herrington
# Purpose: Generates production Perl from PerlSQL code, which is Perl with SQL
#          markup.
# Date: 01/30/03

require "FlexibleSQL"

require "erb/erb"
require "ftools"

# Setup globals

$database_handle = "$dbh"       # The database handle Perl variable name
$next_sth        = 0            # The statement handle index
$sth_prefix      = "$ps_sth"    # The statement handle Perl variable prefix
$template_path   = "templates/" # The directory for the templates
$output_path     = "output/"    # The directory for the output

# run_template( template, sql, type )
#
# template - The file name of the template
# sql - The SQL markup text
# type - The type of command (insert, update, delete, select)
#
# Runs a template against an SQL statement

def run_template( template, sql, type )

  template = File.new( "#{$template_path}#{template}.template" ).read
  erb = ERb.new( template )

  flex = FlexibleSQL.new( sql, type )

  varHash = { "sql" => flex.perl_sql(),
              "binds" => flex.perl_binds(),
              "mapped" => flex.perl_mapped() }

  erb.result( binding )

end

# This section is a set of tag handlers that are invoked by the regular
# expression search engine below

# tag_select( sql )
#
# sql - The Marked up SQL
#
# Handles a select tag

def tag_select( sql )
  return run_template( "select", sql, "select" )
end

# tag_select_into( sql )
#
# sql - The Marked up SQL
#
# Handles a select_into tag

def tag_select_into( sql )
  return run_template( "select_into", sql, "select" )
end

# tag_foreach( sql )
#
# sql - The Marked up SQL
#
# Handles a foreach tag

def tag_foreach( sql )
  return run_template( "foreach", sql, "select" )
end

# tag_function( sql )
#
# sql - The Marked up SQL
#
# Handles a function tag

def tag_function( sql )
  return run_template( "function", sql, "function" )
end

# tag_procedure( sql )
#
# sql - The Marked up SQL
#
# Handles a procedure tag

def tag_procedure( sql )
  return run_template( "procedure", sql, "procedure" )
end

# tag_insert( sql )
#
# sql - The Marked up SQL
#
# Handles an insert tag

def tag_insert( sql )
  return run_template( "insert", sql, "insert" )
end

# tag_update( sql )
#
# sql - The Marked up SQL
#
# Handles an update tag

def tag_update( sql )

  return run_template( "update", sql, "update" )

end

# handle_statement( tag, sql )
#
# tag - The tag name
# sql - The marked up SQL
#
# Handles a tag by routing it to a function with the appropriate name

def handle_statement( tag, sql )

  $statement_handle = "#{$sth_prefix}#{$next_sth}"

  out = send( "tag_" + tag, sql )

  $next_sth += 1

  out

end




# Get the input file

if ( ARGV[0] )

  in_text = File.new( ARGV[0] ).read()

  base = File.basename(ARGV[0])
  base.sub!( /[.]\w+$/, "" )

  out_file_name = "#{$output_path}#{base}.pl"

else

  print "You must specify a psql file name as the first argument\n"
  exit

end

# Parse in any PerlSQL options and put them into the globals

in_text.gsub!( /<option\s+name=\"([^"]*)\"\s+value=\"([^"]*)\"\s*>/i ) {

  name = $1
  value = $2

  name.strip!()
  value.strip!()

  $template_path = value if ( name == "template_path" )
  $database_handle = value if ( name == "database_handle" )
  $sth_prefix = value if ( name == "sth_prefix" )

  ""
}

tag_names = [ "select", "select_into", "function",
              "procedure", "foreach", "insert", "update" ]

# For each of the tag names search for it and feed it to the handler
#
# In this case search for the start and end tag variant 

tag_names.each() { |tag|

  in_text.gsub!( /<#{tag}>\s*(.*?)\s*<\/#{tag}>/s ) {

    sql = $1

    handle_statement( tag, sql )

  }

}

# Then search for the single tag variant

tag_names.each() { |tag|

  in_text.gsub!( /<#{tag}\s+"(.*?)\s*">/s ) {

    sql = $1

    handle_statement( tag, sql )

  }

}

# Output the finished text

print "Building #{out_file_name}...\n"
fh = File.new( out_file_name, "w" )
fh.print in_text
fh.close()

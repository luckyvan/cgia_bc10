# File: JavaDoc.rb
# Author: Jack Herrington
# Purpose: Generic class for parsing JavaDoc comments
# Date: 12/21/02

# class : JavaDoc
#
# Simple JavaDoc interpreter.  This class holds JavaDoc tokens for a series of related JavaDoc
# comments. You should use one JavaDoc object per method or class. The JavaDoc object parses the
# comments, and stores the JavaDoc data in structured holders for easy access.

class JavaDoc

  # initialize()
  #
  # Builds the JavaDoc class

  def initialize()

    # Hash to hold the @name tags. The default text goes into a tag named
    # '@desc'.

    @tags = { '@desc' => "" }

    # Special holder for the @param values

    @params = {}

  end

  attr_reader :tags       # The tag contents

  attr_reader :params     # The @param contents

  # to_s()
  #
  # Pretty prints the current contents of this JavaDoc object

  def to_s()

    text = ""

    @tags.each_key { |k| text += "#{k} : #{@tags[k]}\n" }

    @params.each_key { |k| text += "param(#{k}) : #{@params[k]}\n" }

    text

  end

  # parse( text )
  #
  # text - The JavaDoc comment
  #
  # Parses the JavaDoc comment and stores the contents

  def parse( text )

    # Strip leading and trailing space

    text.strip!

    # Return unless we see the distinctive '/**' JavaDoc beginning
    # marker

    return unless ( text =~ /^\/\*\*/ || text =~ /^\*/ )

    # This section removes all of the leading stars, the comment lines
    # and anything around the text

    cleaned = ""
    text.each_line { |line|

      line.strip!

      line.sub!( /^\/\*\*/, "" )
      line.sub!( /^\*\//, "" )
      line.sub!( /^\*\s*/, "" )

      line.strip!

      next if line.length < 1

      cleaned += "#{line}\n"

    }

    # This section is a mini-tokenizer that splits the content of the string
    # into an array.  The delimiter is whitespace.  The whitespace is stored
    # in the array as well as it may be important to some tags.

    in_whitespace = false
    text = ""
    tokens = []

    cleaned.each_byte { |ch|

      ch = ch.chr()

      if ( ch =~ /\s/ )

        if ( in_whitespace )

          text += ch

        else

          tokens.push( text ) if ( text.length > 0 )
          text = ch
          in_whitespace = true

        end

      else

        if ( in_whitespace )

          tokens.push( text ) if ( text.length > 0 )
          text = ch
          in_whitespace = false

        else

          text += ch

        end

      end

    }

    tokens.push( text ) if ( text.length > 0 )

    # Now we use our 'tokenized' array and search for the '@tag' items. As
    # we go through the tokens we are building a buffer.  When we reach a 
    # new tag we send the buffer on to add_to_tag.

    cur_name = "@desc"
    buffer = ""

    tokens.each { |tok|

      if ( tok =~ /^@/ )

        add_to_tag( cur_name, buffer ) if ( buffer.length > 0 )
        buffer = ""

        cur_name = tok

      else

        buffer += tok

      end

    }

    # Make sure we get the contents of the buffer at the end

    add_to_tag( cur_name, buffer ) if ( buffer.length > 0 )

    # Invoke the tag cleaner

    clean_tags()

  end

protected

  # add_to_tag( key, text )
  #
  # key - The tag name (e.g. '@see' )
  # text - The text of the tag
  #
  # This adds some more text to the tag. This is the method you would
  # override if you wanted to add your own JavaDoc tag to a parser, but
  # only if that tag had special parsing requirements.

  def add_to_tag( key, text )

    if ( key == "@param" )

      # If this is a param then we handle it seperately
      # by storing it's contents into a hash

      text.strip!

      text =~ /^(.*?)\s/
      name = $1
      text.sub!( /^(.*?)\s/, "" )

      text.strip!

      @params[ name ] = text

    else

      # Otherwise we just append it to the tag text in the
      # tag hash

      @tags[ key ] = "" unless ( @tags.has_key?( key ) )
      @tags[ key ] += text

    end

  end

  # clean_tags()
  #
  # A process step method that cleans up the tags after they are read in.

  def clean_tags()

    @tags.each_key { |k| @tags[ k ].strip! }

  end

end

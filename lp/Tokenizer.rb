# File: Tokenizer.rb
# Author: Jack Herrington
# Purpose: The basic tokenizer classes
# Date: 12/21/02

# class : Token
# 
# The base type for all tokens

class Token

  # initialize( text )
  #
  # text - The text of the token
  #
  # Initialieze the token with it's text

  def initialize( text ) @text = text; end

  # to_s()
  #
  # Overload of the to-string method to return the text
  # of the token

  def to_s() @text; end

end

# class : CommentToken
#
# This represents a comment token

class CommentToken < Token

end

# class : WhitespaceToken
#
# This represents a string of whitespace within a source file

class WhitespaceToken < Token

end

# class : CodeToken
#
# This represents a code fragment within a source file

class CodeToken < Token

end

# class : Tokenizer
#
# The base class for all Tokenizers. The Tokenizers are meant to be
# specialized to parse the text of various languages into token streams
# that consist of CodeToken, WhitespaceToken, and CommentToken objects

class Tokenizer

  # initialize()
  #
  # Constructs the Tokenizer base class

  def initialize( )
    @tokens = TokenStream.new()
  end

  attr_reader :tokens       # The ordered array of tokens

  # parse( text )
  #
  # text - The string of code to be turned into tokens  
  #
  # This should be overridden by all derived classes. It is
  # meant to parse the text into tokens. Which should be stored
  # in @tokens.

  def parse( text )
  end

end

# class : TokenStream
#
# An array of tokens with many useful helper methods

class TokenStream < Array

  # initialize()
  #
  # Initalizes the array

  def initialize()

    super()

  end

  # to_s()
  #
  # Converts all of the tokens back to text

  def to_s()

    text = ""
    each { |tok| text += tok.to_s }
    text

  end

  # strip!()
  #
  # Deletes any leading or trailing whitespace

  def strip!()

    while( first.is_a?( WhitespaceToken ) )
      shift
    end
    while( last.is_a?( WhitespaceToken ) )
      pop
    end

  end

  # code_only()
  #
  # Returns a new token stream with the code tokens only

  def code_only()

    out = TokenStream.new()

    each { |tok| out.push( tok ) if ( tok.is_a?( CodeToken ) ) }

    out

  end

  # comments_only()
  #
  # Returns a new token stream with the comments only

  def comments_only()

    out = TokenStream.new()

    each { |tok| out.push( tok ) if ( tok.is_a?( CommentToken ) ) }

    out

  end

  # find_pattern( pattern )
  #
  # pattern - A pattern array
  #
  # This searches the set of tokens for a pattern of strings.  The array should contain
  # a series of strings and lambdas.  In the first pass the pattern finder looks for the
  # strings.  If a match is found the lambdas are called with the token in the original
  # string for that position.
  #
  # For example:
  #
  # find_pattern( "primary", "key", "(", lambda { |name| print name }, ")" )
  #
  # Would print "myname" if the original sequence was "primary key ( myname )"

  def find_pattern( pattern )

    code = code_only

    delta = ( code.length - pattern.length ) + 1

    delta.times { |start|

      found = true

      pattern.each_index { |index|

        if ( pattern[ index ].is_a?( String ) )

          unless ( pattern[ index ].downcase == code[ start + index ].to_s.downcase )
            found = false 
          end

        end

      }

      next unless ( found )

      pattern.each_index { |index|

        unless ( pattern[ index ].is_a?( String ) )

          pattern[index].call( code[ start + index ].to_s.downcase )

        end

      }

      return true

    }

    false

  end

  # get_comments( start )
  #
  # start - The start index
  #
  # This method looks backwards from the starting index to find all of the
  # comments and to put them together into a comment stream.  It stops if it
  # finds new CodeTokens.

  def get_comments( start )

    commentStream = TokenStream.new()

    index = start - 1

    while ( index > -1 )

      break if ( at( index ).is_a?( CodeToken ) )

      commentStream.unshift( at( index ) )

      index -= 1

    end

    comments = commentStream.map { |tok| tok.to_s }.join( "" )

    comments

  end

  # find( code_value )
  #
  # code_value - The code token text as a string
  #
  # This finds a CodeToken with the same text as the input (case insensitive)
  # and returns the index.

  def find( code_value )

    each_index { |index|

      next unless ( at( index ).is_a?( CodeToken ) )

      return index if ( at( index ).to_s.downcase == code_value.to_s.downcase )

    }

    nil

  end

  # find_and_remove( code_value )
  #
  # code_value - The code token text as a string
  #
  # This is the same as find, but it removes the item.  It returns true if it
  # found something and false if not.

  def find_and_remove( code_value )

    index = find( code_value )

    delete_at( index ) if ( index != nil )

    ( index == nil ) ? false : true

  end

end

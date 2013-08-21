# File: SQLTokenizer.rb
# Author: Jack Herrington
# Purpose: A tokenizer specialized to look for SQL style tokens
# Date: 12/21/02

require "Tokenizer"

# Special characters that are found as delineators in SQL

@@specials = { ";" => 1, "," => 1, ":" => 1, "{" => 1, "}" => 1,
               "(" => 1, ")" => 1, "[" => 1, "]" => 1, "%" => 1,
               "+" => 1, "-" => 1, "*" => 1, "." => 1 }

# class : SQLT_State
#
# The base class state object for the SQL-Tokenizer state machine.

class SQLT_State

  # initialize( newstate, addtoken )
  #
  # newstate - A method to be called to change state
  # addtoken - The method to be called to add a token
  #
  # Intializes the state object

  def initialize( newstate, addtoken )

    @newstate = newstate
    @addtoken = addtoken

  end

  # next( ch )
  #
  # ch - The character
  #
  # All states should override this method.  This handles a
  # character from the stream.  Returning true means that the
  # parsing should continue to the next character.  Returning false
  # means the parser should stay on the current character.

  def next( ch )
    true
  end

end

# class : SQLT_Comment
#
# State object for new style SQL comments (e.g. --)

class SQLT_Comment < SQLT_State

  # initialize( newstate, addtoken )
  #
  # newstate - A method to be called to change state
  # addtoken - The method to be called to add a token
  #

  def initialize( newstate, addtoken )

    super( newstate, addtoken )

    # Initialize the text buffer with the beginning //

    @text = "-"
    @waiting_for_dash = true

  end

  # next( ch )
  #
  # ch - The character
  #
  # Handles the character in the parsing stream

  def next( ch )

    if ( @waiting_for_dash && ch != "-" )

      @addtoken.call( CommentToken.new( "-" ) )
      @newstate.call( SQLT_NormalState )
      return false

    end

    @waiting_for_dash = false

    # Add the character to the comment text

    @text += ch

    # Go back to the normal state if we find a return

    if ( ch == "\n" )

      @addtoken.call( CommentToken.new( @text ) )
      @newstate.call( SQLT_NormalState )

    end

    # Proceed to the next character

    true

  end

end

# class : SQLT_DoubleQuote
#
# Handles parsing strings

class SQLT_DoubleQuote < SQLT_State

  # initialize( newstate, addtoken )
  #
  # newstate - A method to be called to change state
  # addtoken - The method to be called to add a token
  #

  def initialize( newstate, addtoken )

    super( newstate, addtoken )

    # Start the text buffer with the beginning double quote

    @text = "\'"

    @waiting_for_end_apostrophe = false

    @waiting_for_apostrophe = true

  end

  # next( ch )
  #
  # ch - The character
  #
  # Handles the character in the parsing stream

  def next( ch )

    if ( @waiting_for_apostrophe )

      if ( ch == "\'" )

        @token += ch
        @waiting_for_apostrophe = false
        return true

      else

        @addtoken.call( CodeToken.new( "\'" ) )
        @newstate.call( SQLT_NormalState )
        return false

      end

    end

    # Add this character to the text buffer

    @text += ch

    if ( @waiting_for_end_apostrophe && ch == "\'" )

      @addtoken.call( CodeToken.new( @text ) )
      @newstate.call( SQLT_NormalState )

    end

    @waiting_for_end_apostrophe = ( ch == "\'" )

    # Proceed to the next character

    true

  end

end

# SQLT_WhitespaceTokenizer
#
# Handles whitespace in the character stream

class SQLT_WhitespaceTokenizer < SQLT_State

  # initialize( newstate, addtoken )
  #
  # newstate - A method to be called to change state
  # addtoken - The method to be called to add a token
  #

  def initialize( newstate, addtoken )

    super( newstate, addtoken )

    # Initialize the text buffer to blank

    @text = ""

  end

  # next( ch )
  #
  # ch - The character
  #
  # Handles the character in the parsing stream

  def next( ch )

    if ( ch =~ /\s/ )

      # If the character is whitespace add it to
      # the buffer

      @text += ch
      return true

    else

      # Otherwise return to the normal state and
      # add the token

      @addtoken.call( WhitespaceToken.new( @text ) )
      @newstate.call( SQLT_NormalState )

      # Return false because we want the tokenizer
      # to re-run on the current character

      return false

    end

  end

end

# class : SQLT_NormalState
#
# The default state machine to which all of the other states return.

class SQLT_NormalState < SQLT_State

  # initialize( newstate, addtoken )
  #
  # newstate - A method to be called to change state
  # addtoken - The method to be called to add a token
  #

  def initialize( newstate, addtoken )

    super( newstate, addtoken )

    # This normal state handles adding CodeTokens in the 
    # basic stream (e.g. not in a string). So we have a
    # text buffer.

    @text = ""

  end

  # next( ch )
  #
  # ch - The character
  #
  # Handles the character in the parsing stream

  def next( ch )

    if ch == "-"

      # Start the comment switcher state if we 
      # see a slash

      @addtoken.call( CodeToken.new( @text ) )
      @newstate.call( SQLT_Comment )

    elsif @@specials[ch]

      # If this is a special character (e.g. ;,*,+, etc.)
      # then dump the current token and add the special  
      # characer token

      @addtoken.call( CodeToken.new( @text ) )
      @text = ""

      @addtoken.call( CodeToken.new( ch ) )

    elsif ch == "\'"

      # Start the double quote state if we see a
      # double quote

      @addtoken.call( CodeToken.new( @text ) )
      @newstate.call( SQLT_DoubleQuote )

    elsif ch =~ /\s/
  
      # Move into the whitespace state if we 
      # see whitespace.  Return true to re-run
      # the parser on this character.
    
      @addtoken.call( CodeToken.new( @text ) )
      @newstate.call( SQLT_WhitespaceTokenizer )
      return false

    else

      # Otherwise add this character to the buffer

      @text += ch

    end

    # Continue onto the next character

    true

  end

end

# class : SQLTokenizer
#
# The main entry class that parses SQL text into a set of tokens

class SQLTokenizer < Tokenizer

  # parse( text )
  #
  # text - The SQL text
  #
  # Parses the SQL text string into tokens

  def parse( text )

    # Set the current state to the normal state

    @state = SQLT_NormalState.new(
      method( :newstate ),
      method( :addtoken ) )

    # Iterate through the text

    index = 0

    while index < text.length

      # Dispatch the character to the current state

      if ( @state.next( text[ index ].chr() ) )

        index += 1

      end

    end

  end

protected

  # newstate( classref )
  #
  # classref - The class to use for the new state object
  #
  # This callback informs the state machine that we are going into a new
  # state.  The state-machine is given a class reference which it then uses to
  # build a new state object
  
  def newstate( classref )

    # Sets the state to a new state based on the class given

    @state = classref.new( method( :newstate ), method( :addtoken ) )

  end

  # addtoken( token )
  #
  # token - The new token
  #
  # Adds a token to the token stream.

  def addtoken( token )

    # Adds a token to the stack. If the token text is empty
    # then ignore it

    return if ( token.to_s().length < 1 )

    # Add the token to the array

    @tokens.push( token )

  end

end

# File: CTokenizer.rb
# Author: Jack Herrington
# Purpose: A tokenizer specialized to look for C style tokens
# Date: 12/21/02

require "Tokenizer"

# Special characters that are found as delineators in C

@@specials = { ";" => 1, "," => 1, ":" => 1, "{" => 1, "}" => 1,
               "(" => 1, ")" => 1, "[" => 1, "]" => 1, "%" => 1,
               "+" => 1, "-" => 1, "*" => 1, "." => 1 }

# class : CT_State
#
# The base class state object for the C-Tokenizer state machine.

class CT_State

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

# class : CT_OldComment
#
# Handles parsing an old-style C comment (e.g. /* ... */ )

class CT_OldComment < CT_State

  # initialize( newstate, addtoken )
  #
  # newstate - A method to be called to change state
  # addtoken - The method to be called to add a token
  #
  # Intializes the old-style comment state object

  def initialize( newstate, addtoken )

    super( newstate, addtoken )

    # Initialize the text with the beginning /*

    @text = "/*"

    # True if the last character was a star

    @last_was_star = false

  end

  # next( ch )
  #
  # ch - The character
  #
  # Handles the character in the parsing stream

  def next( ch )

    # Add this character to the comment

    @text += ch

    # See if we have a '/' if the last character was a star.
    # If that is the case then return to normal parsing
    # and add the comment token to the token array.

    if ( ch == "/" && @last_was_star )

      @addtoken.call( CommentToken.new( @text ) )
      @newstate.call( CT_NormalState )

    end

    # Set the last_was_star to true if we see a star

    @last_was_star = ( ch == "*" )

    # Continue onto the next character

    true

  end

end

# class : CT_NewComment
#
# State object for new style C comments (e.g. //)

class CT_NewComment < CT_State

  # initialize( newstate, addtoken )
  #
  # newstate - A method to be called to change state
  # addtoken - The method to be called to add a token
  #

  def initialize( newstate, addtoken )

    super( newstate, addtoken )

    # Initialize the text buffer with the beginning //

    @text = "//"

  end

  # next( ch )
  #
  # ch - The character
  #
  # Handles the character in the parsing stream

  def next( ch )

    # Add the character to the comment text

    @text += ch

    # Go back to the normal state if we find a return

    if ( ch == "\n" )

      @addtoken.call( CommentToken.new( @text ) )
      @newstate.call( CT_NormalState )

    end

    # Proceed to the next character

    true

  end

end

# class : CT_DoubleQuote
#
# Handles parsing strings

class CT_DoubleQuote < CT_State

  # initialize( newstate, addtoken )
  #
  # newstate - A method to be called to change state
  # addtoken - The method to be called to add a token
  #

  def initialize( newstate, addtoken )

    super( newstate, addtoken )

    # Start the text buffer with the beginning double quote

    @text = "\""

    # Set the escaped flag to false.  This will go true when
    # we see a '\'

    @escaped = false

  end

  # next( ch )
  #
  # ch - The character
  #
  # Handles the character in the parsing stream

  def next( ch )

    # Add this character to the text buffer

    @text += ch

    # If the character is a double qoute and we are not
    # escape then go back to the normal state and add
    # the string token to the array

    if ( ch == "\"" && ! @escaped )

      @addtoken.call( CodeToken.new( @text ) )
      @newstate.call( CT_NormalState )

    end

    # Set escaped to true if we see a \

    @escaped = ( ch == "\\" )

    # Proceed to the next character

    true

  end

end

# CT_WhitespaceTokenizer
#
# Handles whitespace in the character stream

class CT_WhitespaceTokenizer < CT_State

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
      @newstate.call( CT_NormalState )

      # Return false because we want the tokenizer
      # to re-run on the current character

      return false

    end

  end

end

# class : CT_WatingForComment
#
# Handles switching between old comments, new comments, and slashes.

class CT_WaitingForComment < CT_State

  # next( ch )
  #
  # ch - The character
  #
  # Handles the character in the parsing stream

  def next( ch )

    # Check to see if we are looking at a new or old
    # style comment

    if ( ch == "*" )

      @newstate.call( CT_OldComment )

    elsif ( ch == "/" )

      @newstate.call( CT_NewComment )

    else

      # Or if it was just a slash

      @addtoken.call( CodeToken.new( "/" ) )
      @newstate.call( CT_NormalState )

    end

  end

end

# class : CT_NormalState
#
# The default state machine to which all of the other states return.

class CT_NormalState < CT_State

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

    if @@specials[ch]

      # If this is a special character (e.g. ;,*,+, etc.)
      # then dump the current token and add the special  
      # characer token

      @addtoken.call( CodeToken.new( @text ) )
      @text = ""

      @addtoken.call( CodeToken.new( ch ) )

    elsif ch == "\""

      # Start the double quote state if we see a
      # double quote

      @addtoken.call( CodeToken.new( @text ) )
      @newstate.call( CT_DoubleQuote )

    elsif ch == "/"

      # Start the comment switcher state if we 
      # see a slash

      @addtoken.call( CodeToken.new( @text ) )
      @newstate.call( CT_WaitingForComment )

    elsif ch =~ /\s/
  
      # Move into the whitespace state if we 
      # see whitespace.  Return true to re-run
      # the parser on this character.
    
      @addtoken.call( CodeToken.new( @text ) )
      @newstate.call( CT_WhitespaceTokenizer )
      return false

    else

      # Otherwise add this character to the buffer

      @text += ch

    end

    # Continue onto the next character

    true

  end

end

# class : CTokenizer
#
# The main entry class that parses C text into a set of tokens

class CTokenizer < Tokenizer

  # parse( text )
  #
  # text - The C text
  #
  # Parses the C text string into tokens

  def parse( text )

    # Set the current state to the normal state

    @state = CT_NormalState.new( method( :newstate ), method( :addtoken ) )

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
  # classref - The new static class type
  #
  # Called when we are requesting a change of state.  This method creates the
  # new state from the class reference that is passed in.

  def newstate( classref )

    # Sets the state to a new state based on the class
    # given

    @state = classref.new( method( :newstate ), method( :addtoken ) )

  end

  # addtoken( token )
  #
  # token - The new token
  #
  # This adds a token to the token list.

  def addtoken( token )

    # Adds a token to the stack. If the token text is empty
    # then ignore it

    return if ( token.to_s().length < 1 )

    # Add the token to the array

    @tokens.push( token )

  end

end

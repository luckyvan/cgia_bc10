import java.util.regex.*;

class Regex1
{
  public static void main( String args[] )
  {
    Pattern pat = Pattern.compile( "\\S*.txt$" );
    Matcher mat = pat.matcher( "file.txt" );
    if ( mat.matches() ) {
      System.out.println( "File matches" );
    } else {
      System.out.println( "File does not match" );
    }
  }
}

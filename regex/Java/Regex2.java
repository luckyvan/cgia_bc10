import java.util.regex.*;

class Regex2
{
  public static void main( String args[] )
  {
    Pattern pat = Pattern.compile( "(.*?)=(.*?);" );
    Matcher mat = pat.matcher( "a=1;b=2;c=3;" );
    while( mat.find() )
    {
      System.out.println( mat.group(1) + " : " + mat.group( 2 ) );
    }
  }
}

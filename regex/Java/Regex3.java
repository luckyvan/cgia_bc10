import java.util.regex.*;

class Regex3
{
  public static void main( String args[] )
  {
    String out = new String( "jack\td\therrington" );

    Pattern pat = Pattern.compile( "\\t" );
    out = (pat.matcher( out )).replaceAll( "," );

    System.out.println( out );
  }
}

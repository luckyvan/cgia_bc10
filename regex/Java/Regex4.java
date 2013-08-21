import java.util.regex.*;

class Regex4
{
  public static void main( String args[] )
  {
    String str = new String( "Dear <name>, You owe us <cost>" );

    Pattern pat = Pattern.compile( "<(.*?)>" );
    Matcher mat = pat.matcher( str );

    while( mat.find() )
    {
      String key = mat.group(1);

      if ( key.compareTo( "name" ) == 0 )
        str = mat.replaceFirst( "jack" );
      else if ( key.compareTo( "cost" ) == 0 )
        str = mat.replaceFirst( "\\$20" );
      else
        str = mat.replaceFirst( "" );

      mat = pat.matcher( str );
    }

    System.out.println( str );
  }
}

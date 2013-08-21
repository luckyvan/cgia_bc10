import java.io.IOException;
import org.apache.xmlrpc.*;
import java.util.*;

public class Client
{
    public static void main( String args[] )
    {
        try
        {
          XmlRpcClient client = new XmlRpcClient( "http://localhost:8081" );

          TestStubs stubs = new TestStubs( client );

          System.out.println( "add 10, 20 = " + stubs.add( 10.0, 20.0 ) );
          System.out.println( "add 40, 100 = " + stubs.add( 40.0, 100.0 ) );
          System.out.println( "subtract 20, 10 = " + stubs.subtract( 20.0, 10.0 ) );
          System.out.println( "invert true = " + stubs.invert( true ) );
          System.out.println( "invert false = " + stubs.invert( false ) );
          System.out.println( "add_int 20, 10 = " + stubs.add_int( 20, 10 ) );
          System.out.println( "subtract_int 20, 10 = " + stubs.subtract_int( 20, 10 ) );
          System.out.println( "add_string a, b = " + stubs.add_string( "a", "b" ) );

          Vector da = new Vector();
          da.addElement( new Double( 10.0 ) );
          da.addElement( new Double( 20.0 ) );
          da.addElement( new Double( 30.0 ) );
          System.out.println( "add_array 10, 20, 30 = " + stubs.add_array( da ) );

          Hashtable na = new Hashtable();
          na.put( "name", "Jack" );
          na.put( "last_name", "Herrington" );
          System.out.println( "get_name (na) = " + stubs.get_name( na ).toString() );
        }
        catch( Exception e )
        {
          System.out.println( e.toString() );
        }
    }
}

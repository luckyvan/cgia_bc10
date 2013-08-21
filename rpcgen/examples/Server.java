import java.io.IOException;
import org.apache.xmlrpc.*;
import TestHandler;

public class Server
{
    public static void main( String[] args )
    {
        try { 
          WebServer server = new WebServer( 8081 );
          server.addHandler( "Test", new TestHandler() );
        }
        catch( IOException e ) {
        }
    }
}

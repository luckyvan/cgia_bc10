import java.util.*;

public class Test
{
    /**
     * @rpcgen export
     */
    public double add( double a, double b ) { return a+b; }

    /**
     * @rpcgen export
     */
    public double subtract( double a, double b ) { return a-b; }

    /**
     * @rpcgen export
     */
    public boolean invert( boolean b ) { return ( b ? false : true ); }

    /**
     * @rpcgen export
     */
    public int add_int( int a, int b ) { return a+b; }

    /**
     * @rpcgen export
     */
    public int subtract_int( int a, int b ) { return a-b; }

    /**
     * @rpcgen export
     */
    public String add_string( String a, String b ) { return a+" "+b; }

    /**
     * @rpcgen export
     */
    public double add_array( Vector a )
    {
      double total = 0.0;

      for( int index = 0; index < a.size(); index++ )
      {
        total += ((Double)a.get( index )).doubleValue();
      }

      return total;
    }

    /**
     * @rpcgen export
     */
    public String get_name( Hashtable ht )
    {
      return (String)ht.get( "name" );
    }
}

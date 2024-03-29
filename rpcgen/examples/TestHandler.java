// ====================================================================
// Warning.  Do not edit this file directly.  This file is generated
// by rpcgen.  You should edit the original .java file that was used
// to build this file and then re-run the rpcgen generator.
// ====================================================================

import java.util.*;

/** 
 * XML-RPC wrapper for the Test class.
 */
public class TestHandler
{

  public Double add( double a, double b )
  {
    Test obj = new Test();
    return new Double( obj.add( a, b ) );
  }

  public Double subtract( double a, double b )
  {
    Test obj = new Test();
    return new Double( obj.subtract( a, b ) );
  }

  public Boolean invert( boolean b )
  {
    Test obj = new Test();
    return new Boolean( obj.invert( b ) );
  }

  public Integer add_int( int a, int b )
  {
    Test obj = new Test();
    return new Integer( obj.add_int( a, b ) );
  }

  public Integer subtract_int( int a, int b )
  {
    Test obj = new Test();
    return new Integer( obj.subtract_int( a, b ) );
  }

  public String add_string( String a, String b )
  {
    Test obj = new Test();
    return new String( obj.add_string( a, b ) );
  }

  public Double add_array( Vector a )
  {
    Test obj = new Test();
    return new Double( obj.add_array( a ) );
  }

  public String get_name( Hashtable ht )
  {
    Test obj = new Test();
    return new String( obj.get_name( ht ) );
  }

}

// ====================================================================
// Warning.  Do not edit this file directly.  This file is generated
// by rpcgen.  You should edit the original .java file that was used
// to build this file and then re-run the rpcgen generator.
// ====================================================================

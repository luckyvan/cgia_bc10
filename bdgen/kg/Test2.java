import java.math.*;

public class Test2
{
	static public void main( String args[] )
	{
		BigDecimal a;
		double b = 6.0;
		double c = 2.0;

// bdgen_start <a=b/c>
BigDecimal v1 = new BigDecimal( b );
BigDecimal v2 = new BigDecimal( c );
BigDecimal v3 = new BigDecimal( 0 );
v3 = v1.divide( v2, BigDecimal.ROUND_DOWN );
a = v3;
// bdgen_end

		System.out.println( "Correct = 3" );
		System.out.print( "Output = " );
		System.out.println( a );
	}
}

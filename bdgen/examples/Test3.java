import java.math.*;

public class Test3
{
	static public BigDecimal add10( BigDecimal a )
	{
			BigDecimal b = new BigDecimal( 10.0 );
			return a.add( b );
	}
	static public void main( String args[] )
	{
		BigDecimal a;
		double b = 6.0;
		double c = 2.0;

// bdgen_start <a=add10(b/c)>
BigDecimal v1 = new BigDecimal( b );
BigDecimal v2 = new BigDecimal( c );
BigDecimal v3 = new BigDecimal( 0 );
v3 = v1.divide( v2, BigDecimal.ROUND_DOWN );
BigDecimal v4 = add10( v3 );
a = v4;
// bdgen_end

		System.out.println( "Correct = 13" );
		System.out.print( "Output = " );
		System.out.println( a );
	}
}

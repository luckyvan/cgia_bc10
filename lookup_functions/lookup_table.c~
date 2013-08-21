#include <stdio.h>

// <lookup_func name="sin" count="1001" start="0" step="0.0001" equation="sin(x)">
static double sin_lookup( double value )
{
  double dValues = [ 0.0, ... ];
  return dValues[ int( value * 1000 ) ];
}
// </lookup_func>

int main( int argc, char *argv[] )
{
  printf( "sin(0.0) = %d\n", sin_lookup( 0.0 ) );
  printf( "sin(0.5) = %d\n", sin_lookup( 0.5 ) );
  printf( "sin(1.0) = %d\n", sin_lookup( 1.0 ) );
}

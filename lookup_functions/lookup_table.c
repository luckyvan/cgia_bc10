#include <stdio.h>

#define IDOK 2
#define IDCANCEL 3

// <lookup_table>
static char *define_lookup( int value )
{
  if ( value == IDOK ) return "IDOK";
  if ( value == IDCANCEL ) return "IDCANCEL";
  return "";
}
// </lookup_table>

int main( int argc, char *argv[] )
{
  printf( "%d - %s\n", IDOK, define_lookup( IDOK ) );
  printf( "%d - %s\n", IDCANCEL, define_lookup( IDCANCEL ) );
}

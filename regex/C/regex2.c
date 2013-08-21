#include <stdio.h>
#include <pcre.h>

int main( int argc, char *argv[] )
{
  pcre *re;
  const char *error;
  int erroffset, rc, ovector[30], start;
  char *str = "a=1;b=2;c=3;", *totalStr, *key, *value;

  re = pcre_compile( "(.*?)=(.*?);", 0, &error, &erroffset, NULL );

  start = 0;
  while ( 1 )
  {
    rc = pcre_exec( re, NULL, str, strlen(str),
      start, 0, ovector, sizeof(ovector)/sizeof(ovector[0]) );

    if ( rc < 1 ) break;

    totalStr = malloc( 255 );
    pcre_copy_substring( str, ovector, rc, 0, totalStr, 255 );
    start += strlen( totalStr );

    key = malloc( 255 );
    pcre_copy_substring( str, ovector, rc, 1, key, 255 );

    value = malloc( 255 );
    pcre_copy_substring( str, ovector, rc, 2, value, 255 );

    printf( "%s : %s\n", key, value );

    free( totalStr );
    free( key );
    free( value );
  }

  return 0;
}

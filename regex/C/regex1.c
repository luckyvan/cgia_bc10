#include <stdio.h>
#include <pcre.h>

int main( int argc, char *argv[] )
{
  pcre *re;
  const char *error;
  int erroffset, rc, ovector[30];
  char *str = "file.txt";

  re = pcre_compile( "[.]txt$", 0, &error, &erroffset, NULL );

  rc = pcre_exec( re, NULL, str, strlen(str),
     0, 0, ovector, sizeof(ovector)/sizeof(ovector[0]) );

  if ( rc > 0 )
    printf( "File name matches\n" );
  else 
    printf( "File name does not match\n" );
  return 0;
}

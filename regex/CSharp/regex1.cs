using System;
using System.Text.RegularExpressions;

class Regex1
{
  static void Main()
  {
    Regex r = new Regex( "[.]txt$" );

    if ( r.Match( "file.txt" ).Success ) {
      Console.WriteLine( "File name matched" );
    } else {
      Console.WriteLine( "File name did not match" );
    }
  }
}

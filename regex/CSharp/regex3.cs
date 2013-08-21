using System;
using System.Text.RegularExpressions;

class Regex3
{
  static void Main()
  {
    Regex r = new Regex( "\t" );
    String str = r.Replace( "jack\td\therrington", "," );
    Console.WriteLine( str );
  }
}

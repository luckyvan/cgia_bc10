using System;
using System.Text.RegularExpressions;

class Regex2
{
  static void Main()
  {
    Regex r = new Regex( "(?<key>.*?)=(?<value>.*?);" );

    MatchCollection matches = r.Matches( "a=1;b=2;c=3;" );

    foreach ( Match match in matches )
    {
      Console.WriteLine(
        match.Groups["key"] + " : " + match.Groups["value"]
      );
    }

  }
}

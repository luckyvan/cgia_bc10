using System;
using System.Text.RegularExpressions;

class Regex4
{
  public static String myEval( Match mat )
  {
    if ( mat.Groups[ "key" ].ToString() == "name" )
      return "Jack";

    if ( mat.Groups[ "key" ].ToString() == "cost" )
      return "$20";

    return "";
  }

  static void Main()
  {
    Regex r = new Regex( "<(?<key>.*?)>" );
    String str = r.Replace(
                    "Dear <name>, You owe us <cost>",
                    new MatchEvaluator( myEval ) );
    Console.WriteLine( str );
  }
}

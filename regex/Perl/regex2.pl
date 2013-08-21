$input = "a=1;b=2;c=3;";
while( $input =~ /(.*?)=(.*?);/g )
{
  print "$1 : $2\n";
}

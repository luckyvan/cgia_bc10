sub value($)
{
  my ( $key ) = @_;
  return 'Jack' if ( $key eq 'name' );
  return '$20' if ( $key eq 'cost' );
  return '';
}

$str = 'Dear <name>, You owe us <cost>';

$str =~ s/<(.*?)>/value($1)/eg;

print "$str\n";

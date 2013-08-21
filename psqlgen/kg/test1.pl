use PerlSQL::PerlSQL;
use Data::Dumper;
use DB;

my $dbh = DB::get();
my $id = 10;

my $data = eval {
  my $ps_sth0 = $dbh->prepare( "SELECT * FROM user WHERE id=:repvar1" );
  $ps_sth0->bind_param( "repvar1", $id );
$ps_sth0->execute();
  my $ps_out = ();
  while( my $ps_row_ref = $ps_sth0->fetchrow_hashref() ) {
    push @$ps_out, $ps_row_ref;
  }
  $ps_row_ref;
}


print Dumper( $data );

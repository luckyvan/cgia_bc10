use PerlSQL::PerlSQL;
use Data::Dumper;
use DB;

my $dbh = DB::get();

my $id = 10;

my $ps_sth0 = $dbh->prepare( "UPDATE user SET first_name=:repvar2, last_name=:repvar3 WHERE id=:repvar1" );
$ps_sth0->bind_param( "repvar1", $id );
$ps_sth0->bind_param( "repvar2", $first_name );
$ps_sth0->bind_param( "repvar3", $last_name );
$ps_sth0->execute();


use PerlSQL::PerlSQL;
use DB;

my $dbh = DB::get();

my $id = 10;

my ( $first_name );
{
	my $ps_sth0 = $dbh->prepare( "SELECT first_name FROM user WHERE id=:repvar1" );
	$ps_sth0->bind_param( "repvar1", $id );
$ps_sth0->execute();
	my $ps_out = ();
	( $first_name ) = $ps_sth0->fetchrow();
}


print "first_name = $first_name\n";

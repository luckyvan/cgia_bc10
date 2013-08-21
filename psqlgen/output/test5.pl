
use PerlSQL::PerlSQL;
use DB;

my $dbh2 = DB::get();

my $ps_sth1 = $dbh2->prepare( "SELECT id FROM user" );
$ps_sth1->execute();
while( my ( $id ) = $ps_sth1->fetchrow() )
 {
	my $ps_sth0 = $dbh2->prepare( "BEGIN; add_account( :repvar1 ); END;" );
$ps_sth0->bind_param( "repvar1", $id );
$ps_sth0->execute();

}


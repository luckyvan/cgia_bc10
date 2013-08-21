use PerlSQL::PerlSQL;
use Data::Dumper;
use DB;

my $dbh = DB::get();

my $ps_sth0 = $dbh->prepare( "SELECT user_id, user_login FROM user" );
$ps_sth0->execute();
while( my ( $user_id, $user_login ) = $ps_sth0->fetchrow() )
 {
	print "$user_id $user_login\n";
}


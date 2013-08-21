use PerlSQL::PerlSQL;
use Data::Dumper;
use DB;

my $dbh = DB::get();

my $ps_sth0 = $dbh->prepare( "INSERT INTO user ( first_name, last_name ) values ( :repvar1, :repvar2 ) " );
$ps_sth0->bind_param( "repvar1", $first_name );
$ps_sth0->bind_param( "repvar2", $last_name );
$ps_sth0->execute();


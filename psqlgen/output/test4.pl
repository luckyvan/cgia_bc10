use PerlSQL::PerlSQL;
use DB;

my $dbh = DB::get();

my $first_name = "Jack";
my $last_name = "Herrington";

my $ps_sth0 = $dbh->prepare( "BEGIN; add_user( :repvar1, :repvar2 ); END;" );
$ps_sth0->bind_param( "repvar1", $first_name );
$ps_sth0->bind_param( "repvar2", $last_name );
$ps_sth0->execute();


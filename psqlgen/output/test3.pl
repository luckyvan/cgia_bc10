use PerlSQL::PerlSQL;
use DB;

my $dbh = DB::get();

my $first_name = "jack";
my $last_name = "herrington";

my $id = eval {
my $ps_sth0 = $dbh->prepare( "BEGIN; :ps_out := add_user( :repvar1, :repvar2 ); END;" );
my $ps_out;
$ps_sth0->bind_var( "ps_out", \$ps_out );
$ps_sth0->bind_param( "repvar1", $first_name );
$ps_sth0->bind_param( "repvar2", $last_name );
$ps_sth0->execute();
$ps_out;
}


package PerlSQL::CommitRelease;

sub DESTROY
{
	$self->releaseTransaction();
}

sub new
{
	my ( $class, $dbh ) = @_;
	my $self = { dbh => $dbh, committed => 0 };
	bless $self, $class;
	$self->startTransaction();
	return $self;
}

sub get_dbh() { my $self = shift; return $self->{ dbh }; }

sub startTransaction()
{
	my $self = shift;
#	Set for no commit
}

sub commitTransaction()
{
	my $self = shift;
	if ( $self->{ committed } == 0 )
	{
#		Commit transaction
		$self->{ committed } = 1;
	}
}

sub releaseTransaction()
{
	my $self = shift;
#	Set for commit
}

1;

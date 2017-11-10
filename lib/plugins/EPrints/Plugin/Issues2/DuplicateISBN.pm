package EPrints::Plugin::Issues2::DuplicateISBN;
@ISA = ( "EPrints::Plugin::Issues2" );

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{type} = "duplicate_isbn";	# internal name of issue, add to namedsets/issues2
	$self->{name} = "Duplicate ISBNs";	# human readable name
	$self->{field} = "isbn";		# field to test against

	$self->{fieldmap} = $self->{field} . "-map"; # internal cache name
	$self->{disable} = 0; # enable this plugin

	return $self;
}

1;

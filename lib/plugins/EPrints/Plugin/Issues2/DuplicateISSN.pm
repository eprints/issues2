package EPrints::Plugin::Issues2::DuplicateISSN;
@ISA = ( "EPrints::Plugin::Issues2" );

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{type} = "duplicate_issn";	# internal name of issue, add to namedsets/issues2
	$self->{name} = "Duplicate ISSNs";	# human readable name
	$self->{field} = "issn";		# field to test against

	$self->{fieldmap} = $self->{field} . "-map"; # internal cache name
	$self->{disable} = 0; # enable this plugin

	return $self;
}

1;

package EPrints::Plugin::Issues2::DuplicateDOI;
@ISA = ( "EPrints::Plugin::Issues2" );

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{type} = "duplicate_doi";	# internal name of issue, add to namedsets/issues2
	$self->{name} = "Duplicate DOIs";	# human readable name
	$self->{field} = "id_number";		# field to test against

	$self->{fieldmap} = $self->{field} . "-map"; # internal cache name
	$self->{disable} = 0; # enable this plugin

	return $self;
}

1;

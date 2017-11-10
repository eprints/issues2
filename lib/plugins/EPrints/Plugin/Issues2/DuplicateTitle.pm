package EPrints::Plugin::Issues2::DuplicateTitle;
@ISA = ( "EPrints::Plugin::Issues2" );

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{type} = "duplicate_title";	# internal name of issue, add to namedsets/issues2
	$self->{name} = "Duplicate Titles";	# human readable name
	$self->{field} = "title";		# field to test against

	$self->{fieldmap} = $self->{field} . "-map"; # internal cache name
	$self->{disable} = 0; # enable this plugin

	return $self;
}

sub normalise
{
	my( $plugin, $string ) = @_;

	$string =~ s/[ \t\r\n]+/ /;	# replace runs of white space with a single space
	$string = lc($string);		# lowercase the string

	return $string;
}

1;

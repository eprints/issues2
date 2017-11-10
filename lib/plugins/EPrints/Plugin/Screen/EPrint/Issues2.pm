=head1 NAME

EPrints::Plugin::Screen::EPrint::Issues2

=cut

package EPrints::Plugin::Screen::EPrint::Issues2;

our @ISA = ( 'EPrints::Plugin::Screen::EPrint' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{expensive} = 1;
	$self->{appears} = [
		{
			place => "eprint_view_tabs",
			position => 1500,
		},
	];

	return $self;
}

sub can_be_viewed
{
	my( $self ) = @_;

	return $self->allow( "eprint/issues" );
}

sub render
{
	my( $self ) = @_;

	my $eprint = $self->{processor}->{eprint};
	my $session = $eprint->{session};

	my $page = $session->make_doc_fragment;

	# if( $eprint->get_value( "item_issues_count" ) > 0 )
	{
		$page->appendChild( $eprint->render_value( "item_issues2" ) );
	}

	return $page;
}



1;

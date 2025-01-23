=head1 NAME

EPrints::Plugin::Issues2

=cut

package EPrints::Plugin::Issues2;

use strict;

our @ISA = qw/ EPrints::Plugin /;

$EPrints::Plugin::Issues2::DISABLE = 1;

sub matches 
{
	my( $self, $test, $param ) = @_;

	if( $test eq "is_available" )
	{
		return( $self->is_available() );
	}

	# didn't understand this match 
	return $self->SUPER::matches( $test, $param );
}

sub is_available
{
	my( $self ) = @_;

	return 1;
}

# return all issues on this set, as a hash keyed on eprintid.
sub list_issues
{
	my( $plugin, %opts ) = @_;

	my $info = { issues => {}, opts=>\%opts };
	$opts{list}->map( 
		sub { 
			my( $session, $dataset, $item, $info ) = @_;
			my @issues = $plugin->process_item_in_list( $item, $info );
		},
		$info
	);

	$plugin->process_at_end( $info );

	return $info->{issues};
}

# this is used to add any additional issues based on cumulative information
sub process_at_end
{
	my( $plugin, $info, $subject_id ) = @_;

	my $session = $plugin->{session};
	foreach my $code ( keys %{$info->{ $plugin->{fieldmap} }} )
	{
		my @set = @{$info->{ $plugin->{fieldmap} }->{$code}};
		next unless scalar @set > 1;
		foreach my $id ( @set )
		{
			my $eprint = EPrints::DataObj::EPrint->new( $session, $id );
			# my $desc = $session->make_element( "span" );
			my $desc = $session->make_doc_fragment;
			$desc->appendChild( $session->make_text( "Duplicate " ) );
			$desc->appendChild( $session->html_phrase( "eprint_fieldname_" . $plugin->{field} ) );
			$desc->appendChild( $session->make_text( " to " ) );
			$desc->appendChild( $eprint->render_citation_link_staff( "brief" ) );
			$desc->appendChild( $eprint->render_citation_link_staff( "brief_info" ) );

			$desc->appendChild( $session->make_text( "[ " ) );
			my $retire = $session->make_element( "a", href=>"#", "onclick" => "return issues2_retire( $id );", class => "ep_issues2_retire" );
			$retire->appendChild( $session->make_text( "Manage" ) );
			$desc->appendChild( $retire ); # unless $eprint->get_value("eprint_status") eq "deletion";

			$desc->appendChild( $session->make_text( " ]" ) );

			if ( $eprint->get_value("eprint_status") ne "deletion" )
			{
				my $compare = $session->make_element( "a", href=>"#", "onclick" => "return issues2_compare( this, $id );", "class" => "ep_issues2_compare" );
				$compare->appendChild( $session->make_text( "Compare & Merge" ) );
				$desc->appendChild( $session->make_text( " [ " ) );
				$desc->appendChild( $compare );
				$desc->appendChild( $session->make_text( " ]" ) );
			}

			my $ack = $session->make_element( "a", href=>"#",
				"onclick" => "if( issues2_ack( this ) ) { \$(this).up(1).setStyle( { 'font-style': 'italic', 'color': '#bbbbbb' } ); }",
				"class" => "ep_issues2_ack"
			);
			$ack->appendChild( $session->make_text( "Acknowledge" ) );
			$desc->appendChild( $session->make_text( " [ " ) );
			$desc->appendChild( $ack );
			$desc->appendChild( $session->make_text( " ]" ) );

			OTHER: foreach my $id2 ( @set )
			{
				next OTHER if $id == $id2;
				push @{$info->{issues}->{$id2}}, {
					type => $plugin->{type},
					id => $plugin->{type} . "_" . $id,
					description => $desc,
				};
			}

		}
	}
}

# normalise the input before comparisons, eg lowercase it and remove excess white space
sub normalise
{
	my( $plugin, $string ) = @_;

	return $string;
}

# info is the data block being used to store cumulative information for processing at the end.
sub process_item_in_list
{
	my( $plugin, $item, $info ) = @_;

	my $value = $item->get_value( $plugin->{field} );
	return if !defined $value;

	$value = $plugin->normalise( $value );
	return if !defined $value;

	push @{ $info->{ $plugin->{fieldmap} }->{ $value } }, $item->get_id;
}

# return an array of issues. Issues should be of the type
# { description=>XHTMLDOM, type=>string }
# if one item can have multiple occurances of the same issue type then add
# an id field too. This only need to be unique within the item.
sub item_issues
{
	my( $plugin, $dataobj ) = @_;
	
	return ();
}

1;

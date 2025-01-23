=head1 NAME

EPrints::Plugin::Screen::EPrint::Issues2Summary

=cut

package EPrints::Plugin::Screen::EPrint::Issues2Summary;

our @ISA = ( 'EPrints::Plugin::Screen::EPrint' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{appears} = undef;

	return $self;
}

sub can_be_viewed
{
	my( $self ) = @_;

	my $user = $self->{session}->current_user;
	return 1 if defined( $user ) && $user->get_value( "usertype" ) =~ /^(local_admin|admin)$/;

	return $self->allow( "eprint/summary" );
}

sub render
{
	my( $self ) = @_;

	my $session = $self->{session};
	my $page = $session->make_element( "div" );

        my $eprintid1 = $self->{processor}->{eprint}->get_value("eprintid");
	my $eprintid2 = $session->param( "eprintid2" );
	return $page unless $eprintid1 =~ /^[0-9]+$/ && $eprintid2 =~ /^[0-9]+$/;

        my $eprint1 = $self->{processor}->{eprint};
	my $eprint2 = new EPrints::DataObj::EPrint( $self->{session}, $eprintid2 );
	return $page unless defined $eprint1 && defined $eprint2;

	my $table = $session->make_element( "table", "style" => "padding-top: 10px; padding-bottom: 10px; margin-top: 10px; border-top: 1px solid darkgray; border-bottom: 1px solid darkgray;" );
	my $tr1 = $session->make_element( "tr" );
	my $th1 = $session->make_element( "th" );
	my $th2 = $session->make_element( "th" );

	$th1->appendChild( $session->make_text( "#" . $eprintid1 . " - ") );
	$th1->appendChild( $eprint1->render_value( "title" ) );
	$th2->appendChild( $session->make_text( "#" . $eprintid2 . " - ") );
	$th2->appendChild( $eprint2->render_value( "title" ) );

	$tr1->appendChild( $session->make_element( "th" ) );
	$tr1->appendChild( $th1 );
	$tr1->appendChild( $session->make_element( "th" ) );
	$tr1->appendChild( $th2 );

	$table->appendChild( $tr1 );

	my $ds = $session->dataset( "eprint" );
	return $page unless defined $ds;

	my @fields = $ds->fields;
	my $issues2_exclusions = $session->get_repository->get_conf( "issues2_exclusions" );
	# iterate over the fiellds comparing the 2 records
	foreach my $field (@fields)
	{
		my $n =  $field->name;
		my $name =  $field->render_name;
		my $t = $field->type;

		my $string1 = EPrints::Utils::tree_to_utf8( $eprint1->render_value( $n ) );
		my $string2 = EPrints::Utils::tree_to_utf8( $eprint2->render_value( $n ) );

		# report a difference unless its a field which will always differ or we dont want to report on
		if( $n !~ /^(eprintid|type|rev_number|dir|datestamp|lastmod|status_changed|fileinfo)$/ && 
		    $n !~ /^(item_issues|edit_lock|documents)/  && 
		    $n !~ /(_datestamp)$/  && 
		    $t ne "compound" && # sub fields show up separately
		    !defined( $issues2_exclusions->{ $n } ) &&
		    $string1 ne $string2 )
		{
			my $tr = $session->make_element( "tr" );
			my $tda = $session->make_element( "td", style => "vertical-align: top; border: 1px solid white;" );
			my $tdb = $session->make_element( "td", style => "vertical-align: top; border: 1px solid darkgray;" );
			my $tdc = $session->make_element( "td", style => "vertical-align: top; border: 1px soiid white;" );
			my $tdd = $session->make_element( "td", style => "vertical-align: top; border: 1px solid white" );

			my $cb = $session->make_element( "input", "type" => "checkbox", "name" => "$n", value => "1", "class" => "ep_issues2_merge" );

			my $name_span = $session->make_element("span", style => "font-size: 80%;");
			$name_span->appendChild( $session->make_text(" ($n)") );
			$tda->appendChild( $name );
			$tda->appendChild( $name_span );

			$tdb->appendChild( $eprint1->render_value( $n ) );
			$tdc->appendChild( $cb  );
			$tdd->appendChild( $eprint2->render_value( $n ) );

			$tr->appendChild( $tda );
			$tr->appendChild( $tdb );
			$tr->appendChild( $tdc );
			$tr->appendChild( $tdd );
 
			$table->appendChild( $tr );
		}
	}

        $page->appendChild( $session->make_javascript( "var eprints_http_root='/';" ) );
        $page->appendChild( $session->make_javascript( undef, src => $session->current_url( path => "static", "javascript/auto.js" ) ) );

	$page->appendChild( $session->make_text( "Compare the differences between the two records, use the check boxes to mark those to be merged from right to left, press Apply to commit the changes and close this window." ) );
	$page->appendChild( $session->make_element( "br" ) );

	{
		my $submit = $session->make_element( "input", "type" => "button", "name" => "merge", value => "Apply changes and close window", "onclick" => "issues2_merge($eprintid1, $eprintid2);", "style" => "float: right;" );
		my $cancel = $session->make_element( "input", "type" => "button", "name" => "cancel", value => "Cancel changes and close window", "onclick" => "window.close()", "style" => "float: right;" );
		my $swap = $session->make_element( "input", "type" => "button", "name" => "swap", value => "Reverse view", "onclick" => "window.location = '/cgi/users/home?screen=EPrint::Issues2Summary&eprintid=$eprintid2&eprintid2=$eprintid1&mainonly=yes'", "style" => "float: left;" );
		$page->appendChild( $swap );
		$page->appendChild( $submit );
		$page->appendChild( $cancel );
	}

	$page->appendChild( $session->make_element( "br" ) );
	$page->appendChild( $table );

	$page->appendChild( $session->make_element( "br" ) );
	$page->appendChild( $session->make_text( "Once changes have been made, they will be reflected in the reports after the next audit has been run." ) );
	$page->appendChild( $session->make_element( "br" ) );
	$page->appendChild( $session->make_element( "br" ) );

	{
		my $submit = $session->make_element( "input", "type" => "button", "name" => "merge", value => "Apply changes and close window", "onclick" => "issues2_merge($eprintid1, $eprintid2);", "style" => "float: right;" );
		my $cancel = $session->make_element( "input", "type" => "button", "name" => "cancel", value => "Cancel changes and close window", "onclick" => "window.close()", "style" => "float: right;" );
		my $swap = $session->make_element( "input", "type" => "button", "name" => "swap", value => "Reverse view", "onclick" => "window.location = '/cgi/users/home?screen=EPrint::Issues2Summary&eprintid=$eprintid2&eprintid2=$eprintid1&mainonly=yes'", "style" => "float: left;" );
		$page->appendChild( $swap );
		$page->appendChild( $submit );
		$page->appendChild( $cancel );
	}

	return $page;
}	

1;

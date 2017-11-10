push @{$c->{fields}->{eprint}},
        {
                name=>"item_issues2",
                type=>"compound",
                multiple=>1,
                fields => [
                        {
                                sub_name => "id",
                                type => "id",
                                text_index => 0,
                        },
                        {
                                sub_name => "type",
                                type => "namedset",
                                set_name => "issues2",
                                input_style => "long",

                                text_index => 0,
                                sql_index => 1,
                        },
                        {
                                sub_name => "description",
                                type => "longtext",
                                text_index => 0,
                                render_single_value => "EPrints::Extras::render_xhtml_field",
                        },
                        {
                                sub_name => "timestamp",
                                type => "time",
                        },
                        {
                                sub_name => "status",
                                type => "set",
                                text_index => 0,
                                options=> [qw/ discovered ignored reported autoresolved resolved /],
                        },
                        {
                                sub_name => "reported_by",
                                type => "itemref",
                                datasetid => "user",
                        },
                        {
                                sub_name => "resolved_by",
                                type => "itemref",
                                datasetid => "user",
                        },
                        {
                                sub_name => "comment",
                                type => "longtext",
                                text_index => 0,
                                render_single_value => "EPrints::Extras::render_xhtml_field",
                        },
                ],
                make_value_orderkey => "EPrints::DataObj::EPrint::order_issues_newest_open_timestamp",
                render_value => "render_issues2",
                volatile => 1,
        },
        {
                name => "item_issues2_count",
                type => "int",
                volatile => 1,
        },
;

$c->{render_issues2} = sub
{
        my( $session, $field, $value ) = @_;

        # Default rendering only shows discovered and reported issues (not resolved or ignored ones)

        my $f = $field->get_property( "fields_cache" );
        my $fmap = {};  
        foreach my $field_conf ( @{$f} )
        {
                my $fieldname = $field_conf->{name};
                my $field = $field->{dataset}->get_field( $fieldname );
                $fmap->{$field_conf->{sub_name}} = $field;
        }

        my $ol = $session->make_element( "ul" );
        foreach my $issue ( @{$value} )
        {
		next if $issue->{status} eq "resolved";
		next if $issue->{status} eq "ignored";

                my $li = $session->make_element( "li", class => "ep_issue_list ep_issue_type ep_issue_type_".$issue->{type}, "ep_issue_list_id" => $issue->{id} );
                my $sd = $session->make_element( "span", class => "ep_issue_list_description" );
                my $st = $session->make_element( "span", class => "ep_issue_list_timestamp" );
                # my $status = $session->make_element( "span", class => "ep_issue_list_status" );

                $sd->appendChild( EPrints::Extras::render_xhtml_field( $session, $fmap->{description}, $issue->{description} ) );
                $st->appendChild( $fmap->{timestamp}->render_single_value( $session, $issue->{timestamp} ) );
                # $status->appendChild( $fmap->{status}->render_single_value( $session, $issue->{status} ) );

                $li->appendChild( $sd );
                $li->appendChild( $session->make_text( " - " ) );
                $li->appendChild( $st );
                # $li->appendChild( $session->make_text( " - " ) );
                # $li->appendChild( $status );
                $ol->appendChild( $li );
        }
        return $ol;
};

$c->{plugins}->{"Screen::Staff::IssueSearch2"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::Issues2"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::Issues2Summary"}->{params}->{disable} = 0;

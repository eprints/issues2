
$c->{issues_search2} =
{
	search_fields => [
		{ meta_fields => [ "item_issues2_type" ] },
#		{ meta_fields => [ "item_issues2_timestamp" ] },
		{ meta_fields => [ "userid.username" ] },
		{ meta_fields => [ "eprint_status" ], default=>'archive' },
#		{ meta_fields => [ "creators_name" ] },
		{ meta_fields => [ "date" ] },
#		{ meta_fields => [ "subjects" ] },
#		{ meta_fields => [ "type" ] },
	],
	preamble_phrase => "search/issues:preamble",
	title_phrase => "search/issues:title",
	citation => "issue2",
	page_size => 100,
	staff => 1,
	order_methods => {
#		"byyear" 	 => "-date/creators_name/title",
#		"byyearoldest"	 => "date/creators_name/title",
		"bydatestamp"	 => "-datestamp",
		"bydatestampoldest" => "datestamp",
		"byfirstseen" => "item_issues2",
		"bynissues" => "-item_issues2_count",
	},
	default_order => "byfirstseen",
        filters => [
                { meta_fields => [ "item_issues2_status" ], value => "discovered reported autoresolved resolved", describe => 0 } # not ignored
        ],
	show_zero_results => 0,
};


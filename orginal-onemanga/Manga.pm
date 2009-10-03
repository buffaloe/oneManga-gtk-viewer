package Manga;
use strict;
use warnings;
use 5.008008;

use HTML::TreeBuilder;

use Exception;
use Database;
use Cache;

our $VERSION = '0.06';

###############################################################################
# Static Final Global Vars
###############################################################################
my $CACHE_EXPIRE_TIME = 60*15; # 15 minutes

my @PRINT_OUT1 = ('_cached_title', '_cached_ranking', '_cached_aka', 
	'_cached_status', '_cached_record_title', '_cached_max_chapter',
	'_cached_last_update');
my @PRINT_OUT2 = ('_cached_author', '_cached_artist', '_cached_summary');

###############################################################################
# constructor
###############################################################################
sub new {
    my ($class, $id, $database, $rootURL, $cache) = @_;
    defined $database or throw MyException::NoDatabaseHandler(
	    error => 'No Database Handler');
    defined $rootURL or throw MyException::NoRootURL(
	    error => 'No Root Url');
   
    # TODO: Define/setup these exceptions better
    defined $id or throw MyException::Manga(
	    error => 'No Manga Id');
    defined $cache or throw MyException::Cache(
	    error => 'No Cache');
   

    my $self = {
	_manga_table_id	    => $id,
	_database	    => $database,
	_rootUrl	    => $rootURL,
	_cache		    => $cache,
	_timestamp	    => undef,
	_dirty_cache	    => undef,	# If its undef = fresh, defined = setten (need to store to sql db)

	# All of these info are the cached data on this manga object
	_cached_title		=> undef,
	_cached_ranking		=> undef,
	_cached_aka		=> undef,
	_cached_status		=> undef,
	_cached_record_title	=> undef,
	_cached_max_chapter	=> undef,
	_cached_last_update	=> undef,
	_cached_categories	=> undef,   # The categories are stored as a list
	_cached_author		=> undef,
	_cached_artist		=> undef,
	_cached_summary		=> undef,
	_cached_chapters	=> undef    # The chapters are stored as a list of list
    };
    bless $self, $class;

    $self->sql_initalizer($id);
    return $self;
}

###############################################################################
# Initalizes this object from the SQLite manga table
###############################################################################
sub sql_initalizer {
    my ($self, $manga_table_id) = @_;

    # Fetch this record from the database
    my ($title, $ranking, $aka, $status, $record_title, $max_chapter, 
	    $last_update, $author, $artist, $summary) = $self->{_database}->
	manga_record_from_id($manga_table_id);

    # Cache these information
    $self->{_cached_title}	= $title;
    $self->{_cached_ranking}	= $ranking;
    $self->{_cached_aka}	= $aka;
    $self->{_cached_status}	= $status;
    $self->{_cached_record_title}   = $record_title;
    $self->{_cached_max_chapter}    = $max_chapter;
    $self->{_cached_last_update}    = $last_update;
    $self->{_cached_author}	    = $author;
    $self->{_cached_artist}	    = $artist;
    $self->{_cached_summary}	    = $summary;


    # Fetch the Categories information
    my @categories = $self->{_cache}->categories_id_to_type(
	    $self->{_database}->categories_type_id_from_id($manga_table_id));
    $self->{_cached_categories}	    = \@categories;


    # Sets the _timestamp so we know when the information cached has expired
    $self->{_timestamp} = time() + $CACHE_EXPIRE_TIME;
}


###############################################################################
# Print this object out to std-out
###############################################################################
sub print {
    my ($self) = @_;
    my $undef = 'undef';
    
    $self->cache_check();

    print "[";
    foreach my $i (@PRINT_OUT1) {
	if (defined $self->{$i}) {
	    print "(".$self->{$i}.") ";
	} else {
	    print "($undef) ";
	}
    }

    if ($self->{_cached_categories}) {
	print "{";
	foreach my $i (0 .. $#{$self->{_cached_categories}}) {
	    if ($i == $#{$self->{_cached_categories}}) {
		print $self->{_cached_categories}[$i];
	    } else {
		print $self->{_cached_categories}[$i].", ";
	    }
	}
	print "} ";
    }

    foreach my $i (0 .. $#PRINT_OUT2) {
	if ($i == $#PRINT_OUT2) {
	    if (defined $self->{$PRINT_OUT2[$i]}) {
		print "(".$self->{$PRINT_OUT2[$i]}.")";
	    } else {
		print "($undef)";
	    }
	} else {
	    if (defined $self->{$PRINT_OUT2[$i]}) {
		print "(".$self->{$PRINT_OUT2[$i]}.") ";
	    } else {
		print "($undef) ";
	    }
	}
    }
    print "]\n";
}




###############################################################################
# Grab additional information on this manga from this manga's own page
###############################################################################
sub grab_additional_info {
    my ($self) = @_;

    $self->cache_check();
    my $title = $self->{_cached_title};
    my $record_title = $self->{_cached_record_title};


    # TODO: redefine it
    defined $record_title or throw MyException::Manga(
	    error => 'No record Title');

    # Fetch the page and extract all of the information out of it
    my $thePage;
    eval { $thePage = $self->{_cache}->fetch_page(
            $self->{_rootUrl}."/$record_title/");
    };
    if (my $e = Exception::Class->caught('Exceptions::Network')) {
        print $e->trace->as_string(), "\n";
    }



    # Now parse the html page into a tree
    my $tree = HTML::TreeBuilder->new();
    $tree->parse($thePage);
    $tree->eof();
    $tree->elementify();

    # Fetch content in the sidebar of the manga page
    my $side_content = $tree->look_down(
	    '_tag', 'div',
	    'class', 'side-content'
	    );
    
    # Grab the url for the cover page image
    my $image_url = $side_content->look_down(
	    '_tag', 'img'
	    )->attr('src');

    # Grab the categories, author, artist information, because of the
    # <br /> there's no nice way to grab it via the html::treeparser atm
    $side_content->as_text() =~ /Categories: (.*)Author: (.*)Artist: (.*)Chapters: /;
    my @categories = split(/, /, $1);
    my $author = $2;
    my $artist = $3;

    # Grab the summary
    my $summary = $side_content->look_down(
	    '_tag', 'div',
	    'class', undef
	    )->as_text();

    # Store all of the new into the cached areana, and mark the cache dirty so that it will
    # update the sql table
    $self->{_dirty_cache} = 'dirty';

    $self->{_cached_author} = $author;
    $self->{_cached_artist} = $artist;
    $self->{_cached_summary} = $summary;
    $self->{_cached_categories} = \@categories;


    # Done fetching all of the general information, now need to get the
    # chapter information
    my @list = $tree->look_down(
	    '_tag', 'tr',
		sub {
		    defined $_[0]->attr('class') and
		    ($_[0]->attr('class') eq 'bg01' or
		     $_[0]->attr('class') eq 'bg02')
		}
	    );

    my @chapters;
    # Parse each of the entry in the @list into a single chapter entry
    foreach (@list) {

	# Get the chapter name and the url for the chapter
	my $tmp = ($_->look_down('_tag', 'td', 
		    'class', 'ch-subject'));

	# Chapter title
	my $chp_title = $tmp->as_text();

	# Chapter url
	$tmp->as_HTML() =~ /<a href="\/[0-9\.\%\w\\-]+\/(.+)\/">/;
	my $chp_url = $1;

	# Get whom it was scanned by	
	my $scans_by = ($_->look_down('_tag', 'td', 
		    'class', 'ch-scans-by'))->as_text();

	# Get the date that the chapter was released
	my $chapter_date = ($_->look_down('_tag', 'td', 
		    'class', 'ch-date'))->as_text();


	print "[$chp_title, $chp_url, $scans_by, $chapter_date]\n";
	push (@chapters, [$chp_title, $chp_url, $scans_by, $chapter_date]);
    }
    
    $self->{_cached_chapters} = \@chapters;


    # Done extracting the needed information, discard the tree
    $tree->delete();


    # Fetch the cover page image
    # Check to see if the cover image already exists in the cache
    if ((defined $record_title) and (not defined 
		$self->{_cache}->cover_image_exists($record_title))) {
	eval { $self->{_cache}->fetch_and_store_cover_image(
		$image_url, $record_title);
	};
	if (my $e = Exception::Class->caught('Exceptions::Network')) {
	    print $e->trace->as_string(), "\n";
	}
    }

    # Update the sql record
    $self->update_my_recordset();
}


###############################################################################
# Check if the _dirty_cache flag has been set, if so, update the sql record
###############################################################################
sub update_my_recordset {
    my ($self) = @_;

    # check if the cached data is dirty, if so, update the sql rows
    if (defined $self->{_dirty_cache}) {
	my $id = $self->{_manga_table_id};
	
	$self->{_database}->manga_record_update($id, $self->{_cached_title}, 
		$self->{_cached_ranking}, $self->{_cached_aka}, 
		$self->{_cached_status}, $self->{_cached_record_title}, 
		$self->{_cached_max_chapter}, $self->{_cached_last_update}, 
		$self->{_cached_author}, $self->{_cached_artist}, 
		$self->{_cached_summary});


	# Update the categories_type and categories tables now
	my @categories = @{$self->{_cached_categories}};
	$self->{_cache}->categories_exist_and_update(@categories);
	my @cat_id = $self->{_cache}->categories_type_to_id(@categories);

	# Check to make sure there's no un-needed categories
	$self->{_database}->manga_categories_insert_and_remove(
		$id, @cat_id);

	# Update the Chapters tables now
	$self->{_database}->manga_chapters_insert_and_remove(
		$id, @{$self->{_cached_chapters}});

	$self->{_dirty_cache} = undef;
    }
}

###############################################################################
# Return/get the cached information
###############################################################################
sub get_manga_info {
    my ($self) = @_;

    $self->cache_check();

    my @tmp = ($self->{_cached_title}, $self->{_cached_ranking},
    $self->{_cached_aka}, $self->{_cached_status},
    $self->{_cached_record_title}, $self->{_cached_max_chapter},
    $self->{_cached_last_update}, join(', ', @{$self->{_cached_categories}}),
    $self->{_cached_author}, $self->{_cached_artist},
    $self->{_cached_summary});

    return @tmp;
}

























sub fetch_chapters_info($ $) {
    my $thePage = cached_fetcher::fetch_page($_[0].$_[1].'/') or die "Couldn't grab the webpage";
    my @returnArray;

# Parse the html page into a tree for snipeting out needed informations
    my $tree = HTML::TreeBuilder->new();
    $tree->parse($thePage);
    $tree->eof();
    $tree->elementify();

# Fetch all of the listing with the class of 'bg01/02' which will contain the chapter
# information
    my @list = $tree->look_down(
            '_tag', 'tr',
                sub {
                    defined $_[0]->attr('class') and
                    ($_[0]->attr('class') eq 'bg01' or
                    $_[0]->attr('class') eq 'bg02')
                }
            );

# Parse each chapter entry
    foreach (@list) {

        my $ch_subject = $_->look_down(
                '_tag', 'td',
                'class', 'ch-subject'
                );

        my $ch_scans_by = $_->look_down(
                '_tag', 'td',
                'class', 'ch-scans-by'
                );

        my $ch_date = $_->look_down(
                '_tag', 'td',
                'class', 'ch-date'
                );

        $ch_subject->as_HTML() =~ /<a href="(.+)">\w+ ([0-9]+)<\/a>/;
        my $chapter_url = $1;
        my $chapter = $2;

#       print "chapter: ".$chapter."\n";
#       print "chapter Url: ".$chapter_url."\n";
#       print "scans_by: ".$ch_scans_by->as_text."\n";
#       print "date: ".$ch_date->as_text."\n";

# Add all of the information to this array then add it to the master array
        my @tmp;

        push(@tmp, $chapter);
        push(@tmp, $chapter_url);
        push(@tmp, $ch_scans_by->as_text());
        push(@tmp, $ch_date->as_text());

# Push it onto the master array
        push(@returnArray, [@tmp]);
    }

    $tree->delete();
    return reverse @returnArray;
}



sub fetch_detailed_chapters_info($ $ $) {
    my $title = $_[1];
    my $chapter = $_[2];
    my $thePage = cached_fetcher::fetch_page($_[0].$title.'/'.$chapter.'/') or die "Couldn't grab the webpage";
    my @returnArray;

# Parse the html page into a tree for snipeting out needed informations
    my $tree = HTML::TreeBuilder->new();
    $tree->parse($thePage);
    $tree->eof();
    $tree->elementify();

    my @links = ($tree->look_down(
                '_tag', 'div',
                'id', 'chapter-cover'
                ))->look_down(
                '_tag', 'a'
                );

    my $page_num;
    foreach(@links) {
        $_->as_HTML() =~ /<a href="\/$title\/$chapter\/(.+)\/">Begin reading/;

        if (defined $1) {
            $page_num = $1;
            last;
        }
    }

# Now we got the page number, we are going to that page to grab the chapters/page stuff
    undef $thePage;
    $thePage = cached_fetcher::fetch_page($_[0].$title.'/'.$chapter.'/'.$page_num.'/') or die "Couldn't grab the webpage";
    $thePage =~ /<script type="text\/javascript" src="\/manga_js\/([0-9]+)\/"><\/script>/;

# Now grab the result from the javascript
    undef $thePage;
    $thePage = cached_fetcher::fetch_page($_[0].'manga_js/'.$1.'/') or die "Couldn't grab the javascript data";

    foreach (split(/\n/, $thePage)) {
        if ($_ =~ /\["(.+)",'(.+)\/(.+)'\]/) {
            my @tmp;

            push(@tmp, $1);
            push(@tmp, $2);
            push(@tmp, $3);

            push(@returnArray, [@tmp]);
        }
    }

    return reverse @returnArray;
}



sub fetch_page_info($ $ $) {

}



sub fetch_page_online($ $ $) {
    my ($name, $chapter, $page) = @_;
    my $returnImage;
    my $searchRegex = $page . '.jpg';
    my $timeout = 2;
    my $counter = 0;

    do {
        if ($counter != 0) {
            $page = '0'.$page;
        }
        my $searchUrl = 'http://www.onemanga.com/' . $name . '/' . $chapter . '/' . $page . '/';
        $counter++;
print "$searchUrl\n";

        # So far there is: 00, 01, 00-cover, 00-cover2, "02-03", also there's chapter 0 too, 01-02, 001a,001b,

        $returnImage = Image::Grab->new();
        $returnImage->regexp($searchRegex);
        $returnImage->search_url($searchUrl);
        eval{$returnImage->grab};
    } while($@ and $counter lt $timeout);

    return $returnImage;
}











###############################################################################
# Initalizes this object with some data from the raw_fetcher
###############################################################################
sub old_raw_fetcher_initalizer {
    my ($self, $manga_table_id, $title, $ranking, $aka, $status, $record_title, $max_chapter, $last_update) = @_;

    defined ($self->{_dbh}) or die "The database handler is not defined: $!";
    $self->{_manga_table_id} = $manga_table_id;
  
    # Cache these information
    $self->{_cached_title}	= $title;
    $self->{_cached_ranking}	= $ranking;
    $self->{_cached_aka}	= $aka;
    $self->{_cached_status}	= $status;
    $self->{_cached_record_title}   = $record_title;
    $self->{_cached_max_chapter}    = $max_chapter;
    $self->{_cached_last_update}   = $last_update;
    # Since its from the raw fetcher, the catalogories, author, artist, and so forth are undefined

    # Sets the _timestamp so we know when the information cached has expired
    $self->{_timestamp} = time() + $CACHE_EXPIRE_TIME;
}



###############################################################################
# Update the cached copy if the timestamp has expired otherwise do nothing
###############################################################################
sub cache_check {
    my ($self) = @_;
    
    if (time() > $self->{_timestamp}) {
	print "[ Cached copy expired! ]\n";
    }
}








sub test {
   
my @categories;
my $self;
my $id;
# do a select to get the type id out of the type table, if it does not exist
# then add it to tye type table
#
# second step is using the type id to add it to the categories table along with
# the manga id, but will need to check to see if it exists first or something
# like that, then clean out the other categories that should not be there

	my @type_ids;
	foreach my $type (@categories) {
	    my $ref = $self->{_dbh}->selectrow_arrayref("SELECT id FROM categories_type
		    WHERE categories = \"$type\"");

	    if (not defined $ref) {
		# Its not defined which mean it does not exist in the
		# Types table, so insert it in.
		$self->{_dbh}->do("INSERT into categories_type (categories)
			VALUES (\"$type\")");
		
		# get the ID
		$ref = $self->{_dbh}->selectrow_arrayref("SELECT id FROM categories_type
		    WHERE categories = \"$type\"");
	    }

	    # We got an type id, now check the categories table
	    my ($type_id) = @$ref;

	    my $cat = $self->{_dbh}->selectrow_arrayref("SELECT id from categories
		    WHERE manga_id = $id and categories_type_id = $type_id");

	    if (not defined $cat) {
		# Its not defined, insert it into the table
		$self->{_dbh}->do("INSERT into categories (manga_id, categories_type_id)
			VALUES ($id, $type_id)");
	    }

	    push(@type_ids, $type_id);
	}
}

1;
__END__

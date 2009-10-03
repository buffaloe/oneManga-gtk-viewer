package Root;
use strict;
use warnings;
use 5.008008;

use HTML::TreeBuilder;

use Exception;
use Database;
use Manga;
use Cache;

our $VERSION = '0.09';

###############################################################################
# Static Final Global Vars
###############################################################################
my $UPDATED_IMG_URL = quotemeta('http://static.onemanga.com/manga/updated.gif');
my $NEW_IMG_URL = quotemeta('http://static.onemanga.com/manga/new.gif');
my $COMING = 'Coming Soon!';
my $SUSPENDED = 'Suspended';
my $COMPLETED = 'Completed';
my $NORMAL = 'Normal';
my $NEW = 'New';
my $UPDATE = 'Update';


###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class, $rootDir, $rootUrl, $database) = @_;
    defined $rootDir or throw MyException::NoRootDirectory(
	    error => 'No Root Directory');
    defined $rootUrl or throw MyException::NoRootURL(
	    error => 'No Root Url');
    defined $database or throw MyException::NoDatabaseHandler(
	    error => 'No Database handler');

    my $self = {
	_database	=> $database,
	_rootUrl	=> $rootUrl,
	_cache		=> Cache->new($database, $rootDir)
    };
    bless $self, $class;
    return $self;
}


###############################################################################
# This function for now will just fetch a fresh list then probably wipe the
# database clean until I'm able to come up with a nicer solution for updating
# the main tables
###############################################################################
sub overwrite_fetch_manga_list {
    my ($self) = @_;

    # Fetch the directory
    my $thePage;
    eval { $thePage = $self->{_cache}->fetch_page(
	    $self->{_rootUrl}.'directory/');
    };
    if (my $e = Exception::Class->caught('Exceptions::Network')) {
	print $e->trace->as_string(), "\n";
    }


    # For now just delete all entry in all of the tables
    $self->{_database}->clear_all_tables();



    # Parse the html page fetched into a tree
    my $tree = HTML::TreeBuilder->new();
    $tree->parse($thePage);
    $tree->eof();
    $tree->elementify();

    # Fetch a list of all html elements that has an attribute named 'class'
    # with the value 'bg01/02' all of the manga in the directory listing 
    # will be in one of those two class
    my @list = $tree->look_down(
	    '_tag', 'tr',
		sub {
		    defined $_[0]->attr('class') and
		    ($_[0]->attr('class') eq 'bg01' or
		    $_[0]->attr('class') eq 'bg02')
		}
	    );



    # Begin to insert fresh data into the manga table
    my $statement = $self->{_database}->begin_manga_insert();



    # Parse each of the entry in the @list into an single manga entry
    foreach (@list) {

	# Temponary Processing Vars
	my $ch_chapter_as_text;

	# Final values to insert into the database
	my ($title, $ranking, $aka, $status, $record_title, $max_chapter, 
		$last_update);


	my $ch_chapter = $_->look_down(
		'_tag', 'td',
		'class', 'ch-chapter'
		);

	# This block extracts the record_title, Max Completed Chapters, 
	# and the Last time it was updated
	if (defined $ch_chapter) {
	    $ch_chapter_as_text = $ch_chapter->as_text();
	    my $record_title_and_chapter = $ch_chapter->look_down('_tag', 'a');
	    $last_update = ($_->look_down('_tag', 'td'))[2];

	    if (defined $last_update) {
		my $last_update_as_text = $last_update->as_text();

		if (($ch_chapter_as_text eq $COMING) and 
			($last_update_as_text eq "")) {
		    $last_update = $COMING;
		} else {
		    $last_update = $last_update_as_text;
		}
	    } else {
		$last_update = undef;
	    }


	    # This block cleans up and standardizes the formatting of the 
	    # record_title, Max Completed Chapters, and the Last time it 
	    # was updated
	    if (defined $record_title_and_chapter) {
		$record_title_and_chapter->as_HTML() =~ /<a href="\/([0-9\.\%\w\\-]+)\/([0-9]+)\/">Chapter [0-9]+<\/a>/;
		$record_title = $1;
		$max_chapter = $2;
	    } elsif ($last_update eq $SUSPENDED) {
		$ch_chapter->as_text() =~ /Chapter ([0-9]+)/;
		$record_title = undef;
		$max_chapter = $1;
	    } elsif ($ch_chapter_as_text eq $COMING) {
		$record_title = undef;
		$max_chapter = undef;
	    } else {
		$record_title = undef;
		$max_chapter = undef;
	    }
	}

	
	my $ch_subject = $_->look_down(
		'_tag', 'td',
		'class', 'ch-subject'
		);

	# This block extracts the Title, Ranking, AKA, and Status
	if (defined $ch_subject) {
	    $title = $ch_subject->look_down('_tag', 'a');
	    if (defined $title) {
		$title = $title->as_text();
	    }

	    $ranking = $ch_subject->look_down('_tag', 'span');
	    if (defined $ranking) {
		$ranking->as_text() =~ /\(([0-9]+)\)/;
		$ranking = $1;
	    } else {
		$ranking = undef;
	    }

	    $aka = $ch_subject->look_down(
		    '_tag', 'span',
		    'class', 'aka'
		    );
	    if (defined $aka) {
		$aka->as_text() =~ /aka: (.*$)/;
		$aka = $1;
	    } else {
		$aka = undef;
	    }


	    # This block standardizes the formatting for the Status
	    my $img = $ch_subject->look_down('_tag', 'img');
	    if (defined $img) {
		if (($img->as_HTML) =~ m!$UPDATED_IMG_URL!) {
		    $status = $UPDATE;
		} elsif (($img->as_HTML) =~ m!$NEW_IMG_URL!) {
		    $status = $NEW;
		}
	    } elsif ($ch_chapter_as_text eq $COMING) {
		$status = $COMING;
	    } elsif ($last_update eq $SUSPENDED) {
		$status = $SUSPENDED;
	    } elsif ($last_update eq $COMPLETED) {
		$status = $COMPLETED;
	    } else {
		$status = $NORMAL;
	    }
	}

	# This block creates a list then push it onto a larger list to be
	# passed onto to the SQLite storage manager
	if (defined $title) {
	    $self->{_database}->execute_statement($statement, $title, 
		    $ranking, $aka, $status, $record_title, $max_chapter, 
		    $last_update);
	}
    }
    $self->{_database}->commit_transaction($statement);
    
    # We're done with extracting the needed information, discard the tree
    $tree->delete();
}


###############################################################################
# Retrieve the list of all entries, this is in manga format aka one object
# for each record, this format uses id's to give to the manga object and let
# each object fetch its own data out of the sqlite db
#
# Then store it into the model
###############################################################################
sub store_manga_into_model {
    my ($self, $model) = @_;

    # Flush the model
    $model->clear();

    # Update the categories cache
    $self->{_cache}->categories_update();

    # Dump all of the needed data
    my @all = $self->{_database}->list_manga_id();
    foreach (@all) {
	my $manga_obj = Manga->new($_, 
		$self->{_database},
		$self->{_rootUrl},
		$self->{_cache});

	$model->add_entry($manga_obj);
    }
}


###############################################################################
# Retrieve the list of all entries, this is in manga format aka one object
# for each record, this format uses id's to give to the manga object and let
# each object fetch its own data out of the sqlite db
#
# This only retrieves the list of entries with that specific category id
#
# Then store it into the model
###############################################################################
sub store_manga_into_model_categories_id {
    my ($self, $model, $id) = @_;
    
    # Flush the model
    $model->clear();

    # Update the categories cache
    $self->{_cache}->categories_update();

    # Dump all of the needed data
    my @all = $self->{_database}->list_manga_id_categories_id($id);
    foreach (@all) {
	my $manga_obj = Manga->new($_, 
		$self->{_database},
		$self->{_rootUrl},
		$self->{_cache});
	
	$model->add_entry($manga_obj);
    }
}


###############################################################################
# Retrieve the list of all entries, this is in manga format aka one object
# for each record, this format uses id's to give to the manga object and let
# each object fetch its own data out of the sqlite db
###############################################################################
sub old_retrieve_list_manga_format_using_ids {
    my ($self) = @_;
    my @returnArray;
   
    # Update the categories cache
    $self->{_cache}->categories_update();

    # Dump all of the needed data
    my @all = $self->{_database}->list_manga_id();
    foreach (@all) {
	my $manga_obj = Manga->new($_, 
		$self->{_database},
		$self->{_rootUrl},
		$self->{_cache});
	push(@returnArray, $manga_obj);
    }
    
    return @returnArray;
}


###############################################################################
# Private testing function to print the list
###############################################################################
sub print_list_manga_format {
    my @list = @{$_[1]};

    foreach (@list) {
	$_->print();
    }
}


###############################################################################
# Iterate through all of the mangas in the main table and tell it to 
# grab additional information on theirselves
###############################################################################
sub fetch_all_manga_extra_info {
    my ($self) = @_;
    
    foreach ($self->retrieve_list_manga_format_using_ids()) {
	$_->print();
	$_->grab_additional_info();
    }
}















1;
__END__

package Model::Viewer;
use warnings;
use strict;

use Gtk2 '-init';

use Util::Exception;

our $VERSION = '0.01';

use constant TRUE   => 1;
use constant FALSE  => 0;

use constant COLUMN_CHAPTER_ID	    => 0;
use constant COLUMN_CHAPTER_NUMBER  => 1;
use constant COLUMN_CHAPTER_NAME    => 2;
use constant COLUMN_CHAPTER_PAGE_ID => 3;
use constant NUM_COLUMNS_CHAPTER    => 4;


use constant COLUMN_PAGE_ID	    => 0;
use constant COLUMN_PAGE_NUMBER	    => 1;
use constant COLUMN_PAGE_NAME	    => 2;
use constant NUM_COLUMNS_PAGE	    => 4;


###############################################################################
# Static Final Global Vars
###############################################################################


###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class) = @_;

    my $self = {
	_chapter_model	=> undef
    };
    bless $self, $class;

    $self->_init();
    return $self;
}


###############################################################################
# Initalizer
###############################################################################
sub _init {
    my ($self) = @_;

    # <Chapter Table ID>, <Chapter Number>, <Chapter Name>, <Beginning Chapter Page id>
    my $return = Gtk2::ListStore->new('Glib::Int', 'Glib::Int', 'Glib::String', 'Glib::Int');

    # Sample Data
    my @data = (
	{ id => 10, number => 56, name => '56 - Viewer\'s Polls', page => 1 },
	{ id => 11, number => 57, name => '57 - Tsuruta Festival', page => 2 },
	{ id => 12, number => 58, name => '58 - Guest Appearance', page => 3 },
	{ id => 13, number => 59, name => '59 - Hoooo!', page => 4 },
	{ id => 14, number => 60, name => '60 - Terror', page => 5 },
	{ id => 15, number => 61, name => '61 - Akumetsu\'s True Motive', page => 6 },
	{ id => 16, number => 62, name => '62 - If I Don\'t Do It', page => 7 },
	{ id => 17, number => 63, name => '63 - Accomplice', page => 8 },
    );
    
    # Filling the Model with data
    foreach (@data) {
	my $iter = $return->append;
	$return->set($iter,
		COLUMN_CHAPTER_ID,	$_->{id},
		COLUMN_CHAPTER_NUMBER,  $_->{number},
		COLUMN_CHAPTER_NAME,	$_->{name},
		COLUMN_CHAPTER_PAGE_ID,	$_->{page}
	);
    }

    $self->{_chapter_model} = $return;



}

###############################################################################
# Return the Name of the Manga
###############################################################################
sub get_name {
    my ($self) = @_;

    return "Stub Manga";
}


###############################################################################
# Return a list of all of the chapters
###############################################################################
sub get_chapters {
    my ($self) = @_;

    return $self->{_chapter_model};
}


###############################################################################
# Return the chapters name column
###############################################################################
sub get_chapters_name_column {
    my ($self) = @_;
    return COLUMN_CHAPTER_NAME;
}


###############################################################################
# Return a list of the pages for an chapter
###############################################################################
sub get_pages {
    my ($self, $chapter_iter) = @_;

    print "Chapter-List: ".$self->{_chapter_model}->get($chapter_iter)."\n";

    # <Page Table ID>, <Page Number>, <Page Name>
    my $return = Gtk2::ListStore->new('Glib::Int', 'Glib::Int', 'Glib::String');

    # Sample Data
    my @data = (
	{ id => 4, number => 1, name => '01' },
	{ id => 4, number => 2, name => '02' },
	{ id => 4, number => 3, name => '03' },
	{ id => 6, number => 4, name => '04' },
	{ id => 6, number => 5, name => '05-06' },
	{ id => 2, number => 6, name => '07' },
	{ id => 2, number => 7, name => '08' },
	{ id => 2, number => 8, name => '09' }
    );
    
    # Filling the Model with data
    foreach (@data) {
	my $iter = $return->append;
	$return->set($iter,
		COLUMN_PAGE_ID,	    $_->{id},
		COLUMN_PAGE_NUMBER, $_->{number},
		COLUMN_PAGE_NAME,   $_->{name}
	);
    }

    return $return;
}


###############################################################################
# Return the page name column
###############################################################################
sub get_pages_name_column {
    my ($self) = @_;
    return COLUMN_PAGE_NAME;
}


1;
__END__

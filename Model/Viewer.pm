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
use constant COLUMN_CHAPTER_PAGE    => 3;
use constant NUM_COLUMNS_CHAPTER    => 4;


###############################################################################
# Static Final Global Vars
###############################################################################


###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class) = @_;

    my $self = {
	_model	=> undef
    };
    bless $self, $class;
    return $self;
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

    # <Chapter Table ID>, <Chapter Number>, <Chapter Name>, <Beginning Chapter Page name/url>
    my $return = Gtk2::ListStore->new('Glib::Int', 'Glib::Int', 'Glib::String', 'Glib::String');


    # Sample Data
    my @data = (
	{ id => 10, number => 56, name => '56 - Viewer\'s Polls', page => '01' },
	{ id => 11, number => 57, name => '57 - Tsuruta Festival', page => '01' },
	{ id => 12, number => 58, name => '58 - Guest Appearance', page => '01' },
	{ id => 13, number => 59, name => '59 - Hoooo!', page => '01' },
	{ id => 14, number => 60, name => '60 - Terror', page => '01' },
	{ id => 15, number => 61, name => '61 - Akumetsu\'s True Motive', page => '01' },
	{ id => 16, number => 62, name => '62 - If I Don\'t Do It', page => '00-cover' },
	{ id => 17, number => 63, name => '63 - Accomplice', page => '01' },
    );

    
    # Filling the Model with data
    foreach (@data) {
	my $iter = $return->append;
	$return->set($iter,
		COLUMN_CHAPTER_ID,	$_->{id},
		COLUMN_CHAPTER_NUMBER,  $_->{number},
		COLUMN_CHAPTER_NAME,	$_->{name},
		COLUMN_CHAPTER_PAGE,	$_->{page}
	);
    }

    return $return;
}


###############################################################################
# Return the chapters name column
###############################################################################
sub get_chapters_name_column {
    my ($self) = @_;
    return COLUMN_CHAPTER_NAME;
}


1;
__END__

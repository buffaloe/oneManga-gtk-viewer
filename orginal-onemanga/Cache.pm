package Cache;
use strict;
use warnings;
use 5.008008;

use Digest::MD5 qw(md5_hex);
use FileHandle;
use LWP 5.64;

#use BerkeleyDB;
use Exception;
use Database;

our $VERSION = '0.05';

###############################################################################
# Static Final Global Vars
###############################################################################
my $DELAY = 1;	     # new request once every seconds
my $CACHE = 60 * 15; # Fetch data from cache for 15 minutes
my $CACHE_DIR = 'cache';
my $COVER_IMAGE = 'cover_page.jpg';

###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class, $database, $root) = @_;
    defined $database or throw MyException::NoDatabaseHandler(
	    error => 'No Database Handler');
    defined $root or throw MyException::NoRootDirectory(
	    error => 'No Root Directory');

    # Check for the existance of the cache directory, if it does not exist
    # create it
    if (not -d "$root/$CACHE_DIR") {
        mkdir("$root/$CACHE_DIR", 0777) or throw MyException::Filesystem(
		error => "Can't create the cache directory");
    }



# Berekley DB stuff
#    my %tmp;
#    tie %tmp, 'BerkeleyDB::Hash', 
#	-Filename => 'test/BDB.db', 
#	-Flags => DB_CREATE
#	or die "can't make db";

    my $self = {
	_database   => $database,
	_browser    => LWP::UserAgent->new(),

	_page_cache => {},
#	_page_cache => \%tmp,
	_disk_cache => "$root/$CACHE_DIR",

	# Cached Categories data for speeding up sql-queries
	_cached_type_to_id  => undef,
	_cached_id_to_type  => undef
    };
    bless $self, $class;
    return $self;
}


###############################################################################
# Fetches pages, it will check the cache first to see if it is already stored
# there or not
###############################################################################
sub fetch_page {
    my ($self, $url) = @_;

    # Check to see if its already in cache
    my $return = $self->_cache_check($url); 
  
    if (not defined $return) {
	# TODO: Look into this sleep/delay business to see if there isn't a
	# better way of doing it
	sleep($DELAY);
	my $response = $self->{_browser}->get($url);

	$self->_throw_exceptions($response, $url, 'text/html');

	$return = $response->content;
	$self->_cache_add($url, $return);
    }
    return $return;
}


###############################################################################
# Fetches and stores the manga cover page image into the on disk cache
###############################################################################
sub fetch_and_store_cover_image {
    my ($self, $url, $manga_record_title) = @_;
    my $dir = $self->{_disk_cache}."/$manga_record_title";

    # Check to see if there exists a manga record title directory in the
    # on disk cache, if not create it
    if (not -d $dir) {
        mkdir( $dir, 0777) or 
	    throw MyException::Filesystem(
		error => "Can't create the Manga Record Title directory");
    }


    # TODO: Look into this sleep/delay business to see if there isn't a
    # better way of doing it
    sleep($DELAY);
    my $response = $self->{_browser}->get($url,
	    ':content_file' => "$dir/$COVER_IMAGE");

    if (((not $response->is_success()) or (not $response->content_type()
		eq 'image/jpeg')) and (-e -r -w "$dir/$COVER_IMAGE")) {

	unlink("$dir/$COVER_IMAGE");
    }
    $self->_throw_exceptions($response, $url, 'image/jpeg');
}


###############################################################################
# Check the in-memory cache to see if the data exists, will return undef if
# it does not exist
###############################################################################
sub _cache_check {
    my ($self, $url) = @_;
    my $url_md5 = md5_hex($url);
    my $return; 
    
    # Timestamp, Data
    if (defined $self->{_page_cache}->{$url_md5} 
	    and (time() < $self->{_page_cache}->{$url_md5}[0])) {
	$return = $self->{_page_cache}->{$url_md5}[1];
    }
    return $return;

#    return $self->{_page_cache}->{$url_md5};
}


###############################################################################
# Adds the data to the cache, and time-stamps it so it can expire
###############################################################################
sub _cache_add {
    my ($self, $url, $data) = @_;
    my $url_md5 = md5_hex($url);

    $self->{_page_cache}->{$url_md5} = [time() + $CACHE, $data];

#    $self->{_page_cache}->{$url_md5} = $data;
}


###############################################################################
# Populate the type_to_id and id_to_type hash with the available categories
# types so it can be used to speed up sql-queries
###############################################################################
sub categories_update {
    my ($self) = @_;

    my @result = $self->{_database}->list_categories_type_id();

    $self->{_cached_categories_id_to_type} = {map { $_->[0] => $_->[1]} @result};
    $self->{_cached_categories_type_to_id} = {map { $_->[1] => $_->[0]} @result};
}


###############################################################################
# Fetch a type from the id, it operates on scalars or arrays
###############################################################################
sub categories_id_to_type {
    my $self = shift;
    my @id = @_;

    my @return;
    foreach (@id) {
	push(@return, $self->{_cached_categories_id_to_type}->{$_});
    }

    return @return;
}


###############################################################################
# Fetch a id from the type, it operates on scalars or arrays
###############################################################################
sub categories_type_to_id {
    my $self = shift;
    my @type = @_;

    my @return;
    foreach (@type) {
	push(@return, $self->{_cached_categories_type_to_id}->{$_});
    }

    return @return;
}

###############################################################################
# This function is given a list of categories, and it checks to see
# if they are defined, if not it will add it to the categories_type
# table and update the cache
###############################################################################
sub categories_exist_and_update {
    my $self = shift;
    my @type = @_;
    my @type_id = $self->categories_type_to_id(@type);

    my $statement = $self->{_database}->begin_categories_type_insert();
    foreach my $i (0 .. $#type) {
	if (not defined $type_id[$i]) {
	    $self->{_database}->execute_statement($statement, $type[$i]);
	}
    }
    $self->{_database}->commit_transaction($statement);

    $self->categories_update();
}


###############################################################################
# Check to see if a cover page image already exists on the on disk cache
###############################################################################
sub cover_image_exists {
    my ($self, $manga_record_title) = @_;
    my $return;

    if (-e -s -r -w $self->{_disk_cache}."/$manga_record_title/$COVER_IMAGE") {
	$return = 1;
    }

    return $return;
}


###############################################################################
# Throw out exceptions if something weird is up
###############################################################################
sub _throw_exceptions {
    my ($self, $response, $url, $expected_type) = @_;
    throw MyException::FetchFailure(
	    error => "Can not fetch the resource -- ".$response->status_line()."\n",
	    url	=> $url
	    ) unless $response->is_success();
    
    throw MyException::WrongData(
	    error	=> "Wrong data, Expected $expected_type not -- ".$response->content_type()."\n",
	    url	=> $url
	    ) unless $response->content_type() eq $expected_type;
}



#my @USER_AGENTS = ('Mozilla/5.0 (Windows; U; Windows NT 5.1; en) AppleWebKit/526.9 (KHTML, like Gecko) Version/4.0dp1 Safari/526.8',
#	'Opera/9.52 (X11; Linux x86_64; U; en)',
#	'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0)',
#	'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.2) Gecko/2008092313 Ubuntu/8.04 (hardy) Firefox/3.1',
#	'Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US) AppleWebKit/525.19 (KHTML, like Gecko) Chrome/0.2.153.0 Safari/525.19');
1;
__END__

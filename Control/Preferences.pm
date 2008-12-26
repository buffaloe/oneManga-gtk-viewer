package Control::Preferences;
use warnings;
use strict;

use Util::Exception;
use Util::Config;
use View::Preferences;

our $VERSION = '0.01';

use constant TRUE   => 1;
use constant FALSE  => 0;


###############################################################################
# Static Final Global Vars
###############################################################################
my $CONFIG = Util::Config->new();
my $this;

###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class) = @_;
    unless (defined $this) {
	my $self = {
	    _viewer	    => View::Preferences->new()
	};
	$this = bless $self, $class;

	# Initalizes the Preferences Controller
	$this->_initalize();
    }

    return $this;
}


###############################################################################
# The Private Initalizer
###############################################################################
sub _initalize {
    my ($self) = @_;

}




1;
__END__

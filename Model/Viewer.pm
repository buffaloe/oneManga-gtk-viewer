package Model::Viewer;
use warnings;
use strict;

use Gtk2 '-init';

use Util::Exception;

our $VERSION = '0.01';

use constant TRUE   => 1;
use constant FALSE  => 0;


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

    $self->_initalize();
    return $self;
}


###############################################################################
# Initalize this window with all of the GTK settings
###############################################################################
sub _initalize {
    my ($self) = @_;


}


1;
__END__

package Control::Viewer;
use warnings;
use strict;

use Gtk2 '-init';

use Util::Exception;
use View::Viewer;

our $VERSION = '0.03';

use constant TRUE   => 1;
use constant FALSE  => 0;


###############################################################################
# Static Final Global Vars
###############################################################################

###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class, $width, $height) = @_;
    throw Util::MyException::Gtk_Viewer(
	    error => 'Width or Height of the window is undefined!')
	unless (defined $width and defined $height);

    my $self = {
	_gtk_window	=> undef
    };
    bless $self, $class;

    my $test = View::Viewer->new(100, 200);
    $test->display_window();

    return $self;
}


1;
__END__

package Control::Viewer;
use warnings;
use strict;

use Util::Exception;
use View::Viewer;

our $VERSION = '0.01';

use constant TRUE   => 1;
use constant FALSE  => 0;


###############################################################################
# Static Final Global Vars
###############################################################################
my $WIDTH = 300;
my $HEIGHT = 600;
my $TITLE = 'Viewer';

###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class) = @_;

    my $self = {
	_viewer	    => undef
    };
    bless $self, $class;

    # Initalizes the View Controller
    $self->_initalize();

    return $self;
}


###############################################################################
# The Private Initalizer
###############################################################################
sub _initalize {
    my ($self) = @_;

    # The Viewer Window Title
    # TODO: Pull this from the model and create a 'Manga name - Viewer'
    my $window_title = $TITLE;


    # Create all of the Callback hooks needed
    # TODO: Externalize them to functions on a need-to-basis
    my $close_callback = sub {
	my $window;
	if (UNIVERSAL::isa($_[0], 'Gtk2::Action')) {
	    $window = $_[1];
	} else {
	    $window = $_[0];
	}
	
	$window->destroy();
	TRUE
    };

    my $quit_callback = sub {
	Gtk2->main_quit();
	TRUE
    };


    # Initalizes the View::Viewer View now
    my $view = View::Viewer->new($WIDTH, $HEIGHT,
	    $window_title, $close_callback, $quit_callback);


    # Testing
    $view->display_window();

}


1;
__END__

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
    my ($class, $model) = @_;

    my $self = {
	_viewer	    => undef,
	_model	    => $model
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
    my $window_title = $self->{_model}->get_name()." - $TITLE";


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
    my $view = View::Viewer->new($WIDTH, $HEIGHT);
    $view->set_close_callback($close_callback);
    $view->set_quit_callback($quit_callback);


    # Initalize the needed values for the chapter_combo_box
    my $model = $self->{_model}->get_chapters();
    my $chapter_column = $self->{_model}->get_chapters_name_column();
    my $tmp_first_iter = $model->get_iter_first();
    my $chapter_callback = sub {
	my ($combo_box) = @_;

	TRUE
    };

    $view->chapter_combo_box($model, $chapter_column, $tmp_first_iter,
	    $chapter_callback);


    # Initalize the needed values for the page_combo_box
    my $model2 = $self->{_model}->get_pages($tmp_first_iter);
    my $page_column = $self->{_model}->get_pages_name_column();
    my $tmp_first_iter2 = $model2->get_iter_first();
    my $page_callback = sub {
	my ($combo_box) = @_;

	TRUE
    };
    
    $view->page_combo_box($model2, $page_column, $tmp_first_iter2,
	    $page_callback);


    # Testing
    $view->display_window();

}


1;
__END__

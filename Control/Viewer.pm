package Control::Viewer;
use warnings;
use strict;

use Util::Exception;
use Util::Config;
use View::Viewer;

our $VERSION = '0.04';

use constant TRUE   => 1;
use constant FALSE  => 0;

use constant ZOOM   => 1.25;
use constant BLOCK  => 'Viewer';
use constant SCALE_TO_HEIGHT => 'scale_to_height';
use constant SCALE_TYPE	=> 'scale_type';


###############################################################################
# Static Final Global Vars
###############################################################################
my $CONFIG = Util::Config->new();

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
	_model	    => $model,
	_zoom	    => 0
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
    $view->set_close_quit_callback($close_callback, $quit_callback);


    # Initalize the callback for the page combo box
    my $page_callback = sub {
	my ($combo_box) = @_;
	my $iter = $combo_box->get_active_iter();

	$view->set_image_pixbuf(
		$self->_pixbuf_scaler($self->{_model}->load_page_pixbuf($iter),
		    $self->{_zoom}));
	TRUE
    };

    # Initalize the needed values for the chapter_combo_box
    my $model = $self->{_model}->get_chapters();
    my $chapter_column = $self->{_model}->get_chapters_name_column();
    my $tmp_first_iter = $model->get_iter_first();
    my $chapter_callback = sub {
	my ($combo_box) = @_;
	my $iter = $combo_box->get_active_iter();

	my $page_model = $self->{_model}->get_pages($iter);
	my $page_column = $self->{_model}->get_pages_name_column();

	$view->page_combo_box($page_model, $page_column,
		$page_model->get_iter_first());
	TRUE
    };
    
    $view->set_chapter_page_combo_box_callback($chapter_callback,
	    $page_callback);

    $view->chapter_combo_box($model, $chapter_column, $tmp_first_iter);

  
    # Zoom stuff
    my $zoom_in = sub {
	my $pixbuf = $self->{_model}->cached_page_pixbuf();

	$view->set_image_pixbuf(
		$self->_pixbuf_scaler($pixbuf, ++$self->{_zoom}));
    };

    my $zoom_out = sub {
	my $pixbuf = $self->{_model}->cached_page_pixbuf();

	$view->set_image_pixbuf(
		$self->_pixbuf_scaler($pixbuf, --$self->{_zoom}));
    };

    my $normal = sub {
	my $pixbuf = $self->{_model}->cached_page_pixbuf();
	
	$self->{_zoom} = 0;
	$view->set_image_pixbuf($pixbuf);
    };

    my $bestfit = sub {
	$self->{_zoom} = 0;
	
	my $pixbuf = $self->{_model}->cached_page_pixbuf();
	
	$view->set_image_pixbuf(
		$self->_pixbuf_bestfit_scaler($pixbuf, (map { $_ - 20 } 
		    $view->get_image_size())));
    };

    $view->set_zoom_callback($zoom_in, $zoom_out, $normal, $bestfit);


    # Back/forward Callback
    my $back = sub {
	print "hi\n";
    };

    my $forward = sub {
	print "bye\n";
    };

    $view->set_back_forward_callback($back, $forward);




    # TODO: Testing
    $view->display_window();

}


###############################################################################
# The Pixbuf Scaler
###############################################################################
sub _pixbuf_scaler {
    my ($self, $pixbuf, $zoom) = @_;

    my $width = $pixbuf->get_width();
    my $height = $pixbuf->get_height();

    my ($scale_width, $scale_height) = ($width, $height);
    if ($zoom > 0) {
	$scale_width = int($width * ($zoom * ZOOM));
	$scale_height = int($height * ($zoom * ZOOM));
    } elsif($zoom < 0) {
	$scale_width = int($width / ((-$zoom) * ZOOM));
	$scale_height = int($height / ((-$zoom) * ZOOM));
    }
    
    return $pixbuf->scale_simple($scale_width, $scale_height,
	    $CONFIG->get_param(BLOCK, SCALE_TYPE));
}


###############################################################################
# The Pixbuf Best Fit Scaler
###############################################################################
sub _pixbuf_bestfit_scaler {
    my ($self, $pixbuf, $width_widget, $height_widget) = @_;

	my $width = $pixbuf->get_width();
	my $height = $pixbuf->get_height();

	# Aspect ratio
	my $ratio_image = $width / $height;
	my $ratio_widget = $width_widget / $height_widget;

	if ($ratio_image > $ratio_widget) {
	    if ($CONFIG->get_param(BLOCK, SCALE_TO_HEIGHT)) {
		$height_widget = int($width_widget / $ratio_image);
	    } else {
		$width_widget = int($height_widget * $ratio_image);
	    }
	} elsif ($ratio_image < $ratio_widget) {
	    if ($CONFIG->get_param(BLOCK, SCALE_TO_HEIGHT)) {
		$width_widget = int($height_widget * $ratio_image);
	    } else {
		$height_widget = int($width_widget / $ratio_image);
	    }
	}
	
	return $pixbuf->scale_simple($width_widget, $height_widget,
		$CONFIG->get_param(BLOCK, SCALE_TYPE));
}


1;
__END__
